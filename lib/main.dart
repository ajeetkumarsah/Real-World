import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_world/Models/user_data.dart';
import 'package:real_world/Screens/FeedScreen.dart';
import 'package:real_world/Screens/HomeScreen.dart';
import 'package:real_world/Screens/LoginScreen.dart';
import 'package:real_world/Screens/SignupScreen.dart';
import 'package:flutter/services.dart' ;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  

  Widget _getScreenId() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          Provider.of<UserData>(context).currentUserId = snapshot.data.uid;
          return HomeScreen();
        } else if(snapshot.hasError){
          return Center(
              child: CircularProgressIndicator(),
            );
        }else {
          return LoginPage();
        }
      },
    );
  }

  // This widget is the root of your application.
  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    return ChangeNotifierProvider(
      create: (context) => UserData(),
      child: MaterialApp(
        title: 'Real World',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryIconTheme: Theme.of(context).primaryIconTheme.copyWith(
                color: Colors.black,
              ),
        ),
        home: _getScreenId(),
        routes: {
          LoginPage.id: (context) => LoginPage(),
          SignUp.id: (context) => SignUp(),
          FeedScreen.id: (context) => FeedScreen(),
        },
      ),
    );
  }
}


