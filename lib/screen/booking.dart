import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/widgets/datepicker.dart";
import 'package:imm_hotel_app/screen/searchroomlist.dart';

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

  @override
  void initState() {
    super.initState();
    selectedValue1 = '1'; // initialization
    selectedValue2 = '0'; // initialization
    dateCheckin = DateTime.now(); // initialization
    dateCheckout = DateTime.now().add(const Duration(days: 1)); // initialization
    _roomId = widget.roomId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MaterialColors.primaryBackgroundColor,
        foregroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon:
                const Icon(Icons.account_circle, color: Colors.white, size: 40),
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
                                });
                              },
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
                            DatePicker(
                              restorationId: 'checkout',
                              onSelected: (newDate) {
                                setState(() {
                                  dateCheckout = newDate;
                                });
                              },
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
