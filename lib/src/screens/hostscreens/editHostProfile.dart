import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/alertBox.dart';

class EditProfilePage extends StatefulWidget {
  final String currentName;
  final String currentBio;
  final String? currentImageUrl;

  const EditProfilePage({
    Key? key,
    required this.currentName,
    required this.currentBio,
    this.currentImageUrl,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Form key to validate inputs
  final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  File? _imageFile;
  bool _isLoading = false;

  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    // Pre-fill controllers with current data
    _nameController = TextEditingController(text: widget.currentName);
    _bioController = TextEditingController(text: widget.currentBio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
 
  /// Picks image from camera or gallery
  ///  
  /// TODO: user the select image
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    // Example: pick from gallery. If you need from camera, use ImageSource.camera
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  /// Uploads the selected image to Firebase Storage and returns its download URL.
  Future<String?> _uploadImage(File image) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
      final ref = FirebaseStorage.instance.ref().child('profilePics/$fileName');

      // Upload the file
      await ref.putFile(image);

      // Get the download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      showErrorMessage(context, title: 'Image upload failed.');
      return null;
    }
  }

  /// Saves profile changes to Firestore
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is invalid, do not proceed
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Upload new image if available
      String? newProfilePicUrl = widget.currentImageUrl;

      if (_imageFile != null) {
        newProfilePicUrl = await _uploadImage(_imageFile!);
      }

      // 2. Update user document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': _nameController.text,
        'bio': _bioController.text,
        if (newProfilePicUrl != null) 'profilePicUrl': newProfilePicUrl,
      });

      showSnackBar(context, 'Profile updated successfully!');
      Navigator.of(context).pop(); // Return to the previous screen
    } catch (e) {
      showErrorMessage(context, content: 'There was an error updating your profile. Please try again.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tertiaryColor,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
            style: TextStyle(
              color: secondaryColor,
              fontWeight: primaryFontWeight,
              fontSize: 32.0,
            ),
          ),
        backgroundColor: korazonColorLP,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // === Profile Image ===
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: _imageFile == null
                                ? (widget.currentImageUrl != null
                                    ? NetworkImage(widget.currentImageUrl!)
                                    : const AssetImage(
                                        'assets/images/no_profile_picture.webp',
                                      ) as ImageProvider)
                                : FileImage(_imageFile!),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: IconButton(
                              onPressed: _pickImage,
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // === Name Field ===
                      TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name cannot be empty';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: const TextStyle(color: secondaryColor),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: secondaryColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: korazonColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // === Bio Field ===
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Bio',
                          labelStyle: const TextStyle(color: secondaryColor),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: secondaryColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: korazonColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // === Save Changes Button ===
                      ElevatedButton.icon(
                        onPressed: _saveChanges,
                        icon: const Icon(Icons.save,
                        color: secondaryColor,
                        size: 28,
                        ),
                        label: const Text('Save Changes',
                        style: TextStyle(
                          color: secondaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: korazonColor,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
