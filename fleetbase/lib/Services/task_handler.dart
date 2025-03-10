import 'package:fleetbase/Model/delivery_model.dart';
import 'package:latlong2/latlong.dart';
import '../Model/Task.dart';
import '../Services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Model/task_model.dart';
import '../services/delivery_manager.dart';
class TaskHandler {
  Task? acceptedTask;
  AuthService _authService = AuthService();
  deliveryModel? delivery;
  DeliveryHandler? deliveryManager = DeliveryHandler();

 Future<void> acceptTask({
    required Task task,
    required LatLng? currentDestination,
    required Future<void> Function(String) fetchCoordinates,
    required Function(String) onSuccess,
    required Function(String) onError,
    required Function(Task?) updateAcceptedTask,
  }) async {
    if (currentDestination == null) {
      onError("Cannot accept task - location unavailable");
      return;
    }
    
    if (acceptedTask == null) {
      try {
        // Update backend status first
        await updateDeliveryStatus(task.id);
        
        acceptedTask = task;
        updateAcceptedTask(acceptedTask);
        
        // Directly set coordinates instead of geocoding
        await fetchCoordinates(
          "${task.destinationLatitude},${task.destinationLongitude}"
        );
        
        onSuccess("Task ${task.id} accepted");
      } catch (e) {
        onError("Acceptance failed: ${e.toString()}");
      }
    } else {
      onError("Finish current task first");
    }
  }
  Future<void> finishTask({
required int? id,
    required String? imageUrl,
    required Function onFinished,
    required Function(String) onError,
  }) async {
   
    try {
      final String baseUrl = "https://supply-y47s.onrender.com";
      final endpoint = "/delivery/delivery_delivered?delivery_id=${id}";
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${await _authService.getToken()}",
        },
       
      );
      final String baseUrl2 = "https://supply-y47s.onrender.com";
    final endpoint2 = "/delivery/add_client_signature?delivery_id=${id}&signature=$imageUrl";
      final uri2 = Uri.parse('$baseUrl2$endpoint2');

      final response2 = await http.post(
        uri2,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${await _authService.getToken()}",
        },
       
      );

      if (response.statusCode == 200 && response2.statusCode == 200) {
        acceptedTask = null;
        onFinished();
      
      }else {
        onError("Failed to complete task: ${response.statusCode}/ ${response2.statusCode}");
      }
    } catch (e) {
      onError("Task completion error: ${e.toString()}");
    }
  }

  void checkTask({
    required LatLng? currentLocation,
    required LatLng? destination,
    required Function onFinished,
    required Function(String) onError,
  }) {
    if (currentLocation != null && destination != null) {
      final distanceCalculator = Distance();
      final distanceInMeters = distanceCalculator(currentLocation, destination);
      if (distanceInMeters <= 50) {
        acceptedTask = null;
        onFinished();
      } else {
        onError("You haven't reached the warehouse yet.");
      }
    }
  }

  Future<void> routeToAcceptedTask({
    required Future<void> Function(String) fetchCoordinatesCallback,
    required Function(String) onError,
  }) async {
    if (acceptedTask != null) {
      await fetchCoordinatesCallback(
          acceptedTask!.destinationLongitude.toString() +
              ',' +
              acceptedTask!.destinationLatitude.toString());
    } else {
      onError("No task has been accepted.");
    }
  }

  Future<int?> getDriverId() async {
    final String baseUrl = "https://supply-y47s.onrender.com";
    final String endpoint = "/driver_id";
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.get(
        uri,
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer ${await _authService.getToken()}",
        },
      );

      final decoded = jsonDecode(response.body);
      dynamic rawId;

      // If the response is a list, extract the first element.
      if (decoded is List && decoded.isNotEmpty) {
        rawId = decoded[0]['id'];
      } else if (decoded is Map) {
        rawId = decoded['id'];
      } else {
        print("Unexpected JSON format");
        return null;
      }

      print('The driver id is: $rawId');

      // If rawId is already an int, return it. If it's a string, try to parse it.
      if (rawId is int) {
        return rawId;
      } else if (rawId is String) {
        return int.tryParse(rawId);
      } else {
        print("Unexpected type for id: ${rawId.runtimeType}");
        return null;
      }
    } catch (e) {
      print("Error retrieving user ID: $e");
      return null;
    }
  }

Future<int> getdeliveryStatusId(int deliveryid)async{
final String baseUrl = "https://supply-y47s.onrender.com";
    final String endpoint = "/delivery/get_latest_delivery_status_update?delivery_id=$deliveryid";
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.get(
        uri,
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer ${await _authService.getToken()}",
        },
      );

      final decoded = jsonDecode(response.body);
      dynamic rawId;

      // If the response is a list, extract the first element.
      if (decoded is List && decoded.isNotEmpty) {
        rawId = decoded[0]['id'];
      } else if (decoded is Map) {
        rawId = decoded['id'];
      } else {
        print("Unexpected JSON format");
        return -1;
      }

      print('The driver id is: $rawId');

      // If rawId is already an int, return it. If it's a string, try to parse it.
      if (rawId is int) {
        return rawId;
      
      } else {
        print("Unexpected type for id: ${rawId.runtimeType}");
        return -1;
      }
    } catch (e) {
      print("Error retrieving user ID: $e");
      return -1;
    }

}

  Future<List<Task>> fetchDeliveries() async {
    int? drivers = await _authService.getDriverId();
    try {
      if (drivers == null) {
        throw Exception("Invalid driver ID");
      }
      print('the driver id is from fetch deliveries $drivers');
      final String baseUrl = "https://supply-y47s.onrender.com";
      final String endpoint = "/delivery/deliveries_driver?driver_id=$drivers";
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http.get(
        uri,
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer ${await _authService.getToken()}",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Map each JSON object to a TaskModel using the fromJson factory
        return data.map((jsonItem) => Task.fromJson(jsonItem)).toList();
      } else {
        throw Exception(
            "Failed to load deliveries. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching deliveries from task handleer: $e");
    }
  }

  Future<List<TaskModel>> fetchWarehouses(int deliveryId) async {
    //String? deliveryId = await deliveryManager?.getdeliveryid();
    print('the id of delivery is from fetch warehouses: $deliveryId');
    try {
      if (deliveryId == null) {
        throw Exception("Invalid organization ID");
      }
      final String baseUrl = "https://supply-y47s.onrender.com";
      final String endpoint =
          "/delivery/delivery_source?delivery_id=$deliveryId";
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http.get(
        uri,
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer ${await _authService.getToken()}",
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        // If 'data' is already a List, parse each element.
        if (data is List) {
          return data.map((jsonItem) => TaskModel.fromJson(jsonItem)).toList();
        }
        // If 'data' is a single JSON object, wrap it in a list of length 1.
        else if (data is Map) {
          return [TaskModel.fromJson(data.cast<String, dynamic>())];
        }
        // Otherwise, it's an unexpected format.
        else {
          throw Exception("Unexpected JSON format: $data");
        }
      } else {
        throw Exception(
            "Failed to load warehouses. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching warehouses: $e");
    }
  }

  Future<void> delayTask(int deliveryId, String notes) async {
    final String baseUrl = 'https://supply-y47s.onrender.com';
    final Uri url = Uri.parse(
        '$baseUrl/delivery/delivery_delay?delivery_id=$deliveryId&note=$notes');
    final token = await _authService.getToken();

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'application/json', // Use application/json
      },
    );

    if (response.statusCode != 200) {
      print('Response body: ${response.body}');
      throw Exception(
          'Failed to update delivery status: ${response.statusCode}');
    }
  }

 Future<void> updateDeliveryStatus(int deliveryId) async {
    final String baseUrl = 'https://supply-y47s.onrender.com';
    final url = Uri.parse(
      '$baseUrl/delivery/delivery_picked_up?delivery_id=$deliveryId'
    );
    
    final response = await http.post(
      url,
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer ${await _authService.getToken()}',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Status update failed: ${response.statusCode}');
    }
  }

  
}
