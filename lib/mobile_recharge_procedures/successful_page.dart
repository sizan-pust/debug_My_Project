import 'package:flutter/material.dart';
import 'package:payit_1/home_page.dart';

class WidgetOfConfirmation extends StatelessWidget {
  final String recipientName;
  final String recipientNumber;

  const WidgetOfConfirmation({
    super.key,
    required this.recipientName,
    required this.recipientNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('Your',
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: 18,
                                fontWeight: FontWeight.w500)),
                        SizedBox(width: 5),
                        Text('Mobile Recharge',
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        SizedBox(width: 5),
                        Text('request is',
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: 18,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Successful',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 19,
                              fontWeight: FontWeight.w400,
                            )),
                        Image.asset(
                          'assets/images/success.jpg',
                          width: 33,
                        )
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
                    // Other sections remain unchanged...
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.purple,
        height: 54,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Back to Home',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 30,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
