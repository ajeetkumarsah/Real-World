
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_world/Models/user_data.dart';
import 'package:real_world/Screens/ActivityScreen.dart';
import 'package:real_world/Screens/CreatePostScreen.dart';
import 'package:real_world/Screens/FeedScreen.dart';
import 'package:real_world/Screens/ProfileScreen.dart';

import 'package:real_world/Screens/SearchScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    int _currentTab = 0;
  PageController _pageController;
  Color appColor =Color(0xff68FE9A);
  Color bgColor =Color(0xFF24272C);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
  }

  @override
  Widget build(BuildContext context) {
 
    final String currentUserId = Provider.of<UserData>(context).currentUserId;
    return Scaffold(
      backgroundColor: bgColor,
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          FeedScreen(currentUserId: currentUserId),
          SearchScreen(),
          CreatePostScreen(),
          ActivityScreen(currentUserId: currentUserId),
          ProfileScreen(
            currentUserId: currentUserId,
            userId: currentUserId,
          ),
        ],
       
        onPageChanged: (int index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        
        inactiveColor: Colors.white60,
        backgroundColor: Colors.black,
        currentIndex: _currentTab,
        onTap: (int index) {
          setState(() {
            _currentTab = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInCirc,
          );
        },
        
        activeColor: appColor,
        items: [
          
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              
              size: 24.0,
            ),
            
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 24.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 24.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_border,
              size: 24.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
              size: 24.0,
            ),
          ),
        ],
      ),


    );
  }
}