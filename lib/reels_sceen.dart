import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_lite/user_follow_screen.dart';
import 'package:shimmer/shimmer.dart';

import 'Color.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<ReelsScreen> {
  var currentUserEmail;
  var currentUserName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('post_photos')
              .orderBy('timestamp', descending: true) // Fetch in descending order
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: MyColor.blue,));
            } else if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No posts found'));
            } else {
              List<DocumentSnapshot> list = snapshot.data!.docs;

              return PageView.builder(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final _userData = list[index].data() as Map<String, dynamic>;
                  String userName = _userData['username'];
                  String imageUrl = _userData['image'];
                  String currentUserImage = _userData['userimage'] ?? '';
                  String caption = _userData['caption'] ?? '';
                  int likes = _userData['likes'] ?? 0;
                  List likedBy = _userData['likedBy'] ?? [];
                  var name = _userData['name'] ?? '';

                   currentUserEmail = FirebaseAuth.instance.currentUser!.email;
                  getUserName();
                  return Stack(
                    children: [
                      // Full-screen image (replace with VideoPlayer for video content)
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: MediaQuery.of(context).size.height,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: double.infinity,
                            color: Colors.grey[300],
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            Center(child: Text('Please check you internet connection',style: GoogleFonts.roboto(color: Colors.white),)),
                      ),

                      Positioned(
                        bottom: 40,
                        left: 10,
                        right: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [

                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    var postRef = FirebaseFirestore.instance
                                        .collection('post_photos')
                                        .doc(list[index].id);

                                    var postSnapshot = await postRef.get();
                                    var postData = postSnapshot.data() as Map<String, dynamic>;
                                    List likedBy = postData['likedBy'] ?? [];

                                    if (!likedBy.contains(currentUserEmail)) {
                                      likedBy.add(currentUserEmail);

                                      await postRef.update({
                                        'likes': FieldValue.increment(1),
                                        'likedBy': likedBy,
                                      });
                                    } else {
                                      likedBy.remove(currentUserEmail);
                                      await postRef.update({
                                        'likes': FieldValue.increment(-1),
                                        'likedBy': likedBy,
                                      });
                                    }
                                  },
                                  child: likedBy.contains(currentUserEmail)
                                      ? Icon(Icons.favorite, size: 25, color: Colors.red)
                                      : Icon(Icons.favorite_border,
                                      size: 25, color: Colors.white),
                                ),
                                Text(
                                  '${likes}',
                                  style: GoogleFonts.roboto(
                                      fontSize: 16, color: Colors.white),
                                ),
                                SizedBox(width: 5),
                                IconButton(
                                  onPressed: () {
                                    showBottomSheet(list[index].id);
                                  },
                                  icon: Icon(Icons.message, color: Colors.white),
                                ),
                              ],
                            ),
                            ListTile(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => UserFollowScreen(userProfileImage: currentUserImage, userName: userName, name: name),));
                              },
                              leading: CachedNetworkImage(
                                imageUrl: currentUserImage,
                                imageBuilder: (context, imageProvider) =>
                                    CircleAvatar(
                                      backgroundImage: imageProvider,
                                    ),
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[300],
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.account_circle_rounded,
                                        size: 40,
                                        color: Colors.black38,
                                      ),
                                    ),
                              ),
                              title: Text(
                                userName,
                                style: GoogleFonts.roboto(color: Colors.white),
                              ),
                            ),
                            // Caption
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 13),
                              child: Align(
                                alignment: AlignmentDirectional.bottomStart,
                                child: Text(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  caption,
                                  style: GoogleFonts.roboto(color: Colors.white),
                                ),
                              ),
                            ),

                            // Timestamp
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      )
      ,
    );
  }
  void showBottomSheet(String imageId) async {
    final _comment = TextEditingController();
    var user = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    var information = user.data() as Map<String, dynamic>;
    showModalBottomSheet(
      context: context,
      isScrollControlled:
      true, // This allows the bottom sheet to be resized for the keyboard
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // Adjusts for the keyboard height
          ),
          child: Container(
            color: Colors.grey[300],
            child: Column(
              mainAxisSize:
              MainAxisSize.min, // Dynamically adjusts to content height
              children: [
                // Header for comments
                SizedBox(
                  height: 40,
                ),
                Center(
                  child: Text(
                    'Comments',
                    style: GoogleFonts.roboto(fontSize: 20),
                  ),
                ),
                Center(
                  child: Container(
                    height: 2,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.black38,
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Comments List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('user_comments')
                        .doc(imageId)
                        .collection('comments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator(
                              color: MyColor.blue,
                            ));
                      } else if (snapshot.hasError) {
                        return Center(child: Text('${snapshot.error}'));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No comments yet'));
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            List<DocumentSnapshot> list = snapshot.data!.docs;
                            var _user = list[index].data() as Map<String, dynamic>;
                            var name = _user['name'] ?? '';
                            var image = _user['user_pic'] ?? 'https://cdn-icons-png.flaticon.com/128/3033/3033143.png';
                            return GestureDetector(
                              onLongPress: () {
                                if (user['username'] == _user['username']) {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                          content: InkWell(
                                            child: Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Delete',
                                                    style: GoogleFonts.roboto(
                                                        fontSize: 18),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                          'user_comments')
                                                          .doc(imageId)
                                                          .collection(
                                                          'comments')
                                                          .doc(list[index].id)
                                                          .delete()
                                                          .then((_) {
                                                        print(
                                                            'Comment deleted successfully');
                                                      }).catchError((error) {
                                                        print(
                                                            'Failed to delete comment: $error');
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.delete,
                                                      color:
                                                      Colors.red.shade700,
                                                      size: 26,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )));
                                }
                              },
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserFollowScreen(userProfileImage: image, userName: _user['username'], name: name),));
                                },
                                leading: CachedNetworkImage(
                                  imageUrl: image!,
                                  imageBuilder: (context, imageProvider) =>
                                      CircleAvatar(
                                        backgroundImage: imageProvider,
                                      ),
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.grey[300],
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      CircleAvatar(
                                        backgroundColor: Colors.grey[300],
                                        child: Icon(
                                          Icons.account_circle_rounded,
                                          size: 50,
                                          color: Colors.black38,
                                        ),
                                      ),
                                ),
                                title: Text(_user['username']),
                                subtitle: Text(_user['comment']),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),

                // Comment Input Area
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextField(
                            controller: _comment,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black26),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black26),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              hintText: 'Type a comment...',
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('user_comments')
                              .doc(imageId)
                              .collection('comments')
                              .add({
                            'comment': _comment.text.toString(),
                            'name' :information['name'],
                            'username': information['username'],
                            'user_pic': information['image']
                          }).then((onValue) {
                            _comment.clear();
                          });
                        },
                        icon: Icon(Icons.send, size: 38),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void getUserName() async{
    var userData = await FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser!.email).get();
    var data = userData.data();
    currentUserName = data!['username'];
  }
}
