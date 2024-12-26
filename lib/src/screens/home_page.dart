import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/widgets/postCard.dart';




class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  bool _isLoading = false;
  bool _moreEventsleft = true;
  DocumentSnapshot? _lastDocument;
  List<DocumentSnapshot> _documents = [];
  final sizeOfData = 5;
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    _retrieveData();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.05;
      if (!_isLoading && _moreEventsleft && maxScroll - currentScroll <= delta) {
        _retrieveData();
      }
    });
  }


  Future<void> _retrieveData() async {

    if (_isLoading) return; // if already loading, return

    setState(() { _isLoading = true; }); // update state
    

    Query query = FirebaseFirestore.instance.collection('posts').limit(sizeOfData); // create query
    if (_lastDocument != null) {
      query = FirebaseFirestore.instance.collection('posts').startAfterDocument(_lastDocument!).limit(sizeOfData); // create query
    }

  
    QuerySnapshot querySnapshot = await query.get(); // execute query

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _documents.addAll(querySnapshot.docs); // update state
        _lastDocument = _documents.last; // update state
        _moreEventsleft = true;
        _isLoading = false; // update state
      });
    }
    else {
      setState(() {
        _moreEventsleft = false;
        _isLoading = false; // update state
      });
    }

    setState(() { _isLoading = false; }); // update state
    
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _documents.length + (_moreEventsleft ? 1 : 0),
        itemBuilder: (context, index) {
          
          if (_moreEventsleft && index == _documents.length) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return PostCard(
            document: _documents[index]
          );
        }
      )
    );
  }
}
// }