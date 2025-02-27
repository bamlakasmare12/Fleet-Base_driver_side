import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Services/auth_service.dart';
class DeliveryUpdate{
  static Future<void> updateDeliveryStatus(String deliveryId, String status) async {  
    final AuthService authService = AuthService();
    final String baseUrl = 'https://supply-y47s.onrender.com';
    final url = Uri.parse('$baseUrl/delivery/update_delivery_status');
    final token = await authService.getToken();
    final response = await http.post(url, headers: {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    }, body: {
      'delivery_id': deliveryId,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to update delivery status: ${response.statusCode}');
    }
  }

}