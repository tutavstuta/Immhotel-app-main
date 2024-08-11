import 'package:flutter/material.dart';
import "package:imm_hotel_app/screen/landing.dart";
import "package:imm_hotel_app/screen/room.dart";
import 'package:imm_hotel_app/screen/history.dart';
import 'package:imm_hotel_app/screen/booked.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.brown,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'หน้าแรก',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.bed),
            icon: Icon(Icons.bed_outlined),
            label: 'ห้องพัก',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.hotel),
            icon: Icon(Icons.hotel_outlined),
            label: 'ประวัติโรงแรม',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history),
            icon: Icon(Icons.history_outlined),
            label: 'การจอง',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        Landing(),
        const RoomPage(),

        /// Hotel history page
        const History(),

        /// Booked page
        Booked(),
      ][currentPageIndex],
    );
  }
}
