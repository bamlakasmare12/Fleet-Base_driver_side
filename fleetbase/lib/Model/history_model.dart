class HistoryModel {
  final int delivery_status_id;
  final String destinationName;
  final DateTime deliverd_at;
  final DateTime started_at;
  final String created_by;
  const HistoryModel(
      {required this.delivery_status_id,
      required this.destinationName,
      required this.deliverd_at,
      required this.started_at,
      required this.created_by
      });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
            delivery_status_id: json['delivery_status_id'] ?? 0,
            destinationName: json['destination_name']?? '',
            created_by: json['created_by']?? '',
           
            deliverd_at: json['deliverd_at'] != null ? DateTime.parse(json['deliverd_at'])  : DateTime.now(),
            started_at: json['started_at'] !=null ? DateTime.parse(json['started_at'] ) : DateTime.now() , 
            );  
  }
    }
  
