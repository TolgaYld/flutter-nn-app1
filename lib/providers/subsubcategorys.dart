import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nownow_advertiser/models/enviroment.dart';
import '../providers/subsubcategory.dart';
import '../models/http_exception.dart';

class Subsubcategorys with ChangeNotifier {
  List<Subsubcategory> _subsubcategorys = [];

  List<Subsubcategory> get subsubcategorys {
    return [..._subsubcategorys];
  }

  Subsubcategory findById(String id) {
    return _subsubcategorys
        .firstWhere((subsubcategory) => subsubcategory.id == id);
  }

  List<Subsubcategory> findByCategoryId(String categoryId) {
    return _subsubcategorys
        .where((subsubcategory) => subsubcategory.categoryId == categoryId)
        .toList();
  }

  List<Subsubcategory> findBySubcategoryId(String subcategoryId) {
    return _subsubcategorys
        .where(
            (subsubcategory) => subsubcategory.subcategoryId == subcategoryId)
        .toList();
  }

  Future<void> fetchAllSubsubcategorys() async {
    final String _subsubcategorysUrl =
        Enviroment.baseUrl + '/subsubcategory/getAllActiveSubsubcategorys';

    Dio _dio = Dio();
    try {
      Response _responseSubsubcategory = await _dio.get(_subsubcategorysUrl,
          options: Options(headers: {
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseSubsubcategory.statusCode == 200) {
        if (_responseSubsubcategory.data[0] != null) {
          if (_responseSubsubcategory.data[0]["statusCode"] != null) {
            throw HttpException(
                message: "${_responseSubsubcategory.data[0]["message"]}");
          }
        }
        final List _responseData = await _responseSubsubcategory.data;
        final List<Subsubcategory> _loadedSubsubcategorys = [];
        for (var subcategory in _responseData) {
          _loadedSubsubcategorys.add(Subsubcategory(
            id: subcategory["id"],
            color: subcategory["color"],
            name: subcategory["name"],
            categoryId: subcategory["category_id"],
            subcategoryId: subcategory["subcategory_id"],
          ));
        }
        _subsubcategorys = _loadedSubsubcategorys;
        notifyListeners();
      } else {
        throw HttpException(message: _responseSubsubcategory.statusMessage!);
      }
    } catch (e) {
      throw HttpException(message: "Can not fetch Subcategorys.");
    }
  }
}
