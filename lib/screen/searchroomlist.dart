import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

class RoomItem extends StatelessWidget {
  final Map<String, dynamic> room;
  const RoomItem(this.room, {super.key});

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
                      '${ServerConstant.server}/${room['image']}', // Replace with your image URL
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          room['type'],
                          style: const TextStyle(color: MaterialColors.surface),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          trimParagraph(room['description'], 150),
                          style:
                              const TextStyle(color: MaterialColors.secondary),
                          textAlign: TextAlign.start,
                        ),
                        const Text(
                          'ดูรายละเอียดห้องพักและข้อมูลเพิ่มเติม',
                          style: TextStyle(color: MaterialColors.surface),
                          textAlign: TextAlign.start,
                        )
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
                promotion: room['promotions'],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Promotions extends StatefulWidget {
  const Promotions({super.key, required this.promotion});

  final List<dynamic> promotion;

  @override
  State<Promotions> createState() => _PromotionsState();
}

class _PromotionsState extends State<Promotions> {
  late String _selectedPromotion;
  late List _promotion;

  @override
  void initState() {
    super.initState();
    _selectedPromotion =
        widget.promotion.isNotEmpty ? widget.promotion[0]['_id'] : null;
    _promotion = widget.promotion;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _promotion.map((e) {
        return RadioListTile<dynamic>(
          activeColor: Colors.blue,
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
          groupValue: _selectedPromotion,
          onChanged: (value) {
            setState(() {
              _selectedPromotion = value;
            });
          },
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
