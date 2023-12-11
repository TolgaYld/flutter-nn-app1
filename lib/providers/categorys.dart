import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/enviroment.dart';
import '../models/http_exception.dart';
import '../providers/category.dart';

class Categorys with ChangeNotifier {
  List<Category> _categorys = [];

  List<Category> get categorys {
    return [..._categorys];
  }

  Category findById(String id) {
    return _categorys.firstWhere((category) => category.id == id);
  }

  Future<void> fetchAllCategorys() async {
    String _categorysUrl = Enviroment.baseUrl + '/category/getAllActive';

    Dio _dio = Dio();
    try {
      Response _responseCategory = await _dio.get(_categorysUrl,
          options: Options(headers: {
            "Permission": Enviroment.permissionKey,
          }));
      if (_responseCategory.statusCode == 200) {
        final List<Category> _loadedCategorys = [];
        for (var category in await _responseCategory.data) {
          _loadedCategorys.add(Category(
            id: category["id"],
            name: category["name"],
            color: category["color"],
          ));
        }
        _categorys = _loadedCategorys;
        notifyListeners();
      } else {
        throw HttpException(message: _responseCategory.statusMessage!);
      }
    } catch (e) {
      print(e);
      throw HttpException(message: e.toString());
    }
  }
}
