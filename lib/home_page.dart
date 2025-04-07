import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payit_1/more.dart';
import 'package:payit_1/qr_scan.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showBalance = false;
  Timer? _balanceTimer;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  String _getInitials(String firstName, String lastName) {
    return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
        .toUpperCase();
  }

  @override
  void dispose() {
    _balanceTimer?.cancel(); // Cancel timer on dispose
    super.dispose();
  }

  void _handleBalanceTap() {
    // Cancel existing timer if any
    _balanceTimer?.cancel();

    setState(() {
      _showBalance = true;
    });

    // Start new timer
    _balanceTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        // Check if widget is still in tree
        setState(() {
          _showBalance = false;
        });
      }
    });
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
      body: Column(
        children: [
          // 🔴 Curved Header
          ClipPath(
            clipper: CurvedAppBarClipper(),
            child: Container(
              color: Colors.purple,
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
              width: double.infinity,
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(_currentUser!.phoneNumber)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error loading user',
                          style: TextStyle(color: Colors.white)),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final firstName = userData['firstName'] ?? '';
                  final lastName = userData['lastName'] ?? '';
                  final mobileNumber = userData['mobileNumber'] ?? '';
                  final profilePicture = userData['profilePicture']?.toString();
                  final balance = (userData['balance'] ?? 0.0).toDouble();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white,
                            backgroundImage: profilePicture != null
                                ? MemoryImage(base64Decode(profilePicture))
                                : null,
                            child: profilePicture == null
                                ? Text(
                                    _getInitials(firstName, lastName),
                                    style: const TextStyle(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$firstName $lastName",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$mobileNumber, General Consumer",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          const Spacer(),
                          GestureDetector(
                            onTap: _handleBalanceTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _showBalance
                                    ? "৳ ${balance.toStringAsFixed(2)}"
                                    : "Tap for Balance",
                                style: const TextStyle(
                                  color: Colors.purple,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.notifications,
                                color: Colors.white),
                            onPressed: () {
                              // TODO: Notification action
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 4),

          // 🔵 Services Section
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
                _buildServiceTile(context, Icons.money, "Cash Out", '/cashOut'),
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

          // 🔘 Ad Section
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

      // 🔻 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            // Scan QR index
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const QRScanScreen()));
          }
          if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MoreScreen()));
          }
        },
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
        if (route == '/scanQR') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const QRScanScreen()));
        } else {
          Navigator.pushNamed(context, route);
        }
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

class CurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 30); // Reduced curve height from 30 to 20
    path.quadraticBezierTo(
        size.width / 2,
        size.height, // Move control point higher
        size.width,
        size.height - 30); // Reduced curve height from 30 to 20
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
