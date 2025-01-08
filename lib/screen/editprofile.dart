import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/constants/apptheme.dart";
import "package:imm_hotel_app/constants/server.dart";

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  bool _isLoading = false;
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "token");

    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('${ServerConstant.server}/customer/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _emailController.text = data['data']['email'] ?? '';
          _nameController.text = data['data']['name'] ?? '';
          _phoneController.text = data['data']['telephone'] ?? '';
        });
      } else {
        throw Exception("Failed to fetch profile.");
      }
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> editProfile() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "token");

    setState(() => _isLoading = true);

    if (_passwordController.text != _passwordConfirmController.text) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse('${ServerConstant.server}/customer/editprofile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'telephone': _phoneController.text,
          if (_passwordController.text.isNotEmpty)
            'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('แก้ไขโปรไฟล์สำเร็จ')),
        );
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('ไม่สามารถแก้ไขโปรไฟล์ได้')),
        );
      }
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: MaterialApp(
        title: "Edit Profile",
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: ThemeData(
          fontFamily: 'NotoSansThai',
          colorScheme: AppTheme.lightColorDefault,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text("แก้ไขโปรไฟล์", style: TextStyle(color: Colors.white),),
            backgroundColor: const Color.fromARGB(255, 149, 97, 81),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context); // ย้อนกลับไปหน้าก่อนหน้า
              },
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        _buildTextField(
                          controller: _emailController,
                          label: 'อีเมลล์',
                          icon: Icons.email,
                          readOnly: true,
                        ),
                        _buildTextField(
                          controller: _nameController,
                          label: 'ชื่อ-นามสกุล',
                          icon: Icons.person,
                        ),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'เบอร์โทรศัพท์',
                          icon: Icons.phone,
                        ),
                        _buildPasswordField(
                          controller: _passwordController,
                          label: 'รหัสผ่านใหม่ (ถ้ามี)',
                          icon: Icons.lock,
                        ),
                        _buildPasswordField(
                          controller: _passwordConfirmController,
                          label: 'ยืนยันรหัสผ่านใหม่',
                          icon: Icons.lock,
                        ),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        obscureText: _isObscure,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
          suffixIcon: IconButton(
            icon: Icon(
              _isObscure ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isObscure = !_isObscure;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          onPressed: editProfile,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
                MaterialColors.primaryBackgroundColor),
          ),
          child: const Text('บันทึกการเปลี่ยนแปลง', style: TextStyle(color: Colors.white),),
        ),
      ),
    );
  }
}
