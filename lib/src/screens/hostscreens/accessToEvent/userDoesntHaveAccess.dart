import 'package:flutter/material.dart';
import 'package:korazon/src/widgets/accessToEventWidgets/allowGuestIntoPartyButton.dart';
import 'package:korazon/src/widgets/accessToEventWidgets/denyGuestIntoPartyButton.dart';


class UserDoesntHaveAccess extends StatelessWidget {

  const UserDoesntHaveAccess({super.key, required this.userData});
  final Map<String, dynamic> userData;

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 177, 23, 23),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.10),
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                ),
                Icon(Icons.close,
                  color: const Color.fromARGB(255, 177, 23, 23),
                  size: 50,
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align elements to the left
                  children: [
                    Text(userData['name'] ?? 'No name', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(' - Age: ${userData['age'] ?? 'No age'}', style: const TextStyle(color: Colors.white)),
                    Text(' - Gender: ${userData['gender'] ?? 'No gender'}', style: const TextStyle(color: Colors.white)),
                    Text(' - Black listed:', style: const TextStyle(color: Colors.white)),
                  ],
                ),
                const Spacer(),
                Image.asset('assets/images/profilePicture.jpeg', scale: 10,),
              ],
            ),
            const SizedBox(height: 20),
            Text('User DOES NOT have access to event', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            Text('Always remember to check the user\'s ID', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space elements evenly
              children: [
                AllowGuestIn(userData: userData),
                const SizedBox(width: 10),
                DenyGuestIn(),
              ],
            )
          ]
        ),
      ),
    );
  }
  
}