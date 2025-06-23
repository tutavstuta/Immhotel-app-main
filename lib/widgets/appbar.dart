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
  String? _userName; // null = ยังไม่ได้ล็อกอิน

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "token");

    if (token == null || token.isEmpty) {
      setState(() {
        _userName = null;
      });
      return;
    }

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
        setState(() {
          _userName = null;
        });
      }
    } catch (e) {
      setState(() {
        _userName = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(''),
      leadingWidth: 150,
      leading: Image.asset('assets/images/logo.jpg'),
      backgroundColor: MaterialColors.primaryBackgroundColor,
      foregroundColor: Colors.white,
      toolbarHeight: 80,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: _userName != null
              ? Row(
                  children: [
                    Text(
                      _userName!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _userMenu(),
                  ],
                )
              : TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
        ),
      ],
    );
  }

  // เมนูเมื่อผู้ใช้ล็อกอินแล้ว
  Widget _userMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.account_circle,
        color: Colors.white,
        size: 40,
      ),
      onSelected: (String result) {
        // ยังไม่ใช้ result โดยตรง
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
            onPressed: () async {
              const storage = FlutterSecureStorage();
              await storage.delete(key: "token");
              setState(() {
                _userName = null;
              });
              Navigator.pop(context); // ปิด popup menu
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
            child: const Text('ออกจากระบบ'),
          ),
        ),
      ],
    );
  }
}
