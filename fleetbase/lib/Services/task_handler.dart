import 'package:fleetbase/Model/delivery_model.dart';
import 'package:latlong2/latlong.dart';
import '../Model/Task.dart';
import '../Services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Model/task_model.dart';

class TaskHandler {
  Task? acceptedTask;
  AuthService _authService = AuthService();
  deliveryModel? delivery;
  Future<void> acceptTask({
    required Task task,
    required LatLng? currentDestination,
    required Future<void> Function(String) fetchCoordinates,
    required Function(String) onSuccess,
    required Function(String) onError,
    required Function(Task?) updateAcceptedTask,
  }) async {
    if (currentDestination == null) {
      onError("Cannot accept this task yet. Waiting for current location...");
      return;
    }
    if (acceptedTask == null) {
      acceptedTask = task;
      updateAcceptedTask(acceptedTask);
      await fetchCoordinates((task.destinationLatitude.toString() + ',' + task.destinationLongitude.toString()));
      onSuccess("Task '${task.id}' accepted.");
    } else if (acceptedTask!.id == task.id) {
      onError("Task '${task.id}' is already accepted.");
    } else {
      onError("You must finish your current task before accepting another.");
    }
  }

  void finishTask({
    required LatLng? currentLocation,
    required LatLng? destination,
    required Function onFinished,
    required Function(String) onError,
  }) {
    if (acceptedTask == null) {
      onError("No task has been accepted.");
      return;
    }
    if (currentLocation != null && destination != null) {
      final distanceCalculator = Distance();
      final distanceInMeters = distanceCalculator(currentLocation, destination);
      if (distanceInMeters <= 50) {
        acceptedTask = null;
        onFinished();
      } else {
        onError("You haven't reached the destination yet.");
      }
    }
  }

  Future<void> routeToAcceptedTask({
    required Future<void> Function(String) fetchCoordinatesCallback,
    required Function(String) onError,
  }) async {
    if (acceptedTask != null) {
      
      await fetchCoordinatesCallback(acceptedTask!.destinationLongitude.toString() + ',' + acceptedTask!.destinationLatitude.toString());
    } else {
      onError("No task has been accepted.");
    }
  }

  Future<List<Task>> fetchDeliveries(String driverId) async {
    String drivers = '14';
    final String baseUrl = "https://supply-y47s.onrender.com";
    final String endpoint = "/delivery/deliveries_driver?driver_id=$drivers";
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.get(
        uri, headers: {
          "accept": "application/json",
          "Authorization": "Bearer ${await _authService.getToken()}",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Map each JSON object to a TaskModel using the fromJson factory
        return data
            .map((jsonItem) => Task.fromJson(jsonItem))
            .toList();
      } else {
        throw Exception(
            "Failed to load deliveries. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching deliveries: $e");
    }
  }
}
