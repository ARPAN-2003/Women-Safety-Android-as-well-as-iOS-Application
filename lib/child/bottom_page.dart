import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:women_safety_app/child/bottom_screens/add_contacts.dart';
import 'package:women_safety_app/child/bottom_screens/chat_page.dart';
import 'package:women_safety_app/child/bottom_screens/child_home_page.dart';
import 'package:women_safety_app/child/bottom_screens/review_page.dart';
import 'package:women_safety_app/components/fab_bar_bottom.dart';
import 'package:women_safety_app/profile_mode/settings.dart';

class BottomPage extends StatefulWidget {
  const BottomPage({super.key});

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  int currentIndex = 0;
  List<Widget> pages = [
    HomeScreen(),
    AddContactsPage(),
    // ChatPage(),
    CheckUserStatusBeforeChat(),
    // ProfilePage(),
    // ReviewPage(),
    SettingsPage()
  ];

  onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvoked: (didPop) async {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
          else {
            SystemNavigator.pop();
          }
          // return true;
        },
        child: DefaultTabController(
          initialIndex: currentIndex,
          length: pages.length,
          child: Scaffold(
              body: pages[currentIndex],
              bottomNavigationBar: FABBottomAppBar(
                onTabSelected: onTapped,
                items: [
                  FABBottomAppBarItem(iconData: Icons.home_rounded, text: "Home"),
                  FABBottomAppBarItem(iconData: Icons.contacts_rounded, text: "Contacts"),
                  FABBottomAppBarItem(iconData: Icons.chat_rounded, text: "Chats"),
                  // FABBottomAppBarItem(iconData: Icons.rate_review_rounded, text: "Ratings"),
                  FABBottomAppBarItem(iconData: Icons.settings_rounded, text: "Settings"),
                ],
              )
          ),
        )
    );
  }
}
