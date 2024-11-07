import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_lite/main.dart';
import 'package:uuid/uuid.dart';

import 'Color.dart';

class AddProfilePhoto extends StatefulWidget {
  const AddProfilePhoto({super.key});

  @override
  State<AddProfilePhoto> createState() => _AddProfilePhotoState();
}

class _AddProfilePhotoState extends State<AddProfilePhoto> {
  var circularIndicator = false;
  var image = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                'Add a Profile Photo',
                style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold
                )
            ),
            SizedBox(height: 10,),
            Center(child: Text(
              'Add a profile photo so your friends know it\'s you.',
              style: TextStyle(fontSize: 13),)),
            SizedBox(height: 20,),
            InkWell(
              onTap: () {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(title: Text(
                          'Camera', style: TextStyle(fontSize: 20),),
                          onTap: () {
                            pickImage(ImageSource.camera);
                            Navigator.pop(context);
                          },)
                        , ListTile(title: Text(
                          'Gallery', style: TextStyle(fontSize: 20),),
                          onTap: () {
                            pickImage(ImageSource.gallery);
                            Navigator.pop(context);
                          },)
                      ],
                    ),
                  );
                },);
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey.withOpacity(0.4),
                radius: 70,
                backgroundImage: image != null ? FileImage(image) : AssetImage(
                    'assets/images/user.png'),
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                setState(() {
                  circularIndicator = true;
                });
                storeImage();
              },
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: MyColor.blue,
                    borderRadius: BorderRadius.circular(5)),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: circularIndicator
                    ? SizedBox(
                    height: 35,
                    child: CircularProgressIndicator(color: Colors.white,))
                    : Text(
                  'Add Photo',
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 5,),
            InkWell(
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage(title: '')), // Replace `HomePage` with your screen
                    (Route<dynamic> route) => false, // Remove all previous routes
              ),
              child: Text('Skip', style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),),
            ),
            SizedBox(height: 10,)
          ],
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

  void storeImage() async {
    try {
      String? url;
      UploadTask task = FirebaseStorage.instance.ref('Images').child(DateTime.now().microsecondsSinceEpoch.toString()).putFile(image!);
      TaskSnapshot snapshot = await task;
      url = await snapshot.ref.getDownloadURL();
      FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.email)
          .update({
        'image':url
      }).then((onvalue){
        setState(() {
          circularIndicator = false;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage(title: '')), // Replace `HomePage` with your screen
                (Route<dynamic> route) => false, // Remove all previous routes
          );
        });
        print('image Update successfully');

      });
    }catch(e)
    {
      print(e.toString());
    }
  }
}
