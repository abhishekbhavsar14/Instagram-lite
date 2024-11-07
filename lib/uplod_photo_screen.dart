import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_lite/bottom_home_screen.dart';
import 'package:instagram_lite/main.dart';
import 'package:intl/intl.dart';

import 'Color.dart';

class UplodPhotoScreen extends StatefulWidget {
  const UplodPhotoScreen({super.key});

  @override
  State<UplodPhotoScreen> createState() => _UplodPhotoScreenState();
}

class _UplodPhotoScreenState extends State<UplodPhotoScreen> {
  var image = null;
  final _caption = TextEditingController();
  var circularIndicator = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
        title: Text(
          'Upload photo',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Column(
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
                                title: Text(
                                  'Camera',
                                  style: TextStyle(fontSize: 20),
                                ),
                                onTap: () {
                                  pickImage(ImageSource.camera);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: Text(
                                  'Gallery',
                                  style: TextStyle(fontSize: 20),
                                ),
                                onTap: () {
                                  pickImage(ImageSource.gallery);
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    child: image != null
                        ? Image.file(
                            height: MediaQuery.of(context).size.height*0.35,
                            width: double.infinity,
                            image, // Use the file image
                            fit: BoxFit
                                .fill, // Optional: Adjust how the image fits the container
                          )
                        : Image.asset(
                            height: 200,
                            'assets/images/user.png', // Use the asset image as fallback
                            fit: BoxFit.cover, // Optional: Adjust fit
                          ),
                  )),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 90,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white60)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SingleChildScrollView(
                    child: TextField(
                      cursorColor: Colors.white38,
                      style: TextStyle(color: Colors.white),
                      maxLines: null,
                      controller: _caption,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white38),
                        hintText: 'Write a caption...',
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  setState(() {
                    circularIndicator = true;
                    uploadImage();
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: MyColor.blue,
                      borderRadius: BorderRadius.circular(5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: circularIndicator
                      ? const SizedBox(
                          height: 35,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ))
                      : Text(
                          'Upload',
                          style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 16,
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
      image = await ImagePicker().pickImage(source: source);
      if (image != null) {
        var path = File(image.path);
        setState(() {
          image = path;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void uploadImage() async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email;
      if (image == null) {
        Fluttertoast.showToast(
            msg: 'Please select an image',
            backgroundColor: MyColor.blue,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT);
      } else {
        final storageRef = FirebaseStorage.instance.ref().child(
            'Images/$userEmail/${DateTime.now().millisecondsSinceEpoch.toString()}');
        final uploadTask = storageRef.putFile(image);

        await uploadTask.whenComplete(() async {
          final url = await storageRef.getDownloadURL();

          // Access Firestore and retrieve the user data
          final store = FirebaseFirestore.instance;
          final data = await store.collection('Users').doc(userEmail).get();
          final _userdata = data.data() as Map<String,dynamic>;
          print(data.data());

          if (data.exists) {
            final mapData = data.data() as Map<String, dynamic>;
            String formattedDate = DateFormat('d MMMM yyyy').format(DateTime.now());
            String uniqueId= store.collection('post_photos').doc().id;
            await store.collection('post_photos').doc(uniqueId).set({
              'username': mapData['username'],
              'image': url,
              'name':mapData['name'],
              'likes': 0,
              'userimage':mapData['image'],
              'likedBy': [],
              'caption': _caption.text.toString(),
              'timestamp': formattedDate,
            });

            await store
                .collection('user_photos')
                .doc(_userdata['username'])
                .collection('photos')
                .doc(uniqueId)
                .set({
              'image': url,
              'likes': 0,
              'likedBy':[],
              'caption': _caption.text.toString(),
              'timestamp':formattedDate
            });

            setState(() {
              circularIndicator = false;
              image = null;
              _caption.clear();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(title: ''),));
            });
          }
        });
      }
    } catch (e) {
      // Handle and log the error
      print("Error: $e");
    }
  }
}
