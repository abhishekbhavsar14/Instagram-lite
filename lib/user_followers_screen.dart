import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_lite/user_follow_screen.dart';
import 'package:shimmer/shimmer.dart';

import 'Color.dart';

class FollowersScreen extends StatefulWidget {
  final String currentUserName;
  const FollowersScreen({required this.currentUserName, super.key});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF121212),
        title: const Text("Followers", style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('follow')
            .doc(widget.currentUserName)
            .collection('user_followers')
            .orderBy('username', descending: true) // Sort by 'username' in descending order
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "You have no followers.",
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
                      child: const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.account_circle, color: Colors.grey, size: 40),
                    ),
                  ),
                  title: Text(
                    username,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    name,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserFollowScreen(
                          userProfileImage: profileImage,
                          userName: username,
                          name: name,
                        ),
                      ),
                    );
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
