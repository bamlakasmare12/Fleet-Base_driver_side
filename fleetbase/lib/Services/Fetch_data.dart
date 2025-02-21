import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Services/auth_service.dart';
class Fetchdata{
AuthService _authService = AuthService();
  Future<List<dynamic>> fetchDeliveries(String driverId) async {
      final String baseUrl = "https://supply-y47s.onrender.com";

  final String endpoint = "/delivery/deliveries_driver?driver_id=$driverId";

  try {
    final response = await http.get(
      Uri.parse(baseUrl + endpoint),
      headers: {"accept": "application/json",
      "Authorization": "Bearer ${await _authService.getToken()}"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data; // Adjust based on your API response
    } else {
      throw Exception(
          "Failed to load deliveries. Status code: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Error fetching deliveries: $e");
  }
}
Future<String> getCurrentUser()async{
    final String baseUrl = "https://supply-y47s.onrender.com";

  final String endpoint = "/auth/current_user";
final accesstoken= await _authService.getToken();
  try {
    final response = await http.get(
      Uri.parse(baseUrl + endpoint),
      headers: {"Authorization": "Bearer $accesstoken"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['name'];
    } else {
      throw Exception(
          "Failed to get current user. Status code: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Error getting current user: $e");
  }


}

}