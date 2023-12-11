import 'package:flutter/material.dart';
import '../providers/category.dart';

class SubsubCategoryStad with ChangeNotifier {
  final String? id;
  final String stadId;
  final String subsubcategoryId;

  SubsubCategoryStad({
    this.id,
    required this.stadId,
    required this.subsubcategoryId,
  });
}
