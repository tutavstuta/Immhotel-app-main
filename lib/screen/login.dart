import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:imm_hotel_app/constants/theme.dart';
import 'package:imm_hotel_app/constants/apptheme.dart';
import 'package:imm_hotel_app/constants/server.dart';
import 'package:imm_hotel_app/screen/register.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _isObscure = true;

  Future<void> login(String email, String password) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ServerConstant.server}/customer/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        await storage.write(key: "token", value: body['token']);
        if (!mounted) return;
        Navigator.pushNamed(context, '/home');
      } else {
        _showError("อีเมลหรือรหัสผ่านไม่ถูกต้อง");
      }
    } catch (e) {
      _showError("เกิดข้อผิดพลาด: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken != null) {
        await _sendTokenToBackend("google", googleAuth.idToken!);
      } else {
        _showError("ไม่สามารถดึง Google ID Token ได้");
      }
    } catch (e) {
      _showError("Google Login ผิดพลาด: $e");
    }
  }

  Future<void> _handleFacebookLogin() async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!.token;
        await _sendTokenToBackend("facebook", accessToken);
      } else {
        _showError("Facebook Login ล้มเหลว: ${result.message}");
      }
    } catch (e) {
      if (e.toString().contains('MissingPluginException')) {
        _showError(
          "Facebook Login ผิดพลาด: MissingPluginException\n"
          "วิธีแก้ไข:\n"
          "- ให้ปิดแอปแล้วเปิดใหม่ (cold restart) หรือรัน 'flutter clean' แล้ว build ใหม่\n"
          "- ตรวจสอบว่าได้ติดตั้งและตั้งค่า plugin flutter_facebook_auth ถูกต้อง (android/app/build.gradle, AndroidManifest.xml, MainActivity, ฯลฯ)\n"
          "- หากเพิ่งเพิ่ม plugin ให้ปิด emulator/device แล้วเปิดใหม่"
        );
      } else {
        _showError("Facebook Login ผิดพลาด: $e");
      }
    }
  }

  Future<void> _sendTokenToBackend(String provider, String token) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ServerConstant.server}/customer/social-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'provider': provider, 'token': token}), // <<<< ตรงนี้
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        await storage.write(key: "token", value: body['token']);
        if (!mounted) return;
        Navigator.pushNamed(context, '/home');
      } else {
        _showError("เข้าสู่ระบบด้วย $provider ไม่สำเร็จ");
      }
    } catch (e) {
      _showError("เกิดข้อผิดพลาด: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        fontFamily: 'NotoSansThai',
        colorScheme: AppTheme.lightColorScheme,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset("assets/images/logo1.png")),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      prefixIcon: Icon(Icons.email),
                      labelText: 'อีเมลล์',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
                  child: TextField(
                    obscureText: _isObscure,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      labelText: 'รหัสผ่าน',
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
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () {
                              login(_emailController.text,
                                  _passwordController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MaterialColors.primary,
                              foregroundColor: MaterialColors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('เข้าสู่ระบบ'),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleGoogleSignIn,
                          icon: const Icon(Icons.g_mobiledata),
                          label: const Text("Google"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleFacebookLogin,
                          icon: const Icon(Icons.facebook),
                          label: const Text("Facebook"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("ยังไม่มีบัญชีผู้ใช้?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Register(),
                            ),
                          );
                        },
                        child: const Text("สมัครสมาชิก",
                            style:
                                TextStyle(color: MaterialColors.success)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
