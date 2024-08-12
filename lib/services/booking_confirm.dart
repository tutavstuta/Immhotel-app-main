import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import "package:imm_hotel_app/constants/server.dart";

Future<BookingResponse> confirmBooking(String roomId, int adult, int children,
    String promotionId, String checkIn, String checkOut) async {
  const storage = FlutterSecureStorage();
  var token = await storage.read(key: 'token');
  final response = await http.post(
    Uri.parse('${ServerConstant.server}/customer/createbooking'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token'
    },
    body: jsonEncode(<String, dynamic>{
      'roomId': roomId,
      'adult': adult,
      'children': children,
      'promotionId': promotionId,
      'checkIn': checkIn,
      'checkOut': checkOut,
    }),
  );

  if (response.statusCode == 200) {
    return BookingResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to login');
  }
}

class BookingResponse {
  final String bookingId;

  const BookingResponse({
    required this.bookingId,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'bookingId': String bookingId,
      } =>
        BookingResponse(
          bookingId: bookingId,
        ),
      _ => throw const FormatException('Failed to login'),
    };
  }
}
