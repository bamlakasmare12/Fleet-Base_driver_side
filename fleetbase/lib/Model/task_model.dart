class TaskModel {
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

  const TaskModel({
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
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      organizationId: json['organization_id'] as int,
      createdBy: json['created_by'] as String,
      orderId: json['order_id'] as int,
      destinationLongitude: json['destination_longitude'] != null 
          ? (json['destination_longitude'] as num).toDouble() 
          : null,
      deliveryInstructions: json['delivery_instructions'] as String,
      deliveredAt: DateTime.parse(json['delivered_at'] as String),
      id: json['id'] as int,
      driverId: json['driver_id'] as int,
      destinationLatitude: json['destination_latitude'] != null 
          ? (json['destination_latitude'] as num).toDouble() 
          : null,
      startedAt: DateTime.parse(json['started_at'] as String),
      clientSignature: json['client_signature'] as String,
    );
  }
}
