import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instagram_lite/bottom_home_screen.dart';
import 'package:instagram_lite/intro_home_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instagram_lite/reels_sceen.dart';
import 'package:instagram_lite/search_user_screen.dart';
import 'package:instagram_lite/uplod_photo_screen.dart';
import 'package:instagram_lite/userprofile_screen.dart';
import 'package:shimmer/shimmer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final _user = FirebaseAuth.instance.currentUser;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:_user != null ? MyHomePage(title: '') : IntroHomeScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? currentUserImage;
  final list = [
    BottomHomeScreen(),
    SearchUserScreen(),
    UplodPhotoScreen(),
    ReelsScreen(),
    UserprofileScreen()
  ];
  int _selectedIndex = 0;
  updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  void initState() {
    super.initState();
    getUserImage();
  }
  getUserImage() async{
    var data = await FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.email).get();
    var user = data.data();
    currentUserImage = user!['image'];
  }
  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0; // Go back to the home screen
      });
      return false; // Prevent exiting the app
    } else {
      return true; // Exit the app if on the home screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: IndexedStack(index: _selectedIndex,children: [
          BottomHomeScreen(),
          SearchUserScreen(),
          UplodPhotoScreen(),
          ReelsScreen(),
          UserprofileScreen()
        ],),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:Color(0xFF121212),
          onTap: updateIndex,
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 31,
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                ),
                label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('assets/images/post.png',),size: 27,), label: ''),
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage('assets/images/reel.png',),size: 27,), label: ''),
            BottomNavigationBarItem(
                icon:  currentUserImage!= null && currentUserImage!.isNotEmpty
                    ? CircleAvatar(
                  radius: 17, // Adjust the radius as needed
                  backgroundImage: CachedNetworkImageProvider(currentUserImage!),
                )
                    : Icon(Icons.account_circle_rounded), // Fallback icon if no image is available
                label: ''),
          ]),
    );
  }
}
