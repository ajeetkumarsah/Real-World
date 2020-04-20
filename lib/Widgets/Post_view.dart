import 'dart:async';
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:real_world/Models/post_model.dart';
import 'package:real_world/Models/user_model.dart';
import 'package:real_world/Screens/ProfileScreen.dart';
import 'package:real_world/popUpMenu/Constants.dart';
import 'package:real_world/services/database_services.dart';
import 'package:real_world/Screens/CommentScreen.dart';




class PostView extends StatefulWidget {
  final String currentUserId;
  final Post post;
  final User author;

  PostView({this.currentUserId,this.post,this.author});

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  int _likeCount=0;
  

  bool _isLiked=false;
  bool _heartAnim =false;
  Color appColor =Color(0xff68FE9A);
  Color bgColor =Color(0xFF24272C);

  @override
  void initState() {
   
    super.initState();
    _likeCount=widget.post.likeCount;
    
    _initPostLiked();
  }

@override
void didUpdateWidget (PostView oldWidget) {
  super.didUpdateWidget(oldWidget);
  if(oldWidget.post.likeCount != widget.post.likeCount){
    _likeCount = widget.post.likeCount;
  }
  
}

  _initPostLiked() async {
    bool isLiked=await DatabaseService.didLikePost(
      currentUserId: widget.currentUserId,
      post: widget.post
    );
    if(mounted){
    setState(() {
      _isLiked=isLiked;
    });
    }
  }
  
_likePost(){
  if(_isLiked){
    DatabaseService.unlikePost(
      currentUserId: widget.currentUserId,post: widget.post
    );
    setState(() {
      _isLiked=false;
      _likeCount=_likeCount-1;
    });
  }else{
    DatabaseService.likePost(
      currentUserId: widget.currentUserId,post: widget.post
    );
    setState(() {
     _heartAnim=true;
      _isLiked=true;
      _likeCount=_likeCount+1;
    });
    Timer(Duration(milliseconds: 350),(){
        setState(() {
         _heartAnim=false;
        });
    });
  }
}




 void choiceAction(String choice){
    if(choice == Constants.Delete){
    
     print("deleted");
    }else if(choice == Constants.Report){
      print('Report');
    }
  }


  
  @override
  Widget build(BuildContext context) {
   

    return    
    Container(
      
         height:MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          
        ),
                      
                        margin:EdgeInsets.only(bottom: 50,left:1,right:1,top: 0),
                        child:Stack(
                         
                          children: <Widget>[
                          Positioned(
                            top: 0,
                            left: 94,
                            right: 5,
                            
                            child:Row(children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(widget.author.name, style: TextStyle(
                                    color:Colors.white,
                                    fontSize:14,
                                  ),
                                  ),
                                  Text(widget.author.bio, style: TextStyle(
                                    color:Colors.white.withOpacity(0.4),
                                    fontSize:12,
                                  ),
                                  ),


                              ],
                              ),
                              Spacer(),
                              
                              PopupMenuButton<String>(
                                 elevation: 25,
                              color: bgColor.withOpacity(0.9),
                                onSelected: choiceAction,
                                itemBuilder: (BuildContext context){
                                  return Constants.choices.map((String choice){
                                    return PopupMenuItem<String>(
                                      value: choice,
                                      child: Text(choice,style: TextStyle(color:appColor),),
                                    );
                                  }).toList();
                                },
                              )
                            
                            ],
                            )
                          ),
                          // 
                      GestureDetector(
                      onDoubleTap: _likePost,
                      child: Stack(
                        
                        children: <Widget>[
                           
                        Padding(
                           padding:EdgeInsets.symmetric(vertical:60.0,horizontal: 0),
                            
                           
                            
                            child: Container(
                            
                            height: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color:Colors.black,
                              borderRadius:BorderRadius.circular(1),
                               image: DecorationImage(
                                
                                image: CachedNetworkImageProvider(widget.post.imageUrl),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            
                            
                           
                           ),),
                      
                          
                          _heartAnim
                              ? Center(
                                child:Animator(
                                  duration: Duration(milliseconds: 300),
                                  tween: Tween(begin: 0.5, end: 1.4),
                                  curve: Curves.easeInOutSine,
                                  builder: (anim) => Transform.scale(
                                    scale: anim.value,
                                    child: Icon(
                                      Icons.favorite,
                                      size: 30.0,
                                      color: appColor,
                                    ),
                                  ),
                                ))
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                                  
                                  GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfileScreen(
                                        currentUserId: widget.currentUserId,
                                        userId: widget.post.authorId,
                                      ),
                                    ),
                                  ),
                                                        
                                  child: Container(
                                    margin: EdgeInsets.only(left:12),
                                    height: 62,
                                    width: 62,
                                    decoration: BoxDecoration(
                                      color:bgColor,
                                      shape:BoxShape.circle,
                                      border:Border.all(color: appColor,width:1.5),
                                      boxShadow: [
                                      BoxShadow(
                                        color: Colors.black45,
                                        offset: Offset(0, 12),
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                      
                                    ),
                                    child: CircleAvatar(
                                    radius: 25.0,
                                    backgroundColor: Colors.grey,
                                    backgroundImage: widget.author.profileImageUrl.isEmpty
                                        ? AssetImage('assets/images/user_placeholder.jpg')
                                        : CachedNetworkImageProvider(
                                            widget.author.profileImageUrl),
                                  
                                  ),

                                
                                    )
                                ),
                               
                                Positioned(
                                  left: 10,
                                  right: 10,
                                  bottom:-12,
                                  
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      
                                    Row(children: <Widget>[
                                          Text(widget.post.caption,style:TextStyle(color: Colors.white)),
                                    ]),
                                         
                                      
                                      
                                      
                                      Row(
                                        children: <Widget>[
                                          
                                        IconButton(
                                      icon: _isLiked
                                          ? Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                            )
                                          : Icon(Icons.favorite_border,color: appColor,),
                                      iconSize: 18,
                                      onPressed: _likePost,
                                    ),
                                   
                                          Text("$_likeCount  Likes",style: TextStyle(
                                            color:appColor,
                                            fontWeight:FontWeight.bold,
                                            fontSize:12,
                                          ),),
                                    SizedBox(width:6),
                                    IconButton(
                                      icon: Icon(Icons.chat_bubble_outline,color:Colors.white),
                                      iconSize: 18.0,
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CommentsScreen(
                                            post: widget.post,
                                            likeCount: _likeCount,
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                          Text("Comments",style: TextStyle(
                                            color:Colors.white,
                                            fontWeight:FontWeight.bold,
                                            fontSize:12,
                                          ),),
                                          Spacer(),

                                            Row(children: <Widget>[
                                          Text('timestamp',
                                          style: TextStyle(
                                            color:Colors.white.withOpacity(0.2),
                                            fontSize:12,
                                            fontWeight:FontWeight.bold,
                                          ),),
                                    ]),
                                          // Text(widget.post.timestamp,
                                          // style: TextStyle(
                                          //   color:Colors.white.withOpacity(0.2),
                                          //   fontSize:12,
                                          //   fontWeight:FontWeight.bold,
                                          // ),
                                          // ),
                                  ],
                                      ),
                                      
                                      

                                    ],
                                    ),
                                    
                                    ),
                                     
                              ],
                              ) ,

                  
              
              
      );
       
          
    
         
  }
}
