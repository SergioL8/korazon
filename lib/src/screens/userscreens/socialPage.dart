import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:korazon/src/screens/userscreens/user_profile.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';
import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/widgets/colorfulSpinner.dart';
import 'package:korazon/src/widgets/profileListTile.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  bool _isLoading = false;
  List<String> eventUids = []; // List to store event UIDs
  Future<List<DocumentSnapshot<Object?>>>? topHosts;
  List<DocumentSnapshot> events =
      []; // List to store event details as DocumentSnapshots
  List<String> eventImages = [];

  int currentPage = 0; //Make sure to match wit initial page of the carousel

  // This List will be updated with the info from the different events the user is attending to
  // This 2 first elements are the defaults, top hosts and Add events
  List<Map<String, dynamic>> socialList = [
    {
      'photoPath': 'assets/images/starship.jpg',
      'title': 'Find events to find people you may know',
      'peopleYouMayKnow': [],
      'index': 0,
      // This will stay empty be cause for the hosts we are already downloading all the snaps
    },
    // IF ANYTHING IS ADDED REMEMBER TO CHANGE THE CURRENT INDEX IN "getEvents()"
  ];
  // We want to add tickets sold to the map

  @override
  void initState() {
    super.initState();
    getEvents();
    //topHosts = fetchTopHostSnapshots();
  }

  // UNNECESSSARY RIGHT NOW 

  // Future<List<DocumentSnapshot>> fetchTopHostSnapshots() async {
  //   try {
  //     // Query Firestore for all users where 'isHost' is true
  //     final topHostsSnaps = await FirebaseFirestore.instance
  //         .collection('users')
  //         .where('isHost', isEqualTo: true)
  //         .get();

  //     // Return the list of document snapshots
  //     return topHostsSnaps.docs; // List<DocumentSnapshot>
  //   } catch (e) {
  //     print('Error fetching hosts: $e');
  //     return []; // Return an empty list if an error occurs
  //   }
  // }


//! Needs model 
  Future<List<DocumentSnapshot>> fetchUsersAttending(int mapIndex) async {
    final List<DocumentSnapshot> attendingUsers = [];

    try {
      // Access the array "peopleYouMayKnow" from socialList
      for (String uid in socialList[mapIndex]['peopleYouMayKnow']) {

        final attendingUserDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

        final UserModel? attendingUser = UserModel.fromDocumentSnapshot(attendingUserDoc);

        if (attendingUser != null) {
          // Simply add to the local list; no setState here
          attendingUsers.add(attendingUserDoc);
        }
      }
      return attendingUsers;
    } catch (e) {
      // Log the error or show a message
      if (mounted ) {
      showErrorMessage(context, content: 'Error fetching attendees: $e');
      }
      return [];
    }
  }

  /// This is the same function as in your events
  /// Needs model 
  Future<void> getEvents() async { 
    setState(() {
      _isLoading = true;
    });

    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      showErrorMessage(context,
          content:
              'There was an error loading your user. Please logout and login back again.');
      return;
    }

    try {
      // Get the user's doc
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final UserModel? user = UserModel.fromDocumentSnapshot(userDoc);

      if (user == null) {
        showErrorMessage(context, content: 'There was an error loading your user. Please logout and login back again.', errorAction: ErrorAction.logout);
        return;
      }

      // Load tickets array
      setState(() {
        eventUids = user.tickets;
      });

      // Start from index = 2 because the first two are your default socialList entries
      int currentIndex = 1;

      for (String uid in eventUids) {
        final eventDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(uid)
            .get();
        
        EventModel? tempEvent = EventModel.fromDocumentSnapshot(eventDoc);

        if (tempEvent != null) {
          setState(() {
            // If you still want to keep the entire document for other usage:
            events.add(eventDoc);
          });

          // Safely extract and cast fields
          //final data = eventDoc.data() as Map<String, dynamic>;
          //final String? photoPath = data['photoPath'];


          // Cast to List<String>
          //final List<dynamic>? dynamicTickets = data['soldTickets'];
          //final List<String> soldTickets = tempEvent.ticketsSold;
          //final List<String> soldTickets = dynamicTickets != null ? dynamicTickets.cast<String>() : [];

          // If you do not want to skip entries when ticketsSold is empty, remove that condition
          if (tempEvent.photoPath != '') {
            // Add a new entry to socialList
            setState(() {
              socialList.add({
                'index': currentIndex,
                'photoPath': tempEvent.photoPath,
                'title': tempEvent.title,
                'peopleYouMayKnow': tempEvent.ticketsSold,
              });
            });
            currentIndex++;
          }
        }
      }
    } catch (e) {
      showErrorMessage(context, content: e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    final String currentEventTitle = socialList[currentPage]['title'];

    return Scaffold(
      backgroundColor: tertiaryColor,
      appBar: AppBar(
        backgroundColor: tertiaryColor,
        title: _buildSearchBar(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: dividerColor,
            height: barThickness,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(
                Icons.person,
                size: 40,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  // MaterialPageRoute(builder: (context) => const UserSettings()),
                  MaterialPageRoute(builder: (context) => UserProfile()),
                );
              },
            ),
          ),
        ],
      ),
      body: _isLoading
    ? Center(
        child: ColorfulSpinner(
        ),
      )
    : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              (currentPage == 0 || currentPage == 1)
                  ? currentEventTitle
                  : 'People you may know from "$currentEventTitle"',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Carousel
          _buildImageCarousel(),

          const SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: currentPage == 0
                  ? const SizedBox()

                  // THIS ALSO ONLY MADE SENSE FOR TOP HOSTS

                  // : currentPage == 1
                  //     ? FutureBuilder<List<DocumentSnapshot>>(
                  //         future: topHosts,
                  //         builder: (context, snapshot) {
                  //           if (snapshot.connectionState ==
                  //               ConnectionState.waiting) {
                  //             return const Center(
                  //                 child: ColorfulSpinner());
                  //           } else if (snapshot.hasError) {
                  //             return const Center(
                  //                 child: Text('Error loading hosts.'));
                  //           } else if (!snapshot.hasData ||
                  //               snapshot.data!.isEmpty) {
                  //             return const Center(
                  //                 child: Text('No hosts found.'));
                  //           } else {
                  //             final hosts = snapshot.data!;
                  //             return ListView.builder(
                  //               itemCount: hosts.length,
                  //               itemBuilder: (context, index) {
                  //                 final hostData =
                  //                     hosts[index].data() as Map<String, dynamic>?;
                  //                 final username =
                  //                     hostData?['name'] ?? 'Unknown Host';

                  //                 // Custom ListTile Widget
                  //                 return UserListTile(
                  //                   doc: hosts[index],
                  //                   onTap: () => print('Tapped on $username'),
                  //                 );
                  //               },
                  //             );
                  //           }
                  //         },
                  //       )
                      : FutureBuilder<List<DocumentSnapshot>>(
                          future: fetchUsersAttending(currentPage),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: ColorfulSpinner(
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Error loading users.'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('No users found.'));
                            } else {
                              final userDocs = snapshot.data!;
                              return ListView.builder(
                                itemCount: userDocs.length,
                                itemBuilder: (context, index) {
                                  final userDoc = userDocs[index];
                                  return UserListTile(
                                    doc: userDoc,
                                    onTap: () {},
                                  );
                                },
                              );
                            }
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom Search Bar Widget
  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Colors.grey, // dark-grey border
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              Icons.search,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search...',
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // Carousel Widget
  Widget _buildImageCarousel() {
    // Extend the list with eventImages

    return CarouselSlider(
      options: CarouselOptions(
          height: 300,
          enableInfiniteScroll:
              false, // Stops the scroll from being an infinite scroll
          enlargeCenterPage: true,
          viewportFraction:
              0.65, // Porcentage of the page occupied by each selected image
          enlargeFactor: 0.15,
          initialPage: 0,
          // This should change to the first event you have 

          // index represents the carousel number and reason is the reason for change,
          // reason can be manual, automatic, or programmed
          // selected page is set to default to 0
          onPageChanged: (index, reason) {
            setState(() {
              currentPage = index;
            });
          }
          //padEnds: false,
          ),

      // We are mapping over the map
      items: socialList.map((data) {
        final String photoPath = data['photoPath'];
        final int index = data['index']; // Use the pre-defined index

        return Builder(
          builder: (BuildContext context) {
            if (index == 0) {
              // Custom behavior for the first page
              return AspectRatio(
                aspectRatio: 1 / 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.add_circle,
                    color: Colors.grey.shade500,
                    size: 60,
                  ),
                ),
              );
            }

            // THIS ONLY MADE SENSE FOR TOP HOSTS

            // if (index == 1) {
            //   return AspectRatio(
            //     aspectRatio: 1 / 1,
            //     child: Container(
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(10),
            //         image: DecorationImage(
            //           image: AssetImage(photoPath),
            //           fit: BoxFit.cover,
            //         ),
            //       ),
            //     ),
            //   );
            // } 
            else {
              // Default behavior for other pages
              return FutureBuilder<Uint8List?>(
                future: getImage(photoPath), // Call the getImage function
                builder:
                    (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while the image is being fetched

                    return AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade200,
                        ),
                        child: Center(
                          child: Center(
                              child: Center(
                            child: Icon(Icons.account_balance),
                          )),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError || snapshot.data == null) {
                    // Show an error placeholder if image fetching fails
                    // If the image fails to load it makes sense to show a placeholder
                    // because the people attending the event might be there
                    return AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade200,
                        ),
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey.shade500,
                          size: 60,
                        ),
                      ),
                    );
                  } else {
                    // Display the fetched image
                    return AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: MemoryImage(
                                snapshot.data!), // Use the fetched image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            }
          },
        );
      }).toList(),
    );
  }
}
