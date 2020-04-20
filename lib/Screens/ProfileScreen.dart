import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real_world/Loader/color_loader_3.dart';
import 'package:real_world/Models/post_model.dart';
import 'package:real_world/Models/user_data.dart';
import 'package:real_world/Models/user_model.dart';
import 'package:real_world/Screens/CommentScreen.dart';
import 'package:real_world/Screens/EditProfileScreen.dart';
import 'package:real_world/Widgets/Post_view.dart';
import 'package:real_world/services/database_services.dart';
import 'package:real_world/utilities/constants.dart';

class ProfileScreen extends StatefulWidget {

  final String currentUserId;
  final String userId;
 
  ProfileScreen({this.currentUserId, this.userId,Key key}): super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin{
  TabController _tabController;
  Color appColor =Color(0xff68FE9A);
  Color bgColor =Color(0xFF24272C);

  
  bool _isFollowing = false;
  int _followerCount = 0;
  int _followingCount = 0;
  List<Post> _posts = [];
  int _displayPosts = 0;
  User _profileUser;

  
  @override
  void initState() {
    super.initState();
    _tabController= TabController(length: 3, vsync: this);
    _setupIsFollowing();
    _setupFollowers();
    _setupFollowing();
    _setupPosts();
    _setupProfileUser();
  }

  _setupIsFollowing() async {
    bool isFollowingUser = await DatabaseService.isFollowingUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );
    setState(() {
      _isFollowing = isFollowingUser;
    });
  }

  _setupFollowers() async {
    int userFollowerCount = await DatabaseService.numFollowers(widget.userId);
    setState(() {
      _followerCount = userFollowerCount;
    });
  }

  _setupFollowing() async {
    int userFollowingCount = await DatabaseService.numFollowing(widget.userId);
    setState(() {
      _followingCount = userFollowingCount;
    });
  }

 _setupPosts() async {
    List<Post> posts = await DatabaseService.getUserPosts(widget.userId);
    setState(() {
      _posts = posts;
    });
  }

  _followOrUnfollow() {
    if (_isFollowing) {
      _unfollowUser();
    } else {
      _followUser();
    }
  }

  _unfollowUser() {
    DatabaseService.unfollowUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );
    setState(() {
      _isFollowing = false;
      _followerCount--;
    });
  }

 _setupProfileUser() async {
    User profileUser = await DatabaseService.getUserWithId(widget.userId);
    setState(() {
      _profileUser = profileUser;
    });
  }

  _followUser() {
    DatabaseService.followUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );
    setState(() {
      _isFollowing = true;
      _followerCount++;
    });
  }
  _displayButton(User user) {
    return user.id == Provider.of<UserData>(context).currentUserId
        ? Container(
             height: 28,
                    width: 110,
                    decoration: BoxDecoration(
                      color: appColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
            child: FlatButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    user: user,
                  ),
                ),
              ),
             
              textColor: Colors.black,
              child: Text(
                'Edit Profile',
                style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold),
              ),
            ),
          )
        : Container(
            height: 38,
                    width: 160,
                    decoration: BoxDecoration(
                      color: appColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
            child: FlatButton(
              onPressed: _followOrUnfollow,
              
              child: Text(
                _isFollowing ? 'Unfollow' : 'Follow',
                style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold),
              ),
            ),
          );
  }


_buildProfileInfo(User user) {
    return Scaffold(
      backgroundColor: bgColor,
       body: SingleChildScrollView(
            
            child: Container(
          padding: EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0),
         child:  Stack(
      children: <Widget>[
         Container(
           height: MediaQuery.of(context).size.height,
         ) ,
     
        Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: MediaQuery.of(context).size.height/1.9,
            child: Container(
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
                  image: CachedNetworkImageProvider(user.profileImageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode( Colors.black.withOpacity(0.2), BlendMode.darken)
                )
              ),
             
                child:Padding(
                  
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child:Column(

                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                      GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(left:1.0,top:0),
                        decoration: BoxDecoration(
                                      color:bgColor,
                                      shape:BoxShape.circle,
                                      border:Border.all(color: appColor,width:2.5),
                                      boxShadow: [
                                      BoxShadow(
                                        color: Colors.black45,
                                        offset: Offset(0, 12),
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                      
                                    ),
                        child:Center(
                          child:CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(user.profileImageUrl),
                      )),
                      
                      ),
                      
                ),
                    ],),
                    
                     
                          
                               
                

                // Text("Pro", style: GoogleFonts.righteous(
                //     textStyle:TextStyle(
                //       color: appColor
                //     )
                // )),
                SizedBox(height:10),
                Text(user.name, style: GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2
                    )
                )
                ),
               
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    
                Text(user.bio,style: GoogleFonts.yeonSung(
                    textStyle:TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2
                    )
                )
                ),
                
                  ],
                ),
                SizedBox(height:12,),
                Row(children: <Widget>[
                  
                  _displayButton( user),
                  SizedBox(width: 8.0,),
                  Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      shape: BoxShape.circle, 
                      color: Colors.black,
                    ),
                    child: Center(
                      child: Icon(Icons.more_vert,color:appColor,size: 18,),
                    ),
                  ),
                ],),
                
                SizedBox(height: 12,),

                

                ],),
                
              ),
            
            ),

          ),
          Positioned(
            left: 0,
            right: 0,
            top:  MediaQuery.of(context).size.height/2.11,
            
            child:Container(
              height: 80,
              color: Colors.black,
           child: Padding(
             padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(_followerCount.toString(),style:GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 2,
                      )
                  )),Text("Followers",style:GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: appColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,letterSpacing: 2,
                      )
                  ))
                ],
              ),Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(_followingCount.toString(),style:GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 2,
                      )
                  )),Text("Following",style:GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: appColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,letterSpacing: 2,
                      )
                  ))
                ],
              ),Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text( _posts.length.toString(),style:GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 2,
                      )
                  )),Text("Posts",style:GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: appColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,letterSpacing: 2,
                      )
                  ))
                ],
              )
            ],
            )
            )
            ),
          ),



        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top:  MediaQuery.of(context).size.height/1.7,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child:Container(
                    color: Color(0xff1c1f24),
                    child: TabBar(
                      controller:  _tabController,
                      indicatorColor: appColor,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: 1,
                      tabs: <Widget>[
                        Tab(
                          text: "Posts",
                        ),
                        Tab(
                          text: "Images",
                        ),
                        Tab(
                          text: "Videos",
                        )
                      ],
                    ),
                  )
                ),
                Expanded(
                  flex: 15,
                  child:Container(
                    child: TabBarView(
                      controller: _tabController,
                      
                      children: <Widget>[
                        _buildDisplayPosts() ,
                        _buildDisplayPosts() ,
                        _buildDisplayPosts() ,
                        
                     
                        
                      ],
                    ),
                  )
                )
              ],
            ),
          ),

        
    





      ],
    ))));
  }

   
_buildTilePost(Post post) {
    return GridTile(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommentsScreen(
              post: post,
              likeCount: post.likeCount,
            ),
          ),
        ),
        child: Image(
          image: CachedNetworkImageProvider(post.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

 _buildDisplayPosts() {
    if (_displayPosts == 0) {
      // Grid
      List<GridTile> tiles = [];
      _posts.forEach(
        (post) => tiles.add(_buildTilePost(post)),
      );
      return GridView.count(
        padding: EdgeInsets.only(left: 16,right: 16,top: 16),
         mainAxisSpacing: 8,
         crossAxisSpacing: 8,
         crossAxisCount: 3,
        shrinkWrap: true,
        physics:ScrollPhysics(),
        children: tiles,
      );
    } else {
      // Column
      List<PostView> postViews = [];
      _posts.forEach((post) {
        postViews.add(
          PostView(
            currentUserId: widget.currentUserId,
            post: post,
            author: _profileUser,
          ),
        );
      });
      return Column(children: postViews);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body:FutureBuilder(
        future: usersRef.document(widget.userId).
        get(),
        builder: (BuildContext context,AsyncSnapshot snapshot){
          if(!snapshot.hasData){
            return Center(
              
              child: ColorLoader3(),
            );
          }
          User user = User.fromDoc(snapshot.data);
         return 
          
          _buildProfileInfo(user);
          

          
        
         
        }
      ) 
      
    );
     
  }
}