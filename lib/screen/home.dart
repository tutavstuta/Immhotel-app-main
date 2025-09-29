import 'package:flutter/material.dart';
import "package:imm_hotel_app/screen/landing.dart";
import "package:imm_hotel_app/screen/room.dart";
import 'package:imm_hotel_app/screen/history.dart';
import 'package:imm_hotel_app/screen/booked.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 0;
  bool isLoggedIn = false;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await storage.read(key: "token");
    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
      // reset index if not logged in and currentPageIndex > 2
      if (!isLoggedIn && currentPageIndex > 2) {
        currentPageIndex = 0;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['tab'] != null) {
      setState(() {
        currentPageIndex = args['tab']; // หรือ currentTab = args['tab'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = <NavigationDestination>[
      const NavigationDestination(
        selectedIcon: Icon(Icons.home),
        icon: Icon(Icons.home_outlined),
        label: 'หน้าแรก',
      ),
      const NavigationDestination(
        selectedIcon: Icon(Icons.bed),
        icon: Icon(Icons.bed_outlined),
        label: 'ห้องพัก',
      ),
      const NavigationDestination(
        selectedIcon: Icon(Icons.hotel),
        icon: Icon(Icons.hotel_outlined),
        label: 'ประวัติโรงแรม',
      ),
      if (isLoggedIn)
        const NavigationDestination(
          selectedIcon: Icon(Icons.history),
          icon: Icon(Icons.history_outlined),
          label: 'การจอง',
        ),
    ];

    final pages = <Widget>[
      Landing(),
      const RoomPage(),
      const History(),
      if (isLoggedIn) const Booked(),
    ];

    int safeIndex = currentPageIndex;
    if (!isLoggedIn && currentPageIndex > 2) {
      safeIndex = 0;
    }

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.brown,
        selectedIndex: safeIndex,
        destinations: destinations,
      ),
      body: pages[safeIndex],
    );
  }
}
