import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";

class AppBarHome extends StatefulWidget implements PreferredSizeWidget {
  const AppBarHome({super.key});

  @override
  State<AppBarHome> createState() => _AppBarHomeState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarHomeState extends State<AppBarHome> {
  String _selectedOption = 'Option 1'; // Maintain the selected option

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
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle,color: Colors.white,size:40,), // Set icon for PopupMenuButton
          onSelected: (String result) {
            setState(() {
              _selectedOption = result; // Update selected option
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          
            const PopupMenuItem<String>(
              value: 'signout',
              child: Text('ออกจากระบบ'),
            ),
          ],
        ),
        // Add more icons as needed
      ],
    );
  }

}
