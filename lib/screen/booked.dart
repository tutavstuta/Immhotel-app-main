import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/widgets/appbar.dart";

class Booked extends StatelessWidget {
  const Booked({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBarHome(),
      backgroundColor: MaterialColors.primaryBackgroundColor,
      body: SingleChildScrollView(
        child: Center(child: Text("booked"),),
      )
    );
  }
}