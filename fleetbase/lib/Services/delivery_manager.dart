import '../Services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeliveryHandler {
  final AuthService authService = AuthService();

  final String baseUrl = 'https://supply-y47s.onrender.com';

  Future<Map<String, dynamic>> getDeliveryStatusUpdates(
      String deliveryId) async {
    final url = Uri.parse(
        '$baseUrl/delivery/get_delivery_status_updates?delivery_id=$deliveryId');
    try {
      final response = await http.get(url, headers: {
        'accept': 'application/json',
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to fetch delivery status updates: ${response.statusCode}');
      }
    } catch (e) {
      // Log the error and rethrow a more descriptive exception.
      print('Exception caught during GET request: $e');
      throw Exception('Failed to fetch: $url');
    }
  }

  Future<String> getDeliveryStatusId(String deliveryId) async {
    try {
      final data = await getDeliveryStatusUpdates(deliveryId);
      if (data.containsKey('deliveryStatusId')) {
        return data['deliveryStatusId'].toString();
      } else {
        throw Exception('deliveryStatusId not found in response');
      }
    } catch (e) {
      throw Exception('Error getting deliveryStatusId: $e');
    }
  }

  

 Future<String> getdeliveryid() async {
  int? driverId = await authService.getDriverId();
  final url = Uri.parse('$baseUrl/delivery/deliveries_driver?driver_id=$driverId');
  final token = await authService.getToken();
  final response = await http.get(url, headers: {
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
  });

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    if (jsonList.isNotEmpty && jsonList[0]['id'] != null) {
      return jsonList[0]['id'].toString();
    } else {
      throw Exception('No delivery data found.');
    }
  } else {
    throw Exception('Failed to fetch data: ${response.statusCode}');
  }
}

}
