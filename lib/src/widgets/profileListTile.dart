import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart';

class UserListTile extends StatefulWidget {
  const UserListTile({
    super.key,
    required this.first_name,
    required this.last_name,
    required this.username,
    required this.profilePicPath
  });

  final String first_name;
  final String last_name;
  final String username;
  final String profilePicPath; 

  @override
  State<UserListTile> createState() => _UserListTileState();
}



class _UserListTileState extends State<UserListTile> {

  Uint8List? _profilePicData;

  Future<void> loadProfilePic(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) {
      return Future.value();
    }
    _profilePicData = await getImage(photoPath);
    setState(() {
      _profilePicData = _profilePicData;
    });
  }


  @override
  Widget build(BuildContext context) {

    String fullName = '${widget.first_name} ${widget.last_name}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: _profilePicData != null 
          ? MemoryImage(_profilePicData!)
          : AssetImage('assets/images/no_profile_picture.webp'),
          // Optionally show initials or an icon if `photoPath` is null
        ),
        title: Text(
          fullName,
          style: whiteBody.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          )
        ),
        subtitle: Text(
          '@${widget.username}',
          style: whiteBody,
        ),
        onTap: () {
          // Go to the user's profile page
        }, 
      ),
    );
  }
}
