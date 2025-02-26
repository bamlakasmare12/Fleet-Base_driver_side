import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/history_model.dart';
import '../Services/auth_service.dart';
class HistoryManager {
//  final String _url = 'https://supply-y47s.onrender.com/delivery/add_gps';
//final HistoryModel _historyModel = HistoryModel();
final AuthService _authService = AuthService();
  Future<List<dynamic>> loadHistory() async {
    int? driverId = await _authService.getDriverId();

    final url = Uri.parse(
        'https://supply-y47s.onrender.com/delivery/deliveries_driver_history?driver_id=$driverId');

    final token = await _authService.getToken();
    final response = await http.get(url, headers: {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      print('History has been loaded');
      return jsonList;
    } else {
      throw Exception('Failed to fetch history: ${response.statusCode}');
    }
  }
}
