import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class SetNamePage extends StatefulWidget {
  const SetNamePage({super.key});
  static const String routeName = '/set_name';

  @override
  _SetNamePageState createState() => _SetNamePageState();
}

class _SetNamePageState extends State<SetNamePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

/*  Future<void> _saveName() async {
    try {
      await _firestore.collection('users').doc('current_mobile_number').set({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
      }, SetOptions(merge: true));

      Navigator.pushNamed(context, '/add_profile_picture');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save name. Please try again.")),
      );
    }
  }*/
// In _SetNamePageState
  Future<void> _saveName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null || user.phoneNumber == null) return;

      await _firestore.collection('users').doc(user.phoneNumber).set({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'mobileNumber': user.phoneNumber,
      }, SetOptions(merge: true));

      Navigator.pushNamed(context, '/add_profile_picture');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save name")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Set Your Name",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 35.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: "First Name",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 35.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: "Last Name",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddProfilePicturePage extends StatefulWidget {
  const AddProfilePicturePage({super.key});
  static const String routeName = '/add_profile_picture';

  @override
  _AddProfilePicturePageState createState() => _AddProfilePicturePageState();
}

class _AddProfilePicturePageState extends State<AddProfilePicturePage> {
  final ImagePicker _picker = ImagePicker();
  String? _profilePicturePath;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _base64Image;

  Future<void> _showPhotoOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text("Take Photo"),
              onTap: () async {
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _profilePicturePath = pickedFile.path;
                  });
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _profilePicturePath = pickedFile.path;
                  });
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadProfilePicture() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.phoneNumber == null) return;

    final bytes = await File(_profilePicturePath!).readAsBytes();
    setState(() => _base64Image = base64Encode(bytes));

    await _firestore.collection('users').doc(user.phoneNumber).update({
      'profilePicture': _base64Image,
      'registrationComplete': true,
    });

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Profile Picture"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: _profilePicturePath != null
                      ? FileImage(File(_profilePicturePath!))
                      : const AssetImage('assets/images/user.png')
                          as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _showPhotoOptions,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purple,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _uploadProfilePicture,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              ),
              child: const Text(
                "Save & Continue",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
