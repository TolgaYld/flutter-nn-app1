import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/enviroment.dart';
import '../providers/subcategory.dart';
import '../models/http_exception.dart';

class Subcategorys with ChangeNotifier {
  List<Subcategory> _subcategorys = [];

  List<Subcategory> get subcategorys {
    return [..._subcategorys];
  }

  Subcategory findById(String id) {
    return _subcategorys.firstWhere((subcategory) => subcategory.id == id);
  }

  List<Subcategory> findByCategoryId(String categoryId) {
    print(_subcategorys);
    return _subcategorys
        .where((subcategory) => subcategory.categoryId == categoryId)
        .toList();
  }

  Future<void> fetchAllSubcategorys() async {
    final String _subcategorysUrl =
        Enviroment.baseUrl + '/subcategory/getAllActiveSubcategorys';

    Dio _dio = Dio();
    try {
      Response _responseSubcategory = await _dio.get(_subcategorysUrl,
          options: Options(headers: {
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseSubcategory.statusCode == 200) {
        if (_responseSubcategory.data[0] != null) {
          if (_responseSubcategory.data[0]["statusCode"] != null) {
            throw HttpException(
                message: "${_responseSubcategory.data[0]["message"]}");
          }
        }

        final List<Subcategory> _loadedSubcategorys = [];

        for (var subcategory in await _responseSubcategory.data) {
          _loadedSubcategorys.add(Subcategory(
            id: subcategory["id"],
            color: subcategory["color"],
            pickSubsubcategory: subcategory["must_pick_subsubcategory"],
            name: subcategory["name"],
            categoryId: subcategory["category_id"],
          ));
        }

        _subcategorys = _loadedSubcategorys;
        notifyListeners();
      } else {
        throw HttpException(message: _responseSubcategory.statusMessage!);
      }
    } catch (e) {
      print(e);
      throw HttpException(message: "Can not fetch Subcategorys.");
    }
  }

  Future<Subcategory> addSuggestion(Subcategory subcategory) async {
    final String _url =
        Enviroment.baseUrl + '/subcategory/createSubcategorySuggestion';

    Dio _dio = Dio();
    try {
      Response _responseSubcategory = await _dio.post(
        _url,
        data: json.encode({
          "name": subcategory.name,
          "category_id": subcategory.categoryId,
        }),
        options: Options(headers: {
          "Permission": Enviroment.permissionKey,
        }),
      );

      if (_responseSubcategory.statusCode == 200) {
        if (_responseSubcategory.data[0] != null) {
          if (_responseSubcategory.data[0]["statusCode"] != null) {
            throw HttpException(
                message: "${_responseSubcategory.data[0]["message"]}");
          }
        }
        final _responseData = await _responseSubcategory.data;
        final newSubcategory = Subcategory(
          id: _responseData["id"],
          name: _responseData["name"],
          categoryId: _responseData["category_id"],
          color: _responseData["color"],
          pickSubsubcategory: _responseData["must_pick_subsubcategory"],
        );
        _subcategorys.add(newSubcategory);
        notifyListeners();
        return newSubcategory;
      } else {
        throw HttpException(message: _responseSubcategory.statusMessage!);
      }
    } catch (e) {
      throw HttpException(message: "Can not create Subcategory.");
    }
  }
}
