import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/models/userModel.dart';



class BlacklistPage extends StatefulWidget {
  const BlacklistPage({super.key});

  @override
  State<BlacklistPage> createState() => _BlacklistPageState();
}

class _BlacklistPageState extends State<BlacklistPage> {

  late List<BlackListModel>? blackList;
  bool _isLoading = false;

  void loadBlacklist() async {

    setState(() {
      _isLoading = true;
    });

    final uid = FirebaseAuth.instance.currentUser;
    if (uid == null) {
      if (mounted) {
        showErrorMessage(context, content: 'There was an error loading your user. Please logout and login again.', errorAction: ErrorAction.logout);
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid.uid).get();
    if (!userSnapshot.exists) {
      if (mounted) {
        showErrorMessage(context, content: 'There was an error loading your user. Please logout and login again.', errorAction: ErrorAction.logout);
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final userModel = UserModel.fromDocumentSnapshot(userSnapshot);
    if (userModel == null) {
      if (mounted) {
        showErrorMessage(context, content: 'There was an error loading your user. Please logout and login again.', errorAction: ErrorAction.logout);
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    blackList = userModel.blackList;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadBlacklist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColorBM,
      appBar: AppBar(
        toolbarHeight: 85,
        backgroundColor: backgroundColorBM,
        centerTitle: false,
        actionsPadding: EdgeInsets.only(left: 12, right: 12),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Blacklist', style: whiteSubtitle),
            Text('manage banned attendees', style: whiteBody.copyWith(fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              backgroundColor: const Color.fromARGB(255, 168, 27, 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () {},
            child: Text('Add to Blacklist', style: whiteBody),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _isLoading
          ? Text('Loading')
          : ListView.builder(
            itemCount: (blackList?.isNotEmpty ?? false)
              ? blackList!.length + 1 // header + items
              : 2, // header + empty message
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.white, width: 0.5),
                  ),
                  child: 
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${blackList?.length ?? 0}',
                              style: whiteSubtitle.copyWith(fontSize: 30),
                            ),
                            Spacer(),
                            Icon(Icons.people_alt_outlined, color: const Color.fromARGB(255, 168, 27, 17), size: 30,)
                          ],
                        ),
                        // SizedBox(height: 8.0),
                        Text(
                          'Banned Attendees',
                          style: whiteBody.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    )
                );
              } else {
                if (blackList == null || blackList!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                      child: Text(
                        'Blacklists allow chapters to share a list of banned guests. Once someone is on your blacklist, any chapter scanning their QR will immediately see a “Blacklisted” warning. No details about the ban wll be shown.',
                        style: whiteBody.copyWith(height: 1.75),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
              }
            },
          ),
      )
    );
  }
}