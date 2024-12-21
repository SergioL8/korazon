import 'package:flutter/material.dart';
import 'package:korazon/src/data/providers/user_provider.dart';
import 'package:korazon/src/screens/home_page.dart';
import 'package:korazon/src/screens/scanner.dart';
import 'package:korazon/src/screens/socialPage.dart';
import 'package:korazon/src/screens/user_profile_screen.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/screens/eventcreation_screen.dart';
import 'package:provider/provider.dart';



class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() {
    return _BasePage();
  }
}


class _BasePage extends State<BasePage> {

  int selectedPageIndex = 0;

  void _selectedPage(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    addData();
  }

  addData() async{
    UserProvider userProvider = Provider.of(context, listen: false);
     // This line sets up the foundation for interacting with your user data in a way that's consistent across your app and efficiently updates the UI when changes occur.
     //Provider.of is a method to read data from a provider without listening to changes.
    await userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.getUser;
    final host = user?.isHost;
    print('user: $host');


    //! If statement to display 
    

    Widget activePage = const HomePage();
    String activePageTitle = 'Home Page';

    if (selectedPageIndex == 0) {
      setState(() {
        activePage = const HomePage();
      });
      activePageTitle = 'Home Page';
    } else if (selectedPageIndex == 1) {
      setState(() {
        activePage = const ScannerScreen();
      });
      activePageTitle = 'Your Events'; 
    } else if (selectedPageIndex == 2) {
      setState(() {
        activePage = const SocialPage();
      });
      activePageTitle = 'Social';
    } else if (selectedPageIndex == 3) {
      setState(() {
        activePage = const EventCreationScreen();
      });
      activePageTitle = 'Create Event';
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
        elevation: navBarElevation,
        backgroundColor: primaryColor,
        onTap: (selectedPageIndex) { _selectedPage(selectedPageIndex); },
        currentIndex: selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
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
          BottomNavigationBarItem(
            icon: Icon(
              Icons.upload,
              color: secondaryColor,
              ),
            label: 'Post Event',
          ),
        ],
      ),
      body: activePage
    );
  }
}