import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_lite/user_follow_screen.dart';
import 'package:shimmer/shimmer.dart';

import 'Color.dart';
import 'intro_home_screen.dart';

class BottomHomeScreen extends StatefulWidget {
  const BottomHomeScreen({super.key});

  @override
  State<BottomHomeScreen> createState() => _BottomHomeScreenState();
}

class _BottomHomeScreenState extends State<BottomHomeScreen> {
  String? userName;
  String? currentUserImage;
  var postRef;
  var imageId;
  String? currentUserName;
  int? commentLength;
  List? likedBy;
  String likeString = 'Hide like count';
  String commentString = 'Turn off commenting';
  @override
  void initState() {
    super.initState();
    getUserName();
  }

  getUserName() async {
    final _user = await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    final data = _user.data() as Map<String, dynamic>;
    currentUserName = data!['username'];
    var email = data['email'];
    print(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
        title: Text(
          'Instagram',
          style: GoogleFonts.arima(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('post_photos')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: MyColor.blue,));
                } else if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No user found'));
                } else {
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      List<DocumentSnapshot> list = snapshot.data!.docs;
                      final _userData = list[index].data() as Map<String, dynamic>;
                      userName = _userData['username'] ?? '';
                      var imageurl = _userData['image'] ?? '';
                      currentUserImage = _userData['userimage'] ?? '';
                      var caption = _userData['caption'] ?? '';
                      var likes = _userData['likes'];
                      var name = _userData['name'] ?? '';
                      var date = _userData['timestamp'] ?? '';
                      List likedBy = _userData['likedBy'] ?? [];
                      var currentUserEmail =
                          FirebaseAuth.instance.currentUser!.email;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                           onTap: () {
                             print(name);
                             Navigator.push(context,MaterialPageRoute(builder: (context) => UserFollowScreen(userProfileImage: list[index]['userimage']!, userName: list[index]['username']!, name:name),));
                           } ,
                            trailing: currentUserName == userName ?  InkWell(
                                child: InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                        SnackBar(
                                            duration: Duration(milliseconds: 2000),
                                            content: Column(
                                              children: [
                                                ListTile(
                                                  onTap: () {
                                                    FirebaseFirestore.instance
                                                        .collection('post_photos')
                                                        .doc(list[index].id)
                                                        .delete();
                                                    FirebaseFirestore.instance
                                                        .collection('user_photos')
                                                        .doc(currentUserName)
                                                        .collection('photos')
                                                        .doc(list[index].id)
                                                        .delete();
                                                  },
                                                  leading: Icon(Icons.delete_outline,color: Colors.redAccent,size: 30,),
                                                  title: Text('Delete',style: GoogleFonts.roboto(color: Colors.redAccent,fontSize: 19),),
                                                )
                                              ],
                                            )
                                        )
                                    );
                                  },
                                  child: Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                  ),
                                )):null,
                            leading: CachedNetworkImage(
                              imageUrl: currentUserImage!,
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
                              userName!,
                              style: GoogleFonts.roboto(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Suggested for you',
                              style: GoogleFonts.roboto(color: Colors.white),
                            ),
                          ),
                          CachedNetworkImage(
                            imageUrl: imageurl!,
                            height: MediaQuery.of(context).size.height * 0.47,
                            width: double.infinity,
                            fit: BoxFit.fill,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.47,
                                width: double.infinity,
                                color: Colors.grey[300],
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  postRef = FirebaseFirestore.instance
                                      .collection('post_photos')
                                      .doc(list[index].id);

                                  var postSnapshot = await postRef.get();
                                  var postData = postSnapshot.data()
                                      as Map<String, dynamic>;

                                  List likedBy = postData['likedBy'] ?? [];

                                  if (!likedBy.contains(currentUserEmail)) {
                                    likedBy.add(currentUserEmail);
                                    await postRef.update({
                                      'likes': FieldValue.increment(1),
                                      'likedBy': likedBy,
                                    });
                                  } else {
                                    likedBy.remove(
                                        currentUserEmail); // Remove user from likedBy
                                    await postRef.update({
                                      'likes': FieldValue.increment(-1),
                                      'likedBy': likedBy,
                                    });
                                  }
                                },
                                icon: likedBy.contains(currentUserEmail)
                                    ? Icon(Icons.favorite,
                                        size: 29, color: Colors.red)
                                    : Icon(
                                        Icons.favorite_border,
                                        size: 29,
                                        color: Colors.white,
                                      ),
                              ),
                              Text(
                                '${likes}',
                                style: GoogleFonts.roboto(
                                    fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(
                                width: 13,
                              ),
                              IconButton(
                                  onPressed: () {
                                    showBottomSheet(list[index].id);
                                  },
                                  icon: Icon(
                                    Icons.message,
                                    color: Colors.white,
                                  )),

                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            child: Text(
                              caption,
                              style: GoogleFonts.roboto(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            child: Text(
                              date,
                              style: GoogleFonts.roboto(color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ]),
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
                            commentLength = list.length;
                            var _user = list[index].data() as Map<String, dynamic>;
                            var image = _user['user_pic'] ?? 'https://cdn-icons-png.flaticon.com/128/3033/3033143.png';
                            var name = _user['name'] ?? '';
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
                            'name':information['name'],
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
