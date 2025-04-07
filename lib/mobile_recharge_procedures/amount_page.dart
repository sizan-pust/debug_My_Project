import 'package:flutter/material.dart';
import 'package:payit_1/mobile_recharge_procedures/recipient_page.dart';
import 'package:payit_1/mobile_recharge_procedures/verify_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AmountPage extends StatefulWidget {
  final String recipientName;
  final String recipientNumber;
  final String operatorLogo;

  const AmountPage({
    super.key,
    required this.recipientNumber,
    required this.operatorLogo,
    required this.recipientName,
  });

  @override
  _AmountPageState createState() => _AmountPageState();
}

class _AmountPageState extends State<AmountPage> {
  final TextEditingController _amountController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool isProceedEnabled = false;
  double _balance = 0.0;
  bool _isLoading = true;
  String? _errorMessage;

  String get formattedBalance => NumberFormat.currency(
        symbol: '৳',
        decimalDigits: 2,
      ).format(_balance);

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    try {
      if (_currentUser?.phoneNumber == null) return;

      final doc = await _firestore
          .collection('users')
          .doc(_currentUser!.phoneNumber)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load balance';
        _isLoading = false;
      });
    }
  }

  void _updateProceedButton() {
    setState(() {
      isProceedEnabled = _amountController.text.isNotEmpty &&
          double.tryParse(_amountController.text) != null &&
          double.parse(_amountController.text) > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Recharge',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecipientInfo(),
              const SizedBox(height: 20),
              _buildAmountOptions(),
              const SizedBox(height: 40),
              _buildAmountInput(),
              const SizedBox(height: 20),
              _buildBalanceInfo(),
              const SizedBox(height: 30),
              _buildProceedButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey,
              child: Text(
                ContactUtils.getInitials(widget.recipientName),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.recipientNumber,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  widget.recipientName,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(widget.operatorLogo),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DefaultTabController(
          length: 6,
          child: Column(
            children: [
              TabBar(
                labelColor: Colors.pink,
                indicatorColor: Colors.pink,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Amount'),
                  Tab(text: 'Internet'),
                  Tab(text: 'My Offer'),
                  Tab(text: 'Call Rate'),
                  Tab(text: 'Minute'),
                  Tab(text: 'Bundle'),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountOptions() {
    return Wrap(
      spacing: 12,
      children:
          [69, 228, 398].map((amount) => _buildAmountChip(amount)).toList(),
    );
  }

  Widget _buildAmountChip(int amount) {
    return GestureDetector(
      onTap: () {
        _amountController.text = amount.toString();
        _updateProceedButton();
      },
      child: Chip(
        label: Text('৳$amount',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Center(
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 36, color: Colors.purple),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '৳0',
        ),
        onChanged: (_) => _updateProceedButton(),
      ),
    );
  }

  Widget _buildBalanceInfo() {
    return Column(
      children: [
        _isLoading
            ? const LinearProgressIndicator()
            : _errorMessage != null
                ? Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red))
                : Text('Available Balance: $formattedBalance',
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 16),
        const Row(
          children: [
            Icon(Icons.local_offer, color: Colors.purple),
            SizedBox(width: 8),
            Text('Coupon / Promo Code',
                style: TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildProceedButton() {
    return Center(
      child: ElevatedButton(
        onPressed: isProceedEnabled ? _navigateToVerifyPage : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isProceedEnabled ? Colors.purple : Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('Proceed',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  void _navigateToVerifyPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyPinPage(
          recipientNumber: widget.recipientNumber,
          operatorLogo: widget.operatorLogo,
          amount: _amountController.text,
          recipientName: widget.recipientName,
        ),
      ),
    );
  }
}
