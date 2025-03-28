import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SetPinPage extends StatefulWidget {
  static const String routeName = '/setPin';

  final String mobileNumber;

  const SetPinPage({super.key, required this.mobileNumber});

  @override
  _SetPinPageState createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  final TextEditingController _pinController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
/*  Future<void> _savePin() async {
    try {
      await _firestore.collection('users').doc(widget.mobileNumber).set({
        'mobileNumber': widget.mobileNumber,
        'pin': _pinController.text,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Navigator.pushReplacementNamed(context, '/set_name');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save PIN. Please try again.")),
      );
    }
  }*/
// In _SetPinPageState
  /*Future<void> _savePin() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || user.phoneNumber == null) return;

      await _firestore.collection('users').doc(user.phoneNumber).set({
        'pin': _pinController.text,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Navigator.pushReplacementNamed(context, '/set_name');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save PIN")),
      );
    }
  }*/
  Future<void> _savePin() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || user.phoneNumber == null) return;

      final String phoneNumber = user.phoneNumber!;
      final batch = _firestore.batch();

      // Update user document
      final userRef = _firestore.collection('users').doc(phoneNumber);
      batch.set(
          userRef,
          {
            'mobileNumber': phoneNumber,
            'pin': _pinController.text,
            'createdAt': FieldValue.serverTimestamp(),
            'balance': 0.0,
            'registrationComplete': false,
          },
          SetOptions(merge: true));

      // Update phone numbers index
      final phoneRef = _firestore.collection('phoneNumbers').doc(phoneNumber);
      batch.set(phoneRef, {'exists': true});

      await batch.commit();

      Navigator.pushReplacementNamed(context, '/set_name');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save PIN: ${e.toString()}"),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Set your PIN",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter PIN",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_pinController.text.length == 4) {
                  _savePin();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("PIN must be 4 digits.")),
                  );
                }
              },
              child: const Text("Save PIN"),
            ),
          ],
        ),
      ),
    );
  }
}
