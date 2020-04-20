import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real_world/Models/user_model.dart';
import 'package:real_world/services/database_services.dart';
import 'package:real_world/services/storage_services.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  EditProfileScreen({this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  File _profileImage;
  String _name = '';
  String _bio = '';
  bool _isLoading = false;
  Color appColor =Color(0xff68FE9A);
  Color bgColor =Color(0xFF24272C);

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _bio = widget.user.bio;
  }

  _handleImageFromGallery() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _profileImage = imageFile;
      });
    }
  }

  _displayProfileImage() {
    // No new profile image
    if (_profileImage == null) {
      // No existing profile image
      if (widget.user.profileImageUrl.isEmpty) {
        // Display placeholder
        return AssetImage('assets/images/user_placeholder.jpg');
      } else {
        // User profile image exists
        return CachedNetworkImageProvider(widget.user.profileImageUrl);
      }
    } else {
      // New profile image
      return FileImage(_profileImage);
    }
  }

  _submit() async {
    if (_formKey.currentState.validate() && !_isLoading) {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      // Update user in database
      String _profileImageUrl = '';

      if (_profileImage == null) {
        _profileImageUrl = widget.user.profileImageUrl;
      } else {
        _profileImageUrl = await StorageService.uploadUserProfileImage(
          widget.user.profileImageUrl,
          _profileImage,
        );
      }

      User user = User(
        id: widget.user.id,
        name: _name,
        profileImageUrl: _profileImageUrl,
        bio: _bio,
      );
      // Database update
      DatabaseService.updateUser(user);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text(
          'Edit Profile',
         style: GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: appColor,
                      fontSize: 18,
                    )
                )
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          children: <Widget>[
            _isLoading
                ? LinearProgressIndicator(
                    backgroundColor: Colors.blue[200],
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  )
                : SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap:_handleImageFromGallery,
                    child:
                    
                    Container(
                      
                      height: 500,
                    

              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.black.withOpacity(0.8),
                   Colors.black.withOpacity(0.4)
                ],
                
                begin: Alignment.bottomCenter,
                end:Alignment.topCenter,
                stops: [0,1] 
                ),
                
                image: DecorationImage(
                  image: _displayProfileImage(),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode( Colors.black.withOpacity(0.2), BlendMode.darken)
                )
              ),
              // child: SafeArea(
                
              //   top: true,
              //   child:Padding(

              //   padding: const EdgeInsets.symmetric(horizontal: 150,vertical: 150),
              //   child:GestureDetector(
              //         child: Container(
              //           decoration: BoxDecoration(
              //                         color:bgColor,
              //                         shape:BoxShape.circle,
              //                         border:Border.all(color: appColor,width:2.5),
              //                         boxShadow: [
              //                         BoxShadow(
              //                           color: Colors.black45,
              //                           offset: Offset(0, 12),
              //                           blurRadius: 6.0,
              //                         ),
              //                       ],
                                      
              //                       ),
              //         //   child:Center(
              //         //     child:CircleAvatar(
              //         // radius: 95.0,
              //         // backgroundColor: Colors.grey,
              //         // backgroundImage: _displayProfileImage())),
              //         ),
              //   )
              //   ),
              //    ),
                    )
                    ),
                    
                    SizedBox(height:20),
                    TextFormField(
                      style:GoogleFonts.righteous(
                   textStyle:TextStyle(color:appColor,fontSize: 18.0)),
                      initialValue: _name,
                        decoration: InputDecoration(
                        enabledBorder:OutlineInputBorder(
                          borderSide:BorderSide(color:Colors.black)
                        ) ,
                        focusedBorder: OutlineInputBorder(
                          borderSide:BorderSide(color:appColor)),
                        labelStyle: TextStyle(color:appColor),
                        icon: Icon(
                          Icons.person,
                          size: 20.0,
                          color: appColor,
                        ),
                        labelText: 'Name',hintStyle: GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: appColor,
                      fontSize: 18,
                    )
                )
                      ),
                      validator: (input) => input.trim().length < 1
                          ? 'Please enter a valid name'
                          : null,
                      onSaved: (input) => _name = input,
                    ),
                    SizedBox(height:20),
                    TextFormField(
                      

                      cursorColor: appColor,
                      style:GoogleFonts.righteous(
                   textStyle:TextStyle(color:appColor,fontSize: 18.0)),
                      initialValue: _bio,
                     
                      decoration: InputDecoration(
                        enabledBorder:OutlineInputBorder(
                          borderSide:BorderSide(color:Colors.black)
                        ) ,
                        focusedBorder: OutlineInputBorder(
                          borderSide:BorderSide(color:appColor)),
                        hintStyle:TextStyle(
                      color: appColor,
                      fontSize: 16,
                    ),
                        labelStyle: TextStyle(color:appColor),
                        fillColor: appColor,
                        icon: Icon(
                          Icons.book,
                          size: 20.0,
                          color: appColor,
                        ),
                        labelText: 'Bio',
                      ),
                      validator: (input) => input.trim().length > 40
                          ? 'Please enter a bio less than 40 characters'
                          : null,
                      onSaved: (input) => _bio = input,
                    ),
                    Container(
                      decoration: BoxDecoration(
                      color: appColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                      margin: EdgeInsets.all(40.0),
                      height: 40.0,
                      width: 250.0,
                      child: FlatButton(
                        onPressed: _submit,
                        
                        textColor: Colors.white,
                        child: Text(
                          'Save Profile',
                          style: GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: bgColor,
                      fontSize: 18,
                    )
                )
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
