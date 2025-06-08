import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/profileListTile.dart';
import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/widgets/loading_place_holders.dart';

class GuestList extends StatelessWidget {

  const GuestList({super.key, required this.guestList});

  final List<String> guestList;

  @override
  Widget build(context) {
    if (guestList.isEmpty) {
      return Center(
        child: Text(
          'No registered guests found.',
          style: whiteBody,
        ),
      );
    }
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: guestList)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              height: 500,
              child: LoadingImagePlaceHolder(),
            )
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No registered guests found.',
              style: whiteBody,
            ),
          );
        }
        final docs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            UserModel? user = UserModel.fromDocumentSnapshot(docs[index]);
            return UserListTile(
              first_name: user!.name,
              last_name: user.lastName,
              username: user.username,
              profilePicPath: user.profilePicPath,
            );
          },
        );
      },
    );
  }
}