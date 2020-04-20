import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:real_world/Models/post_model.dart';
import 'package:real_world/Models/user_data.dart';
import 'package:real_world/services/database_services.dart';
import 'package:real_world/services/storage_services.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  Color appColor =Color(0xff68FE9A);
  Color bgColor =Color(0xFF24272C);

  File _image;
  TextEditingController _captionController = TextEditingController();
  String _caption = '';
  bool _isLoading = false;

  _showSelectImageDialog() {
    return Platform.isIOS ? _iosBottomSheet() : _androidDialog();
  }

  _iosBottomSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Add Photo'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text('Take Photo'),
              onPressed: () => _handleImage(ImageSource.camera),
            ),
            CupertinoActionSheetAction(
              child: Text('Choose From Gallery'),
              onPressed: () => _handleImage(ImageSource.gallery),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  _androidDialog() {
    showCupertinoModalPopup(
      
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          
          title: Text('Add Photo',),
          actions: <Widget>[
            CupertinoActionSheetAction(
              
              child: Text('Take Photo',style: TextStyle(color:Colors.black),),
              onPressed: () => _handleImage(ImageSource.camera),
            ),
            CupertinoActionSheetAction(
              child: Text('Choose From Gallery',style: TextStyle(color:Colors.black),),
              onPressed: () => _handleImage(ImageSource.gallery),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('Cancel',style: TextStyle(color:appColor,),),
            onPressed: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  _handleImage(ImageSource source) async {
    

    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: source);
    if (imageFile != null) {
      setState(() {
        _image = imageFile;
      });
      
    }
  
    
  }

 /* _cropImage(File imageFile) async {
    try{
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );
    return croppedImage;
    }catch(e){
      print(e);
    }
  }*/

  _submit() async {
    try{
    if (!_isLoading && _image != null && _caption.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      // Create post
      String imageUrl = await StorageService.uploadPost(_image);
      Post post = Post(
        imageUrl: imageUrl,
        caption: _caption,
        likeCount: 0,
        authorId: Provider.of<UserData>(context).currentUserId,
        timestamp: Timestamp.fromDate(DateTime.now()),
      );
      DatabaseService.createPost(post);

      // Reset data
      _captionController.clear();

      setState(() {
        _caption = '';
        _image = null;
        _isLoading = false;
      });
    }
    }catch(e){
      print(e);
    }
  }








  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor:bgColor,
        centerTitle: true,
        title: Text(
          'Create Post',
          style: GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: appColor
                    )
                )
        ),
      actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add,color: appColor,),
            onPressed: _submit,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            height: height,
            child: Column(
              children: <Widget>[
                _isLoading
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.blue[200],
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
                        ),
                      )
                    : SizedBox.shrink(),
                GestureDetector(
                  onTap: _showSelectImageDialog,
                  child: Container(
                    height: width,
                    width: width,
                    color: appColor.withOpacity(0.4),
                    child: _image == null
                        ? Icon(
                            Icons.add_a_photo,
                            color: bgColor,
                            size: 150.0,
                          )
                        : Image(
                            image: FileImage(_image),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 30),
                  child:Form(
                    key: _formKey,
                     child:TextFormField(
                    cursorColor: appColor,
                   
                    controller: _captionController,
                    style: TextStyle(fontSize: 20.0,color: appColor,),
                    decoration: InputDecoration(
                     enabledBorder:OutlineInputBorder(
                          borderSide:BorderSide(color: Colors.black,)
                        ) ,
                        focusedBorder: OutlineInputBorder(
                          borderSide:BorderSide(color:appColor)),
                      hoverColor: appColor,fillColor: Colors.white,focusColor: appColor,
                      labelText: 'Descriptions',labelStyle: TextStyle(color:appColor,fontSize:18),
                    ),
                    validator: (input) => input.trim().length > 40
                          ? 'Please enter a bio less than 40 characters'
                          : null,
                    onChanged: (input) => _caption = input,
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
      
    );
  }
}