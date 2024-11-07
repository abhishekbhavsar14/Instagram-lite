import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_lite/user_follow_screen.dart';
import 'package:shimmer/shimmer.dart';

import 'Color.dart';

class FollwingScreen extends StatefulWidget {
  String? currentUserName;
   FollwingScreen({required this.currentUserName,super.key});

  @override
  State<FollwingScreen> createState() => _FollwingScreenState();
}

class _FollwingScreenState extends State<FollwingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar:AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF121212),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('following')
            .doc(widget.currentUserName)
            .collection('user_following')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "You are not following anyone.",
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var userDoc = snapshot.data!.docs[index];
                String username = userDoc['username'] ?? '';
                String name = userDoc['name'] ?? '';
                String profileImage = userDoc['user_pic'] ?? '';

                return ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: profileImage,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundImage: imageProvider,
                      radius: 25,
                    ),
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.account_circle, color: Colors.grey[700],size: 40,),
                    ),
                  ),
                  title: Text(
                    username,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    name,
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserFollowScreen(userProfileImage: profileImage, userName: username, name: name),));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
