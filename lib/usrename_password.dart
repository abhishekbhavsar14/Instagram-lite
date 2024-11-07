import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_lite/add_profile_photo.dart';

import 'Color.dart';

class UsrenamePassword extends StatefulWidget {
  String email;
  UsrenamePassword({required this.email,super.key});

  @override
  State<UsrenamePassword> createState() => _UsrenamePasswordState();
}

class _UsrenamePasswordState extends State<UsrenamePassword> {
  final _userName = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();
  var flag = true;
  var circularIndicator = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                  'Enter your details',
                  style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold
                  )
              ),
            ),
            SizedBox(height: 5,),
            Center(child: Text('You can always change it later.',style: TextStyle(fontSize: 13),)),
            SizedBox(height: 20,),
            Text(
              'Username',
              style: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: 15,
              )
            ),
            SizedBox(height: 3,),
            SizedBox(
              height: 50,
              child: TextField(
                cursorColor: Colors.black,
                cursorHeight: 20,
                controller: _userName,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
            ),
            SizedBox(height: 10,),
            Text(
                'Enter your full name',
                style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontSize: 15,
                )
            ),
            SizedBox(height: 3,),
            SizedBox(
              height: 50,
              child: TextField(
                cursorColor: Colors.black,
                cursorHeight: 20,
                controller: _name,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
            ),
            SizedBox(height: 15,),
            InkWell(
              onTap: () {
                if(_userName.text.isNotEmpty && _name.text.isNotEmpty){
                  setState(() {
                    circularIndicator = true;
                  });
                  addUserInfo(_name.text.toString().trim(), _userName.text.toString().trim());
                }else{
                  Fluttertoast.showToast(msg: 'Please fill the fields',backgroundColor: MyColor.blue,textColor: Colors.white);
                }
              },
              child:  Container(
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: MyColor.blue,
                    borderRadius: BorderRadius.circular(5)),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: circularIndicator ? SizedBox(
                  height: 35,
                    child: CircularProgressIndicator(color: Colors.white,)) : Text(
                  'Sign in',
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
    );
  }
  Future<void> addUserInfo(String name ,String username) async{
    var reference = FirebaseFirestore.instance.collection('Users');
    try{
      print(username);
      var userNameQuery = await reference.where('username',isEqualTo: username).get();
      print(userNameQuery.docs);
      if(userNameQuery.docs.isEmpty){
        FirebaseFirestore.instance.collection('Users').doc(widget.email).set({
          'email':widget.email,
          'username':username,
          'name':name,
          'image':''
        }).then((onVlaue){
          setState(() {
            circularIndicator = false;
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddProfilePhoto(),));
          });
        });
      }else{
        setState(() {
          circularIndicator = false;
        });
        Fluttertoast.showToast(msg: 'Username already exists.',backgroundColor: MyColor.blue,textColor: Colors.white,gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_SHORT);
      }
    }catch(e){
      print(e.toString());
    }
  }
}
