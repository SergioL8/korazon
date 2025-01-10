import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/cloudresources/authentication.dart';
import 'package:korazon/src/cloudresources/firestore_methods.dart';
import 'package:korazon/src/screens/singUpLogin/signUpScreen1.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/eventCard2.0.dart';
import 'package:korazon/src/widgets/followButton.dart';

class HostProfileScreen extends StatefulWidget {
  final String uid;
  const HostProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<HostProfileScreen> createState() => _HostProfileScreenState();
}

class _HostProfileScreenState extends State<HostProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Retrieve user document
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // If the document exists, parse data
      if (userSnap.exists) {
        userData = userSnap.data()!;

        // Example: if you store the user's follower count or array, you can parse them here
        // followers = userData['followers']?.length ?? 0;
        // isFollowing = userData['followers']?.contains(FirebaseAuth.instance.currentUser!.uid) ?? false;
        // etc.
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  /// Builds a card-like widget for stats (e.g. posts, followers)
  Widget _buildStatCard(String label, int count) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the row containing multiple stat cards (e.g. posts, followers, etc.)
  Widget _buildStatsRow() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildStatCard("Posts", postLen),
        _buildStatCard("Followers", followers),
        // If you have "following" or any other stat, you can add more cards here
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // === Top Section (Profile Info) ===
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 48, bottom: 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [korazonColor, Color.fromARGB(255, 255, 255, 255)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: userData['profilePicUrl'] != null
                                ? NetworkImage(userData['profilePicUrl'])
                                    as ImageProvider
                                : const AssetImage(
                                    'assets/images/no_profile_picture.webp',
                                  ),
                            radius: 40,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Name
                        Text(
                          userData['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Bio
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            userData['bio'] ?? 'No bio available',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Follow/Sign Out Button
                        _buildFollowOrSignOutButton(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),

                  // === Stats Row ===
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: _buildStatsRow(),
                  ),

                  const Divider(thickness: 1),

                  // === Events List ===
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('events')
                        .where('host', isEqualTo: widget.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(child: Text('No events found')),
                        );
                      }

                      final eventDocs = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: eventDocs.length,
                        itemBuilder: (context, index) {
                          final doc = eventDocs[index];
                          return EventCard2(document: doc);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildFollowOrSignOutButton() {
    final bool isCurrentUser =
        FirebaseAuth.instance.currentUser!.uid == widget.uid;

    if (isCurrentUser) {
      // Sign Out button if it's your own profile
      return FollowButton(
        text: 'Sign Out',
        backgroundColor: secondaryColor,
        textColor: tertiaryColor,
        borderColor: Colors.white,
        function: () async {
          await AuthMethods().signOut();
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const SignUpScreen(),
            ),
          );
        },
      );
    } else {
      // If it's someone else's profile, show follow/unfollow button
      return isFollowing
          ? FollowButton(
              text: 'Unfollow',
              backgroundColor: Colors.white,
              textColor: Colors.black,
              borderColor: Colors.grey,
              function: () async {
                await FireStoreMethods().followUser(
                  FirebaseAuth.instance.currentUser!.uid,
                  userData['uid'],
                );

                setState(() {
                  isFollowing = false;
                  followers--;
                });
              },
            )
          : FollowButton(
              text: 'Follow',
              backgroundColor: korazonColor,
              textColor: Colors.white,
              borderColor: secondaryColor,
              function: () async {
                await FireStoreMethods().followUser(
                  FirebaseAuth.instance.currentUser!.uid,
                  userData['uid'],
                );

                setState(() {
                  isFollowing = true;
                  followers++;
                });
              },
            );
    }
  }
}