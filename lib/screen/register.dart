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
    setState(() => _isLoading = true);
    try {
      print('Starting Facebook Register...');
      
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!.token;
        print('Facebook access token obtained: ${accessToken.length} characters');
        
        // ใช้ Facebook token เพื่อดึงข้อมูลผู้ใช้และสมัครสมาชิก
        await _registerWithFacebookUserData(accessToken);
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Facebook Login ล้มเหลว: ${result.message}')),
        );
      }
    } catch (e) {
      if (e.toString().contains('MissingPluginException')) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Facebook plugin ไม่ได้ติดตั้งอย่างถูกต้อง')),
        );
      } else {
        print('Facebook Register error: $e');
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Facebook Register ผิดพลาด: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerWithFacebookUserData(String token) async {
    try {
      print('Getting Facebook user data with token...');
      print('Token length: ${token.length}');
      print('Token preview: ${token.substring(0, 50)}...');
      
      // ดึงข้อมูลผู้ใช้จาก Facebook API
      final userInfoResponse = await http.get(
        Uri.parse('https://graph.facebook.com/me?fields=name,email&access_token=$token'),
        headers: {'Accept': 'application/json'},
      );

      print('Facebook user info response: ${userInfoResponse.statusCode}');
      print('Facebook user info body: ${userInfoResponse.body}');

      if (userInfoResponse.statusCode == 200) {
        final userInfo = jsonDecode(userInfoResponse.body);
        final email = userInfo['email'];
        final name = userInfo['name'];
        
        print('Facebook user email: $email');
        print('Facebook user name: $name');

        if (email != null && name != null) {
          // ใช้ข้อมูลที่ได้เพื่อสมัครสมาชิก
          await _registerWithFacebookData(email, name);
        } else {
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text('ไม่สามารถดึงข้อมูล email หรือ name จาก Facebook ได้')),
          );
        }
      } else {
        print('Failed to get Facebook user info: ${userInfoResponse.statusCode}');
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('ไม่สามารถดึงข้อมูลผู้ใช้จาก Facebook ได้')),
        );
      }
    } catch (e) {
      print('Error getting Facebook user data: $e');
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการดึงข้อมูลจาก Facebook: $e')),
      );
    }
  }

  Future<void> _registerWithFacebookData(String email, String name) async {
    try {
      print('Registering user with Facebook data...');
      print('Email: $email, Name: $name');
      
      // ใช้ endpoint signup ที่มีอยู่แล้ว
      final endpoint = '${ServerConstant.server}/customer/signup';
      print('Using endpoint: $endpoint');
      
      final requestBody = {
        'name': name,
        'email': email,
        'password': 'facebook_${email.split('@')[0]}_${DateTime.now().millisecondsSinceEpoch}', // สร้าง password ที่ไม่ซ้ำ
        'telephone': '0000000000', // เบอร์โทรเริ่มต้นสำหรับ Facebook register
      };
      
      print('Facebook register request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      print('Facebook register response status: ${response.statusCode}');
      print('Facebook register response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        
        if (body['token'] != null && body['token'].toString().isNotEmpty) {
          await storage.write(key: "token", value: body['token']);
          print('Facebook register token saved successfully');
          
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text('สมัครสมาชิกด้วย Facebook สำเร็จ!'),
              backgroundColor: Colors.green,
            ),
          );
          
          if (!mounted) return;
          
          // ไปหน้า home
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text('สมัครสมาชิกสำเร็จแต่ไม่ได้รับโทเคน กรุณา login ด้วย Facebook อีกครั้ง')),
          );
          
          // กลับไปหน้า login
          Navigator.pop(context);
        }
      } else if (response.statusCode == 409) {
        // อีเมลมีอยู่แล้ว
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('อีเมลนี้มีบัญชีอยู่แล้ว กรุณาไปที่หน้า Login แล้วเข้าสู่ระบบด้วย Facebook'),
            backgroundColor: Colors.orange,
          ),
        );
        
        // กลับไปหน้า login
        Navigator.pop(context);
      } else if (response.statusCode == 400) {
        final errorBody = response.body.isNotEmpty ? response.body : 'ไม่มีข้อความจาก server';
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('ข้อมูลไม่ถูกต้อง: $errorBody')),
        );
      } else {
        final errorBody = response.body.isNotEmpty ? response.body : 'ไม่มีข้อความจาก server';
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('ไม่สามารถสมัครสมาชิกได้ (${response.statusCode}): $errorBody')),
        );
      }
    } catch (e) {
      print('Facebook register error: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('Connection')) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต')),
        );
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() => _isLoading = true);
    try {
      print('Starting Google Register...');
      
      // Clear any existing sign-in first
      await GoogleSignIn().signOut();
      
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: ['email', 'profile']
      ).signIn();
      
      if (googleUser == null) {
        print('Google register cancelled by user');
        setState(() => _isLoading = false);
        return;
      }
      
      print('Google user signed in: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      print('Google auth obtained - idToken: ${googleAuth.idToken != null}');
      print('Google auth obtained - accessToken: ${googleAuth.accessToken != null}');
      
      // ใช้ accessToken เพื่อดึงข้อมูลผู้ใช้จาก Google API
      if (googleAuth.accessToken != null && googleAuth.accessToken!.isNotEmpty) {
        await _registerWithGoogleUserData(googleAuth.accessToken!);
      } else if (googleAuth.idToken != null && googleAuth.idToken!.isNotEmpty) {
        // หาก accessToken ไม่มี ให้ลองใช้ idToken
        await _registerWithGoogleUserData(googleAuth.idToken!);
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('ไม่สามารถดึง Google Token ได้ กรุณาลองใหม่อีกครั้ง')),
        );
      }
    } catch (e) {
      print('Google Register error: $e');
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Google Register ผิดพลาด: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerWithGoogleUserData(String token) async {
    try {
      print('Getting Google user data with token...');
      print('Token length: ${token.length}');
      print('Token preview: ${token.substring(0, 50)}...');
      
      // ดึงข้อมูลผู้ใช้จาก Google API
      final userInfoResponse = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Google user info response: ${userInfoResponse.statusCode}');
      print('Google user info body: ${userInfoResponse.body}');

      if (userInfoResponse.statusCode == 200) {
        final userInfo = jsonDecode(userInfoResponse.body);
        final email = userInfo['email'];
        final name = userInfo['name'];
        
        print('Google user email: $email');
        print('Google user name: $name');

        if (email != null && name != null) {
          // ใช้ข้อมูลที่ได้เพื่อสมัครสมาชิก
          await _registerWithGoogleData(email, name);
        } else {
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text('ไม่สามารถดึงข้อมูล email หรือ name จาก Google ได้')),
          );
        }
      } else {
        print('Failed to get Google user info: ${userInfoResponse.statusCode}');
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('ไม่สามารถดึงข้อมูลผู้ใช้จาก Google ได้')),
        );
      }
    } catch (e) {
      print('Error getting Google user data: $e');
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการดึงข้อมูลจาก Google: $e')),
      );
    }
  }

  Future<void> _registerWithGoogleData(String email, String name) async {
    try {
      print('Registering user with Google data...');
      print('Email: $email, Name: $name');
      
      // ใช้ endpoint signup ที่มีอยู่แล้ว
      final endpoint = '${ServerConstant.server}/customer/signup';
      print('Using endpoint: $endpoint');
      
      final requestBody = {
        'name': name,
        'email': email,
        'password': 'google_${email.split('@')[0]}_${DateTime.now().millisecondsSinceEpoch}', // สร้าง password ที่ไม่ซ้ำ
        'telephone': '0000000000', // เบอร์โทรเริ่มต้นสำหรับ Google register
        
      };
      
      print('Register request body: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      print('Google register response status: ${response.statusCode}');
      print('Google register response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        
        if (body['token'] != null && body['token'].toString().isNotEmpty) {
          await storage.write(key: "token", value: body['token']);
          print('Google register token saved successfully');
          
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text('สมัครสมาชิกด้วย Google สำเร็จ!'),
              backgroundColor: Colors.green,
            ),
          );
          
          if (!mounted) return;
          
          // ไปหน้า home หรือกลับหน้า login
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text('สมัครสมาชิกสำเร็จแต่ไม่ได้รับโทเคน กรุณา login ด้วย Google อีกครั้ง')),
          );
          
          // กลับไปหน้า login
          Navigator.pop(context);
        }
      } else if (response.statusCode == 409) {
        // อีเมลมีอยู่แล้ว
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('อีเมลนี้มีบัญชีอยู่แล้ว กรุณาไปที่หน้า Login แล้วเข้าสู่ระบบด้วย Google'),
            backgroundColor: Colors.orange,
          ),
        );
        
        // กลับไปหน้า login
        Navigator.pop(context);
      } else if (response.statusCode == 400) {
        final errorBody = response.body.isNotEmpty ? response.body : 'ไม่มีข้อความจาก server';
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('ข้อมูลไม่ถูกต้อง: $errorBody')),
        );
      } else {
        final errorBody = response.body.isNotEmpty ? response.body : 'ไม่มีข้อความจาก server';
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('ไม่สามารถสมัครสมาชิกได้ (${response.statusCode}): $errorBody')),
        );
      }
    } catch (e) {
      print('Google register error: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('Connection')) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต')),
        );
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
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
