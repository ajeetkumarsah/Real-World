import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:real_world/Models/activity_model.dart';
import 'package:real_world/Models/post_model.dart';
import 'package:real_world/Models/user_data.dart';
import 'package:real_world/Models/user_model.dart';
import 'package:real_world/Screens/CommentScreen.dart';
import 'package:real_world/services/database_services.dart';

class ActivityScreen extends StatefulWidget {
  final String currentUserId;

  ActivityScreen({this.currentUserId});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<Activity> _activities = [];
 Color appColor =Color(0xff68FE9A);
  Color bgColor =Color(0xFF24272C);

  @override
  void initState() {
    super.initState();
    _setupActivities();
  }

  _setupActivities() async {
    List<Activity> activities =
        await DatabaseService.getActivities(widget.currentUserId);
    if (mounted) {
      setState(() {
        _activities = activities;
      });
    }
  }

    _buildActivity(Activity activity) {
    return FutureBuilder(
      future: DatabaseService.getUserWithId(activity.fromUserId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        User user = snapshot.data;
        return ListTile(
          leading: CircleAvatar(
            radius: 20.0,
            backgroundColor: Colors.grey,
            backgroundImage: user.profileImageUrl.isEmpty
                ? AssetImage('assets/images/user_placeholder.jpg')
                : CachedNetworkImageProvider(user.profileImageUrl),
          ),
          title: activity.comment != null
              ? Text('${user.name} commented: "${activity.comment}"')
              : Text('${user.name} liked your post'),
          subtitle: Text(
            DateFormat.yMd().add_jm().format(activity.timestamp.toDate()),
          ),
          trailing: CachedNetworkImage(
            imageUrl: activity.postImageUrl,
            height: 40.0,
            width: 40.0,
            fit: BoxFit.cover,
          ),
          onTap: () async {
            String currentUserId = Provider.of<UserData>(context).currentUserId;
            Post post = await DatabaseService.getUserPost(
              currentUserId,
              activity.postId,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommentsScreen(
                  post: post,
                  likeCount: post.likeCount,
                ),
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: GoogleFonts.righteous(
                    textStyle:TextStyle(
                      color: appColor
                    )
                )
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _setupActivities(),
        child: ListView.builder(
          itemCount: _activities.length,
          itemBuilder: (BuildContext context, int index) {
            Activity activity = _activities[index];
            return _buildActivity(activity);
          },
        ),
      ),
    );
  }
}
