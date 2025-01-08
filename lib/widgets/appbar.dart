import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/constants/server.dart";

class AppBarHome extends StatefulWidget implements PreferredSizeWidget {
  const AppBarHome({super.key});

  @override
  State<AppBarHome> createState() => _AppBarHomeState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarHomeState extends State<AppBarHome> {
  String _userName = '';  // Variable to store username

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // Function to fetch username from the server
  Future<void> _fetchUserName() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "token");

    try {
      final response = await http.get(
        Uri.parse('${ServerConstant.server}/customer/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userName = data['data']['name'] ?? 'ไม่มีชื่อ';
        });
      } else {
        throw Exception("Failed to fetch user data");
      }
    } catch (e) {
      setState(() {
        _userName = 'ไม่มีชื่อ';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(''),
      leadingWidth: 150,
      leading: Image.asset(
        'assets/images/logo.jpg',
      ),
      backgroundColor: MaterialColors.primaryBackgroundColor,
      foregroundColor: Colors.white,
      toolbarHeight: 80,
      actions: <Widget>[
        // Add the username in the AppBar directly
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Text(
            '$_userName',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // PopupMenu for user actions
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.account_circle,
            color: Colors.white,
            size: 40,
          ),
          onSelected: (String result) {
            setState(() {
              // Update selected option
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'editprofile',
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/editprofile');
                },
                child: const Text('แก้ไขข้อมูลส่วนตัว'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'signout',
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('ออกจากระบบ'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
