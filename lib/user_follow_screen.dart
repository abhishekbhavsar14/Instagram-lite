import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:instagram_lite/follwing_screen.dart';
import 'package:instagram_lite/user_followers_screen.dart';
import 'package:shimmer/shimmer.dart';

import 'Color.dart';

class UserFollowScreen extends StatefulWidget {
  String userProfileImage;
  String userName;
  String name;
  UserFollowScreen(
      {required this.userProfileImage,
      required this.userName,
      required this.name,
      super.key});

  @override
  State<UserFollowScreen> createState() => _UserFollowScreenState();
}

class _UserFollowScreenState extends State<UserFollowScreen> {
  String followButton = 'Follow';
  int? totalPosts;
  String? followUserImg;
  String? userName;
  String? followName;
  int? totalFollow;
  int? totalFollowing;
  @override
  void initState() {
    super.initState();
    getTotalPosts();
    getCurrentUserName();
    getTotalFollowersCount();
    getTotalFollowingCount();
    getUserPhotos();
  }

  getCurrentUserName() async {
    var data = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    var user = data.data() as Map<String, dynamic>;
    userName = user['username'];
    followUserImg = user['image'];
    followName = user['name'];

    FirebaseFirestore.instance
        .collection('following')
        .doc(userName)
        .collection('user_following')
        .snapshots()
        .listen((snapshot){
      if (snapshot.docs.isNotEmpty) {
        for(var userData in  snapshot.docs){
          var data = userData.data() as Map<String,dynamic>;
          if(data['username'] == widget.userName){
            setState(() {
              followButton = 'Following';
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.userName,
          style: GoogleFonts.roboto(fontSize: 20, color: Colors.white),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CachedNetworkImage(
                  imageUrl: widget.userProfileImage,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 38,
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
                  errorWidget: (context, url, error) => const CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.account_circle_rounded,
                      size: 77,
                      color: Colors.black38,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  children: [
                    Text('$totalPosts',
                        style: GoogleFonts.roboto(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Text(
                      'posts',
                      style:
                          GoogleFonts.roboto(fontSize: 15, color: Colors.white),
                    )
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    print(userName);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FollowersScreen(currentUserName: widget.userName,),));
                  },
                  child: Column(
                    children: [
                      Text('$totalFollow',
                          style: GoogleFonts.roboto(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(
                        'followers',
                        style:
                            GoogleFonts.roboto(fontSize: 15, color: Colors.white),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context,MaterialPageRoute(builder: (context) => FollwingScreen(currentUserName: widget.userName)));
                  },
                  child: Column(
                    children: [
                      Text('$totalFollowing',
                          style: GoogleFonts.roboto(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(
                        'following',
                        style:
                            GoogleFonts.roboto(fontSize: 15, color: Colors.white),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.name,
                style: GoogleFonts.roboto(fontSize: 15, color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                width: double.infinity,
                decoration: followButton == 'Following' ?  BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey)
                ) :BoxDecoration(
                    color: MyColor.blue,
                    borderRadius: BorderRadius.circular(11)),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  followButton,
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                if(followButton == 'Following'){
                  deleteFollowersFollowing();
                  setState(() {
                    followButton = 'Follow';
                  });
                }else{
                  updateFollowing();
                  updateFollowers();
                  setState(() {
                    followButton = 'Following';
                  });
                }
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(child: getUserPhotos())
          ],
        ),
      ),
    );
  }

  updateFollowers() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('follow')
          .doc(widget.userName)
          .collection('user_followers')
          .where('username', isEqualTo: userName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Update existing document
        snapshot.docs.first.reference.update({
          'user_pic': followUserImg,
          'username': userName,
          'name': followName
        });
      } else {
        // Add new document if none exists
        FirebaseFirestore.instance
            .collection('follow')
            .doc(widget.userName)
            .collection('user_followers')
            .add({
          'user_pic': followUserImg,
          'username': userName,
          'name': followName
        });
      }
    } catch (e) {
      print('Error in updateFollowers: $e');
    }
  }

  updateFollowing() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('following')
          .doc(userName)
          .collection('user_following')
          .where('username', isEqualTo: widget.userName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.first.reference.update({
          'user_pic': widget.userProfileImage,
          'username': widget.userName,
          'name': widget.name
        });
      } else {
        FirebaseFirestore.instance
            .collection('following')
            .doc(userName)
            .collection('user_following')
            .add({
          'user_pic': widget.userProfileImage,
          'username': widget.userName,
          'name': widget.name
        });
      }
    } catch (e) {
      print('Error in updateFollowing: $e');
    }
  }

  deleteFollowersFollowing() async {
    try {
      // Delete from 'user_following' collection
      var followingSnapshot = await FirebaseFirestore.instance
          .collection('following')
          .doc(userName)
          .collection('user_following')
          .where('username', isEqualTo: widget.userName)
          .get();

      for (var userData in followingSnapshot.docs) {
        await userData.reference.delete();
      }

      // Delete from 'user_followers' collection
      var followersSnapshot = await FirebaseFirestore.instance
          .collection('follow')
          .doc(widget.userName)
          .collection('user_followers')
          .where('username', isEqualTo: userName)
          .get();

      for (var userData in followersSnapshot.docs) {
        await userData.reference.delete();
      }

      setState(() {
        // Update any necessary UI elements after deletion
      });
    } catch (e) {
      print(e.toString());
    }
  }

  getTotalPosts() async{
    try{
      FirebaseFirestore.instance
          .collection('user_photos')
          .doc(widget.userName)
          .collection('photos')
          .snapshots()
          .listen((onData) {
        if (onData.docs.isNotEmpty) {
          setState(() {
            totalPosts = onData.docs.length;
          });
        } else {
          setState(() {
            totalPosts = 0;
          });
        }
      });
    }catch(e){
      print(e.toString());
    }
  }
  getTotalFollowersCount() async{
    try{
      FirebaseFirestore.instance
          .collection('follow')
          .doc(widget.userName)
          .collection('user_followers')
          .snapshots()
          .listen((snapshot){
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            totalFollow = snapshot.docs.length;
          });
        } else {
          setState(() {
            totalFollow = 0;
          });
        }
      });
    }catch(e){
      print(e.toString());
    }
  }
  getTotalFollowingCount()  async{
    try{
      FirebaseFirestore.instance
          .collection('following')
          .doc(userName)
          .collection('user_following')
          .snapshots()
          .listen((snapshot){
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            totalFollowing = snapshot.docs.length;
            print('Total follwing $totalFollowing');
          });
        } else {
          setState(() {
            totalFollowing = 0;
            print('Total follwing $totalFollowing');
          });
        }
      });
    }catch(e){
      print(e.toString());
    }

  }
  getUserPhotos() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('user_photos')
          .doc(widget.userName)
          .collection('photos')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        } else if (snapshot.hasData) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 2, mainAxisSpacing: 2),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index];
              String? imageurl = data['image'];
              return InstaImageViewer(
                  child: CachedNetworkImage(
                      imageUrl: imageurl!,
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
                      errorWidget: (context, url, error) => Icon(Icons.error)));
            },
          );
        }
        return Container();
      },
    );
  }
  // getTotalFollowers() {
  //   return StreamBuilder(
  //     stream: FirebaseFirestore.instance
  //         .collection('follow')
  //         .doc(widget.userName)
  //         .collection('user_followers')
  //         .snapshots(),
  //     builder: (context, snapshot) {
  //       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
  //         return Container();
  //       } else if (snapshot.hasError) {
  //         return Text('${snapshot.error}');
  //       } else if (snapshot.hasData) {
  //         return ListView.builder(
  //           itemCount: snapshot.data!.docs.length,
  //           itemBuilder: (context, index) {
  //             var user = snapshot.data!.docs[index];
  //             var image = user['user_pic'];
  //             return ListTile(
  //               onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => UserFollowScreen(userProfileImage: image, userName: user['username'], name: user['name']),)),
  //               leading: CircleAvatar(
  //                 backgroundImage: image != '' ? NetworkImage(user['image']) : NetworkImage('https://cdn-icons-png.flaticon.com/128/64/64572.png'),
  //               ),
  //               title: Text(user['username'],style: GoogleFonts.roboto(color: Colors.white)),
  //               subtitle: Text(user['name'],style: GoogleFonts.roboto(color: Colors.white)),
  //             );
  //           },
  //         );
  //       }
  //       return Container();
  //     },
  //   );
  // }
}
