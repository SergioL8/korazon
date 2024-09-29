import 'package:flutter/material.dart';
import 'package:korazon/screens/users.dart';

class HomePageScreen extends StatelessWidget{
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const UserSettings();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Home Page'),
      ),
    );
  }
}