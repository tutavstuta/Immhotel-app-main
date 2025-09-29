import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/constants/apptheme.dart";
import "package:imm_hotel_app/constants/server.dart";
import 'package:imm_hotel_app/screen/login.dart';

// Define a global key for ScaffoldMessenger
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isObscure = true;

  final storage = const FlutterSecureStorage(); // ประกาศตรงนี้

  // ฟังก์ชันสำหรับการสมัครสมาชิก (ส่งคำขอ API)
  Future<void> registerUser() async {
    setState(() {
      _isLoading = true;
    });

    // ตรวจสอบว่าฟิลด์ไม่ว่าง
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _passwordConfirmController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Center(child: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
          backgroundColor: Colors.white,
        ),
      );
      return;
    }

    // ตรวจสอบว่า password ตรงกันหรือไม่
    if (_passwordController.text != _passwordConfirmController.text) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Center(child: Text('รหัสผ่านไม่ตรงกัน')),
          backgroundColor: Colors.white,
        ),
      );
      return;
    }

    try {
      // ส่งคำขอ POST ไปยัง API
      final response = await http.post(
        Uri.parse('${ServerConstant.server}/customer/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': _nameController.text,
          'password': _passwordController.text,
          'telephone': _phoneController.text,
          'email': _emailController.text,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'];
        await storage.write(key: "token", value: token);

        if (!mounted) return;

        Navigator.pop(context);
      } else {
        if (!mounted) return;

        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Center(child: Text('ไม่สามารถสมัครสมาชิกได้ โปรดลองใหม่')),
            backgroundColor: Colors.white,
          ),
        );
      }
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Center(child: Text('เกิดข้อผิดพลาด: $e')),
          backgroundColor: Colors.white,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleFacebookRegister() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!.token;
        await _sendTokenToBackend("facebook", accessToken);
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Facebook Login ล้มเหลว: ${result.message}')),
        );
      }
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> _handleGoogleRegister() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // ผู้ใช้กดยกเลิก
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken != null) {
        await _sendTokenToBackend("google", idToken);
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Google Login ล้มเหลว')),
        );
      }
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<void> _sendTokenToBackend(String provider, String token) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ServerConstant.server}/customer/social-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'provider': provider, 'token': token}),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        await storage.write(key: "token", value: body['token']);
        if (!mounted) return;
        Navigator.pushNamed(context, '/home');
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('เข้าสู่ระบบด้วย $provider ไม่สำเร็จ')),
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
    return MaterialApp(
        title: "imm hotel",
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: ThemeData(
            fontFamily: 'NotoSansThai',
            colorScheme: AppTheme.lightColorDefault),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: MaterialColors.primaryBackgroundColor,
            toolbarHeight: 100,
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Image.asset('assets/images/logo2.png',
                    fit: BoxFit.cover,
                    width: 200,
                    alignment:
                        Alignment.bottomRight), // Replace with your logo image
              ),
            ],
          ),
          backgroundColor: MaterialColors.secondaryBackgroundColor,
          body: SingleChildScrollView(
            child: Center(
                child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                    color: MaterialColors.primaryBackgroundColor,
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 73,
                    child: Center(
                        child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(
                                  300), // Adjust the radius as needed
                              topRight: Radius.circular(300),
                            ),
                            child: SizedBox(
                                child: Container(
                                    alignment: Alignment.centerLeft,
                                    color:
                                        MaterialColors.secondaryBackgroundColor,
                                    child: const Padding(
                                      padding: EdgeInsets.only(left: 50),
                                      child: Text("สมัครสมาชิก",
                                          style: TextStyle(
                                              fontSize: 24,
                                              color: MaterialColors.secondary)),
                                    )))))),
                Padding(
                  padding:
                      const EdgeInsets.only(right: 20, left: 20, bottom: 20),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(
                              color: MaterialColors.onPrimary,
                              width: 1.0,
                              style: BorderStyle.solid),
                          gapPadding: 10),
                      prefixIcon: Icon(Icons.email),
                      labelText: 'อีเมลล์',
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(right: 20, left: 20, bottom: 20),
                  child: TextField(
                    obscureText: _isObscure,
                    controller: _passwordController,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0)),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 0, 0, 0),
                              width: 1.0,
                              style: BorderStyle.solid),
                          gapPadding: 10),
                      prefixIcon: const Icon(Icons.lock),
                      labelText: 'พาสเวิร์ด',
                      suffixIcon: IconButton(
                        icon: Icon(_isObscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(right: 20, left: 20, bottom: 20),
                  child: TextField(
                    obscureText: _isObscure,
                    controller: _passwordConfirmController,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0)),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 0, 0, 0),
                              width: 1.0,
                              style: BorderStyle.solid),
                          gapPadding: 10),
                      prefixIcon: const Icon(Icons.lock),
                      labelText: 'ยืนยันพาสเวิร์ด',
                      suffixIcon: IconButton(
                        icon: Icon(_isObscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(right: 20, left: 20, bottom: 20),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(
                              color: MaterialColors.onPrimary,
                              width: 1.0,
                              style: BorderStyle.solid),
                          gapPadding: 10),
                      prefixIcon: Icon(Icons.email),
                      labelText: 'ชื่อ-นามสกุล',
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(right: 20, left: 20, bottom: 20),
                  child: TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(
                              color: MaterialColors.onPrimary,
                              width: 1.0,
                              style: BorderStyle.solid),
                          gapPadding: 10),
                      prefixIcon: Icon(Icons.email),
                      labelText: 'เบอร์โทรศัพท์',
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: 20, left: 20, top: 20),
                    child: ElevatedButton(
                        onPressed: () {
                          registerUser();
                        },
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                MaterialColors.primaryBackgroundColor),
                            foregroundColor: WidgetStateProperty.all(
                                MaterialColors.primary),
                                ),
                                child: const Text('สมัครสมาชิก'),
                      ),
                  ),
                ),
                // ปุ่มสมัครด้วย Facebook/Google
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.facebook, color: Colors.white),
                      label: Text('สมัครด้วย Facebook'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: _handleFacebookRegister,
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: Icon(Icons.g_mobiledata, color: Colors.white),
                      label: Text('สมัครด้วย Google'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: _handleGoogleRegister,
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: 20, left: 20, top: 20),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("มีบัญชีอยู่แล้ว?",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 108, 108, 108))),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Login(),
                                ),
                              );
                            },
                            child: const Text(" Sign In",
                                style: TextStyle(color: MaterialColors.success)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ),
        ));
  }
}
