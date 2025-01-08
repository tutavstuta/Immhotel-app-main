import 'package:flutter/material.dart';
import "package:imm_hotel_app/screen/booked.dart";
import "package:imm_hotel_app/screen/home.dart";
import "package:imm_hotel_app/screen/login.dart";
import "package:imm_hotel_app/constants/apptheme.dart";
import "package:imm_hotel_app/screen/register.dart";
import 'package:imm_hotel_app/screen/editprofile.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Imm hotel',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'NotoSansThai', colorScheme: AppTheme.lightColorScheme),
        initialRoute: '/login',
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => const Home(),
          '/login': (BuildContext context) => const Login(),
          "/register": (BuildContext context) => const Register(),
          "/booked": (BuildContext context) => const Booked(),     
          "/editprofile": (BuildContext context) => const EditProfile(),
        });
  }
}

