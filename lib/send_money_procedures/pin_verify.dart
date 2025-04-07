import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payit_1/send_money_procedures/dialog_box_widget_sm.dart';

class PinReferencePage extends StatefulWidget {
  final Map<String, String> recipient;
  final String amount;

  const PinReferencePage({
    super.key,
    required this.recipient,
    required this.amount,
  });

  @override
  State<PinReferencePage> createState() => _PinReferencePageState();
}

class _PinReferencePageState extends State<PinReferencePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _referenceController = TextEditingController();
  String _enteredPin = '';
  String _errorMessage = '';
  bool _isLoading = false;
  bool _isKeypadVisible = false;

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
              recipientName: widget.recipient["name"]!,
              recipientNumber: widget.recipient["number"]!,
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          toolbarHeight: 65,
          title: const Center(
            child: Text(
              'Send Money',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          iconTheme: const IconThemeData(
            size: 30,
            color: Colors.white,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0, right: 12.0),
              child: InkWell(
                child: SizedBox(
                  width: 50,
                  height: 45,
                  child: Image.asset('assets/images/logo.png'),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          if (_errorMessage.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              color: Colors.red[50],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text(
                                    _errorMessage,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey, width: 0.3),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'To',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 5, 0, 8),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/user.png',
                                          width: 65,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.recipient["name"]!,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(widget.recipient["number"]!),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey, width: 0.2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      const Text(
                                        'Amount',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Text('৳${widget.amount}'),
                                    ],
                                  ),
                                  const Column(
                                    children: [
                                      Text('Charge',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                      Text('৳0.00'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text('Total',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                      Text('৳${widget.amount}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey, width: 0.2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Reference',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15),
                                        ),
                                        TextField(
                                          controller: _referenceController,
                                          decoration: const InputDecoration(
                                            hintStyle: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            hintText: 'Tap to add a note',
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Text('0/50'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => _toggleKeypad(true),
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0.2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.lock,
                                      color: Color(0xFFE11471),
                                      size: 30,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: AbsorbPointer(
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            hintText: 'Enter PIN',
                                            border: InputBorder.none,
                                            hintStyle: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                            contentPadding: EdgeInsets.zero,
                                            alignLabelWithHint: true,
                                          ),
                                          textAlign: TextAlign.center,
                                          controller: TextEditingController(
                                              text: _enteredPin),
                                          obscureText: true,
                                          maxLength: 4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Container(
                  height: _isKeypadVisible ? 390 : 0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          children: [
                            _buildNumberButton('1'),
                            _buildNumberButton('2'),
                            _buildNumberButton('3'),
                            _buildNumberButton('4'),
                            _buildNumberButton('5'),
                            _buildNumberButton('6'),
                            _buildNumberButton('7'),
                            _buildNumberButton('8'),
                            _buildNumberButton('9'),
                            _buildSpecialButton('✕',
                                onPressed: _onBackspacePressed),
                            _buildNumberButton('0'),
                            _buildSpecialButton('✔', onPressed: _verifyPin),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
