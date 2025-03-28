import 'package:flutter/material.dart';
//import 'package:mf/registration_procedures/verification_page.dart';
import 'package:payit_1/registration_procedures/otp_verification.dart';

class MobileNumberPage extends StatefulWidget {
  static const String routeName = '/mobileNumber';

  const MobileNumberPage({super.key});

  @override
  _MobileNumberPageState createState() => _MobileNumberPageState();
}

class _MobileNumberPageState extends State<MobileNumberPage> {
  final TextEditingController _mobileNumberController = TextEditingController();
  bool _isButtonEnabled = false;

  void _onTextChanged(String value) {
    setState(() {
      _isButtonEnabled =
          value.length == 11 && RegExp(r'^[0-9]+$').hasMatch(value);
    });
  }

  void _onNextPressed() {
    if (_isButtonEnabled) {
      Navigator.pushNamed(
        context,
        OtpVerificationPage.routeName,
        arguments: {'mobileNumber': _mobileNumberController.text},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
                child: Image.asset(
              "assets/images/logo.png", // Replace with your logo path
              height: 150,
              width: 150,
            )),
            const SizedBox(height: 24),
            const Text(
              "Enter mobile number for",
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 97, 97, 97),
              ),
            ),
            const Text(
              "Login / Registration",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Country Code",
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 89, 89, 89),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/bd_icon.png',
                    height: 20,
                    width: 20, // Specify the path to your image asset
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Bangladesh",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Mobile Number",
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 88, 88, 88),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Text(
                    "+88",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _mobileNumberController,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      onChanged: _onTextChanged,
                      decoration: const InputDecoration(
                        hintText: "01XXXXXXXXX",
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 194, 190, 190)),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "By proceeding, you agree to the",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Handle Terms and Conditions
                  },
                  child: const Text(
                    "Terms and Conditions",
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: _isButtonEnabled ? _onNextPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isButtonEnabled ? Colors.purple : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    SizedBox(width: 24), // Placeholder to balance arrow icon
                    Text(
                      "Next",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
