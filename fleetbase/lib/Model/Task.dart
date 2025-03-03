import 'package:flutter/foundation.dart';

class Task {
  final int organizationId;
  final int orderId;
  final double? destinationLongitude;
  final String deliveryInstructions;
  final DateTime deliveredAt;
  final int id;
  final int driverId;
  final double? destinationLatitude;
  final DateTime startedAt;
  final String clientSignature;
  final String destinationAddress;
  final String status;
  // Main constructor
  Task({
    required this.organizationId,
    required this.orderId,
    this.destinationLongitude,
    required this.deliveryInstructions,
    required this.deliveredAt,
    required this.id,
    required this.driverId,
    this.destinationLatitude,
    required this.startedAt,
    required this.clientSignature,
    required this.destinationAddress,
    required this.status,
  });

  // Convert Task to JSON
  Map<String, dynamic> toJson() => {
        'organization_id': organizationId,
        'order_id': orderId,
        'destination_longitude': destinationLongitude,
        'delivery_instructions': deliveryInstructions,
        'delivered_at': deliveredAt.toIso8601String(),
        'id': id,
        'driver_id': driverId,
        'destination_latitude': destinationLatitude,
        'started_at': startedAt.toIso8601String(),
        'client_signature': clientSignature,
        'destination_name': destinationAddress,
        'status': status,
      };

  // Parse JSON into Task
  factory Task.fromJson(Map<String, dynamic> json) {
    // Safely parse numeric fields by converting them to String then double
    double? parseDouble(dynamic val) {
      if (val == null) return null;
      return double.tryParse(val.toString());
    }

    return Task(
      organizationId: json['organization_id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      destinationLongitude: parseDouble(json['destination_longitude']),
      deliveryInstructions: json['delivery_instructions'] ?? '',

      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : DateTime.now(),
      id: json['id'] ?? 0,
      driverId: json['driver_id'] ?? 0,
      destinationLatitude: parseDouble(json['destination_latitude']),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : DateTime.now(),
      clientSignature: json['client_signature'] ?? '',
      destinationAddress: json['destination_name'] ?? '',
      status: json['delivery_status'] ?? '',
    );
 
 }
}