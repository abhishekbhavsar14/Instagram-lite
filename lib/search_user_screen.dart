import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_lite/user_follow_screen.dart';
import 'package:instagram_lite/userprofile_screen.dart';
import 'package:shimmer/shimmer.dart';

class SearchUserScreen extends StatefulWidget {
  @override
  _SearchUserScreenState createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  String searchText = '';
  String? cUserName;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getUserDetails();
  }
  Future<void> getUserDetails() async {
    final _user = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    var data = _user.data() as Map<String, dynamic>;
    cUserName = data['username'] ?? '';
    setState(() {
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
        title: Text('Search User',style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 22,),
      ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              cursorColor: Colors.white60,
              style: TextStyle(color: Colors.white),
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value; // Update search text as user types
                });
              },
              decoration: InputDecoration(
                hintStyle: GoogleFonts.roboto(
                  color: Colors.white60,),
                hintText: 'Search by username',
                prefixIcon: Icon(Icons.search),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: (searchText.isEmpty)
                ? Center(child: Text(''))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .where('username', isGreaterThanOrEqualTo: searchText)
                        .where('username',
                            isLessThanOrEqualTo: searchText + '\uf8ff')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView.builder(
                            itemCount: 6, // Show 5 shimmer items
                            itemBuilder: (context, index) {
                              return Shimmer.fromColors(
                                baseColor: Colors.white60!,
                                highlightColor: Colors.black26,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius:25,
                                    backgroundColor: Colors.grey,
                                  ),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children:[ Container(
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),color: Colors.white,),
                                      width:
                                          double.infinity, // Set a fixed width for the username
                                      height: 20,
                                    ),
                                      SizedBox(height: 5,),
                                      Container(
                                        width:
                                        100, // Set a fixed width for the username
                                        height: 15,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),color: Colors.white,),
                                      ),
                                  ]
                                  ),
                                ),
                              );
                            });
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No users found',style: GoogleFonts.roboto(color: Colors.white)));
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var user = snapshot.data!.docs[index];
                          var image = user['image'];
                          var userName = user['username'];
                          return ListTile(
                            onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => cUserName == userName ? UserprofileScreen() :UserFollowScreen(userProfileImage: image, userName: user['username'], name: user['name']),)),
                            leading: CircleAvatar(
                              backgroundImage: image != '' ? NetworkImage(user['image']) : NetworkImage('https://cdn-icons-png.flaticon.com/128/64/64572.png'),
                            ),
                            title: Text(user['username'],style: GoogleFonts.roboto(color: Colors.white)),
                            subtitle: Text(user['name'],style: GoogleFonts.roboto(color: Colors.white)),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
