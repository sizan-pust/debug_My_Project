import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payit_1/SplashScreen.dart';
import 'package:payit_1/home_page.dart';
import 'package:payit_1/login.dart';
import 'package:payit_1/registration_procedures/mobile_num_entry_page.dart';
import 'package:payit_1/registration_procedures/otp_verification.dart';
import 'package:payit_1/registration_procedures/set_name&pic.dart';
import 'package:payit_1/registration_procedures/set_pin.dart';
import 'package:payit_1/send_money_procedures/number_entry.dart';
import 'package:payit_1/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PayitApp());
}

class PayitApp extends StatelessWidget {
  const PayitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Payit App',
      theme: ThemeData(primarySwatch: Colors.orange),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case OtpVerificationPage.routeName:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => OtpVerificationPage(
                mobileNumber: args['mobileNumber'],
              ),
            );
          case SetPinPage.routeName:
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => SetPinPage(
                mobileNumber: args['mobileNumber'],
              ),
            );
          default:
            return null;
        }
      },
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomePage(),
        '/mobileNumber': (context) => const MobileNumberPage(),
        '/set_name': (context) => const SetNamePage(),
        '/add_profile_picture': (context) => const AddProfilePicturePage(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
        '/sendMoney': (context) => SendMoneyPage(),
      },
      home: FutureBuilder<DocumentSnapshot>(
        future: _checkUserRegistration().catchError((_) => null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            bool isRegistered = snapshot.data!['registrationComplete'] ?? false;
            return isRegistered ? const LoginScreen() : const SplashScreen();
          }

          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              if (authSnapshot.hasData) {
                return const LoginScreen();
              }
              return const WelcomePage();
            },
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot> _checkUserRegistration() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || user.phoneNumber == null) {
        throw Exception("User not authenticated");
      }

      return await FirebaseFirestore.instance
          .collection('users')
          .doc(user.phoneNumber)
          .get();
    } catch (e) {
      print("Error checking registration: $e");

      return FirebaseFirestore.instance.collection('users').doc('dummy').get();
    }
  }
}
