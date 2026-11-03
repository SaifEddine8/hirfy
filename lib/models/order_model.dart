class OrderModel {
  final String orderId;
  final String serviceId;     
  final String craftsmanId;   
  final String craftsmanName; 
  final String craftsmanPhone; 
  final String clientId;      
  final String clientName;    
  final String clientPhone;   
  final String location;      
  final String notes;         
  final String status;      
  final DateTime createdAt;   
  final String serviceName;
  final double? price; 
  final String priceType; 

  OrderModel({
    required this.orderId,
    required this.serviceId,
    required this.craftsmanId,
    required this.craftsmanName,
    required this.craftsmanPhone,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.location,
    required this.notes,
    required this.status,
    required this.createdAt,
    required this.serviceName,
    required this.price,
    required this.priceType,
  });

  OrderModel copyWith({
    String? orderId,
    String? serviceId,
    String? craftsmanId,
    String? craftsmanName,
    String? craftsmanPhone,
    String? clientId,
    String? clientName,
    String? clientPhone,
    String? location,
    String? notes,
    String? status,
    DateTime? createdAt,
    String? serviceName,
    double? price,
    String? priceType,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      serviceId: serviceId ?? this.serviceId,
      craftsmanId: craftsmanId ?? this.craftsmanId,
      craftsmanName: craftsmanName ?? this.craftsmanName,
      craftsmanPhone: craftsmanPhone ?? this.craftsmanPhone,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'serviceId': serviceId,
      'craftsmanId': craftsmanId,
      'craftsmanName': craftsmanName,
      'craftsmanPhone': craftsmanPhone,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'location': location,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'serviceName': serviceName,
      'price': price,
      'priceType': priceType,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      serviceId: map['serviceId'] ?? '',
      craftsmanId: map['craftsmanId'] ?? '',
      craftsmanName: map['craftsmanName'] ?? '',
      craftsmanPhone: map['craftsmanPhone'] ?? '',
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      clientPhone: map['clientPhone'] ?? '',
      location: map['location'] ?? '',
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'قيد الانتظار',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String(),
      
      ),
      serviceName: map['serviceName'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      priceType: map['priceType'] ?? '',
    );
  }
}