import 'package:cloud_firestore/cloud_firestore.dart';

// When creating a new code in firebase, the only two required fields are:
// 'code' and 'used=false', otherwise it will not work
class IdentityCodeModel {
  IdentityCodeModel({
    required this.documentID,
    required this.code,
    required this.used,
    required this.dateUsed,
    required this.fratUID,
    // I will not be requiring fratName and email becuase we will never
    // show this information to the user and it requires downloading
    // current user document to update the code.

    // required this.fratName,
    // required this.fratEmail,
  });

  final String documentID;
  final String code;
  final bool used;
  final DateTime dateUsed;
  final String fratUID;
  // final String fratName;
  // final String fratEmail;

  static IdentityCodeModel? fromDocumentSnapshot(DocumentSnapshot doc) {
    // If document doesn't exist or no data is found, return null
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null || data.isEmpty) return null;

    // Handle Firestore Timestamp (if 'dateUsed' is a Timestamp, convert it to DateTime)
    final dynamic rawDate = data['dateUsed'];
    DateTime dateTime;
    if (rawDate is Timestamp) {
      dateTime = rawDate.toDate();
    } else if (rawDate is DateTime) {
      dateTime = rawDate;
    } else {
      // If no valid date is found, default to "now" or any other fallback
      dateTime = DateTime.now();
    }

    return IdentityCodeModel(
      documentID: doc.id,
      code: data['code'] ?? '',
      used: data['used'] ?? true,
      dateUsed: dateTime,
      fratUID: data['fratUID'] ?? 'No uid found',
      // fratName: data['fratName'] ?? 'No name found',
      // fratEmail: data['fratEmail'] ?? 'No email found',
    );
  }
}
