import '../Services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Model/orderList_model.dart';

class ListViewManager {
  final AuthService authService = AuthService();

  final String baseUrl = 'https://supply-y47s.onrender.com';

 Future<OrderDelivery> getDeliveryDetails(int orderId) async {
  final token = await authService.getToken(); // get bearer token
  // Use the correct query param and headers:
  final url = Uri.parse('$baseUrl/sales/invoice?order_id=$orderId');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token', // add bearer token
      'accept': 'application/json'
    },
  );

  if (response.statusCode == 200) {
    return OrderDelivery.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load order: ${response.statusCode}');
  }
}
}
