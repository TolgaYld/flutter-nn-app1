import 'package:flutter/material.dart';
import '../providers/category.dart';

class SubsubCategoryQroffer with ChangeNotifier {
  final String? id;
  final String qrofferId;
  final String subsubcategoryId;

  SubsubCategoryQroffer({
    this.id,
    required this.qrofferId,
    required this.subsubcategoryId,
  });
}
