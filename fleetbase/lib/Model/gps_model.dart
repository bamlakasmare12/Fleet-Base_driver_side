class gpsModel {
  final int delivery_status_id;
  final double longitude;
  final double latitude;
  final DateTime timestamp;
  const gpsModel( {
    required this.delivery_status_id,
     required this.longitude, 
     required this.latitude, 
     required this.timestamp});

  factory gpsModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'delivery_status_id': int delivery_status_id, 
      'longitude': double longitude, 
      'latitude': double latitude, 
      'timestamp': DateTime timestamp
      } => gpsModel(
        delivery_status_id: delivery_status_id,
        longitude: longitude,
        latitude: latitude,
        timestamp: timestamp
      ),
      _ => throw const FormatException('Failed to update gps coordinate.'),
    };
  }
}


 