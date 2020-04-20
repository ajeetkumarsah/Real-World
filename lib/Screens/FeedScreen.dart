import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real_world/Chat/main.dart';
import 'package:real_world/Models/post_model.dart';
import 'package:real_world/Models/user_data.dart';
import 'package:real_world/Models/user_model.dart';
import 'package:real_world/Widgets/Post_view.dart';
import 'package:real_world/services/auth_services.dart';
import 'package:real_world/services/database_services.dart';
import 'package:shared_preferences/shared_preferences.dart';



class FeedScreen extends StatefulWidget {
  static final String id = 'feed_screen';
  final String currentUserId;

  FeedScreen({this.currentUserId});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  Color appColor =Color(0xff68FE9A);
  Color bgColor =Color(0xFF24272C);
  List<Post> _posts = [];
  bool isLoading = false;
  bool isLoggedIn = false;
  SharedPreferences prefs;



  @override
  void initState() {
    super.initState();
    _setupFeed();
  }

  _setupFeed() async {
    List<Post> posts = await DatabaseService.getFeedPosts(widget.currentUserId);
    setState(() {
      _posts = posts;
    });
  }

showAlertDialog(BuildContext context) {

  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel",style: TextStyle(color:appColor),),
    onPressed:  () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = FlatButton(
    child: Text("Logout",style: TextStyle(color:Colors.red),),
    onPressed:  () {
      AuthService.logout();
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: bgColor,
    title: Text("Real World",style: TextStyle(color:appColor),),
    content: Text("Do you want to logout?",style: TextStyle(color:Colors.white),),
    actions: [
      cancelButton,
      continueButton,
    ],
    elevation: 100,
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
void isSignedIn() async {
    

    prefs = await SharedPreferences.getInstance();

    
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(currentUserId: prefs.getString('id'))),
      );
    

    
  }
  @override
  Widget build(BuildContext context) {
   
    final String currentUserId = Provider.of<UserData>(context).currentUserId;

    return Scaffold(
      backgroundColor:bgColor,
     
      body: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
         
          Container(
        height: 5000,
      ),
         
            
          
          Positioned(
            left: 0,
            right:0,
            top: 0,
            
            child: Container(
              padding:EdgeInsets.only(left: 16,right: 16,bottom: 22,top: 10) ,
              height: MediaQuery.of(context).size.height / 11,
              decoration: BoxDecoration(
                color:Colors.black,
              ),
              child: 
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 3,
                      width: 42,
                      decoration: BoxDecoration(color: Colors.white),
                    ),
                    SizedBox(height: 8,),
                    Container(
                      height: 2,
                      width: 42,
                      decoration: BoxDecoration(color: Colors.white),
                    ),
                   
                  ],
                ),
                RichText(
                  text: TextSpan(
                    children: [
                    TextSpan(text: "Real",style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: appColor,
                  )),
                  TextSpan(text: " World",style: GoogleFonts.righteous(
                    textStyle:TextStyle(
                      fontWeight: FontWeight.bold,
                       fontSize: 20,
                      color: Colors.white,
                    )
                )),
                    ],
                    
                  )
                ),
                IconButton(icon:Icon(Icons.exit_to_app,color:Colors.white,size: 18,), 
                onPressed: () {
                  
                  showAlertDialog(context);
                },),
                 IconButton(icon:Icon(Icons.send,color:Colors.white,size: 18,), 
                onPressed: () {
                  
                 
                  isSignedIn();
                  
                },)
              ],),
              
            )
            
          ),
          // Positioned(
          //   left: 0,
          //   right:0,
          //   top: MediaQuery.of(context).size.height / 8.5,
          //   child: Container(
          //     height: MediaQuery.of(context).size.height / 12,

          //     decoration: BoxDecoration(
          //       color: Colors.black,
          //     ),
          //     padding: EdgeInsets.only(bottom:12,left:24,top:4),
          //     child: ListView(
          //       scrollDirection: Axis.horizontal,
          //       children: <Widget>[
          //         DottedBorder(
          //           padding: EdgeInsets.all(8),
          //           dashPattern: [4],
          //           borderType:BorderType.Circle,                  
          //           color: appColor,
          //           child: Container(
                      
          //             width: 64,
          //             child: Center(
          //               child: Icon(Icons.add,color:Colors.white,size: 28,),
          //             ),
                      
          //           ),
          //         ),
          //         SizedBox(width: 16,),
          //         Container(
          //           width: 80,
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             shape: BoxShape.circle,
          //             border: Border.all(color: appColor,width: 1.5),
          //             image:DecorationImage(
          //             image: NetworkImage(""),
          //             fit: BoxFit.fill
          //           )),
          //         ),
                 
          //       ],
          //     ),
          //   )
          // ),
          Positioned(
            left: 0,
            right:0,
            top: (MediaQuery.of(context).size.height / 10.9),
            bottom: 0,
            child: Container(
              

             child:Column(
               children: <Widget>[
                 
                 Expanded(
                   
                   child:Container(

        
       
                          child: ListView.builder(
                            itemCount: _posts.length,
                            itemBuilder: (BuildContext context, int index) {
                              Post post = _posts[index];
                              return FutureBuilder(
                                future: DatabaseService.getUserWithId(post.authorId),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                  if (!snapshot.hasData) {
                                    return SizedBox.shrink();
                                  }
                                  User author = snapshot.data;
                                  return PostView(
                                    currentUserId: widget.currentUserId,
                                    post: post,
                                    author: author,
                                  );
                                },
                              );
                            },
                          ),
      
                   ),
                 )]
               )
            ),
          )
          
          
          
          ]
      ),
      
     
    );
  }
}
