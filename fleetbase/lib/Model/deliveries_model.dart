class DeliveriesModel {
  final int delivery_id;
  final String delivery_status;
  final DateTime timestamp;
  const DeliveriesModel( {required this.delivery_id, required this.delivery_status, required this.timestamp});

  factory DeliveriesModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'delivery_id': int delivery_id, 'delivery_status': String delivery_status, 'timestamp': DateTime timestamp} => DeliveriesModel(
        delivery_id: delivery_id,
        delivery_status: delivery_status,
        timestamp: timestamp
      ),
      _ => throw const FormatException('Failed to update deliveries status.'),
    };
  }
}