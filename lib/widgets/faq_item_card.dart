import 'dart:core';

import 'package:flutter/material.dart';

class FaqItemCard extends StatelessWidget {
  final String question;
  final String answer;
  const FaqItemCard({super.key,required  this.question, required  this.answer});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}