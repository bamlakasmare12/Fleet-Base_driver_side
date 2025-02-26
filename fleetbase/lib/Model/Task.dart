import 'package:flutter/foundation.dart';

class Task {
  final int organizationId;
  final String createdBy;
  final int orderId;
  final double? destinationLongitude;
  final String deliveryInstructions;
  final DateTime deliveredAt;
  final int id;
  final int driverId;
  final double? destinationLatitude;
  final DateTime startedAt;
  final String clientSignature;
  final String destinationAddress ;
  // Main constructor
  Task({
    required this.organizationId,
    required this.createdBy,
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
  });

  // Convert Task to JSON
  Map<String, dynamic> toJson() => {
        'organization_id': organizationId,
        'created_by': createdBy,
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
      createdBy: json['created_by'] ?? '',
      orderId: json['order_id'] ?? 0,
      destinationLongitude: parseDouble(json['destination_longitude']),
      deliveryInstructions: json['delivery_instructions'] ?? '',
      destinationAddress: json['destination_name'] ?? '',

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
    );
  }
}