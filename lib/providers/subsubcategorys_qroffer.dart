import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/enviroment.dart';
import '../providers/subsubcategory_qroffer.dart';
import '../models/http_exception.dart';

class SubsubCategorysQroffer with ChangeNotifier {
  List<SubsubCategoryQroffer> _subsubcategorys = [];

  List<SubsubCategoryQroffer> get subsubcategorys {
    return [..._subsubcategorys];
  }

  SubsubCategorysQroffer(this.authToken, this._subsubcategorys);

  String? authToken;

  Future<void> fetchAllSubsubcategorys(String qrofferId) async {
    final String _subsubcategorysUrl =
        Enviroment.baseUrl + '/subsubcategoryQroffer/qrofferssubsub/$qrofferId';

    Dio _dio = Dio();
    try {
      Response _responseSubsubcategory = await _dio.get(_subsubcategorysUrl,
          options: Options(headers: {
            "Authorization": "Bearer $authToken",
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
        print(_responseData);
        final List<SubsubCategoryQroffer> _loadedSubsubcategorys = [];
        for (var subcategory in _responseData) {
          _loadedSubsubcategorys.add(SubsubCategoryQroffer(
            id: subcategory["id"],
            qrofferId: subcategory["qroffer_id"],
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
