import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_lite/Color.dart';
import 'package:instagram_lite/email_screen.dart';
import 'package:instagram_lite/sign_in_screen.dart';

class IntroHomeScreen extends StatelessWidget {
  const IntroHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Image.asset(
                'assets/images/ig_pic.png',
                height: 120,
                width: 120,
              ),
              Text(
                'Instagram',
                style: GoogleFonts.arima(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => EmailScreen(),)),
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: MyColor.blue,
                      borderRadius: BorderRadius.circular(5)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Create New Account',
                    style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => SignInScreen(),)),
                  child: Text(
                'Log in',
                style: GoogleFonts.roboto(
                    color: Colors.blueAccent,
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
              )),
              Spacer(),
              Text('from',
                  style: GoogleFonts.roboto(
                      color: CupertinoColors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/metalogo.png',
                    height: 37,
                    width: 37,
                  ),
                  Text('Meta',
                      style: GoogleFonts.arima(
                          color: CupertinoColors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
