import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real_world/Loader/color_loader_2.dart';
import 'package:real_world/Models/user_data.dart';
import 'package:real_world/Models/user_model.dart';
import 'package:real_world/Screens/ProfileScreen.dart';
import 'package:real_world/services/database_services.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State< SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  Future<QuerySnapshot> _users;
  Color appColor =Color(0xff68FE9A);
  Color bgColor =Color(0xFF24272C);
 
 



  // pageview index
  int selectedIndex = 0;


  _buildUserTile(User user) {
    return Container(
       margin: EdgeInsets.only(left:12,top: 12),
      child: ListTile(
        
        
      leading: CircleAvatar(
         
      
        radius: 20.0,
        backgroundImage: user.profileImageUrl.isEmpty
            ? AssetImage('assets/images/user_placeholder.jpg')
            : CachedNetworkImageProvider(user.profileImageUrl),
      ),
      title: Text(user.name,style: GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: appColor
                    )
                )),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(
            currentUserId: Provider.of<UserData>(context).currentUserId,
            userId: user.id,
          ),
        ),
      ),
      
    ),
    );
  }

  _clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      _users = null;
    });
  }
   @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: TextField(
          controller: _searchController,
          cursorColor: appColor,
           style: TextStyle(fontSize: 18.0,color: appColor,),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15.0),
            border: InputBorder.none,
            hintText: 'Search',focusColor: appColor,hoverColor: appColor, hintStyle: TextStyle(color:appColor,decorationColor: appColor),
            prefixIcon: Icon(
              Icons.search,color: appColor,
              size: 30.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,color: appColor,
              ),
              onPressed: _clearSearch,
            ),
            filled: true,
          ),
          onSubmitted: (input) {
            if (input.isNotEmpty) {
              setState(() {
                _users = DatabaseService.searchUsers(input);
              });
            }
          },
        ),
      ),
       body:
       _users == null
          ? Center(
              child: Text('Search for a user',style: GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: appColor,
                      fontSize: 18,
                    )
                )),
            )
          : FutureBuilder(
              future: _users,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
              
              child:ColorLoader2()
            );
                }
                if (snapshot.data.documents.length == 0) {
                  return Center(
                    child: Text('No users found! Please try again.',style: GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: appColor
                    )
                )),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  
                  itemBuilder: (BuildContext context, int index) {
                    User user = User.fromDoc(snapshot.data.documents[index]);
                    return _buildUserTile(user);
                  },
                  
                );
              },
            
    )
    );
       
         
    
           
      }
  
         
          
         


     
  }
  