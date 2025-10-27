import 'dart:async'; 
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/constants/server.dart";
import "package:imm_hotel_app/screen/roomdetail.dart";
import 'package:imm_hotel_app/widgets/appbar.dart';

Future<List<dynamic>> getRoom() async {
  const storage = FlutterSecureStorage();
  var token = await storage.read(key: 'token');

  if (token == null || token.isEmpty) {
    // handle not-logged-in state: prompt login or return early
    throw Exception('Not authenticated');
  }

  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer $token',
  };

  final response = await http.get(
    Uri.parse('${ServerConstant.server}/customer/roomlist'),
    headers: headers,
  ).catchError((error) => throw Exception('Error: $error'));

  if (response.statusCode == 200) {
    Map<String, dynamic> roomData = jsonDecode(response.body);

    if (kDebugMode) {
      print(roomData['data']);
    }

    return roomData['data'];
  } else {
    throw Exception('Failed to get room list');
  }
}

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late Future<List<dynamic>> roomDataFuture;

  @override
  void initState() {
    super.initState();
    roomDataFuture = getRoom();
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
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
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
                                  "ห้องพัก",
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
      height: MediaQuery.of(context).size.height,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                '${ServerConstant.server}/${room['image']}',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              room['type'],
              style: const TextStyle(color: MaterialColors.surface),
            ),
            subtitle: Text('Max Persons: ${room['max_person']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomDetail(roomId: room['_id']),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
