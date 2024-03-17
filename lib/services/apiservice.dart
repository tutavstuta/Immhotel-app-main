// api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:imm_hotel_app/constants/server.dart";
import 'package:imm_hotel_app/models/loginresponse.dart';

class ApiService {
  Future<dynamic> login(String email, String password) async {
    var response = await http.post(
      Uri.parse('${ServerConstant.server}/customer/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to login');
    }
  }
}
