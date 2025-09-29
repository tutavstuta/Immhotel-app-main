import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/widgets/datepicker.dart";
import 'package:imm_hotel_app/screen/searchroomlist.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:imm_hotel_app/constants/server.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({
    super.key, required this.roomId
  });

  final String roomId;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late String selectedValue1 = '1';
  late String selectedValue2 = '0';
  late DateTime dateCheckin;
  late DateTime dateCheckout;
  late String _roomId;
  String? _userName;

  @override
  void initState() {
    super.initState();
    selectedValue1 = '1'; // initialization
    selectedValue2 = '0'; // initialization
    dateCheckin = DateTime.now(); // initialization
    dateCheckout = DateTime.now().add(const Duration(days: 1)); // initialization
    _roomId = widget.roomId;
    _fetchUserName(); // <<--- เพิ่มบรรทัดนี้
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
    }// ถ้ามี API สำหรับดึงชื่อ user ให้เพิ่ม logic ตรงนี้
    // ตัวอย่าง: setState(() { _userName = 'ชื่อผู้ใช้'; });
  }

  Widget _userMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.account_circle,
        color: Colors.white,
        size: 40,
      ),
      onSelected: (String result) {},
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

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(child: Image.asset("assets/images/logo1.png")),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 50, 10, 20),
            decoration: const BoxDecoration(
              color: MaterialColors.primary,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person, // Use the heart icon
                      color: MaterialColors
                          .primaryBackgroundColor, // Set the color
                      size: 24.0, // Set the size
                    ),
                    const SizedBox(width: 10),
                    const Text('ผู้ใหญ่',
                        style: TextStyle(color: MaterialColors.secondary)),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: selectedValue1,
                      style: const TextStyle(color: MaterialColors.secondary),
                      dropdownColor: MaterialColors.onSurface,
                      onChanged: (newValue) {
                        setState(() {
                          selectedValue1 = newValue!;
                        });
                      },
                      items: <String>['0','1', '2', '3'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: const TextStyle(
                                  color: MaterialColors.secondary)),
                        );
                      }).toList(),
                    ),
                    const Text('เด็ก',
                        style: TextStyle(color: MaterialColors.secondary)),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: selectedValue2,
                      style: const TextStyle(color: MaterialColors.secondary),
                      dropdownColor: MaterialColors.onSurface,
                      onChanged: (newValue) {
                        setState(() {
                          selectedValue2 = newValue!;
                        });
                      },
                      items: <String>['0','1', '2', '3'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: const TextStyle(
                                  color: MaterialColors.secondary)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Center(
                  child: SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today,
                                color: MaterialColors.primaryBackgroundColor,
                                size: 24.0),
                            const SizedBox(width: 10),
                            const Text("เช็คอิน",
                                textAlign: TextAlign.end,
                                style:
                                    TextStyle(color: MaterialColors.secondary)),
                            DatePicker(
                              restorationId: 'checkin',
                              onSelected: (newDate) {
                                setState(() {
                                  dateCheckin = newDate;
                                  // ถ้าเลือกวันเช็คอินใหม่ ให้ปรับวันเช็คเอาท์อย่างน้อย +1 วัน
                                  if (!dateCheckout.isAfter(newDate)) {
                                    dateCheckout = newDate.add(const Duration(days: 1));
                                  }
                                });
                              },
                             // initialDate: dateCheckin,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today,
                                color: MaterialColors.primaryBackgroundColor,
                                size: 24.0),
                            const SizedBox(width: 10),
                            const Text("เช็คเอาท์",
                                textAlign: TextAlign.end,
                                style:
                                    TextStyle(color: MaterialColors.secondary)),
                            // ตรวจสอบว่ามี firstDate ใน DatePicker หรือไม่ ถ้าไม่มีให้ลบออก
                            DatePicker(
                              restorationId: 'checkout',
                              onSelected: (newDate) {
                                setState(() {
                                  dateCheckout = newDate;
                                });
                              },
                              // ถ้า initialDate ขึ้นแดง ให้ลองใช้ selectedDate แทน หรือดูชื่อพารามิเตอร์ที่ถูกต้องใน DatePicker ของคุณ
                              // initialDate: dateCheckout,
                              //selectedDate: dateCheckout,
                              // ถ้า widget ของคุณใช้ชื่ออื่น เช่น value: dateCheckout, ให้เปลี่ยนเป็นชื่อนั้น
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (kDebugMode) {
                        print(selectedValue1);
                        print(selectedValue2);
                        print(dateCheckin);
                        print(dateCheckout);
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchRoomList(
                            roomId:_roomId,
                            adult: int.parse(selectedValue1),
                            dateCheckin: dateCheckin.toString(),
                            dateCheckout: dateCheckout.toString(),
                            children: int.parse(selectedValue2),
                          ),
                        ),
                      );
                    },
                    child: const Text('สำรองห้องพัก'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
