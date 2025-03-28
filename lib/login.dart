import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? savedMobileNumber;
  String? savedPin;
  String? savedFirstName;
  String? savedLastName;
  String? profilePicture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  /* Future<void> _loadSavedCredentials() async {
    try {
      setState(() => _isLoading = true);

      // Fetch user profile details from current_mobile_number
      DocumentSnapshot currentUserDoc = await _firestore
          .collection('users')
          .doc('current_mobile_number')
          .get();

      if (currentUserDoc.exists) {
        savedFirstName = currentUserDoc.get('firstName') ?? '';
        savedLastName = currentUserDoc.get('lastName') ?? '';
        profilePicture = currentUserDoc.get('profilePicture') ?? '';
      }

      // Fetch mobile number and PIN from the specific user's document
      QuerySnapshot userCollection = await _firestore.collection('users').get();
      for (var doc in userCollection.docs) {
        if (doc.id != 'current_mobile_number') {
          savedMobileNumber = doc.get('mobileNumber');
          savedPin = doc.get('pin')?.toString() ?? '';
          break;
        }
      }
    } catch (e) {
      print('Error loading credentials: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load user data")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }*/
// Update _loadSavedCredentials
  Future<void> _loadSavedCredentials() async {
    try {
      setState(() => _isLoading = true);
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || user.phoneNumber == null) return;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.phoneNumber).get();

      if (userDoc.exists) {
        setState(() {
          savedFirstName = userDoc.get('firstName') ?? '';
          savedLastName = userDoc.get('lastName') ?? '';
          savedMobileNumber = userDoc.get('mobileNumber') ?? '';
          savedPin = userDoc.get('pin')?.toString() ?? '';
          profilePicture = userDoc.get('profilePicture') ?? '';
        });
      }
    } catch (e) {
      print('Error loading credentials: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String get fullName => "${savedFirstName ?? ''} ${savedLastName ?? ''}";

// Update _login method
  void _login() async {
    try {
      setState(() => _isLoading = true);
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || user.phoneNumber == null) return;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.phoneNumber).get();

      String storedPin = userDoc.get('pin')?.toString() ?? '';
      String enteredPin = _pinController.text.trim();

      if (enteredPin == storedPin) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Show error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Invalid PIN"),
            content: const Text("Please check your PIN and try again"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Login error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

/*  void _login() async {
    if (_pinController.text.isEmpty) return;

    try {
      setState(() => _isLoading = true);

      if (savedMobileNumber == null || savedMobileNumber!.isEmpty) {
        throw Exception('No mobile number found');
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(savedMobileNumber).get();

      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      String storedPin = userDoc.get('pin')?.toString() ?? '';
      String enteredPin = _pinController.text.trim();

      if (enteredPin == storedPin) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Invalid PIN"),
            content: const Text("Please check your PIN and try again"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const SizedBox.shrink(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () {
                // Handle language toggle
              },
              child: const Text(
                "বাংলা",
                style: TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Image.asset(
                    "assets/images/logo.png", // Replace with your logo asset
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 16),
                  // Welcome Message
                  const Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Display Full Name
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Display Mobile Number
                  Text(
                    savedMobileNumber ?? 'Unknown Number',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // PIN Entry
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 47.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.grey.shade100,
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(5.5),
                            child: Icon(Icons.lock, color: Colors.purple),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _pinController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Enter PIN",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Login Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 47.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Forgot PIN
                  GestureDetector(
                    onTap: () {
                      // Handle Forgot PIN
                    },
                    child: const Text(
                      "Forgot Payit PIN?",
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                // Handle Store Locator
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.location_on, color: Colors.purple),
                  Text(
                    "Store Locator",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                // Handle Help & Support
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.help_outline, color: Colors.purple),
                  Text(
                    "Help & Support",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
