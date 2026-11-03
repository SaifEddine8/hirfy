import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final User? user;
  final double radius;

  const ProfileAvatarWidget({
    Key? key,
    required this.user,
    this.radius = 50.0, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? photoPath = user?.photoURL;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: (photoPath != null && photoPath.isNotEmpty)
          ? (photoPath.startsWith('http')
              ? NetworkImage(photoPath) as ImageProvider
              : FileImage(File(photoPath)))
          : null,
      child: (photoPath == null || photoPath.isEmpty)
          ? Icon(Icons.person, size: radius, color: Colors.white)
          : null,
    );
  }
}