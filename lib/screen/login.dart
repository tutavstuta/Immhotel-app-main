import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/constants/apptheme.dart";
import "package:imm_hotel_app/constants/server.dart";
import 'package:imm_hotel_app/screen/register.dart';

Future<LoginResponse> login(String email, String password) async {
  const storage = FlutterSecureStorage();
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
    storage.write(key: "token", value: token);
  
    return LoginResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to login');
  }
}

class LoginResponse {
  final String token;
  final String message;
  final String tokenType;

  const LoginResponse({
    required this.token,
    required this.message,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'token': String token,
        'message': String message,
        'tokenType': String tokenType,
      } =>
        LoginResponse(
          token: token,
          message: message,
          tokenType: tokenType,
        ),
      _ => throw const FormatException('Failed to login'),
    };
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<LoginResponse>? _futureLoginResponse;
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                  padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
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
                    style:
                        const TextStyle(color: MaterialColors.secondaryTextColor),
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
                        icon: Icon(
                            _isObscure ? Icons.visibility : Icons.visibility_off),
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
                    padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
                    child: ElevatedButton(
                        onPressed: () {
                          // Handle button press
                          setState(() {
                            _futureLoginResponse = login(
                                _emailController.text, _passwordController.text);
                          });
                          if (_futureLoginResponse != null) {
                            Navigator.pushReplacementNamed(context, '/home');
                          }else{
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(MaterialColors.primary),
                            foregroundColor: WidgetStateProperty.all(
                                MaterialColors.onPrimary)),
                        child: const Text('เข้าสู่ระบบ')),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
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
                              style: TextStyle(color: MaterialColors.success)),
                        ),
                      ],
                    )),
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


