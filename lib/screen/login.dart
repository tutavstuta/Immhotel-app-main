import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/constants/apptheme.dart";
import "package:imm_hotel_app/constants/server.dart";
import 'package:imm_hotel_app/screen/register.dart';

// Define a global key for ScaffoldMessenger
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

  bool _isLoading = false;
  bool _isObscure = true;

  Future<void> login(String email, String password) async {
    const storage = FlutterSecureStorage();

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${ServerConstant.server}/customer/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final token = body['token'];
        await storage.write(key: "token", value: token);

        if (!mounted) return;

        Navigator.pushNamed(context, '/home');
      } else {
        if (!mounted) return;

        // Use the global scaffoldMessengerKey to show SnackBar
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Center(child: Text('Invalid email or password')),
            backgroundColor: Colors.white,
          ),
        );
      }
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Center(child: Text('An error occurred: $e')),
          backgroundColor: Colors.white,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey, // Use the global key here
      theme: ThemeData(
          fontFamily: 'NotoSansThai', colorScheme: AppTheme.lightColorScheme),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: Image.asset("assets/images/logo1.png")),
                Padding(
                  padding:
                      const EdgeInsets.only(right: 20, left: 20, bottom: 20),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(
                              color: MaterialColors.inpBorderColor,
                              width: 1.0,
                              style: BorderStyle.solid),
                          gapPadding: 10),
                      prefixIcon: Icon(Icons.email),
                      labelText: 'อีเมลล์',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20),
                  child: TextField(
                    obscureText: _isObscure,
                    controller: _passwordController,
                    style: const TextStyle(
                        color: MaterialColors.secondaryTextColor),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(
                              color: MaterialColors.inpBorderColor,
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
                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: 20, left: 20, top: 20),
                    child: _isLoading
                        ? const Center(
                          child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator()),
                        )
                        : ElevatedButton(
                            onPressed: () {
                              login(_emailController.text,
                                  _passwordController.text);
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  MaterialColors.primary),
                              foregroundColor: WidgetStateProperty.all(
                                  MaterialColors.onPrimary),
                            ),
                            child: const Text('เข้าสู่ระบบ')),
                  ),
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
                          const Text("สมัครสมาชิก?"),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Register(),
                                ),
                              );
                            },
                            child: const Text(" Sign Up",
                                style:
                                    TextStyle(color: MaterialColors.success)),
                          ),
                        ],
                      ),
                    ),
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
