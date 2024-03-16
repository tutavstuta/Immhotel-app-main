import 'package:flutter/material.dart';
import "package:flutter/widgets.dart";
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/constants/apptheme.dart";

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          fontFamily: 'NotoSansThai',
          colorScheme: AppTheme.lightColorScheme),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20),
                  child: Image.asset("assets/images/logo1.png")),
              const Padding(
                padding: EdgeInsets.only(right: 20, left: 20,bottom: 20),
                child: TextField(
                  decoration: InputDecoration(
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
              const Padding(
                padding: EdgeInsets.only(right: 20, left: 20),
                child: TextField(
                  // obscureText: true,
                  style: TextStyle(color: MaterialColors.secondaryTextColor),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          borderSide: BorderSide(
                              color: MaterialColors.inpBorderColor,
                              width: 1.0,
                              style: BorderStyle.solid),
                          gapPadding: 10),
                          prefixIcon: Icon(Icons.lock),
                      labelText: 'พาสเวิร์ด',
                      
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
                      },
                      style:  ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(MaterialColors.primary),
                        foregroundColor: MaterialStateProperty.all(MaterialColors.onPrimary)
                      ),
                      child: const Text('เข้าสู่ระบบ')),
                ),
              ),
               const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(right: 20, left: 20, top: 20),
                  child: Center(child: Row(
                    mainAxisAlignment :MainAxisAlignment.center,
                    children: [
                      Text("สมัครสมาชิก?"),
                      Text(" Sign Up",style:TextStyle(color: MaterialColors.success)),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
