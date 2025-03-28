import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payit_1/send_money_procedures/pin_verify.dart';

class AmountPage extends StatefulWidget {
  final Map<String, String> recipient; // Recipient details

  const AmountPage({super.key, required this.recipient});

  @override
  State<AmountPage> createState() => _AmountPageState();
}

class _AmountPageState extends State<AmountPage> {
  final TextEditingController _amountController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  double _availableBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    if (_currentUser?.phoneNumber == null) return;

    final doc = await _firestore
        .collection('users')
        .doc(_currentUser!.phoneNumber)
        .get();

    if (doc.exists) {
      setState(() {
        _availableBalance = (doc.data()!['balance'] ?? 0.0).toDouble();
      });
    }
  }

  Future<double> _getCurrentBalance() async {
    if (_currentUser?.phoneNumber == null) return 0.0;

    final doc = await _firestore
        .collection('users')
        .doc(_currentUser!.phoneNumber)
        .get();

    return (doc.data()?['balance'] ?? 0.0).toDouble();
  }

  void _handleProceed() async {
    final enteredAmount = _amountController.text.trim();
    final amount = double.tryParse(enteredAmount) ?? 0.0;

    if (enteredAmount.isEmpty || amount <= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum amount is ৳20')),
      );
      return;
    }
    final currentBalance = await _getCurrentBalance();

    if (amount > currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance')),
      );
      return;
    }

    final recipientName = widget.recipient["name"] ?? "Unknown";
    final recipientNumber =
        widget.recipient["number"]?.startsWith('+88') ?? false
            ? widget.recipient["number"]!
            : '+88${widget.recipient["number"] ?? ''}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PinReferencePage(
          recipient: {
            'name': recipientName,
            'number': recipientNumber,
          },
          amount: enteredAmount,
        ),
      ),
    );
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
          children: [
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(widget.recipient["name"] ?? "Unknown Recipient"),
              subtitle: Text(
                widget.recipient["number"]?.startsWith('+88') ?? false
                    ? widget.recipient["number"]!
                    : '+88${widget.recipient["number"] ?? ''}',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '৳',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            StreamBuilder<DocumentSnapshot>(
              stream: _currentUser?.phoneNumber != null
                  ? _firestore
                      .collection('users')
                      .doc(_currentUser!.phoneNumber)
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final balance = data?['balance'] ?? 0.0;

                return Text(
                  "Available Balance: ৳${balance.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.grey),
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: const [
                    Icon(Icons.send, color: Colors.pink),
                    Text("Send Money"),
                  ],
                ),
                Column(
                  children: const [
                    Icon(Icons.card_giftcard, color: Colors.pink),
                    Text("Gift"),
                  ],
                ),
                Column(
                  children: const [
                    Icon(Icons.cake, color: Colors.pink),
                    Text("Birthday"),
                  ],
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _handleProceed,
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: const Text(
                "Proceed",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            ),
          ],
        ),
      ),
    );
  }
}
