import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import "package:imm_hotel_app/constants/server.dart";

Future<List<dynamic>> searchRomm(String roomId,int adult,int children,String dateCheckin,String dateCheckout) async {
  const storage = FlutterSecureStorage();
  var token = await storage.read(key: 'token');
  final response = await http.post(
    Uri.parse('${ServerConstant.server}/customer/searchroom'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    },
    body: jsonEncode(<String,dynamic>{
      'roomId':roomId,
      'adult': adult,
      'children': children,
      'checkIn':dateCheckin,
      'checkOut':dateCheckout
    }),
  ).catchError((error) => throw Exception('Error: $error'));

  if (response.statusCode == 200) {
    List<dynamic> roomData = jsonDecode(response.body);

    if (kDebugMode) {
      print(roomData);
    }

    return roomData;
  } else {
    throw Exception('Failed to get room list');
  }
}