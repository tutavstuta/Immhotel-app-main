import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:imm_hotel_app/screen/booked.dart';
import 'package:imm_hotel_app/services/booking_confirm.dart';
import 'package:imm_hotel_app/services/searchroom.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/constants/server.dart";
import 'package:imm_hotel_app/widgets/appbar.dart';

class SearchRoomList extends StatefulWidget {
  const SearchRoomList(
      {super.key,
      required this.adult,
      required this.children,
      required this.dateCheckin,
      required this.dateCheckout,
      required this.roomId});

  final String roomId;
  final int adult;
  final int children;
  final String dateCheckin;
  final String dateCheckout;

  @override
  State<SearchRoomList> createState() => _SearchRoomListState();
}

class _SearchRoomListState extends State<SearchRoomList> {
  late Future<List<dynamic>> roomDataFuture;

  @override
  void initState() {
    super.initState();
    String roomId = widget.roomId;
    int adult = widget.adult;
    int children = widget.children;
    String dateCheckin = widget.dateCheckin;
    String dateCheckout = widget.dateCheckout;
    roomDataFuture =
        searchRomm(roomId, adult, children, dateCheckin, dateCheckout);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: roomDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          List<dynamic> roomData = snapshot.data!;
          return Scaffold(
            appBar: const AppBarHome(),
            backgroundColor: MaterialColors.secondaryBackgroundColor,
            body: SingleChildScrollView(
              dragStartBehavior: DragStartBehavior.start,
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: MaterialColors.primaryBackgroundColor,
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 73,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(300),
                            topRight: Radius.circular(300),
                          ),
                          child: SizedBox(
                            child: Container(
                              alignment: Alignment.center,
                              color: MaterialColors.secondaryBackgroundColor,
                              child: const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  "เลือกห้องพัก",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: MaterialColors.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      child: RoomList(roomData: roomData),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class RoomList extends StatelessWidget {
  const RoomList({super.key, required this.roomData});

  final List<dynamic> roomData;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context)
          .size
          .height, // Set height to fill available space
      child: ListView.builder(
        itemCount: roomData.length,
        itemBuilder: (context, index) {
          return RoomItem(roomData[index]);
        },
      ),
    );
  }
}

class RoomItem extends StatefulWidget {
  final Map<String, dynamic> room;
  const RoomItem(this.room, {super.key});

  @override
  State<RoomItem> createState() => _RoomItemState();
}

class _RoomItemState extends State<RoomItem> {
  late int _totalPrice;
  late int _price;
  late String _id;

  String trimParagraph(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }

    // Find the last space before the maxLength
    int lastSpaceIndex = text.lastIndexOf(' ', maxLength);

    // If there's no space found, just trim at the maxLength
    if (lastSpaceIndex == -1) {
      return text.substring(0, maxLength);
    }

    return '${text.substring(0, lastSpaceIndex)}...';
  }

  @override
  void initState() {
    super.initState();
    _totalPrice = widget.room['promotions'][0]['total_price'];
    _price = widget.room['promotions'][0]['price'];
    _id = widget.room['promotions'][0]['_id'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey, // Set the color of the top border
            width: 1.0, // Set the width of the top border
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.network(
                      '${ServerConstant.server}/${widget.room['image']}',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.room['type'],
                          style: const TextStyle(color: MaterialColors.surface),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          trimParagraph(widget.room['description'], 150),
                          style:
                              const TextStyle(color: MaterialColors.secondary),
                          textAlign: TextAlign.start,
                        ),
                        //const Text(
                        //  'ดูรายละเอียดห้องพักและข้อมูลเพิ่มเติม',
                        //  style: TextStyle(color: MaterialColors.surface),
                        //  textAlign: TextAlign.start,
                        //)
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              const Text(
                'Promotion',
                style: TextStyle(color: MaterialColors.secondary),
                textAlign: TextAlign.start,
              ),
              Promotions(
                promotion: widget.room['promotions'],
                onSelected: (value) {
                  if (kDebugMode) {
                    print(value);
                  }
                  setState(() {
                    _totalPrice = value['total_price'];
                    _price = value['price'];
                    _id = value['_id'];
                  });
                },
              ),
              ElevatedButton(
                  onPressed: () async {
                    await confirmBooking(
                      widget.room['_id'],
                      widget.room['adults'],
                      widget.room['childs'],
                      _id,
                      widget.room['date_checkin'],
                      widget.room['date_checkout'],
                    );
                    // ส่งค่ากลับไปหน้า home ว่าให้เปิด tab booked (index 2 หรือ 3 แล้วแต่แอปคุณ)
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                      arguments: {'tab': 3}, // สมมติว่า tab 2 คือ booked
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '$_price บาท',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text('$_totalPrice บาท',
                                style: const TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                      const Expanded(
                        child: Column(
                          children: [
                            Text(
                              'จอง',
                              style: TextStyle(fontSize: 25),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

class Promotions extends StatefulWidget {
  const Promotions(
      {super.key, required this.promotion, required this.onSelected});

  final List<dynamic> promotion;
  final ValueChanged onSelected;

  @override
  State<Promotions> createState() => _PromotionsState();
}

class _PromotionsState extends State<Promotions> {
  late String _selectedPromotionId;
  late List _promotion;

  @override
  void initState() {
    super.initState();
    _selectedPromotionId = widget.promotion[0]['_id'];
    _promotion = widget.promotion;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _promotion.map((e) {
        return Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey, // Set the color of the top border
                width: 1.0, // Set the width of the top border
              ),
              bottom: BorderSide(
                color: Colors.grey, // Set the color of the top border
                width: 1.0, // Set the width of the top border
              ),
            ),
          ),
          child: RadioListTile<dynamic>(
            activeColor: Colors.blue,
            hoverColor: Colors.black,
            tileColor: MaterialColors.primary,
            title: Text(
              e['title'],
              style: const TextStyle(color: Color.fromARGB(255, 238, 11, 11)),
              textAlign: TextAlign.start,
            ),
            subtitle: Promotion(
              detail: e,
            ),
            value: e['_id'],
            groupValue: _selectedPromotionId,
            onChanged: (value) {
              setState(() {
                _selectedPromotionId = value;
                widget.onSelected(e);
              });
            },
          ),
        );
      }).toList(),
    );
  }
}

class Promotion extends StatelessWidget {
  const Promotion({super.key, required this.detail});

  final dynamic detail;

  @override
  Widget build(BuildContext context) {
    int price = detail['total_price'];
    return Center(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail['description'],
                  style: const TextStyle(color: MaterialColors.secondary),
                  textAlign: TextAlign.start,
                ),
                Text(
                  detail['condition'],
                  style: const TextStyle(color: MaterialColors.secondary),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$price บาท',
                  style: const TextStyle(color: MaterialColors.secondary),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
