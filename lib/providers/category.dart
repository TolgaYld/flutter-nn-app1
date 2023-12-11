import 'package:flutter/material.dart';

class Category with ChangeNotifier {
  final String? id;
  final String name;
  final String color;

  Category({
    this.id,
    required this.name,
    required this.color,
  });
}
