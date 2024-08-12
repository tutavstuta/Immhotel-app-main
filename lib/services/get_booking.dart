import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import "package:imm_hotel_app/constants/server.dart";

Future<List<dynamic>> getbooking() async {
  const storage = FlutterSecureStorage();
  var token = await storage.read(key: 'token');
  final response = await http.get(
    Uri.parse('${ServerConstant.server}/customer/booked'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    },
  ).catchError((error) => throw Exception('Error: $error'));

  if (response.statusCode == 200) {
    List<dynamic> bookings = jsonDecode(response.body);

    if (kDebugMode) {
      print(bookings);
    }

    return bookings;
  } else {
    throw Exception('Failed to get room list');
  }
}
