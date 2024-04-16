import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/widgets/datepicker.dart";

class BookingPage extends StatefulWidget {
  const BookingPage({
    super.key,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late String selectedValue1;
  late String selectedValue2;
  late String selectedValue3;
  late String selectedValue4;

  @override
  void initState() {
    super.initState();
    // Initialize selectedValue here (e.g., fetch from an API or set a default)
    selectedValue1 = 'ผู้ใหญ่ 1'; // initialization
    selectedValue2 = 'เด็ก 1'; // initialization
    selectedValue3 = 'Superior'; // initialization
    selectedValue4 = 'ผู้ใหญ่ 1'; // initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MaterialColors.primaryBackgroundColor,
          foregroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.account_circle,
                  color: Colors.white, size: 40),
              onPressed: () {
                // Handle the icon button press
              },
            ),
            // Add more icons as needed
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
                    borderRadius: BorderRadius.all(Radius.circular(50))),
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
                        DropdownButton<String>(
                          value: selectedValue1,
                          onChanged: (newValue) {
                            setState(() {
                              selectedValue1 = newValue!;
                            });
                          },
                          items: <String>['ผู้ใหญ่ 1', 'ผู้ใหญ่ 2', 'ผู้ใหญ่ 3']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(
                                      color: MaterialColors.secondary)),
                            );
                          }).toList(),
                        ),
                        DropdownButton<String>(
                          value: selectedValue2,
                          onChanged: (newValue) {
                            setState(() {
                              selectedValue2 = newValue!;
                            });
                          },
                          items: <String>['เด็ก 1', 'เด็ก 2', 'เด็ก 3']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(
                                      color: MaterialColors.secondary)),
                            );
                          }).toList(),
                        ),
                        DropdownButton<String>(
                          value: selectedValue3,
                          onChanged: (newValue) {
                            setState(() {
                              selectedValue3 = newValue!;
                            });
                          },
                          items: <String>['Superior', 'Delux', 'Twin']
                              .map((String value) {
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
                    const Text("เช็คอิน",
                        style: TextStyle(color: MaterialColors.secondary)),
                    const SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookingPage(),
                            ),
                          );
                        },
                        child: const Text('สำรองห้องพัก'),
                      ),
                    ),
                  ],
                )),
            Expanded(
              child: Container(
                color: Colors.blue,
                child: const DatePicker(
                  restorationId: 'main',
                ),
              ),
            ),
          ],
        ));
  }
}
