import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_lite/Color.dart';
import 'package:instagram_lite/edit_profile_screen.dart';
import 'package:instagram_lite/follwing_screen.dart';
import 'package:instagram_lite/intro_home_screen.dart';
import 'package:instagram_lite/upload_photo_detail_screen.dart';
import 'package:instagram_lite/user_followers_screen.dart';
import 'package:shimmer/shimmer.dart';

class UserprofileScreen extends StatefulWidget {
  const UserprofileScreen({super.key});

  @override
  State<UserprofileScreen> createState() => _UserprofileScreenState();
}

class _UserprofileScreenState extends State<UserprofileScreen> {
  String? userProfile;
  String? userName;
  String? name;
  int totalPosts = 0;
  int totalFollow = 0;
  int? totalFollowing;
  @override
  void initState() {
    super.initState();
    getUserDetails();
    getUserPhotos();
    getTotalFollowersCount();
    getTotalFollowingCount();
  }

   Future<void> getUserDetails() async {
    try{
      final _user = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .get();
      var data = _user.data() as Map<String, dynamic>;
      userName = data['username'] ?? '';
      userProfile = data['image'];
      name = data['name'];
      setState(() {
        getTotalPosts();
        getTotalFollowersCount();
        getTotalFollowingCount();
      });
    }catch(e){
      print(e.toString());
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: const Color(0xFF121212),
          title: Text(
            userName!,
            style: GoogleFonts.roboto(fontSize: 20, color: Colors.white),
          ),
        ),
        body: RefreshIndicator(
          color: MyColor.blue,
          onRefresh: getUserDetails,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: userProfile!,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 38,
                          backgroundImage: imageProvider,
                        ),
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: CircleAvatar(
                            radius: 38,
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
                        width: 24,
                      ),
                      Column(
                        children: [
                          Text('${totalPosts!}',
                              style: GoogleFonts.roboto(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            'posts',
                            style: GoogleFonts.roboto(
                                fontSize: 15, color: Colors.white),
                          )
                        ],
                      ),
                      const SizedBox(
                        width: 19,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FollowersScreen(currentUserName: userName!,),));
                        },
                        child: Column(
                          children: [
                            Text('${totalFollow}',
                                style: GoogleFonts.roboto(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              'followers',
                              style: GoogleFonts.roboto(
                                  fontSize: 15, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 19,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FollwingScreen(currentUserName: userName),));
                        },
                        child: Column(
                          children: [
                            Text('${totalFollowing}',
                                style: GoogleFonts.roboto(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              'following',
                              style: GoogleFonts.roboto(
                                  fontSize: 15, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 13),
                    child: Text(name!,
                        style: GoogleFonts.roboto(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(profileImage: userProfile!, username: userName!, name: name!),));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding:
                                EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border:
                                  Border.all(color: Colors.grey), // Gray border
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                            ),
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(color: Colors.grey), // Gray text
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20,),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                              signOut();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding:
                                EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey, // Gray background
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                            ),
                            child: Text(
                              'Log Out',
                              style: TextStyle(color: Colors.white), // White text
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Expanded(child: getUserPhotos())
                ],
              )),
        ));
  }
  signOut() async{
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => IntroHomeScreen(),));
  }
  getUserPhotos() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('user_photos')
          .doc(userName)
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
              String? date = data['timestamp'];
              String? captain = data['caption'];
              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UploadPhotoDetailScreen(username:userName!,imageUrl: imageurl!,imageId: snapshot.data!.docs[index].id,captain: captain!,date: date!),));
                },
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
                          errorWidget: (context, url, error) => Icon(Icons.error)),
              );
            },
          );
        }
        return Container();
      },
    );
  }
  getTotalPosts() {
    FirebaseFirestore.instance
        .collection('user_photos')
        .doc(userName)
        .collection('photos')
        .snapshots()
        .listen((onData) {
      if (onData.docs.isNotEmpty) {
        setState(() {
          print(totalPosts);
          totalPosts = onData.docs.length ;
        });
      } else {
        setState(() {
          totalPosts = 0;
        });
      }
    });
  }
  getTotalFollowersCount(){
    FirebaseFirestore.instance
        .collection('follow')
        .doc(userName)
        .collection('user_followers')
        .snapshots()
        .listen((snapshot){
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          totalFollow = snapshot.docs.length;
          print(totalFollow);
        });
      } else {
        setState(() {
          totalFollow = 0;
          print(totalFollow);
        });
      }
    });
  }
  getTotalFollowingCount(){
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
  }
}
