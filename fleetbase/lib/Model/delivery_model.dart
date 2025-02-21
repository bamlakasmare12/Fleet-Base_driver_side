class deliveryModel {
  final int id;
  final int order_id;
  final String delivery_instructions;
  final DateTime started_at;
  final DateTime delivered_at;
  final double destination_latitude;
  final double destination_longitude;
  const deliveryModel(
      {required this.delivery_instructions,
      required this.id,
      required this.order_id,
      required this.started_at,
      required this.delivered_at,
      required this.destination_latitude,
      required this.destination_longitude,
      });

  factory deliveryModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'oreder_id': int order_id,
        'delivery_instructions': String delivery_instructions,
        'started_at': DateTime started_at,
        'delivered_at': DateTime delivered_at,
        'destination_latitude': double destination_latitude,
        'destination_longitude': double destination_longitude,
      } =>
        deliveryModel(
            id: id,
            order_id: order_id,
            delivery_instructions: delivery_instructions,
            started_at: started_at,
            delivered_at: delivered_at,
            destination_latitude: destination_latitude,
            destination_longitude: destination_longitude,
            
            ),
      _ => throw const FormatException('Failed to load deliveries.'),
    };
  }
}
