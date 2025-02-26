import 'package:flutter/foundation.dart';

class TaskModel {
  final String userId;
  final String name;
  final double latitude;
  final DateTime updatedAt;
  final double longitude;
  final int id;
  final int organizationId;
  final DateTime createdAt;

  TaskModel({
    required this.userId,
    required this.name,
    required this.latitude,
    required this.updatedAt,
    required this.longitude,
    required this.id,
    required this.organizationId,
    required this.createdAt,
  });

  // Convert TaskModel to JSON
  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'latitude': latitude,
        'updated_at': updatedAt.toIso8601String(),
        'longitude': longitude,
        'id': id,
        'organization_id': organizationId,
        'created_at': createdAt.toIso8601String(),
      };

  // Parse JSON into TaskModel
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      userId: json['user_id']?.toString() ?? '', // Handle UUID as String
      name: json['name']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      id: json['id'] ?? 0,
      organizationId: json['organization_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}