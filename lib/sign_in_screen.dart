import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_lite/email_screen.dart';

import 'Color.dart';
import 'main.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _userName = TextEditingController();
  final _password = TextEditingController();
  var flag = true;
  var indicator = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Instagram',
                style: GoogleFonts.arima(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Text(
              'Enter your email',
              style: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 50,
              child: TextField(
                cursorHeight: 20,
                controller: _userName,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Enter your password',
              style: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 50,
              child: TextField(
                obscureText: flag,
                cursorHeight: 20,
                controller: _password,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            flag = !flag;
                          });
                        },
                        icon: flag
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                if(_userName.text.isNotEmpty && _password.text.isNotEmpty){
                  setState(() {
                    indicator = true;
                    signIn(_userName.text.toString().trim(),_password.text.toString().trim());
                  });
                }else{
                  setState(() {
                    indicator = false;
                  });
                  Fluttertoast.showToast(
                      msg: 'Please fill the fields',
                      backgroundColor: MyColor.blue,
                      textColor: Colors.white,
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_SHORT);
                }
              },
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: MyColor.blue,
                    borderRadius: BorderRadius.circular(5)),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: indicator ? CircularProgressIndicator(color: Colors.white,) : Text(
                  'Log in',
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: Text(
                'OR',
                style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmailScreen(),
                    )),
                child: Text(
                  'Create new account',
                  style: GoogleFonts.roboto(
                      color: Colors.black,
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

  Future<void> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((onvalue) {
            setState(() {
              indicator = false;
            });
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyHomePage(title: '')),
                    (Route<dynamic> route) => false);
      });
    } on FirebaseException catch (e) {
      setState(() {
        indicator = false;
      });
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(
            msg: 'No user found for that email.',
            backgroundColor: MyColor.blue,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT);
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(
            msg: 'Wrong password provided for that user.',
            backgroundColor: MyColor.blue,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT);
        print('Wrong password provided for that user.');
      } else {
        Fluttertoast.showToast(
            msg: '${e.message}',
            backgroundColor: MyColor.blue,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT);
      }
    }

  }
}
