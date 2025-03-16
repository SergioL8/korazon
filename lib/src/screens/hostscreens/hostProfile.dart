import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/screens/hostscreens/editHostProfile.dart';
import 'package:korazon/src/screens/singUpLogin/landing_page.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/widgets/colorfulSpinner.dart';
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
  UserModel? user;
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
      
      user = UserModel.fromDocumentSnapshot(userDocument);

      if (user == null) {
        showErrorMessage(context, content: 'There was an error loading the profile. Please logout and login.', errorAction: ErrorAction.logout);
        return;
      }

      followers = user!.followers.length;

      isFollowing = user!.followers.contains(FirebaseAuth.instance.currentUser!.uid);

      numberOfCreatedEvents = (user!.createdEvents as List<dynamic>?)?.length ?? 0;
      
    } catch (e) {
      showErrorMessage(context, content: 'There was an error loading the profile. Please logout and login.', errorAction: ErrorAction.logout);
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
              child: ColorfulSpinner(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: secondaryColor,
              title: Text(
                user!.name,
                textAlign: TextAlign.center, // Ensures the text stays centered
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: isCurrentUser 
              ? [
                  InkWell(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LandingPage(),
                        ),
                      );
                    },
                    child: Icon(
                        Icons.login_outlined,
                        color: tertiaryColor,
                        size: 32,
                      ),
                  ),
                ]
              : [],
              leading: !isCurrentUser ?
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: tertiaryColor,
                  ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
              : null,
                
            ),
            backgroundColor: tertiaryColor,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // === Top Section (Profile Info) ===
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 48),
                    color: appBarColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 48,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 48,
                                        backgroundColor: Colors.grey,
                                        backgroundImage: user!.profilePicPath == ''
                                          ? const AssetImage('assets/images/no_profile_picture.webp',)
                                          : NetworkImage(user!.profilePicPath) as ImageProvider
                                      ),
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Spacer(),
                                    buildStatColumn( numberOfCreatedEvents ,'Events'),
                                    SizedBox(width: 32,),
                                    buildStatColumn( followers,'Followers'),
                                    SizedBox(width: 16,),
                                  ],
                                ),
                                const SizedBox(height: 16),

                          // Bio
                          
                          Text(
                            user!.bio,
                            style: const TextStyle(
                              fontSize: 16,
                              color: secondaryColor,
                              fontWeight: FontWeight.w400
                            ),
                          ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),


                          // === Follow/Unfollow/Edit Profile ===

                          isCurrentUser
                              ?
                              // Sign Out button if it's your own profile
                              FollowButton(
                                  backgroundColor: secondaryColor,
                                  borderColor: Colors.grey.shade600,
                                  text: 'Edit Profile',
                                  textColor: tertiaryColor,
                                  function: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => EditProfilePage(
                                          currentName: user!.name,
                                          currentBio: user!.bio,
                                          currentImageUrl: user!.profilePicPath,
                                        ),
                                      ),
                                    );
                                  },
                              )

                              
          
                              // If it's someone else's profile, show follow/unfollow button
                              : isFollowing
                                  ? FollowButton(
                                      text: 'Unfollow',
                                      backgroundColor: Colors.white,
                                      textColor: secondaryColor,
                                      borderColor: Colors.grey,
                                      function: () async {
                                        await followUser(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          user!.userID,
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
                                          user!.userID,
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
                    thickness: 0.5,
                    color: dividerColor,
                  ), 
                

                  // === Events List ===
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('events')
                        .where('hostId', isEqualTo: widget.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: ColorfulSpinner());
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
                          return EventCard(document: doc, parentPage: ParentPage.hostProfile,);
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
            color: secondaryColor,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: secondaryColor,
            ),
          ),
        ),
      ],
    );
  }

