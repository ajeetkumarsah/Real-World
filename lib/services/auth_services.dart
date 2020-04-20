import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_world/Models/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = Firestore.instance;
  
  static void signUpUser(
    
      BuildContext context, String name, String email, String password) async {
        
    try {      
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseUser signedInUser = authResult.user;
      SharedPreferences prefs;
       
      if (signedInUser != null) {
        _firestore.collection('/users').document(signedInUser.uid).setData({
          'name': name,
          'email': email,
          'profileImageUrl':'',
          'id': signedInUser.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null
        }
        );      
       
        await prefs.setString('id', signedInUser.uid);
        await prefs.setString('name', signedInUser.displayName);
        await prefs.setString('profileImageUrl', signedInUser.photoUrl);
        Provider.of<UserData>(context).currentUserId = signedInUser.uid;
        Navigator.pop(context);
        
      }else {
        final QuerySnapshot result =
          await Firestore.instance.collection('/users').where('id', isEqualTo: signedInUser.uid).getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
        // Write data to local
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('name', documents[0]['name']);
        await prefs.setString('profileImageUrl', documents[0]['profileImageUrl']);
        await prefs.setString('bio', documents[0]['bio']);
      }
    } catch (e) {
      print(e);
    }
  }



  static void logout() {
    _auth.signOut();
  }

  static void login(String email, String password) async {
    try {
     await _auth.signInWithEmailAndPassword(email: email, password: password);
   
    } catch (e) {
      print(e);
    }
  }
}