import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payit_1/send_money_procedures/amount.dart';

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  final TextEditingController _numberController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _checkNumberAndProceed(String enteredNumber) async {
    try {
      // Convert to Firestore format (+880XXXXXXXXXX)
      final formattedNumber = '+88$enteredNumber';

      final doc = await _firestore
          .collection('phoneNumbers')
          .doc(formattedNumber)
          .get();

      if (doc.exists) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AmountPage(
              recipient: {"number": formattedNumber},
            ),
          ),
        );
      } else {
        _showErrorDialog(context, "Recipient number not registered");
      }
    } catch (e) {
      _showErrorDialog(context, "Error checking number. Please try again.");
    }
  }

  bool _isValidNumber(String number) {
    return number.length == 11 &&
        number.startsWith('01') &&
        RegExp(r'^[0-9]+$').hasMatch(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Send Money',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _numberController,
              decoration: InputDecoration(
                labelText: 'To',
                hintText: 'Enter 11-digit number',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () async {
                    final enteredNumber = _numberController.text.trim();
                    if (!_isValidNumber(enteredNumber)) {
                      _showErrorDialog(context,
                          "Please enter valid 11-digit number starting with 01");
                      return;
                    }
                    await _checkNumberAndProceed(enteredNumber);
                  },
                ),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 11,
            ),
            const SizedBox(height: 16),
            const Text(
              "Recent",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildContactList([
              {"name": "Abdur Rakib Rafi", "number": "01123456789"},
              {"name": "Tabbusum Ruhi", "number": "01123456789"},
              {"name": "John Doe", "number": "01123456789"},
            ], context),
            const Divider(),
            const Text(
              "All Contact",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildContactList([
              {"name": "Father", "number": "01123456789"},
              {"name": "Mother 2", "number": "01123456789"},
            ], context),
          ],
        ),
      ),
    );
  }

  Widget _buildContactList(
      List<Map<String, String>> contacts, BuildContext context) {
    return Column(
      children: contacts.map((contact) {
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(contact["name"]!),
          subtitle: Text(contact["number"]!),
          onTap: () async {
            final number = contact["number"]!;
            if (!_isValidNumber(number)) {
              _showErrorDialog(context, "Invalid contact number format");
              return;
            }
            await _checkNumberAndProceed(number);
          },
        );
      }).toList(),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
