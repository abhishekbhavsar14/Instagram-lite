import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_lite/sign_in_screen.dart';
import 'package:instagram_lite/usrename_password.dart';

import 'Color.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final _userName = TextEditingController();
  var flag = true;
  var circularIndicator = false;
  final _password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text('What\'s your email?',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 28),))
            ,SizedBox(height: 10,),
            Text('Enter the email where  you can be contacted.No one will see this  on you profile.',textAlign: TextAlign.center,)
            ,SizedBox(height: 20,),
            Text(
              'Enter your email address',
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
                keyboardType: TextInputType.emailAddress,
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
                'Create a password',
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
                obscureText: flag,
                cursorHeight: 20,
                controller: _password,
                decoration: InputDecoration(
                    suffixIcon: IconButton(onPressed: () {
                      setState(() {
                        flag = !flag;
                      });
                    }, icon: flag ? Icon(Icons.visibility) : Icon(Icons.visibility_off)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
            ),
            SizedBox(height: 2,),
            Text(
                'Use a mix of at least 6 numbers and letters.',
                style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontSize: 15,
                )
            ),
            SizedBox(height: 15,),
            InkWell(
              onTap:() {
                if(_userName.text.isNotEmpty && _password.text.isNotEmpty){
                  setState(() {
                    circularIndicator = true;
                  });
                  createUser(_userName.text.toString().trim(),_password.text.toString().trim());
                }
              },
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: MyColor.blue,
                    borderRadius: BorderRadius.circular(5)),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: circularIndicator ? CircularProgressIndicator(color: Colors.white,):Text(
                  'Next',
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account? ',  style: GoogleFonts.roboto(
                    color: Colors.black54,
                    fontSize: 14,)),
                InkWell(
                  onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => SignInScreen(),)),
                  child: Text('Sign in',  style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
                )
              ],
            ),
            SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }
  Future<void> createUser(String email,String password) async{
    try{
      final _auth = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password)
          .then((onValue){
        setState(() {
          circularIndicator = false;
          Navigator.push(context,MaterialPageRoute(builder: (context) => UsrenamePassword(email: _userName.text.toString()),));
        });
      });
    }on FirebaseException catch(e){
      setState(() {
        circularIndicator = false;
      });
      if (e.code == 'email-already-in-use') {
        // Show message using ScaffoldMessenger
        Fluttertoast.showToast(msg: 'User with this email already exists.',backgroundColor: MyColor.blue,textColor: Colors.white,gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_SHORT);
      }else if(e.code == 'weak-password'){
        Fluttertoast.showToast(msg: 'Password minimum be 6 character',backgroundColor: MyColor.blue,textColor: Colors.white,gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_SHORT);
      }else if(e.code == 'invalid-email'){
        Fluttertoast.showToast(msg: 'Invalid Email Format',backgroundColor: MyColor.blue,textColor: Colors.white,gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_SHORT);
      } else{
        Fluttertoast.showToast(msg: '${e.message}',backgroundColor: MyColor.blue,textColor: Colors.white,gravity: ToastGravity.BOTTOM,toastLength: Toast.LENGTH_SHORT);
      }
    }

  }
}
