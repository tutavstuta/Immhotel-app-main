import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";

class AppBarHome extends StatelessWidget implements PreferredSizeWidget {
  const AppBarHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(''),
      leadingWidth: 150,
      leading: Image.asset(
        'assets/images/logo.jpg',
      ),
      backgroundColor: MaterialColors.primaryBackgroundColor,
      foregroundColor: Colors.white,
      toolbarHeight: 80,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.white, size: 40),
          onPressed: () {
            // Handle the icon button press
          },
        ),
        // Add more icons as needed
      ],
    );
  }
  
   @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
