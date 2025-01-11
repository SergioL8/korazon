import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/eventCard.dart';
import 'package:korazon/src/widgets/followButton.dart';

class HostProfileScreen extends StatefulWidget {
  final String uid;
  const HostProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<HostProfileScreen> createState() => _HostProfileScreenState();
}

class _HostProfileScreenState extends State<HostProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> listOfCreatedEvents = []; // list of the events that the host has created
  var userData = {};
  int followers = 0;
  bool isLoading = false;
  bool isFollowing = false;
  int numberOfCreatedEvents = 0;

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
      var userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // If the document exists, parse data
      if (userDocument.exists) {
        userData = userDocument.data()!;

        // checks the number of followers 
        followers = userData['followers']?.length ?? 0;

        // checks if the user follows the account
        isFollowing = (userData['followers']?.contains(FirebaseAuth.instance.currentUser!.uid)) ?? false;

        numberOfCreatedEvents = (userData['createdEvents'] as List<dynamic>?)?.length ?? 0;
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  /// Builds a card-like widget for stats (e.g. posts, followers)
  

  Future<void> followUser(
    String uid,
    String followingUserId, // This is the user of the profile you are in
  ) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followingUserId)) {
        await _firestore.collection('users').doc(followingUserId).update({
          'followers': FieldValue.arrayRemove([uid]),
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followingUserId]),
        });
      } else {
        await _firestore.collection('users').doc(followingUserId).update({
          'followers': FieldValue.arrayUnion([uid]),
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followingUserId]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // this is how we know if this is us
    final bool isCurrentUser =
        FirebaseAuth.instance.currentUser!.uid == widget.uid;

    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            backgroundColor: tertiaryColor,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // === Top Section (Profile Info) ===
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 48),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          korazonColor,
                          Color.fromARGB(255, 255, 255, 255)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 42,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        backgroundImage: userData['profilePicUrl'] !=
                                                null
                                            ? NetworkImage(userData['profilePicUrl'])
                                                as ImageProvider
                                            : const AssetImage(
                                                'assets/images/no_profile_picture.webp',
                                              ),
                                        radius: 40,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Text(
                                      userData['name'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    buildStatColumn( numberOfCreatedEvents ,'Events'),
                                    SizedBox(width: 16,),
                                    buildStatColumn( followers,'Followers'),
                                  ],
                                ),
                                const SizedBox(height: 12),

                          // Bio
                          Text(
                            userData['bio'] ?? 'No bio available',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),


                          // === Follow/Unfollow/Edit Profile ===

                          isCurrentUser
                              ?
                              // Sign Out button if it's your own profile
                              FollowButton(
                                  backgroundColor: Colors.grey.shade700,
                                  borderColor: Colors.grey.shade600,
                                  text: 'Edit Profile',
                                  textColor: tertiaryColor)

                              /*FollowButton(
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
      ); */
                              // If it's someone else's profile, show follow/unfollow button
                              : isFollowing
                                  ? FollowButton(
                                      text: 'Unfollow',
                                      backgroundColor: Colors.white,
                                      textColor: Colors.black,
                                      borderColor: Colors.grey,
                                      function: () async {
                                        await followUser(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
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
                                        followUser(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          userData['uid'],
                                        );

                                        setState(() {
                                          isFollowing = true;
                                          followers++;
                                        });
                                      },
                                    ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),


                  const Divider(
                    thickness: 4,
                    color: secondaryColor,
                  ),

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
                          return EventCard(document: doc);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
  }
}

Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            color: tertiaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: tertiaryColor,
            ),
          ),
        ),
      ],
    );
  }

