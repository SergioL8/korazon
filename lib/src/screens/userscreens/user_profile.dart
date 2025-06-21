import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/alertBox.dart';
// import 'package:korazon/src/widgets/profileEventCard.dart';
import 'package:korazon/src/widgets/loading_place_holders.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:timelines_plus/timelines_plus.dart';
import 'package:korazon/src/screens/userscreens/user_settings.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key, this.userID});
  final String? userID;

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Variable declartion
  int _imageIndex = 0;
  bool _loadingData = true;
  bool _loadingImages = true;
  bool _loadingEvents = true;
  UserModel? userData;
  List<MemoryImage?> images = [];
  List<DocumentSnapshot?> events = [];
  bool ownProfile = false;

  void _getUserEvents(List<String> eventUids) async {
    for (int i = 0; i < eventUids.length; i++) {
      final eventUid = eventUids[i];
      try {
        final eventDocument = await FirebaseFirestore.instance
            .collection('events')
            .doc(eventUid)
            .get();
        if (!eventDocument.exists) {
          continue;
        }

        setState(() {
          events[i] = eventDocument;
        });
      } catch (e) {
        showErrorMessage(context,
            content:
                'There was an error loading the events. Please try again.');
      }
    }
  }

  void _getUserImages(List<String> imagePaths) async {
    for (int i = 0; i < imagePaths.length; i++) {
      final path = imagePaths[i];
      try {
        final tempImage = await getImage(path);
        if (tempImage == null) {
          continue;
        }

        setState(() {
          images[i] = MemoryImage(tempImage);
        });
      } catch (e) {
        showErrorMessage(context,
            content:
                'There was an error loading the images. Please try again.');
      }
    }
  }

  void _getUserData(userUID) async {
    if (userUID == null) {
      showErrorMessage(context,
          content: 'There was an error loading the profile. Please try again.');
      return;
    }

    final userDocument =
        await FirebaseFirestore.instance.collection('users').doc(userUID).get();
    final userModel = UserModel.fromDocumentSnapshot(userDocument);

    if (userModel == null) {
      showErrorMessage(context,
          content: 'There was an eror loading the profile. Please try again.');
      return;
    }

    setState(() {
      userData = userModel;
      _loadingData = false;
    });

    if (userModel.profilePicturesPath.isEmpty) {
      setState(() {
        _loadingImages = false;
      });
      return;
    } else {
      setState(() {
        images = List.filled(userModel.profilePicturesPath.length, null);
      });
    }

    if (userModel.tickets.isEmpty) {
      setState(() {
        _loadingEvents = false;
      });
    } else {
      events = List.filled(userModel.tickets.length, null);
    }

    _getUserImages(userModel.profilePicturesPath);
    setState(() {
      _loadingImages = false;
    });

    _getUserEvents(userModel.tickets.map((ticket) => ticket['eventID'] as String).toList());
    setState(() {
      _loadingEvents = false;
    });
  }

  @override
  void initState() {
    super.initState();
    ownProfile = widget.userID == null;
    final userID = widget.userID ?? FirebaseAuth.instance.currentUser?.uid;
    _getUserData(userID);
  }

  @override
  Widget build(context) {
    return Scaffold(
        backgroundColor: backgroundColorBM,
        body: CustomScrollView(
          slivers: [
            // ----------------- Profile Pictures Section ---------------------
            SliverAppBar(
              elevation: 0,
              backgroundColor: backgroundColorBM,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.white)),
              ),
              expandedHeight: MediaQuery.of(context).size.width * (4 / 3) -
                  MediaQuery.of(context).padding.top,
              floating: false,
              snap: false,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    _loadingImages
                        ? LoadingImagePlaceHolder()
                        : IndexedStack(
                            index: _imageIndex,
                            children: [
                              if (images.isEmpty)
                                Container(
                                  color: korazonColor,
                                )
                              else
                                for (MemoryImage? image in images)
                                  if (image == null)
                                    LoadingImagePlaceHolder()
                                  else
                                    AspectRatio(
                                        // crop the image to a 3:4 aspect ratio
                                        aspectRatio: 3 / 4,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image(
                                              image: image,
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment(-1, 0.8),
                                                  end: Alignment(-1, -1),
                                                  colors: [
                                                    const Color.fromARGB(
                                                        160, 0, 0, 0),
                                                    const Color.fromARGB(
                                                        140, 0, 0, 0),
                                                    const Color.fromARGB(
                                                        120, 0, 0, 0),
                                                    const Color.fromARGB(
                                                        100, 0, 0, 0),
                                                    const Color.fromARGB(
                                                        75, 0, 0, 0),
                                                    const Color.fromARGB(
                                                        50, 0, 0, 0),
                                                    Colors.transparent
                                                  ],
                                                  stops: [
                                                    0.01,
                                                    0.05,
                                                    0.1,
                                                    0.15,
                                                    0.2,
                                                    0.3,
                                                    0.75
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ))
                            ],
                          ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 5,
                      left: MediaQuery.of(context).size.width * 0.13,
                      right: MediaQuery.of(context).size.width * 0.13,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(images.length, (index) {
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: AnimatedContainer(
                                  // use to smoothly change the indicator
                                  duration: const Duration(milliseconds: 300),
                                  height: index == _imageIndex ? 4 : 3,
                                  decoration: BoxDecoration(
                                    color: index == _imageIndex
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            );
                          })),
                    ),
                    Positioned(
                        left: MediaQuery.of(context).size.width * 0.060,
                        bottom: MediaQuery.of(context).size.height * 0.025,
                        child: Text(
                          userData == null
                              ? ''
                              : '${userData!.name} ${userData!.lastName}',
                          style: whiteTitle,
                        )),
                    SizedBox(
                      // needed because the height of the row is 0, without it, the gesture detector becomes ultra thin and you are not clicking it
                      height: double.infinity,
                      child: Row(
                        // needed to place the gesture detectors on the left and right of the screen
                        children: [
                          Expanded(
                            // needed to space the gesture detectors evenly occupying the entire screen
                            child: GestureDetector(
                                // needed to detect the tap on the left side of the screen
                                // gesture detector needs a child to detect the tap
                                child: Container(
                                  color: Colors.transparent,
                                ),
                                onTap: () {
                                  if (_imageIndex > 0) {
                                    setState(() {
                                      _imageIndex--;
                                    });
                                  } else {
                                    print('Animation in the future');
                                  }
                                }),
                          ),
                          Expanded(
                            child: GestureDetector(
                                // needed to detect the tap on the right side of the screen
                                child: Container(
                                  color: Colors.transparent,
                                ),
                                onTap: () {
                                  if (_imageIndex < images.length - 1 &&
                                      images[_imageIndex + 1] != null) {
                                    setState(() {
                                      _imageIndex++;
                                    });
                                  } else {
                                    print('Animation in the future');
                                  }
                                }),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            // ----------------- User Info Section ---------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  children: [
                    _loadingData
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: LoadingTextPlaceHolder(),
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.only(left: 25.0, right: 15.0),
                            child: Row(
                              children: [
                                Text(
                                  'Friends:  ${userData!.followers.length}',
                                  style: whiteSubtitle,
                                ),
                                const Spacer(),
                                ownProfile
                                    ? IconButton(
                                        onPressed: () =>
                                            Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserSettings(),
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.settings_outlined,
                                          color: korazonColorBM,
                                          size: 30,
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: () {},
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  korazonColorBM),
                                          minimumSize: WidgetStatePropertyAll(
                                              const Size(30, 27)),
                                        ),
                                        child: Text(
                                          'Follow',
                                          style: buttonBlackText,
                                        ),
                                      )
                              ],
                            ),
                          ),
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: _loadingData
                          ? LoadingTextPlaceHolder()
                          : SelectableText(
                              userData!.bio,
                              style: whiteBody,
                            ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: _loadingData
                          ? LoadingTextPlaceHolder()
                          : Column(
                              children: [
                                userData!.instaAcc == ''
                                    ? Container()
                                    : Row(
                                        children: [
                                          Icon(
                                            FaIcon(FontAwesomeIcons.instagram)
                                                .icon,
                                            color: korazonColorBM,
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Expanded(
                                            child: SelectableText(
                                              userData!.instaAcc,
                                              style: whiteBody,
                                            ),
                                          )
                                        ],
                                      ),
                                const SizedBox(
                                  height: 10,
                                ),
                                userData!.snapAcc == ''
                                    ? Container()
                                    : Row(
                                        children: [
                                          Icon(
                                            FaIcon(FontAwesomeIcons.snapchat)
                                                .icon,
                                            color: korazonColorBM,
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Expanded(
                                            child: SelectableText(
                                              userData!.snapAcc,
                                              style: whiteBody,
                                            ),
                                          )
                                        ],
                                      )
                              ],
                            ),
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: const SizedBox(
                height: 20,
              ),
            ),

            // ----------------- Your Events Section ---------------------
            // SliverToBoxAdapter(
            //   child: _loadingEvents ? Padding(
            //     padding: const EdgeInsets.all(25.0),
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(16),
            //       child: SizedBox(
            //         height: MediaQuery.of(context).size.width * 4/3,
            //         child: LoadingImagePlaceHolder()
            //       ),
            //     ),
            //   ) :
            //   Timeline.tileBuilder(
            //     physics: NeverScrollableScrollPhysics(),
            //     shrinkWrap: true,
            //     builder: TimelineTileBuilder.connected(
            //       itemCount: events.length,
            //       contentsBuilder: (context, index) {
            //         final event = events[index];
            //         if (event == null) {
            //           return Container();
            //         }
            //         return ProfileEventCard(document: event);
            //       },
            //       connectorBuilder: (context, index, connectorType) {
            //         return const SolidLineConnector(color: korazonColorBM, thickness: 2.5,);
            //       },
            //       indicatorBuilder: (context, index) {
            //       return const DotIndicator(
            //         size:8.0,
            //         color: korazonColorBM, // or any color you prefer
            //       );
            //     },
            //     nodePositionBuilder: (context, index) => 0.03,
            //     indicatorPositionBuilder: (context, index) => 0.1
            //     )
            //   )
            // ),
          ],
        ));
  }
}
