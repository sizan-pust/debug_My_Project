import 'package:flutter/material.dart';
//import 'package:mfs1/login.dart';
import 'dart:async';

import 'package:payit_1/welcome_page.dart';
// Assuming you want to navigate to HomePage after the splash

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => WelcomePage(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 250, 250, 250), // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.png', // Place your logo file here
              height: 150,
              width: 150,
            ),
            SizedBox(height: 20),
            // Text below the logo

            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
