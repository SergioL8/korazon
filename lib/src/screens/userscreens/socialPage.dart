import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:korazon/src/screens/userscreens/user_profile_screen.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/alertBox.dart';

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

  int currentPage = 0;

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
    {
      'photoPath': 'assets/images/pary.jpg',
      'title': 'Top Hosts',
      'peopleYouMayKnow': [],
      'index': 1,
    },
  ];
  // We want to add tickets sold to the map

  @override
  void initState() {
    super.initState();
    getEvents();
    topHosts = fetchTopHostSnapshots();
  }

  Future<List<DocumentSnapshot>> fetchTopHostSnapshots() async {
    try {
      // Query Firestore for all users where 'isHost' is true
      final topHostsSnaps = await FirebaseFirestore.instance
          .collection('users')
          .where('isHost', isEqualTo: true)
          .get();

      // Return the list of document snapshots
      return topHostsSnaps.docs; // List<DocumentSnapshot>
    } catch (e) {
      print('Error fetching hosts: $e');
      return []; // Return an empty list if an error occurs
    }
  }

  /// This is the same function as in your events
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
      // Get the current user's document
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        showErrorMessage(context,
            content:
                'There was an error loading your user. Please logout and login back again.');
        return;
      }

      setState(() {
        // Extract the fetched tickets array and turn them into a list
        eventUids = List.from(userDoc.data()?['tickets'] ?? []);
      });

      // Fetch event details for each event UID
      // This goes to the list of all events to find if they match any of the ones
      // in your tickets list.

      // We start from 2 because the first two elements are for the top hosts and add events
      int currentIndex = 2;

      for (String uid in eventUids) {
        //TODO: Use Model
        var eventDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(uid)
            .get();

        if (eventDoc.exists) {
          // Adds the entire document snapshot to the list events
          setState(() {
            events.add(eventDoc);
          });

          // Extract the photoPath and ticketsSold fields from the event
          final String? photoPath = eventDoc.data()?['photoPath'];
          final List<String> ticketsSold = eventDoc.data()?['ticketsSold'];

          if (photoPath != null && photoPath.isNotEmpty) {
            // Adding the image of every event the user has to the map and also
            // the list of people attending (ticketsSold)
            setState(() {
              socialList.add({
                'index': currentIndex,
                'photoPath': photoPath,
                'title': eventDoc.data()?['eventName'] ?? 'Untitled Event',
                'peopleYouMayKnow':
                    ticketsSold ?? [], // or [] if it's supposed to be a list
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
                  MaterialPageRoute(builder: (context) => const UserSettings()),
                );
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: secondaryColor,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Party People',
                    //The Text will be the value title of the currently selected page from the carousel
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: secondaryColor,
                    ),
                  ),
                ),
                //Now we need to add the ListView.builder for the profile

                // Carousel
                _buildImageCarousel(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        socialList[currentPage]['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                currentPage == 0
                    ? SizedBox()
                    // This is if you are in the top hosts card
                    : FutureBuilder<List<DocumentSnapshot>>(
                        future: topHosts,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error loading hosts.'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(child: Text('No hosts found.'));
                          } else {
                            final hosts = snapshot.data!;
                            return Expanded(
                              child: ListView.builder(
                                itemCount: hosts.length,
                                itemBuilder: (context, index) {
                                  final hostData = hosts[index].data()
                                      as Map<String, dynamic>?;
                              
                                  // Extract username and photoPath
                                  final username =
                                      hostData?['username'] ?? 'Unknown Host';
                                  //final photoPath = hostData?['photoPath'];
                                  return ListTile(
                                    // leading: CircleAvatar(
                                    //   backgroundImage: NetworkImage(photoPath),
                                    // ),
                                    title: Text(username),
                                    onTap: () {
                                      // Add navigation or interaction logic here
                                      print('Tapped on $username');
                                    },
                                  );
                                },
                              ),
                            );
                          }
                        },
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
              true, // Stops the scroll from being an infinite scroll
          enlargeCenterPage: true,
          viewportFraction:
              0.65, // Porcentage of the page occupied by each selected image
          enlargeFactor: 0.15,
          initialPage: 0,

          // index represents the carousel number and reason is the reason for change,
          // reason can be manual, automatic, or programmed
          // selected page is set to default to 0
          onPageChanged: (index, reason) {
            setState(() {
              currentPage = index;
              print(index);
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
              return InkWell(
                onTap: () {
                  print("Tapped on $index");
                },
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(photoPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            }
            if (index == 1) {
              return AspectRatio(
                aspectRatio: 1 / 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(photoPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            } else {
              // Default behavior for other pages
              return AspectRatio(
                aspectRatio: 1 / 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(photoPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }
          },
        );
      }).toList(),
    );
  }
}
