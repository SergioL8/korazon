

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserListTile extends StatelessWidget {
  final DocumentSnapshot doc;
  final VoidCallback? onTap;

  const UserListTile({
    super.key,
    required this.doc,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Convert DocumentSnapshot data to a Map
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Extract the fields you need
    final String username = data['name'] ?? 'Unknown User';
    final String? photoUrl = data['photoUrl']; // adjust field name to match your DB

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: photoUrl != null 
          ? NetworkImage(photoUrl)
          : AssetImage('assets/images/no_profile_picture.webp'),
          // Optionally show initials or an icon if `photoPath` is null
        ),
        title: Text(
          username,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onTap: onTap, // Passes the tap action up if provided
      ),
    );
  }
}
