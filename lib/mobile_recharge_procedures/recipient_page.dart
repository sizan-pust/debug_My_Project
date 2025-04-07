import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:payit_1/mobile_recharge_procedures/amount_page.dart';

class MobileRechargePage extends StatefulWidget {
  const MobileRechargePage({super.key});

  @override
  _MobileRechargePageState createState() => _MobileRechargePageState();
}

class _MobileRechargePageState extends State<MobileRechargePage> {
  final TextEditingController _recipientController = TextEditingController();
  List<Contact> _contacts = [];
  bool _contactsLoading = false;
  String _errorMessage = '';

  // Helper function to get initials
  // String _getInitials(Contact contact) {
  //   return contact.displayName.isNotEmpty
  //       ? contact.displayName
  //           .split(' ')
  //           .map((e) => e.isNotEmpty ? e[0] : '')
  //           .take(2)
  //           .join()
  //           .toUpperCase()
  //       : '?';
  // }

  @override
  void initState() {
    super.initState();
    _requestContactsPermission();
  }

  Future<void> _requestContactsPermission() async {
    setState(() {
      _contactsLoading = true;
      _errorMessage = '';
    });

    var status = await Permission.contacts.status;
    if (status.isDenied) {
      status = await Permission.contacts.request();
    }

    if (status.isPermanentlyDenied) {
      setState(() {
        _errorMessage = 'Please enable contacts permission in app settings';
        _contactsLoading = false;
      });
      await openAppSettings();
      return;
    }

    if (status.isGranted) {
      await _loadContacts();
    } else {
      setState(() {
        _errorMessage = 'Contacts permission required to access your contacts';
        _contactsLoading = false;
      });
    }
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: true,
      );
      setState(() {
        _contacts = contacts.where((c) => c.phones.isNotEmpty).toList();
        _contactsLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load contacts';
        _contactsLoading = false;
      });
    }
  }

  void _showOperatorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return OperatorBottomSheet(
          recipientName: _recipientController.text,
          recipientNumber: _recipientController.text,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        centerTitle: true,
        title: const Text(
          'Mobile Recharge',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phone Input Row
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.purple),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _recipientController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Enter 11-digit Mobile Number',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.purple),
                  onPressed: () {
                    if (_recipientController.text.isNotEmpty) {
                      _showOperatorBottomSheet(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid mobile number'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const Divider(),
            // Contacts Section
            const Text(
              'Own Number & Contacts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildContactsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    if (_errorMessage.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
              _requestContactsPermission();
            },
            child: const Text('Open Settings'),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            child: Text(
              ContactUtils.getInitials(contact.displayName),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(contact.displayName),
          subtitle: Text(contact.phones.first.number),
          onTap: () {
            _recipientController.text = contact.phones.first.number;
            _showOperatorBottomSheet(context);
          },
        );
      },
    );
  }
}

class OperatorBottomSheet extends StatelessWidget {
  final String recipientName;
  final String recipientNumber;

  const OperatorBottomSheet({
    super.key,
    required this.recipientName,
    required this.recipientNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Choose Your Operator',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Choose the current operator for this number',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            childAspectRatio: 1.05,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            children: [
              _buildOperatorLogo(
                context,
                imagePath: 'assets/images/robi_logo.png',
                operatorName: 'Robi',
              ),
              _buildOperatorLogo(
                context,
                imagePath: 'assets/images/gp_logo.png',
                operatorName: 'GP',
              ),
              _buildOperatorLogo(
                context,
                imagePath: 'assets/images/banglalink_logo.png',
                operatorName: 'Banglalink',
              ),
              _buildOperatorLogo(
                context,
                imagePath: 'assets/images/airtel_logo.png',
                operatorName: 'Robi',
              ),
              _buildOperatorLogo(
                context,
                imagePath: 'assets/images/teletalk_logo.png',
                operatorName: 'Robi',
              ),
              _buildOperatorLogo(
                context,
                imagePath: 'assets/images/skitto_logo.png',
                operatorName: 'Robi',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorLogo(
    BuildContext context, {
    required String imagePath,
    required String operatorName,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AmountPage(
              recipientName: recipientName,
              recipientNumber: recipientNumber,
              operatorLogo: imagePath,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class ContactUtils {
  static String getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ')..removeWhere((e) => e.isEmpty);
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : 'U';
  }
}
