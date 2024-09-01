import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/constants/apptheme.dart";
import "package:imm_hotel_app/screen/login.dart";

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

  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "imm hotel",
        debugShowCheckedModeBanner: false,
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
                Padding(
                  padding:
                      const EdgeInsets.only(right: 20, left: 20, bottom: 20),
                  child: TextField(
                    obscureText: _isObscure,
                    controller: _passwordConfirmController,
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
                          // Handle button press
                          setState(() {
                            // _futureLoginResponse = login(_emailController.text,
                            //         _passwordController.text)
                            //     as Future<LoginResponse>?;
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => const Home()),
                            // );
                          });
                        },
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                MaterialColors.primaryBackgroundColor),
                            foregroundColor: WidgetStateProperty.all(
                                MaterialColors.primary)),
                        child: const Text('สมัครสมาชิก')),
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
                    )),
                  ),
                ),
              ],
            )),
          ),
        ));
  }
}
