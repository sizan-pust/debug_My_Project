import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payit_1/home_page.dart';
import 'package:payit_1/qr_scan.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.phoneNumber)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final firstName = userData['firstName'] ?? '';
          final lastName = userData['lastName'] ?? '';
          final mobileNumber = userData['mobileNumber'] ?? '';
          final profilePicture = userData['profilePicture']?.toString();

          return Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 180,
                    decoration: const BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$firstName $lastName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$mobileNumber, General Consumer eAC',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            backgroundImage: profilePicture != null
                                ? MemoryImage(base64Decode(profilePicture))
                                : null,
                            child: profilePicture == null
                                ? const Icon(Icons.person,
                                    size: 40, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.purple,
                              child: const Icon(Icons.edit,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _sectionTitle("Services"),
                    _menuTile(Icons.account_balance_wallet, "Balance Inquiry"),
                    _menuTile(Icons.receipt_long, "Mini Statement"),
                    _menuTile(Icons.lock_clock, "Transaction Limits"),
                    _menuTile(Icons.percent, "Service Charges"),
                    _sectionTitle("Information"),
                    _menuTile(Icons.qr_code, "My QR"),
                    _menuTile(Icons.location_on, "Store Locator"),
                    _sectionTitle("Others"),
                    _menuTile(Icons.help_outline, "Help Center"),
                    _menuTile(Icons.security, "Privacy Policy"),
                    _menuTile(Icons.description, "Terms & Conditions"),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String label) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.purple),
          title: Text(label, style: const TextStyle(fontSize: 16)),
          onTap: () {
            // TODO: Handle tile tap
          },
        ),
        const Divider(height: 1, thickness: 0.6),
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRScanScreen()),
            );
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
}
