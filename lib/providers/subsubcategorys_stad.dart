import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/enviroment.dart';
import '../providers/subsubcategory_stad.dart';
import '../providers/subsubcategory.dart';
import '../models/http_exception.dart';

class SubsubCategorysStad with ChangeNotifier {
  List<SubsubCategoryStad> _subsubcategorys = [];

  List<SubsubCategoryStad> get subsubcategorys {
    return [..._subsubcategorys];
  }

  SubsubCategorysStad(this.authToken, this._subsubcategorys);

  String? authToken;

  Future<void> fetchAllSubsubcategorys(String stadId) async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    final String _subsubcategorysUrl =
        Enviroment.baseUrl + '/subsubcategoryStad/stadsubsub/$stadId';

    Dio _dio = Dio();
    try {
      Response _responseSubsubcategory = await _dio.get(_subsubcategorysUrl,
          options: Options(headers: {
            "Authorization": "Bearer $authToken",
            "Permission": Enviroment.permissionKey,
          }));
      print(_responseSubsubcategory);

      if (_responseSubsubcategory.statusCode == 200) {
        if (_responseSubsubcategory.data[0] != null) {
          if (_responseSubsubcategory.data[0]["statusCode"] != null) {
            throw HttpException(
                message: "${_responseSubsubcategory.data[0]["message"]}");
          }
        }
        final List _responseData = await _responseSubsubcategory.data;
        final List<SubsubCategoryStad> _loadedSubsubcategorys = [];
        for (var subcategory in _responseData) {
          _loadedSubsubcategorys.add(SubsubCategoryStad(
            id: subcategory["id"],
            stadId: subcategory["stad_id"],
            subsubcategoryId: subcategory["subsubcategory_id"],
          ));
        }
        _subsubcategorys = _loadedSubsubcategorys;
        notifyListeners();
      } else {
        throw HttpException(message: _responseSubsubcategory.statusMessage!);
      }
    } catch (e) {
      print(e);
      throw HttpException(message: "Can not fetch Subcategorys.");
    }
  }
}
