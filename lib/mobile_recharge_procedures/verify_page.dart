import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payit_1/mobile_recharge_procedures/dialog_box_widget.dart';
import 'package:payit_1/mobile_recharge_procedures/recipient_page.dart';
//import 'package:payit_1/send_money_procedures/dialog_box_widget.dart';
//import 'package:payit_1/utils/contact_utils.dart';

class VerifyPinPage extends StatefulWidget {
  final String recipientNumber;
  final String recipientName;
  final String operatorLogo;
  final String amount;

  const VerifyPinPage({
    super.key,
    required this.recipientName,
    required this.recipientNumber,
    required this.operatorLogo,
    required this.amount,
  });

  @override
  _VerifyPinPageState createState() => _VerifyPinPageState();
}

class _VerifyPinPageState extends State<VerifyPinPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _referenceController = TextEditingController();
  String _enteredPin = '';
  String _errorMessage = '';
  bool _isLoading = false;
  bool _isKeypadVisible = false;
  bool _isPrepaidSelected = true;

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  void _toggleKeypad(bool show) {
    setState(() {
      _isKeypadVisible = show;
    });
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_enteredPin.length < 4) {
        _enteredPin += number;
        _errorMessage = '';
      }
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_enteredPin.isNotEmpty) {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (_isKeypadVisible) {
      _toggleKeypad(false);
      return false;
    }
    return true;
  }

  Future<void> _verifyPin() async {
    if (_enteredPin.length != 4) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_currentUser?.phoneNumber == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore
          .collection('users')
          .doc(_currentUser!.phoneNumber)
          .get();

      if (!doc.exists) {
        throw Exception('User document not found');
      }

      final userData = doc.data() as Map<String, dynamic>;
      final storedPin = userData['pin'] as String? ?? '';
      final currentBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;
      final transactionAmount = double.parse(widget.amount);

      if (_enteredPin == storedPin) {
        final newBalance = currentBalance - transactionAmount;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WidgetOfDialogBox(
              recipientName: widget.recipientNumber,
              recipientNumber: widget.recipientNumber,
              amount: widget.amount,
              reference: _referenceController.text,
              newBalance: newBalance.toStringAsFixed(2),
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Incorrect PIN';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error verifying PIN. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildNumberButton(String number, {String? letters}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNumberPressed(number),
        child: SizedBox(
          height: 70,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                if (letters != null)
                  Text(
                    letters,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final totalAmount = double.parse(widget.amount) + 0.0;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mobile Recharge',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.purple,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildErrorDisplay(),
                      _buildRecipientInfo(),
                      const SizedBox(height: 20),
                      _buildAmountDetails(),
                      const SizedBox(height: 20),
                      _buildPaymentTypeSelector(),
                      const SizedBox(height: 20),
                      _buildPinInputField(),
                    ],
                  ),
                ),
              ),
            ),
            _buildNumberPad(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return _errorMessage.isNotEmpty
        ? Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.red[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildRecipientInfo() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey,
              child: Text(
                ContactUtils.getInitials(widget.recipientNumber),
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
                Text(widget.recipientName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Text(widget.recipientNumber,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Text(_isPrepaidSelected ? 'Prepaid' : 'Postpaid',
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            const Spacer(),
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(widget.operatorLogo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountDetails() {
    final totalAmount = double.parse(widget.amount) + 0.0;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAmountColumn('Amount', '৳${widget.amount}'),
            _buildAmountColumn('Charge', '৳0.00'),
            _buildAmountColumn('Total', '৳${totalAmount.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountColumn(String title, String value) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }

  Widget _buildPaymentTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('Prepaid'),
          selected: _isPrepaidSelected,
          selectedColor: Colors.purple,
          onSelected: (selected) => setState(() => _isPrepaidSelected = true),
        ),
        const SizedBox(width: 20),
        ChoiceChip(
          label: const Text('Postpaid'),
          selected: !_isPrepaidSelected,
          selectedColor: Colors.purple,
          onSelected: (selected) => setState(() => _isPrepaidSelected = false),
        ),
      ],
    );
  }

  Widget _buildPinInputField() {
    return GestureDetector(
      onTap: () => setState(() => _isKeypadVisible = true),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 0.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(Icons.lock, color: Color(0xFFE11471), size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(text: _enteredPin),
                    decoration: const InputDecoration(
                      hintText: 'Enter PIN',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    textAlign: TextAlign.center,
                    obscureText: true,
                    maxLength: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Container(
        height: _isKeypadVisible ? null : 0,
        decoration: _buildNumberPadDecoration(),
        child: Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              children: _buildNumberPadButtons(),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNumberPadButtons() {
    return [
      _buildNumberButton('1'),
      _buildNumberButton('2'),
      _buildNumberButton('3'),
      _buildNumberButton('4'),
      _buildNumberButton('5'),
      _buildNumberButton('6'),
      _buildNumberButton('7'),
      _buildNumberButton('8'),
      _buildNumberButton('9'),
      _buildSpecialButton('✕', onPressed: _onBackspacePressed),
      _buildNumberButton('0'),
      _buildSpecialButton('✔', onPressed: _verifyPin),
    ];
  }

  BoxDecoration _buildNumberPadDecoration() {
    return const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
      ],
    );
  }

  Widget _buildSpecialButton(String text, {VoidCallback? onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 70,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: Colors.purple,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
