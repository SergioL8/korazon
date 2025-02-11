import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:korazon/src/screens/home_page.dart';
import 'package:korazon/src/screens/hostscreens/hostProfile.dart';
import 'package:korazon/src/screens/userscreens/socialPage.dart';
import 'package:korazon/src/screens/userscreens/yourEvents.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/screens/hostscreens/eventCreationScreen.dart';
import 'package:korazon/src/screens/hostscreens/selectEventForAction.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/utilities/models/userModel.dart';


class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() {
    return _BasePage();
  }
}

class _BasePage extends State<BasePage> {
  int selectedPageIndex = 2;
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
      showErrorMessage(context, content: 'There was an error loading your user. Please logout and login again.', errorAction: ErrorAction.logout);
      return;
    }

    final userDocuement = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    
    final UserModel? user = UserModel.fromDocumentSnapshot(userDocuement);

    if (user == null) {
      showErrorMessage(context, content: 'There was an error loading your user. Please logout and login again.', errorAction: ErrorAction.logout);
      return;
    }

    final bool host = user.isHost;

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
          activePage = const SocialPage();
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
      icon: SvgPicture.asset('assets/icons/home-empty.svg', height: 32,),
      activeIcon: SvgPicture.asset('assets/icons/home-filled.svg', height: 32,),
      label: 'Home'
      ),
    BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/icons/ticket-empty.png'),),
      activeIcon: ImageIcon(AssetImage('assets/icons/ticket-filled.png'),),
      label: 'Your events'
      ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people_alt_outlined),
      activeIcon: Icon(Icons.people_alt),
      label: 'Social'
      ),
  ];
  
    return Scaffold(
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: barThickness,
                    color: dividerColor, // change to your desired color
                  ),
                ),
              ),
              // height: 70, // I had to comment this because there was an overflow in the iphone 16 pro
              child: BottomNavigationBar(
                iconSize: 32.0, // 32.0
                showSelectedLabels: false,
                showUnselectedLabels: false,
                selectedItemColor: secondaryColor,
                unselectedItemColor: secondaryColor,
                elevation: navBarElevation,
                backgroundColor: tertiaryColor,
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
