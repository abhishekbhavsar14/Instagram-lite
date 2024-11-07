import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:instagram_lite/user_follow_screen.dart';
import 'package:instagram_lite/userprofile_screen.dart';
import 'package:shimmer/shimmer.dart';

import 'Color.dart';

class UploadPhotoDetailScreen extends StatefulWidget {
  String imageUrl;
  String imageId;
  String captain;
  String username;
  String date;
  UploadPhotoDetailScreen({required this.username,required this.imageUrl,required this.imageId,required this.captain,required this.date,super.key});
  @override
  State<UploadPhotoDetailScreen> createState() => _UploadPhotoDetailScreenState();
}

class _UploadPhotoDetailScreenState extends State<UploadPhotoDetailScreen> {
  int likes = 0;
  @override
  void initState() {
    super.initState();
    getTotalLikes();
  }
  getTotalLikes() async{
    var _user = await FirebaseFirestore.instance
        .collection('post_photos')
        .doc(widget.imageId)
        .get();
    var likesData = _user.data() as Map<String,dynamic>;
    setState(() {
      likes = likesData['likes'] ?? 0;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                    SnackBar(
                        duration: Duration(milliseconds: 2000),
                        content: Column(
                          children: [
                            ListTile(
                              onTap: () {
                                final store = FirebaseFirestore.instance;
                                store.collection('post_photos').doc(widget.imageId).delete();
                                store.collection('user_photos')
                                    .doc(widget.username)
                                    .collection('photos')
                                    .doc(widget.imageId)
                                    .delete();
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserprofileScreen(),));
                              },
                              leading: Icon(Icons.delete_outline,color: Colors.redAccent,size: 30,),
                              title: Text('Delete',style: GoogleFonts.roboto(color: Colors.redAccent,fontSize: 19),),
                            )
                          ],
                        )
                    )
                );
              },
              child: InstaImageViewer(
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl!,
                  height: MediaQuery.of(context).size.height * 0.47,
                  width: double.infinity,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.47,
                      width: double.infinity,
                      color: Colors.grey[300],
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error)),
              ),
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                Icon(likes! > 0 ? Icons.favorite : Icons.favorite_outline,color: likes! > 0 ? Colors.redAccent : Colors.white,size: 22,),
                SizedBox(width: 10,),
                Text('${likes}',style: GoogleFonts.aclonica(color: Colors.white,fontSize: 17),),
                SizedBox(width: 12,),
                IconButton(
                  onPressed: () {
                    showBottomSheet(widget.imageId);
                  },
                  icon: Icon(Icons.message, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 7,),
            Text(widget.captain,style: GoogleFonts.roboto(color: Colors.white,fontSize: 17),),
            SizedBox(height: 7,),
            Text(widget.date,style: GoogleFonts.roboto(color: Colors.white,fontSize: 17),),
        ]),
      ),
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

}
