import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteHandler {
  // Replace with your actual OpenRouteService API key.
  final String openRouteServiceApiKey = '5b3ce3597851110001cf62484e009de0ea124e889e5bd3297722d931';

  Future<List<LatLng>> getRoute({
    required LatLng current,
    required LatLng destination,
  }) async {
    final headers = {
      'Accept': 'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
    };

    final start = '${current.longitude},${current.latitude}';
    final end = '${destination.longitude},${destination.latitude}';
    final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$openRouteServiceApiKey&start=$start&end=$end');

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List coordinates = data['features'][0]['geometry']['coordinates'];
        return coordinates
            .map<LatLng>((e) => LatLng(e[1].toDouble(), e[0].toDouble()))
            .toList();
      } else {
        throw Exception('Failed to fetch route: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<LatLng?> fetchCoordinates(String location) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat'].toString());
        final lon = double.parse(data[0]['lon'].toString());
        return LatLng(lat, lon);
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to fetch location. Please try again later.');
    }
  }
}
