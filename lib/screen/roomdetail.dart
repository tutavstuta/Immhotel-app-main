import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import "package:imm_hotel_app/constants/theme.dart";
import "package:imm_hotel_app/constants/server.dart";
import 'package:imm_hotel_app/screen/booking.dart';
import "package:imm_hotel_app/widgets/appbar.dart";

Future<RoomDetailResponse> getRoomDetail(String roomId) async {
  const storage = FlutterSecureStorage();
  var token = await storage.read(key: 'token');
  final response = await http.get(
    Uri.parse('${ServerConstant.server}/customer/roomdetail/$roomId'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    },
  );

  if (response.statusCode == 200) {
    if (kDebugMode) {
      print(response.body);
    }

    final body = jsonDecode(response.body);
    final data = body['data'];

    return RoomDetailResponse.fromJson(data);
  } else {
    throw Exception('Failed to login');
  }
}

class RoomDetailResponse {
  final String id;
  final String type;
  final int maxPerson;
  final int children;
  final int roomAmount;
  final String image;
  final String status;
  final String description;
  final List imageMapping;
  final List overview;
  final List amenity;

  const RoomDetailResponse({
    required this.id,
    required this.type,
    required this.maxPerson,
    required this.children,
    required this.roomAmount,
    required this.image,
    required this.status,
    required this.description,
    required this.imageMapping,
    required this.overview,
    required this.amenity,
  });

  factory RoomDetailResponse.fromJson(Map<String, dynamic> json) {
    final id = json['_id'];
    final type = json['type'];
    final maxPerson = json['max_person'];
    final children = json['children'];
    final roomAmount = json['room_amount'];
    final image = json['image'];
    final status = json['status'];
    final description = json['description'];
    final imageMapping = json['image_mapping'];
    final overview = json['overview_mapping'];
    final amenity = json['amenity_mapping'];

    if (id != null &&
        type != null &&
        maxPerson != null &&
        children != null &&
        roomAmount != null &&
        image != null &&
        status != null &&
        description != null &&
        overview != null &&
        amenity != null &&
        imageMapping != null) {
      return RoomDetailResponse(
        id: id,
        type: type,
        maxPerson: maxPerson,
        children: children,
        roomAmount: roomAmount,
        image: image,
        status: status,
        description: description,
        imageMapping: imageMapping,
        overview: overview,
        amenity: amenity,
      );
    } else {
      throw const FormatException('Failed to get room detail');
    }
  }
}

class RoomDetail extends StatefulWidget {
  final String roomId;
  const RoomDetail({super.key, required this.roomId});

  @override
  State<RoomDetail> createState() => _RoomDetailState();
}

class _RoomDetailState extends State<RoomDetail> {
  late String roomId;
  Future<RoomDetailResponse>? roomDetailFutureResponse;

  @override
  void initState() {
    super.initState();
    roomDetailFutureResponse = getRoomDetail(widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RoomDetailResponse>(
        future: roomDetailFutureResponse,
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
            RoomDetailResponse roomData = snapshot.data!;
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
                                  color:
                                      MaterialColors.secondaryBackgroundColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      roomData.type,
                                      style: const TextStyle(
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
                          child: DetailView(
                            detail: roomData,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: BottomAppBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                     
                    ],
                  ),
                ));
          }
        });
  }
}

class DetailView extends StatelessWidget {
  final RoomDetailResponse detail;
  const DetailView({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            CarouselSlider(
              items: detail.imageMapping.map((img) {
                return Image.network(
                    '${ServerConstant.imagehost}/${img['filename']}',
                    fit: BoxFit.cover,
                    width: double.infinity);
              }).toList(),
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction:
                    1, // Show a fraction of the next and previous images
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  BookingPage(roomId: detail.id,),
                        ),
                      );
                    },
                    child: const Text('สำรองห้องพัก'),
                  ),
                ),
              ],
            ),
            const Divider(
              color: Color.fromARGB(
                  255, 106, 106, 106), // Set the color of the line
              height: 10, // Set the height (vertical space) around the line
              thickness: 0.5, // Set the thickness of the line
              indent: 0, // Set the left padding (space before the line)
              endIndent: 0, // Set the right padding (space after the line)
            ),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('รายละเอียดห้องพัก',
                      style: TextStyle(color: MaterialColors.secondary)),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: OverviewList(overviewData: detail.overview)),
              ],
            ),
            const Divider(
              color: Color.fromARGB(
                  255, 106, 106, 106), // Set the color of the line
              height: 10, // Set the height (vertical space) around the line
              thickness: 0.5, // Set the thickness of the line
              indent: 0, // Set the left padding (space before the line)
              endIndent: 0, // Set the right padding (space after the line)
            ),
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text("สิ่งอำนวยความสะดวก",
                      style: TextStyle(color: MaterialColors.secondary)),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: AmenityList(detail: detail)),
              ],
            ),
            const Divider(
              color: Color.fromARGB(
                  255, 106, 106, 106), // Set the color of the line
              height: 10, // Set the height (vertical space) around the line
              thickness: 0.5, // Set the thickness of the line
              indent: 0, // Set the left padding (space before the line)
              endIndent: 0, // Set the right padding (space after the line)
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(detail.description,
                  style: const TextStyle(color: MaterialColors.secondary)),
            ),
          ],
        ),
      ),
    );
  }
}

class AmenityList extends StatelessWidget {
  const AmenityList({
    super.key,
    required this.detail,
  });

  final RoomDetailResponse detail;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // Number of columns
        mainAxisSpacing: 10.0, // Vertical spacing
        crossAxisSpacing: 10.0,
      ),
      itemCount: detail.amenity.length,
      itemBuilder: (BuildContext context, int index) {
        return AmenityItem(amenityDetail: detail.amenity[index]);
      },
    );
  }
}

class AmenityItem extends StatelessWidget {
  final Map<String, dynamic> amenityDetail;
  const AmenityItem({required this.amenityDetail, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.network(
            '${ServerConstant.server}/${amenityDetail['icon']}', // Replace with your image URL
            height: 50,
            fit: BoxFit.contain,
          ),
          // Text(amenityDetail["name"],
          //     style: const TextStyle(fontSize: 8,color: MaterialColors.primaryBackgroundColor)),
        ],
      ),
    );
  }
}

class OverviewList extends StatelessWidget {
  const OverviewList({super.key, required this.overviewData});

  final List<dynamic> overviewData;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // Number of columns
        mainAxisSpacing: 10.0, // Vertical spacing
        crossAxisSpacing: 10.0,
      ),
      itemCount: overviewData.length,
      itemBuilder: (BuildContext context, int index) {
        return OverviewItem(overviewDetail: overviewData[index]);
      },
    );
  }
}

class OverviewItem extends StatelessWidget {
  final Map<String, dynamic> overviewDetail;
  const OverviewItem({required this.overviewDetail, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.network(
            '${ServerConstant.server}/${overviewDetail['icon']}', // Replace with your image URL
            height: 50,
            fit: BoxFit.contain,
          ),
          // Text(overviewDetail["name"],
          //     style: const TextStyle(
          //         fontSize: 8, color: MaterialColors.primaryBackgroundColor)),
        ],
      ),
    );
  }
}
