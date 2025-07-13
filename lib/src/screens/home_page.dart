import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/eventCard.dart';
import 'package:korazon/src/widgets/filterChip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:korazon/src/widgets/colorfulSpinner.dart';
import 'package:korazon/src/utilities/design_variables.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedFilter = 'Upcoming'; // variable to set the selected filter for the events
  bool _isLoading = false; // variable to set execution of retrieving data (to avoid multiple requests and set the loading)
  bool _moreEventsleft = true; // variable needed to check if there are more events to retrieve
  DocumentSnapshot? _lastDocument; // variable needed to start the next query from the last document of the preivous query
  List<DocumentSnapshot> _documents = []; // sotres all documents retrieved
  final sizeOfData = 5; // variable that sets teh number of documents to retrieve per query
  final ScrollController _scrollController = ScrollController(); // controller to handle the scroll

  @override
  void initState() {
    super.initState();
    _retrieveData(); // as soons as you start this page start retrieving data

    // add listener to the scroll controller
    _scrollController.addListener(() {
      double maxScroll = _scrollController
          .position.maxScrollExtent; // set the maximum position of the scroll
      double currentScroll = _scrollController
          .position.pixels; // the current position of the scroll
      double delta = MediaQuery.of(context).size.height *
          0.05; // this is the distance to the bottom of the list view at which the next query will be executed
      if (!_isLoading &&
          _moreEventsleft &&
          maxScroll - currentScroll <= delta) {
        // logic to check if the next query should be executed
        _retrieveData();
      }
    });
  }

  Future<void> _retrieveData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance.collection('events');

    // Apply filters
    // Apply the upcoming filter

    //? Events show up to 4 hours after the start time
    if (selectedFilter == 'Upcoming') {
      final fourHoursAgo = DateTime.now().subtract(const Duration(hours: 4));
      query = query.where('startDateTime',
          isGreaterThan: Timestamp.fromDate(fourHoursAgo));
    }

    //Events that are happening in the next 24 hours
    // I think this makes more sense than events up to 6 am of the next day
    if (selectedFilter == 'Tonight') {
      final now = DateTime.now();
      final next24h = now.add(const Duration(hours: 24));

      query = query
          .where('startDateTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('startDateTime', isLessThan: Timestamp.fromDate(next24h));
    }

    //Events that are happening in the next 7 days
    if (selectedFilter == 'This Week') {
      final now = DateTime.now();
      final next7Days = now.add(const Duration(days: 7));

      query = query
          .where('startDateTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('startDateTime', isLessThan: Timestamp.fromDate(next7Days));
    }

    query = query.orderBy('startDateTime').limit(sizeOfData);

    if (_lastDocument != null) {
      final lastTime = _lastDocument!.get('startDateTime');
      query = query.startAfter([lastTime]);
    }

    QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _documents.addAll(querySnapshot.docs);
        _lastDocument = querySnapshot.docs.last;
        _moreEventsleft = querySnapshot.docs.length >= sizeOfData;
        _isLoading = false;
      });
    } else {
      setState(() {
        _moreEventsleft = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColorBM,
      body: CustomScrollView(
          // Builds the sliver(s) for the outer scrollable
          slivers: [
            SliverAppBar(
              snap: true,
              floating: true,
              backgroundColor: backgroundColorBM,
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(50), // adjust if needed
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      16, 0, 16, 12), // padding to match original style
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Korazon Logo
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return linearGradient.createShader(bounds);
                        },
                        child: Text(
                          'Korazon',
                          style: whiteTitle,
                        ),
                      ),

                      // Search Bar
                      // Container(
                      //   height: 44,
                      //   decoration: BoxDecoration(
                      //     color: tertiaryColor,
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   padding: const EdgeInsets.symmetric(horizontal: 12),
                      //   child: Row(
                      //     children: const [
                      //       Icon(Icons.search, color: Colors.grey),
                      //       SizedBox(width: 8),
                      //       Text(
                      //         'Search',
                      //         style: TextStyle(
                      //           color: Colors.grey,
                      //           fontSize: 16,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(height: 12),

                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChipLabel(
                              label: 'Upcoming',
                              selected: selectedFilter == 'Upcoming',
                              onTap: () {
                                setState(() {
                                  selectedFilter = 'Upcoming';
                                  _documents.clear();
                                  _lastDocument = null;
                                  _moreEventsleft = true;
                                });
                                _retrieveData(); // Fetch filtered data
                              },
                            ),
                            FilterChipLabel(
                              label: 'This Week',
                              selected: selectedFilter == 'This Week',
                              onTap: () {
                                setState(() {
                                  selectedFilter = 'This Week';
                                  _documents.clear();
                                  _lastDocument = null;
                                  _moreEventsleft = true;
                                });
                                _retrieveData(); // Fetch filtered data
                              },
                            ),
                            FilterChipLabel(
                              label: 'Tonight',
                              selected: selectedFilter == 'Tonight',
                              onTap: () {
                                setState(() {
                                  selectedFilter = 'Tonight';
                                  _documents.clear();
                                  _lastDocument = null;
                                  _moreEventsleft = true;
                                });
                                _retrieveData();
                              },
                            ),
                            // FilterChipLabel(
                            //   label: 'Free',
                            //   selected: selectedFilter == 'Free',
                            //   onTap: () =>
                            //       setState(() => selectedFilter = 'Free'),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //SliverToBoxAdapter(child: SizedBox(height: 20),),

            CupertinoSliverRefreshControl(
              onRefresh: () async {
                setState(() {
                  _documents.clear();
                  _lastDocument = null;
                  _moreEventsleft = true;
                });
                await _retrieveData();
              },
            ),

            // I added the padding to the postcard so that it is consistent across the app

            SliverToBoxAdapter(
              child: _isLoading && _documents.isEmpty
                  ? const Center(child: SpinKitThreeBounce(color: Colors.white, size: 30),)
                  : _documents.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 64.0),
                          child: Center(
                            child: Text(
                              'No events available at the moment.',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 24.0),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              _documents.length + (_moreEventsleft ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_moreEventsleft && index == _documents.length) {
                              return const Center(child: ColorfulSpinner());
                            }
                            return EventCard(
                              document: _documents[index],
                              parentPage: ParentPage.homePage,
                            );
                          },
                        ),
            ),
          ]),
    );
  }
}
