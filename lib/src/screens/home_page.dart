import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/eventCard.dart';
import 'package:korazon/src/widgets/eventCard2.0.dart';




class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

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
      double maxScroll = _scrollController.position.maxScrollExtent; // set the maximum position of the scroll
      double currentScroll = _scrollController.position.pixels; // the current position of the scroll
      double delta = MediaQuery.of(context).size.height * 0.05; // this is the distance to the bottom of the list view at which the next query will be executed
      if (!_isLoading && _moreEventsleft && maxScroll - currentScroll <= delta) { // logic to check if the next query should be executed
        _retrieveData();
      }
    });
  }


  Future<void> _retrieveData() async {

    if (_isLoading) return; // if already loading, return (avoid multiple requests at the same time)

    setState(() { _isLoading = true; }); // update state for the loading spinner

    Query query = FirebaseFirestore.instance.collection('events').limit(sizeOfData); // create query
    if (_lastDocument != null) {
      query = FirebaseFirestore.instance.collection('events').startAfterDocument(_lastDocument!).limit(sizeOfData); // create query
    }

    QuerySnapshot querySnapshot = await query.get(); // execute query
    if (querySnapshot.docs.isNotEmpty) { // if documents have been returned 
      setState(() {
        _documents.addAll(querySnapshot.docs); // add the documents to the total list of documents
        _lastDocument = _documents.last; // update the last document retrieved
        
        // if fewer documents have been returned than the number of documents requested, there are no more documents to retrieve
        if (querySnapshot.docs.length < sizeOfData) { // this is what will stop the next query from being executed
          _moreEventsleft = false; 
        } else {
          _moreEventsleft = true;
        }
        _isLoading = false; // stop the loading spinner
      });
    }
    else { // if no documents have been returned then there are no more documents to retrieve
      setState(() {
        _moreEventsleft = false;
        _isLoading = false; // update state
      });
    }    
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tertiaryColor,
      body: _documents.isEmpty && !_isLoading ? // if there are no documents and it's not because of loading
        Center(child: const Text('No events :(')) : 
        ListView.builder( // if there are documents, build the list view
          controller: _scrollController,
          itemCount: _documents.length + (_moreEventsleft ? 1 : 0), // we want to add an extra space if more events left for the loading spinner
          itemBuilder: (context, index) {
            
            if (_moreEventsleft && index == _documents.length) { // if we are at the end of the list and more events are left
              return const Center( // show the loading spinner
                child: CircularProgressIndicator(),
              );
            }

            // show the event card
            return EventCard2(
                document: _documents[index]
              );
          }
        )
    );
  }
}
// }