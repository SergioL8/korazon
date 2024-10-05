import 'package:flutter/material.dart';
import 'package:korazon/screens/users.dart';
import 'package:korazon/screens/homePage.dart';
import 'package:korazon/screens/yourEventsPage.dart';
import 'package:korazon/screens/socialPage.dart';


class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() {
    return _HomePageScreen();
  }
}



class _HomePageScreen extends State<HomePageScreen> {

  int selectedPageIndex = 0;

  void _selectedPage(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    Widget activePage = const HomePage();
    String activePageTitle = 'Home Page';

    if (selectedPageIndex == 0) {
      setState(() {
        activePage = const HomePage();
      });
      activePageTitle = 'Home Page';
    } else if (selectedPageIndex == 1) {
      setState(() {
        activePage = const yourEventsPage();
      });
      activePageTitle = 'Your Events'; 
    } else if (selectedPageIndex == 2) {
      setState(() {
        activePage = const SocialPage();
      });
      activePageTitle = 'Social';
    }
      
    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
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
      bottomNavigationBar: BottomNavigationBar(
        onTap: (selectedPageIndex) { _selectedPage(selectedPageIndex); },
        currentIndex: selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.airplane_ticket),
            label: 'Your events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Social',
          ),
        ],
      ),
      body: activePage
    );
  }
}