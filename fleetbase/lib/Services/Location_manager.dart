import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class LocationResult {
  final LatLng coordinates;
  final DateTime timestamp;
  LocationResult(this.coordinates, this.timestamp);
}

class LocationHandler {
  final Location locationService = Location();

  Future<bool> checkAndRequestPermission() async {
    try {
      // Check/enable location services
      bool serviceEnabled = await locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await locationService.requestService();
        if (!serviceEnabled) return false;
      }

      // Check/request location permissions
      // PermissionStatus permission = await locationService.hasPermission();
      // if (permission == PermissionStatus.denied) {
      //   permission = await locationService.requestPermission();
      //   if (permission != PermissionStatus.granted) return false;
      // }
       return true;
    } catch (e) {
      print('Permission error: $e');
      return false;
    }
  }

  Future<LocationResult?> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      final locationData = await locationService.getLocation();
      if (locationData.latitude == null || locationData.longitude == null) {
        return null;
      }

      return LocationResult(
        LatLng(locationData.latitude!, locationData.longitude!),
        locationData.time != null 
            ? DateTime.fromMillisecondsSinceEpoch(locationData.time! as int)
            : DateTime.now(),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<void> initializeLocation({
    required Function(LatLng) onLocationUpdate,
    required MapController mapController,
  }) async {
    try {
      await locationService.changeSettings(
        interval: 5000,
        distanceFilter: 0,
        accuracy: LocationAccuracy.high,
      );
      
      locationService.onLocationChanged.listen((locationData) {
        if (locationData.latitude != null && locationData.longitude != null) {
          final currentLatLng = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
          onLocationUpdate(currentLatLng);
          mapController.move(currentLatLng, 16);
        }
      });
    } catch (e) {
      print('Location tracking error: $e');
    }
  }
}