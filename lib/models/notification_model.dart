import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final String relatedId;
  final bool isRead;
  final Timestamp? createdAt; 

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.relatedId,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NotificationModel(
      id: documentId,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? '',
      relatedId: map['relatedId'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'relatedId': relatedId,
      'isRead': isRead,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}