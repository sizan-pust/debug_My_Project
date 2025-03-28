import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showBalance = false; // State to track if balance is visible
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  String _getInitials(String firstName, String lastName) {
    return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser?.phoneNumber == null) {
      return const Scaffold(
        body: Center(child: Text('User not authenticated')),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection('users')
              .doc(_currentUser!.phoneNumber)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error loading data');
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('Loading...');
            }
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final firstName = userData['firstName'] ?? '';
            final lastName = userData['lastName'] ?? '';

            return Text(
              '$firstName $lastName'.trim(),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Notification action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // User Info Section
          Container(
            color: Colors.purple,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4), //8

            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(_currentUser.phoneNumber)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error loading user data');
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const LinearProgressIndicator();
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final firstName = userData['firstName'] ?? '';
                final lastName = userData['lastName'] ?? '';
                final mobileNumber = userData['mobileNumber'] ?? '';
                final profilePicture = userData['profilePicture']?.toString();
                final balance = (userData['balance'] ?? 0.0).toDouble();

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage: profilePicture != null
                          ? MemoryImage(base64Decode(profilePicture))
                          : null,
                      child: profilePicture == null
                          ? Text(
                              _getInitials(firstName, lastName),
                              style: const TextStyle(color: Colors.purple),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mobileNumber.isNotEmpty
                                ? "$mobileNumber, General Consumer eAC"
                                : "Unknown Number",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showBalance = !_showBalance;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.purple,
                            ),
                            child: const Text("Tap for Balance"),
                          ),
                          const SizedBox(height: 8),
                          AnimatedOpacity(
                            duration: const Duration(seconds: 1),
                            opacity: _showBalance ? 1.0 : 0.0,
                            child: Text(
                              _showBalance
                                  ? "৳ ${balance.toStringAsFixed(2)}"
                                  : "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Services Section
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildServiceTile(
                    context, Icons.send_to_mobile, "Send Money", '/sendMoney'),
                _buildServiceTile(context, Icons.phone_android,
                    "Mobile Recharge", '/mobileRecharge'),
                _buildServiceTile(context, Icons.money, "Cash Out",
                    '/cashOut'), // Add the cashOut page
                _buildServiceTile(context, Icons.shopping_cart, "Merchant Pay",
                    '/merchantPay'),
                _buildServiceTile(context, Icons.add, "Add Money", '/addMoney'),
                _buildServiceTile(
                    context, Icons.receipt, "Bill Pay", '/billPay'),
                _buildServiceTile(context, Icons.account_balance,
                    "Bank Transfer", '/bankTransfer'),
                _buildServiceTile(
                    context, Icons.link, "Link A/C Setup", '/linkAccount'),
                _buildServiceTile(
                    context, Icons.swap_horiz, "Binimoy", '/binimoy'),
                _buildServiceTile(
                    context, Icons.directions_car, "e-Toll", '/eToll'),
                _buildServiceTile(
                    context, Icons.volunteer_activism, "Donation", '/donation'),
                _buildServiceTile(
                    context, Icons.beach_access, "Pension", '/pension'),
              ],
            ),
          ),
          // Ad Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 100,
              color: Colors.grey[200],
              child: const Center(
                child: Text(
                  "Ad Space",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "Scan QR"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "More"),
        ],
      ),
    );
  }

  Widget _buildServiceTile(
      BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route); // Navigate to the route
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.purple.withOpacity(0.1),
            child: Icon(icon, size: 28, color: Colors.purple),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
