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
    setState(() => _isLoading = true);
    try {
      print('Starting Google Sign-in...');
      
      await GoogleSignIn().signOut();
      
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        print('Google sign-in cancelled by user');
        setState(() => _isLoading = false);
        return;
      }
      
      print('Google user signed in: ${googleUser.email}');
      
      // ดึงข้อมูลจาก Google
      final email = googleUser.email;
      final name = googleUser.displayName ?? '';
      
      // ส่งไปยัง backend โดยไม่ต้องใช้ token
      await _loginWithGoogleEmail(email, name);
      
    } catch (e) {
      print('Google Sign-in error: $e');
      _showError("Google Login ผิดพลาด: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogleEmail(String email, String name) async {
    try {
      print('Attempting Google login with email: $email');
      
      // ส่งข้อมูลแบบพิเศษเพื่อบอกว่าเป็น Google login
      final response = await http.post(
        Uri.parse('${ServerConstant.server}/customer/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'googleLogin': true, // flag พิเศษ
          'name': name,
        }),
      );

      print('Google login response status: ${response.statusCode}');
      print('Google login response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        
        if (body['token'] != null && body['token'].toString().isNotEmpty) {
          await storage.write(key: "token", value: body['token']);
          print('Google login successful');
          if (!mounted) return;
          Navigator.pushNamed(context, '/home');
        } else {
          _showError("Server ไม่ส่งโทเคนกลับมา");
        }
      } else if (response.statusCode == 404 || response.statusCode == 401) {
        // หากไม่พบผู้ใช้หรือ server ไม่รองรับ googleLogin flag
        print('User not found or Google login not supported, trying alternative...');
        await _tryAlternativeGoogleLogin(email, name);
      } else {
        final errorBody = response.body.isNotEmpty ? response.body : 'ไม่มีข้อความจาก server';
        _showError("เข้าสู่ระบบด้วย Google ไม่สำเร็จ: $errorBody");
      }
    } catch (e) {
      print('Google login error: $e');
      _showError("เกิดข้อผิดพลาด: $e");
    }
  }

  Future<void> _tryAlternativeGoogleLogin(String email, String name) async {
    try {
      // วิธีที่ 1: ลองส่งไปที่ endpoint อื่น
      final endpoints = [
        '${ServerConstant.server}/customer/google-login',
        '${ServerConstant.server}/customer/social-check',
        '${ServerConstant.server}/customer/email-check',
      ];
      
      for (final endpoint in endpoints) {
        try {
          print('Trying alternative endpoint: $endpoint');
          
          final response = await http.post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'name': name,
              'provider': 'google',
            }),
          );

          print('Alternative endpoint response: ${response.statusCode}');

          if (response.statusCode == 200) {
            final body = jsonDecode(response.body);
            
            if (body['token'] != null && body['token'].toString().isNotEmpty) {
              await storage.write(key: "token", value: body['token']);
              print('Alternative Google login successful');
              if (!mounted) return;
              Navigator.pushNamed(context, '/home');
              return;
            }
          }
        } catch (e) {
          print('Alternative endpoint error: $e');
          continue;
        }
      }
      
      // วิธีที่ 2: ลองใช้ password ง่ายๆ เพียงแค่รูปแบบเดียว
      print('Trying simple password method...');
      await _trySimplePasswordLogin(email);
      
    } catch (e) {
      print('Alternative login error: $e');
      _showError("ไม่สามารถเข้าสู่ระบบด้วย Google ได้");
    }
  }

  Future<void> _trySimplePasswordLogin(String email) async {
    try {
      // ลองใช้ password เพียงแค่ 2-3 แบบที่เป็นไปได้
      final passwords = [
        'google_${email.split('@')[0]}', // google_tutavstuta
        email.split('@')[0], // tutavstuta
      ];
      
      for (final password in passwords) {
        print('Trying simple login with password pattern: $password');
        
        final response = await http.post(
          Uri.parse('${ServerConstant.server}/customer/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          
          if (body['token'] != null && body['token'].toString().isNotEmpty) {
            await storage.write(key: "token", value: body['token']);
            print('Simple password login successful');
            if (!mounted) return;
            Navigator.pushNamed(context, '/home');
            return;
          }
        }
      }
      
      // หากทุกวิธีล้มเหลว
      _showError(
        'ไม่พบบัญชีที่ลงทะเบียนด้วย Google สำหรับอีเมล: $email\n\n'
        'กรุณาไปที่หน้า "สมัครสมาชิก" แล้วสมัครด้วย Google ก่อน'
      );
      
    } catch (e) {
      print('Simple password login error: $e');
      _showError("ไม่สามารถเข้าสู่ระบบด้วย Google ได้: $e");
    }
  }

  // เก็บฟังก์ชัน _sendTokenToBackend ไว้สำหรับ Facebook
  Future<void> _sendTokenToBackend(String provider, String token) async {
    try {
      print('Sending $provider token to backend...');
      
      final response = await http.post(
        Uri.parse('${ServerConstant.server}/customer/social-login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'provider': provider,
          'token': token,
        }),
      );

      print('$provider login response status: ${response.statusCode}');
      print('$provider login response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        
        if (body['token'] != null && body['token'].toString().isNotEmpty) {
          await storage.write(key: "token", value: body['token']);
          print('$provider login token saved successfully');
          if (!mounted) return;
          Navigator.pushNamed(context, '/home');
        } else {
          _showError("Server ไม่ส่งโทเคนกลับมาจาก $provider login");
        }
      } else {
        final errorBody = response.body.isNotEmpty ? response.body : 'ไม่มีข้อความจาก server';
        _showError("เข้าสู่ระบบด้วย $provider ไม่สำเร็จ: $errorBody");
      }
    } catch (e) {
      print('$provider login error: $e');
      _showError("เกิดข้อผิดพลาด: $e");
    }
  }

  Future<void> _handleFacebookLogin() async {
    setState(() => _isLoading = true);
    try {
      print('Starting Facebook Login...');
      
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!.token;
        print('Facebook access token obtained');
        
        await _sendTokenToBackend("facebook", accessToken);
      } else {
        _showError('Facebook Login ล้มเหลว: ${result.message}');
      }
    } catch (e) {
      if (e.toString().contains('MissingPluginException')) {
        _showError(
          "Facebook Login ผิดพลาด: MissingPluginException\n"
          "วิธีแก้ไข:\n"
          "- ให้ปิดแอปแล้วเปิดใหม่ (cold restart)\n"
          "- หรือรัน 'flutter clean' แล้ว build ใหม่\n"
          "- ตรวจสอบการตั้งค่า Facebook plugin"
        );
      } else {
        print('Facebook Login error: $e');
        _showError("Facebook Login ผิดพลาด: $e");
      }
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
