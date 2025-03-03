class OrderDelivery {
  final OrderDetails orderDetails;
  final List<OrderItem> orderItems;
  final double total;
  final ClientDetails clientDetails;
  final List<ProductMap> productMap;

  OrderDelivery({
    required this.orderDetails,
    required this.orderItems,
    required this.total,
    required this.clientDetails,
    required this.productMap,
  });

  factory OrderDelivery.fromJson(Map<String, dynamic> json) {
    return OrderDelivery(
      orderDetails: OrderDetails.fromJson(json['order_details']),
      orderItems: (json['order_items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      total: (json['total'] as num).toDouble(),
      clientDetails: ClientDetails.fromJson(json['client_details']),
      productMap: (json['product_map'] as List)
          .map((item) => ProductMap.fromJson(item))
          .toList(),
    );
  }
}

class OrderDetails {
  final int clientId;
  final DateTime orderDate;
  final int organizationId;
  final DateTime updatedAt;
  final int id;
  final String userId;
  final DateTime createdAt;
  final String status;

  OrderDetails({
    required this.clientId,
    required this.orderDate,
    required this.organizationId,
    required this.updatedAt,
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.status,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      clientId: json['client_id'] as int,
      orderDate: DateTime.parse(json['order_date'] as String),
      organizationId: json['organization_id'] as int,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      id: json['id'] as int,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String,
    );
  }
}

class OrderItem {
  final double price;
  final int id;
  final int productId;
  final int quantity;
  final int orderId;

  OrderItem({
    required this.price,
    required this.id,
    required this.productId,
    required this.quantity,
    required this.orderId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      price: (json['price'] as num).toDouble(),
      id: json['id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      orderId: json['order_id'] as int,
    );
  }
}

class ClientDetails {
  final String phone;
  final int id;
  final String companyName;
  final String clientType;
  final String email;
  final int? organizationId;
  final String contactPerson;

  ClientDetails({
    required this.phone,
    required this.id,
    required this.companyName,
    required this.clientType,
    required this.email,
    this.organizationId,
    required this.contactPerson,
  });

  factory ClientDetails.fromJson(Map<String, dynamic> json) {
    return ClientDetails(
      phone: json['phone'] as String,
      id: json['id'] as int,
      companyName: json['company_name'] as String,
      clientType: json['client_type'] as String,
      email: json['email'] as String,
      organizationId: json['organization_id'] as int?,
      contactPerson: json['contact_person'] as String,
    );
  }
}

class ProductMap {
  final int productId;
  final String productName;
  final int warehouseId;
  final String warehouseName;
  final int quantity;
  final double price;

  ProductMap({
    required this.productId,
    required this.productName,
    required this.warehouseId,
    required this.warehouseName,
    required this.quantity,
    required this.price,
  });

  factory ProductMap.fromJson(Map<String, dynamic> json) {
    return ProductMap(
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      warehouseId: json['warehouse_id'] as int,
      warehouseName: json['warehouse_name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }
}