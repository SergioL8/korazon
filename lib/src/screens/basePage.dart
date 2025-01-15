import 'package:flutter/material.dart';
import 'package:korazon/src/screens/home_page.dart';
import 'package:korazon/src/screens/hostscreens/hostProfile.dart';
import 'package:korazon/src/screens/userscreens/user_profile_screen.dart';
import 'package:korazon/src/screens/userscreens/yourEvents.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/screens/hostscreens/eventCreationScreen.dart';
import 'package:korazon/src/screens/hostscreens/selectEventForAction.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';


class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() {
    return _BasePage();
  }
}

class _BasePage extends State<BasePage> {
  int selectedPageIndex = 0;
  String? _uid;
  bool? isHost;

  void _selectedPage(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  
  Future<void> _getUserInfo() async {
    // await FirebaseAuth.instance.signOut();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      print('Something went wrong please log out and login again. In the future use an alert box');
      return;
    }

    final userDocuement = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!userDocuement.exists) {
      print('There was an error loading your profile, please log out and login again. In the future use an alert boxx');
      return;
    }

    final bool? host = userDocuement.data()?['isHost'];
    if (host == null) {
      print('There was an error loading your profile, please log out and login again. In the future use an alert box');
      return;
    }

    setState(() {
      isHost = host;
      _uid = uid;
    });
  }



  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  @override
  Widget build(BuildContext context) {

    Widget activePage = const HomePage();

    if (isHost == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
          ),
        ),
      );
    }

    if (isHost == false) {
      if (selectedPageIndex == 0) {
        setState(() {
          activePage = const HomePage();
        });
      } else if (selectedPageIndex == 1) {
        setState(() {
          activePage = const YourEvents();
        });
      } else if (selectedPageIndex == 2) {
        setState(() {
          // activePage = const SocialPage();
          activePage = const UserSettings();
        });
      }
    } else {
      if (selectedPageIndex == 0) {
        setState(() {
          activePage = const HomePage();
        });
      } else if (selectedPageIndex == 1) {
        setState(() {
          
          activePage = const SelectEventForAction(action: HostAction.scan);
        });
      }else if (selectedPageIndex == 2) {
        setState(() {
          activePage = const EventCreationScreen();
        });
      } else if (selectedPageIndex == 3) {
        setState(() {
          activePage = const SelectEventForAction(action: HostAction.analytics);
        });
      } else if (selectedPageIndex == 4) {
          setState(() {
            // If have used the null assertion operator because if the uid is null this would
            // never execute
            activePage = HostProfileScreen(uid: _uid!);
          });
        }
    }

      final hostNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.qr_code_scanner_rounded),
      activeIcon: Icon(Icons.qr_code_rounded),
      label: 'Scan',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.add_circle_outline),
      activeIcon: Icon(Icons.add_circle),
      label: 'Create',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.analytics_outlined),
      activeIcon: Icon(Icons.analytics),
      label: 'Analytics',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  final userNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home'
      ),
    BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/icons/ticket-empty.png'),),
      activeIcon: ImageIcon(AssetImage('assets/icons/ticket-filled.png'),),
      label: 'Your events'
      ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded),
      activeIcon: Icon(Icons.person_rounded),
      label: 'Social'
      ),
  ];
  
    return Scaffold(
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: barThickness,
                    color: korazonColor, // change to your desired color
                  ),
                ),
              ),
              height: 70,
              child: BottomNavigationBar(
                iconSize: 32.0,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                selectedItemColor: secondaryColor,
                unselectedItemColor: secondaryColor,
                elevation: navBarElevation,
                backgroundColor: korazonColorLP,
                onTap: (selectedPageIndex) {
                  _selectedPage(selectedPageIndex);
                },
                currentIndex: selectedPageIndex,
                items: isHost == true
                    ? hostNavItems : userNavItems,
              ),
            ),
            body: activePage
    );
  }
}
