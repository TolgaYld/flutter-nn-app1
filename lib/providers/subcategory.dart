import 'package:flutter/material.dart';
import '../providers/category.dart';

class Subcategory with ChangeNotifier {
  final String? id;
  final String name;
  final String? color;
  final bool? pickSubsubcategory;
  final String categoryId;

  Subcategory({
    this.id,
    required this.name,
    this.color,
    this.pickSubsubcategory,
    required this.categoryId,
  });
}
