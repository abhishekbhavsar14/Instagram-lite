import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_lite/userprofile_screen.dart';
import 'package:shimmer/shimmer.dart';

import 'Color.dart';

class EditProfileScreen extends StatefulWidget {
  String profileImage;
  String username;
  String name;
  EditProfileScreen({required this.profileImage,required this.username,required this.name,super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? image = null;
  bool circularIndicator = false;
  var _updateUsername = TextEditingController();
  var _updateName = TextEditingController();
  @override
  void initState() {
    super.initState();
    _updateName.text = widget.name;
    _updateUsername.text = widget.username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: Text('Camera', style: TextStyle(fontSize: 20)),
                                onTap: () {
                                  pickImage(ImageSource.camera);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text('Gallery', style: TextStyle(fontSize: 20)),
                                onTap: () {
                                  pickImage(ImageSource.gallery);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                    child: CircleAvatar(
                      radius: 68,
                      backgroundImage: image != null ? FileImage(image!) : (widget.profileImage != null && widget.profileImage!.isNotEmpty) ? CachedNetworkImageProvider(widget.profileImage!) : null,
                      child: image == null && (widget.profileImage == null || widget.profileImage!.isEmpty) ? Icon(Icons.account_circle_rounded, size: 117, color: Colors.black38) : null,
                    ),
                  ),
                SizedBox(height: 20,),
                TextField(
                  cursorHeight: 16,
                  controller: _updateName,
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Name',
                      hintStyle: TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38),borderRadius: BorderRadius.circular(10)),
                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38),borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(height: 20,),
                TextField(
                  cursorHeight: 16,
                  controller: _updateUsername,
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Username',
                      hintStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38),borderRadius: BorderRadius.circular(10)),
                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38),borderRadius: BorderRadius.circular(10))),
                ),
        SizedBox(height: 20,),
        InkWell(
          onTap: () {
            setState(() {
              circularIndicator = true;
            });
            editUserDetails();
          },
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            decoration: BoxDecoration(
                color: MyColor.blue,
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: circularIndicator
                ? const SizedBox(
                height: 35,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ))
                : Text(
              'Edit',
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
              ],
            ),
        ),
        ),
    );
  }

  void pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
  editUserDetails() async{
    try{
      String? newImage;
      var task = FirebaseStorage.instance.ref("Images").child('Images/${DateTime.now().millisecondsSinceEpoch.toString()}').putFile(image!);
      await task.whenComplete(() async{
        newImage =  await task.snapshot.ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .update({
          'username':_updateUsername.text.toString(),
          'name':_updateName.text.toString(),
          'image':newImage
            });
        setState(() {
          circularIndicator = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(milliseconds: 2500),content: Text('Profile update sucessfully',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),backgroundColor: MyColor.blue,));
        // Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => UserprofileScreen(),));
      });
    }catch(e){
      setState(() {
        circularIndicator = false;
      });
      print(e.toString());
    }
  }
}
