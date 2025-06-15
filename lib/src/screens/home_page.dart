import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/colorfulSpinner.dart';
import 'package:korazon/src/widgets/eventCard.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/filterChip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedFilter =
      'Upcoming'; // variable to set the selected filter for the events
  bool _isLoading =
      false; // variable to set execution of retrieving data (to avoid multiple requests and set the loading)
  bool _moreEventsleft =
      true; // variable needed to check if there are more events to retrieve
  DocumentSnapshot?
      _lastDocument; // variable needed to start the next query from the last document of the preivous query
  List<DocumentSnapshot> _documents = []; // sotres all documents retrieved
  final sizeOfData =
      5; // variable that sets teh number of documents to retrieve per query
  final ScrollController _scrollController =
      ScrollController(); // controller to handle the scroll

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
    if (_isLoading) {
      return;
    } // if already loading, return (avoid multiple requests at the same time)

    setState(() {
      _isLoading = true;
    }); // update state for the loading spinner

    Query query = FirebaseFirestore.instance
        .collection('events')
        .limit(sizeOfData); // create query

    if (_lastDocument != null) {
      query = FirebaseFirestore.instance
          .collection('events')
          .startAfterDocument(_lastDocument!)
          .limit(sizeOfData); // create query
    }

    QuerySnapshot querySnapshot = await query.get(); // execute query
    if (querySnapshot.docs.isNotEmpty) {
      // if documents have been returned
      setState(() {
        _documents.addAll(querySnapshot
            .docs); // add the documents to the total list of documents
        _lastDocument = _documents.last; // update the last document retrieved

        // if fewer documents have been returned than the number of documents requested, there are no more documents to retrieve
        if (querySnapshot.docs.length < sizeOfData) {
          // this is what will stop the next query from being executed
          _moreEventsleft = false;
        } else {
          _moreEventsleft = true;
        }
        _isLoading = false; // stop the loading spinner
      });
    } else {
      // if no documents have been returned then there are no more documents to retrieve
      setState(() {
        _moreEventsleft = false;
        _isLoading = false; // update state
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
                preferredSize: const Size.fromHeight(100), // adjust if needed
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      16, 0, 16, 12), // padding to match original style
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: tertiaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: const [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              'Search',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChipLabel(
                              label: 'Upcoming',
                              selected: selectedFilter == 'Upcoming',
                              onTap: () =>
                                  setState(() => selectedFilter = 'Upcoming'),
                            ),
                            FilterChipLabel(
                              label: 'This Week',
                              selected: selectedFilter == 'This Week',
                              onTap: () =>
                                  setState(() => selectedFilter = 'This Week'),
                            ),
                            FilterChipLabel(
                              label: 'Tonight',
                              selected: selectedFilter == 'Tonight',
                              onTap: () =>
                                  setState(() => selectedFilter = 'Tonight'),
                            ),
                            FilterChipLabel(
                              label: 'Free',
                              selected: selectedFilter == 'Free',
                              onTap: () =>
                                  setState(() => selectedFilter = 'Free'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //SliverToBoxAdapter(child: SizedBox(height: 20),),

            // I added the padding to the postcard so that it is consistent across the app

            SliverToBoxAdapter(
              child: _documents.isEmpty && !_isLoading
                  ? const Center(child: Text('No events :('))
                  : ListView.builder(
                      physics:
                          const NeverScrollableScrollPhysics(), // Remove custom scrollController here
                      shrinkWrap: true,
                      itemCount: _documents.length + (_moreEventsleft ? 1 : 0),
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
