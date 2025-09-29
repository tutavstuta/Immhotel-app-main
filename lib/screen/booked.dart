import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/services/get_booking.dart";
import 'components/bookingdetails.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:imm_hotel_app/constants/server.dart'; 

class Booked extends StatefulWidget {
  const Booked({super.key});

  @override
  State<Booked> createState() => _BookedState();
}

class _BookedState extends State<Booked> {
  String? _userName;
  late Future<List<dynamic>> bookings;
  @override
  void initState() {
    super.initState();
    _fetchUserName();
    bookings = getbooking();
  }

  Future<void> _fetchUserName() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "token");

    if (token == null || token.isEmpty) {
      setState(() {
        _userName = null;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ServerConstant.server}/customer/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userName = data['data']['name'] ?? 'ไม่มีชื่อ';
        });
      } else {
        setState(() {
          _userName = null;
        });
      }
    } catch (e) {
      setState(() {
        _userName = null;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: bookings,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<dynamic> bookings = snapshot.data!;

            return Scaffold(
                appBar: AppBar(
                  backgroundColor: MaterialColors.primaryBackgroundColor,
                  foregroundColor: Colors.white,
                  actions: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _userName != null
                          ? Row(
                              children: [
                                Text(
                                  _userName!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _userMenu(),
                              ],
                            )
                          : TextButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              icon: const Icon(Icons.login, color: Colors.white),
                              label: const Text(
                                'เข้าสู่ระบบ',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                    ),
                  ],
                ),
                backgroundColor: MaterialColors.primaryBackgroundColor,
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(child: Image.asset("assets/images/logo3.png")),
                      Container(
                        padding: const EdgeInsets.fromLTRB(50, 50, 50, 50),
                        decoration: const BoxDecoration(
                          color: MaterialColors.primary,
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: const Text(
                                "การจองของคุณ",
                                style: TextStyle(
                                    color: MaterialColors.label, fontSize: 25),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            BookingList(bookings: bookings),
                          ],
                        ),
                      ),
                    ],
                  ),
                ));
          }
        });
  }

  Widget _userMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.account_circle,
        color: Colors.white,
        size: 40,
      ),
      onSelected: (String result) {
        // ยังไม่ใช้ result โดยตรง
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'editprofile',
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/editprofile');
            },
            child: const Text('แก้ไขข้อมูลส่วนตัว'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'signout',
          child: TextButton(
            onPressed: () async {
              const storage = FlutterSecureStorage();
              await storage.delete(key: "token");
              Navigator.pop(context); // ปิด popup menu
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
            child: const Text('ออกจากระบบ'),
          ),
        ),
      ],
    );
  }
}

class BookingList extends StatelessWidget {
  const BookingList({super.key, required this.bookings});
  final dynamic bookings;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (BuildContext context, int index) {
                return Booking(booking: bookings[index]);
              },
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border.fromBorderSide(
                  BorderSide(width: 0.5, color: Colors.grey)),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text('เลขที่บัญชีในการชำระค่าห้องพัก',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: MaterialColors.surface)),
          const SizedBox(
            height: 10,
          ),
          const Text('xx-xx-xxx-xxxxx',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: MaterialColors.surface)),
        ],
      ),
    );
  }
}

class Booking extends StatelessWidget {
  const Booking({super.key, required this.booking});
  final dynamic booking;
  @override
  Widget build(BuildContext context) {
    var promotion = booking['promotion'];
    var guest = booking['num_guess'];
    var price_per_night = booking['price_per_night'];
    var totalPrice = booking['total_price'];
    var totalNight = booking['total_nigths'];
    return Center(
        child: ListTile(
      title: Column(
        children: [
          Column(
            children: [
              Text(promotion['title'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 242, 8, 0))),
              Text(promotion['description'],
                 style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: MaterialColors.surface)),
            ],
          ),
        ],
      ),
      subtitle: BookingDetails(
          booking: booking,
          guest: guest,
          price_per_night: price_per_night,
          totalPrice: totalPrice,
          totalNight: totalNight),
    ));
  }
}
