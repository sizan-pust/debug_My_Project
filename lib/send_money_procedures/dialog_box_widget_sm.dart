import 'package:flutter/material.dart';
import 'package:payit_1/send_money_procedures/animatedbutton_widget.dart';
import 'package:payit_1/send_money_procedures/successful_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WidgetOfDialogBox extends StatelessWidget {
  final String recipientName;
  final String recipientNumber;
  final String amount;
  final String reference;
  final String newBalance;

  const WidgetOfDialogBox({
    super.key,
    required this.recipientName,
    required this.recipientNumber,
    required this.amount,
    required this.reference,
    required this.newBalance,
  });
  Future<void> _updateBalances(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser;

    try {
      if (currentUser?.phoneNumber == null) {
        throw Exception('User not authenticated');
      }

      final amount = double.parse(this.amount);
      final senderRef =
          firestore.collection('users').doc(currentUser!.phoneNumber);
      final recipientRef = firestore.collection('users').doc(recipientNumber);

      await firestore.runTransaction((transaction) async {
        final senderDoc = await transaction.get(senderRef);
        final senderBalance = (senderDoc.data()!['balance'] as num).toDouble();

        final recipientDoc = await transaction.get(recipientRef);
        final recipientBalance =
            (recipientDoc.data()!['balance'] as num).toDouble();

        if (senderBalance < amount) {
          throw Exception('Insufficient balance');
        }

        transaction.update(senderRef, {'balance': senderBalance - amount});
        transaction
            .update(recipientRef, {'balance': recipientBalance + amount});
      });

      // ✅ Send SMS after successful transaction
      // final senderNumber = currentUser.phoneNumber!;
      // final senderMessage =
      //     'Send money to $recipientNumber successful. Amount Tk $amount';
      // final recipientMessage =
      //     'You have received Tk $amount from $senderNumber';

      // await sendSMS(senderNumber, senderMessage);
      // await sendSMS(recipientNumber, recipientMessage);

      // ✅ Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: WidgetOfConfirmation(
            recipientName: recipientName,
            recipientNumber: recipientNumber,
          ),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Transaction Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
      print('Transaction Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0, right: 12.0),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const SizedBox(
                width: 34,
                height: 34,
                child: Icon(
                  Icons.close_sharp,
                  size: 30,
                  color: Colors.pink,
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text(
                          "Confirm to",
                          style: TextStyle(
                            color: Color(0xFFE11471),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Send Money",
                          style: TextStyle(
                            color: Color(0xFFE11471),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 6),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/user.png',
                            width: 65,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipientName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(recipientNumber),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      indent: 10,
                      endIndent: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 2, 12, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '৳$amount',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            color: Colors.black12,
                            width: 2,
                            height: 50,
                          ),
                          Column(
                            children: [
                              const Text(
                                'New Balance',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '৳$newBalance',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      indent: 10,
                      endIndent: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 2, 38, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  const Text(
                                    'Reference',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    reference.isEmpty ? 'N/A' : reference,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.black12,
                            width: 2,
                            height: 50,
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Text(''),
                                  SizedBox(height: 4),
                                  Text(''),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      indent: 10,
                      endIndent: 10,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/images/fnf.png',
                            width: 45,
                          ),
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'You can Send Money free up ro\n25,000 TK monthly to adding Priyo\nnumber',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedButton(
              onComplete: () => _updateBalances(context), //{
              //   Navigator.pop(context);
              //   showDialog(
              //     context: context,
              //     builder: (context) => Dialog(
              //       insetPadding: EdgeInsets.all(20),
              //       child: WidgetOfConfirmation(
              //         recipientName: recipientName,
              //         recipientNumber: recipientNumber,
              //       ),
              //     ),
              //   );
              // },
            ),
          )
        ],
      ),
    );
  }
}
