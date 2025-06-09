import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/widgets/profileListTile.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/widgets/loading_place_holders.dart';

class GuestList extends StatefulWidget {

  GuestList({super.key, required this.guestList});

  final List<String> guestList;

  @override
  State<GuestList> createState() => _GuestListState();
}

class _GuestListState extends State<GuestList> {
  List<UserModel> attendees = [];
  bool _displayAtendees = false;
  bool _isLoading = false;

  Future<List<UserModel>> _fetchAllAttendees() async {
  // 1. Early exit if no guests
  final List<String> allUids = widget.guestList;
  if (allUids.isEmpty) {
    return [];
  }

  // 2. Split the full guestList into chunks of at most 10 UIDs each
  final List<List<String>> chunks = [];
  for (var i = 0; i < allUids.length; i += 10) {
    chunks.add(allUids.sublist(i, min(i + 9, allUids.length),),);
  }

  // 3. For each chunk, kick off a query Future
  final List<Future<QuerySnapshot>> futures = chunks.map((chunk) {
    return FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: chunk)
        .get();
  }).toList();

  // 4. Wait for all batch‐queries to complete (or throw on any one error)
  final List<QuerySnapshot> snapshots = await Future.wait(futures);

  // 5. Flatten all QuerySnapshot.docs and map to your UserModel
  final List<UserModel> tempAttendees = snapshots
      .expand((snap) => snap.docs)
      .map((doc) => UserModel.fromDocumentSnapshot(doc)!)
      .toList();

  return tempAttendees;
}




  @override
  Widget build(context) {

    // ============ Blocked until end of event =============

    
    // ============= Hidden list =============
    if (!_displayAtendees) {
      return GestureDetector(
        onTap: () async {
          setState(() {
            _displayAtendees = true;
            _isLoading = true;
          });
          final List<UserModel> fetched = await _fetchAllAttendees();
          setState(() {
            attendees = fetched;
            _isLoading = false;
          });
        },
        child: Container(
          width: MediaQuery.of(context).size.width - 32,
          height: 500,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 1
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'Tap to see the guest list. \n'
              '(Temporary Placeholder)',
              style: whiteSubtitle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // ============= No attendees found =============
    if (widget.guestList.isEmpty) {
      return Center(
        child: Text(
          'No registered guests found. \n'
          '(Temporary Placeholder)',
          style: whiteBody,
          textAlign: TextAlign.center,
        ),
      );
    }

    // ============= Loading attendees =============
    if (_isLoading) {
      return SizedBox(
        width: MediaQuery.of(context).size.width - 32,
        height: 500,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              LoadingTextPlaceHolder(height: 75),
              const SizedBox(height: 20),
              LoadingTextPlaceHolder(height: 75),
              const SizedBox(height: 20),
              LoadingTextPlaceHolder(height: 75),
              const SizedBox(height: 20),
              LoadingTextPlaceHolder(height: 75),
              const SizedBox(height: 20),
              LoadingTextPlaceHolder(height: 75),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 0.0),
        physics: const NeverScrollableScrollPhysics(),
        primary: false,
        itemCount: attendees.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final UserModel attendee = attendees[index];
          return UserListTile(
            first_name: attendee.name,
            last_name: attendee.lastName,
            username: attendee.username,
            profilePicPath: attendee.profilePicPath,
          );
        },
        separatorBuilder: (context, index) => const Divider(
          color: Colors.white38,
          thickness: 1,
        ),
      ),
    );
  }
}