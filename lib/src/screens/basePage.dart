import 'package:flutter/material.dart';
// import 'package:korazon/src/data/providers/user_provider.dart';
import 'package:korazon/src/screens/home_page.dart';
import 'package:korazon/src/screens/userscreens/socialPage.dart';
import 'package:korazon/src/screens/userscreens/user_profile_screen.dart';
import 'package:korazon/src/screens/userscreens/yourEvents.dart';
import 'package:korazon/src/utilities/design_variables.dart';
// import 'package:provider/provider.dart';
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
    });
  }



  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  // addData() async {
  //   UserProvider userProvider = Provider.of(context, listen: false);
  //   // This line sets up the foundation for interacting with your user data in a way that's consistent across your app and efficiently updates the UI when changes occur.
  //   //Provider.of is a method to read data from a provider without listening to changes.
  //   await userProvider.refreshUser();
  // }

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    // final user = userProvider.getUser;
    // final host = user?.isHost;
  

    Widget activePage = const HomePage();
    String activePageTitle = 'Home Page';

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
        activePageTitle = 'korazon';
      } else if (selectedPageIndex == 1) {
        setState(() {
          activePage = const YourEvents();
        });
        activePageTitle = 'Your Events';
      } else if (selectedPageIndex == 2) {
        setState(() {
          activePage = const SocialPage();
        });
        activePageTitle = 'Social';
      }
    } else {
      if (selectedPageIndex == 0) {
        setState(() {
          activePage = const HomePage();
        });
        activePageTitle = 'korazon';
      } else if (selectedPageIndex == 1) {
        setState(() {
          activePage = const EventCreationScreen();
        });
        activePageTitle = 'Create Event';
      }else if (selectedPageIndex == 2) {
        setState(() {
          activePage = const SelectEventForAction(action: HostAction.scan);
        });
        activePageTitle = 'Start Event';
      } else if (selectedPageIndex == 3) {
        setState(() {
          activePage = const SelectEventForAction(action: HostAction.analytics);
        });
        activePageTitle = 'Analytics ';
      } 
    }
    

    return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
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
              selectedItemColor: secondaryColor,
              unselectedItemColor: secondaryColor,
              elevation: navBarElevation,
              backgroundColor: korazonColor,
              onTap: (selectedPageIndex) {
                _selectedPage(selectedPageIndex);
              },
              currentIndex: selectedPageIndex,
              items: isHost == true
                  ? [
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.home,
                          color: secondaryColor,
                        ),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: secondaryColor,
                        ),
                        label: 'Create Event',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.qr_code_scanner_rounded,
                          color: secondaryColor,
                        ),
                        label: 'QR Code Scanner',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.analytics,
                          color: secondaryColor,
                        ),
                        label: 'Analytics',
                      ),
                    ]
                  : [
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.home,
                          color: secondaryColor,
                        ),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.diamond_sharp,
                          color: secondaryColor,
                        ),
                        label: 'Your events',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.people,
                          color: secondaryColor,
                        ),
                        label: 'Social',
                      ),
                    ],
            ),
            body: activePage
    );
  }
}
