import 'package:cloud_firestore/cloud_firestore.dart';

class WorkModel {
  final String serviceId;
  final String craftsmanId;
  final String craftsmanName;
  final String craftsmanPhone;
  final String title;
  final String category;
  final String description;
  final double? price;
  final String priceType;
  final String location;
  final String imageUrl;
  final bool isAvailable;
  final double rating;
  final int rateCount;
  final Timestamp? createdAt;
  final bool isFav;

  WorkModel({
    required this.serviceId,
    required this.craftsmanId,
    required this.craftsmanName,
    required this.craftsmanPhone,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.priceType,
    required this.location,
    required this.imageUrl,
    required this.isAvailable,
    required this.rating,
    this.rateCount=0,
    this.createdAt,
    this.isFav=false
  });

  WorkModel copyWith({
    String? serviceId,
    String? craftsmanId,
    String? craftsmanName,
    String? craftsmanPhone,
    String? title,
    String? category,
    String? description,
    double? price,
    String? priceType,
    String? location,
    String? imageUrl,
    bool? isAvailable,
    double? rating,
    int? rateCount,
    Timestamp? createdAt,
    bool? isFav

  }) {
    return WorkModel(
      serviceId: serviceId ?? this.serviceId,
      craftsmanId: craftsmanId ?? this.craftsmanId,
      craftsmanName: craftsmanName ?? this.craftsmanName,
      craftsmanPhone: craftsmanPhone ?? this.craftsmanPhone,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      rateCount: rateCount ?? this.rateCount,
      createdAt: createdAt ?? this.createdAt,
      isFav: isFav??this.isFav
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'craftsmanId': craftsmanId,
      'craftsmanName': craftsmanName,
      'craftsmanPhone': craftsmanPhone,
      'title': title,
      'category': category,
      'description': description,
      'price': price,
      'priceType': priceType,
      'location': location,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'rating': rating,
      'rateCount': rateCount,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'isFav':isFav
    };
  }

  factory WorkModel.fromMap(Map<String, dynamic> map, String docId) {
    return WorkModel(
      serviceId: docId, 
      craftsmanId: map['craftsmanId'] ,
      craftsmanName: map['craftsmanName'] ,
      craftsmanPhone: map['craftsmanPhone'] ,
      title: map['title'] ,
      category: map['category'] ,
      description: map['description'] ,
      price: (map['price'] ?? 0.0).toDouble(),
      priceType: map['priceType'] ,
      location: map['location'] ,
      imageUrl: map['imageUrl'] ,
      isAvailable: map['isAvailable'] ,
      rating: (map['rating'] ?? 0.0).toDouble(),
      rateCount: map['rateCount'] ?? 0,
      createdAt: map['createdAt'] as Timestamp?,
      isFav: map['isFav']
    );
  }
}