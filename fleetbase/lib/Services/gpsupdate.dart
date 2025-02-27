import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Services/auth_service.dart';
import '../Model/gps_model.dart';
import '../Services/Location_manager.dart';

class GpsUpdateService {
  final String _url = 'https://supply-y47s.onrender.com/delivery/add_gps';
  final AuthService _authService = AuthService();

  Future<void> updateLocation(String deliveryStatusId) async {
    final location = await LocationHandler().getCurrentLocation();
    
    if (location == null) {
      print('Failed to get current location');
      return;
    }

    final gpsData = gpsModel(
      delivery_status_id: int.parse(deliveryStatusId),
      longitude: location.coordinates.longitude,
      latitude: location.coordinates.latitude,
      timestamp: location.timestamp,
    );

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Authorization': 'Bearer ${await _authService.getToken()}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'delivery_status_id': gpsData.delivery_status_id.toString(),
        'longitude': gpsData.longitude.toString(),
        'latitude': gpsData.latitude.toString(),
        'timestamp': gpsData.timestamp.toIso8601String(),
      },
    );

    if (response.statusCode != 200) {
      print('Update failed: ${response.body}');
    }
  }
}
