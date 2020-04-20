import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:real_world/Models/comment_model.dart';
import 'package:real_world/Models/post_model.dart';
import 'package:real_world/Models/user_data.dart';
import 'package:real_world/Models/user_model.dart';
import 'package:real_world/services/database_services.dart';
import 'package:real_world/utilities/constants.dart';

class CommentsScreen extends StatefulWidget {
  final Post post;
  final int likeCount;

  CommentsScreen({this.post, this.likeCount});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isCommenting = false;
  Color appColor =Color(0xff68FE9A);
  Color bgColor =Color(0xFF24272C);

  _buildComment(Comment comment) {
    return FutureBuilder(
      future: DatabaseService.getUserWithId(comment.authorId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        User author = snapshot.data;
        return ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.white,
            backgroundImage: author.profileImageUrl.isEmpty
                ? AssetImage('assets/images/user_placeholder.jpg')
                : CachedNetworkImageProvider(author.profileImageUrl),
          ),
          title: Text(author.name,style: GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: appColor,
                      fontSize: 18,
                    )
                )),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(comment.content,style: GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: appColor,
                      fontSize: 14,
                    )
                )),
              SizedBox(height: 6.0),
              Text(
                DateFormat.yMd().add_jm().format(comment.timestamp.toDate()),style: GoogleFonts.alef(
                    textStyle:TextStyle(
                      color: appColor,
                      fontSize: 16,
                    )
                )
              ),
            ],
          ),
        );
      },
    );
  }

  _buildCommentTF() {
    final currentUserId = Provider.of<UserData>(context).currentUserId;
    return IconTheme(
      data: IconThemeData(
        color: _isCommenting
            ? Theme.of(context).accentColor
            : Theme.of(context).disabledColor,
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 10.0),
            Expanded(
              child: TextField(
                controller: _commentController,
                textCapitalization: TextCapitalization.sentences,
                style:GoogleFonts.righteous(
                   textStyle:TextStyle(color:appColor)),
                onChanged: (comment) {
                  setState(() {
                    _isCommenting = comment.length > 0;
                  });
                },
                decoration:
                    InputDecoration.collapsed(hintText: 'Write a comment...',hintStyle: GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: appColor,
                      fontSize: 16,
                    )
                ), ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send,color: appColor,),
                onPressed: () {
                  if (_isCommenting) {
                    DatabaseService.commentOnPost(
                      currentUserId: currentUserId,
                      post: widget.post,
                      comment: _commentController.text,
                    );
                    _commentController.clear();
                    setState(() {
                      _isCommenting = false;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
         
        title: Text(
          'Comments',
         style: GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: appColor,
                      fontSize: 18,
                    )
                )
        ),
        
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              '${widget.likeCount} likes',
              style: GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: appColor,
                      fontSize: 16,
                    )
                )
            ),
          ),
          StreamBuilder(
            stream: commentsRef
                .document(widget.post.id)
                .collection('postComments')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    Comment comment =
                        Comment.fromDoc(snapshot.data.documents[index]);
                    return _buildComment(comment);
                  },
                ),
              );
            },
          ),
          Divider(height: 10.0),
          _buildCommentTF(),
        ],
      ),
    );
  }
}
