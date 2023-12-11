import 'dart:async';
import 'dart:convert' as JSON;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/enviroment.dart';
import '../models/http_exception.dart';
import '../providers/stad.dart';

class Stads with ChangeNotifier {
  List<Stad> _stads = [];

  List<Timer> _timers = [];

  final String? authToken;

  Stads(this.authToken, this._stads);

  List<Stad> get stads {
    return [..._stads];
  }

  Stad? activeStad(String addressId) {
    if (_stads.isNotEmpty) {
      List stds = _stads
          .where((element) =>
              (element.isActive! ||
                  DateTime.now().toUtc().isAfter(element.begin!)) &&
              DateTime.now().toUtc().isBefore(element.end!) &&
              element.addressId == addressId.trim())
          .toList();
      if (stds.isEmpty) {
        return null;
      } else {
        return stds.first;
      }
    }
    return null;
  }

  List<Stad> nowAndFuture(String addressId) {
    return stads
        .where((std) =>
            std.addressId == addressId &&
            std.isArchive == false &&
            std.isDeleted == false &&
            std.isBanned == false)
        .toList();
  }

  List<Stad> future(String addressId) {
    return stads
        .where((std) =>
            std.addressId == addressId &&
            std.isDeleted == false &&
            std.isArchive == false &&
            std.isActive == false &&
            std.begin!.isAfter(DateTime.now().toUtc()) &&
            std.isBanned == false)
        .toList();
  }

  List<Stad> now(String addressId) {
    return stads
        .where((std) =>
            std.addressId == addressId &&
            std.isActive == true &&
            std.isDeleted == false &&
            std.isBanned == false)
        .toList();
  }

  List<Stad> addressId(String addressId) {
    return stads
        .where((std) => std.addressId == addressId && std.isBanned == false)
        .toList();
  }

  List<Stad> deleted(String addressId) {
    return stads
        .where((std) =>
            std.addressId == addressId &&
            std.isBanned == false &&
            std.isDeleted == true)
        .toList();
  }

  Stad findById(String id) {
    return _stads.firstWhere((stad) => stad.id == id);
  }

  Future<void> fetchAllMyStads() async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    final String _myAddressesUrl = Enviroment.baseUrl + '/stad/myStads';

    Dio _dio = Dio();
    try {
      Response _responseStad = await _dio.get(_myAddressesUrl,
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseStad.statusCode == 200) {
        final List _responseData = await _responseStad.data;
        final List<Stad> _loadedStads = [];
        for (var stad in _responseData) {
          _loadedStads.add(
            Stad(
              id: stad["id"],
              title: stad["title"],
              latitude: stad["latitude"],
              longitude: stad["longitude"],
              shortDescription: stad["short_description"],
              longDescription: stad["long_description"],
              price: double.parse(stad["price"]),
              taxPrice: double.parse(stad["tax_price"]),
              gross: double.parse(stad["gross"]),
              type: stad["type"],
              media: stad["media"],
              begin:
                  stad["begin"] != null ? DateTime.parse(stad["begin"]) : null,
              end: stad["end"] != null ? DateTime.parse(stad["end"]) : null,
              displayRadius: double.parse(stad["display_radius"].toString()),
              pushNotificationRadius:
                  double.parse(stad["push_notification_radius"].toString()),
              categoryId: stad["category_id"],
              subcategoryId: stad["subcategory_id"],
              advertiserId: stad["advertiser_id"],
              isActive: stad["is_active"],
              isBanned: stad["is_banned"],
              isDeleted: stad["is_deleted"],
              isArchive: stad["is_archive"],
              addressId: stad["address_id"],
              createdAt: DateTime.parse(stad["created_at"]),
              invoiceAddressId: stad["invoice_address_id"],
              completelyDeleted: stad["completely_deleted"],
              inInvoice: stad["in_invoice"],
              invoiceDate: stad["invoice_date"] != null
                  ? DateTime.parse(stad["invoice_date"])
                  : null,
              invoiceId: stad["invoice_id"],
              isEditable: DateTime.parse(stad["created_at"])
                          .add(Duration(minutes: 3))
                          .difference(DateTime.now().toUtc())
                          .inSeconds >
                      0
                  ? true
                  : false,
            ),
          );
        }
        _stads.clear();
        _stads = _loadedStads;
        await setStadActive();
        notifyListeners();
      } else {
        throw HttpException(message: _responseStad.statusMessage!);
      }
    } catch (e) {
      throw HttpException(message: "Can not fetch Stads: " + e.toString());
    }
  }

  Future<void> setStadActive() async {
    if (_timers.isNotEmpty) {
      _timers.forEach((element) => element.cancel());
      _timers.clear();
    }
    _stads.forEach((std) {
      if (!std.isActive!) {
        if (!std.isArchive!) {
          if (std.begin != null) {
            if (!std.isDeleted!) {
              Timer(
                  Duration(
                      seconds: std.begin!
                          .difference(DateTime.now().toUtc())
                          .inSeconds), () async {
                final String _url =
                    Enviroment.baseUrl + '/address//inPanel/${std.addressId}';
                Dio _dio = Dio();
                var response = await _dio.get(_url,
                    options: Options(headers: {
                      "Authorization": "Bearer $authToken",
                      "Permission": Enviroment.permissionKey,
                    }));
                if (response.statusCode == 200) {
                  if (response.data != null) {
                    if (!response.data["active_stad"]) {
                      std.isActive = true;
                      notifyListeners();
                    }
                  }
                }
              });
            }
          }
        }
      }
    });

    _stads.forEach((std) {
      if (std.isEditable!) {
        if (!std.isDeleted!) {
          Timer(
              Duration(
                  seconds: std.begin!
                      .add(Duration(minutes: 3))
                      .difference(DateTime.now().toUtc())
                      .inSeconds), () async {
            std.isEditable = false;
            notifyListeners();
          });
        }
      }
    });
  }

  Future<void> addStad(Stad stad) async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    final String _url = Enviroment.baseUrl + '/stad/createStad';

    Dio _dio = Dio();
    try {
      Response _responseStad = await _dio.post(_url,
          data: {
            'title': stad.title,
            'short_description': stad.shortDescription,
            'long_description': stad.longDescription,
            'price': stad.price,
            'media': stad.media,
            'begin': stad.begin != null ? stad.begin!.toIso8601String() : null,
            'end': stad.end != null ? stad.end!.toIso8601String() : null,
            'display_radius': stad.displayRadius,
            'push_notification_radius': stad.pushNotificationRadius,
            'address_id': stad.addressId,
            'invoice_address_id': stad.invoiceAddressId,
            'subsubcategorys': stad.subsubcategoryIds,
          },
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseStad.statusCode == 200) {
        if (_responseStad.data[0] != null) {
          if (_responseStad.data[0]["statusCode"] != null) {
            throw HttpException(message: "${_responseStad.data[0]["message"]}");
          }
        }

        final _responseData = await _responseStad.data;
        final newStad = Stad(
          id: _responseData["id"],
          title: _responseData["title"],
          latitude: _responseData["latitude"],
          longitude: _responseData["longitude"],
          shortDescription: _responseData["short_description"],
          longDescription: _responseData["long_description"],
          price: double.parse(_responseData["price"].toString()),
          taxPrice: double.parse(_responseData["tax_price"].toString()),
          gross: double.parse(_responseData["gross"].toString()),
          type: _responseData["type"],
          media: _responseData["media"],
          begin: _responseData["begin"] != null
              ? DateTime.parse(_responseData["begin"])
              : null,
          end: _responseData["end"] != null
              ? DateTime.parse(_responseData["end"])
              : null,
          displayRadius:
              double.parse(_responseData["display_radius"].toString()),
          pushNotificationRadius: double.parse(
              _responseData["push_notification_radius"].toString()),
          categoryId: _responseData["category_id"],
          subcategoryId: _responseData["subcategory_id"],
          advertiserId: _responseData["advertiser_id"],
          isActive: _responseData["is_active"],
          isBanned: _responseData["is_banned"],
          isDeleted: _responseData["is_deleted"],
          isArchive: _responseData["is_archive"],
          addressId: _responseData["address_id"],
          createdAt: DateTime.parse(_responseData["created_at"]),
          invoiceAddressId: _responseData["invoice_address_id"],
          completelyDeleted: _responseData["completely_deleted"],
          inInvoice: _responseData["in_invoice"],
          invoiceDate: _responseData["invoice_date"] != null
              ? DateTime.parse(_responseData["invoice_date"])
              : null,
          invoiceId: _responseData["invoice_id"],
          isEditable: DateTime.parse(_responseData["created_at"])
                      .add(Duration(minutes: 3))
                      .difference(DateTime.now().toUtc())
                      .inSeconds >
                  0
              ? true
              : false,
        );
        _stads.add(newStad);
        notifyListeners();
        await setStadActive();
      } else {
        throw HttpException(message: _responseStad.statusMessage!);
      }
    } catch (e) {
      throw HttpException(message: e.toString());
    }
  }

  Future<void> addArchive(Stad stad) async {
    final String _url = Enviroment.baseUrl + '/stad/createArchive';

    Dio _dio = Dio();
    try {
      Response _responseStad = await _dio.post(_url,
          data: JSON.json.encode({
            'title': stad.title,
            'short_description': stad.shortDescription,
            'long_description': stad.longDescription,
            'price': stad.price,
            'media': stad.media,
            'display_radius': stad.displayRadius,
            'push_notification_radius': stad.pushNotificationRadius,
            'address_id': stad.addressId,
            'invoice_address_id': stad.invoiceAddressId,
            'subsubcategorys': stad.subsubcategoryIds,
          }),
          options: Options(headers: {
            "Authorization": "Bearer $authToken",
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseStad.statusCode == 200) {
        if (_responseStad.data[0] != null) {
          if (_responseStad.data[0]["statusCode"] != null) {
            throw HttpException(message: "${_responseStad.data[0]["message"]}");
          }
        }
        final _responseData = await _responseStad.data;
        final newStad = Stad(
          id: _responseData["id"],
          title: _responseData["title"],
          latitude: _responseData["latitude"],
          longitude: _responseData["longitude"],
          shortDescription: _responseData["short_description"],
          longDescription: _responseData["long_description"],
          price: _responseData["price"],
          taxPrice: _responseData["tax_price"],
          gross: _responseData["gross"],
          type: _responseData["type"],
          media: _responseData["media"],
          begin: _responseData["begin"] != null
              ? DateTime.parse(_responseData["begin"])
              : null,
          end: _responseData["end"] != null
              ? DateTime.parse(_responseData["end"])
              : null,
          displayRadius: _responseData["display_radius"],
          pushNotificationRadius: _responseData["push_notification_radius"],
          categoryId: _responseData["category_id"],
          subcategoryId: _responseData["subcategory_id"],
          advertiserId: _responseData["advertiser_id"],
          isActive: _responseData["is_active"],
          isBanned: _responseData["is_banned"],
          isDeleted: _responseData["is_deleted"],
          isArchive: _responseData["is_archive"],
          addressId: _responseData["address_id"],
          createdAt: DateTime.parse(_responseData["created_at"]),
          invoiceAddressId: _responseData["invoice_address_id"],
          completelyDeleted: _responseData["completely_deleted"],
          inInvoice: _responseData["in_invoice"],
          invoiceDate: DateTime.parse(_responseData["invoice_date"]),
          invoiceId: _responseData["invoice_id"],
        );
        _stads.add(newStad);
        notifyListeners();
      } else {
        throw HttpException(message: _responseStad.statusMessage!);
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateStad({required String id, required Stad stad}) async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    final _stadIndex = _stads.indexWhere((std) => std.id == id);
    if (_stadIndex >= 0) {
      final String _url = Enviroment.baseUrl + '/stad/updateStad';

      Dio _dio = Dio();
      try {
        Response _responseStad = await _dio.patch(_url,
            data: JSON.json.encode({
              'id': id,
              'title': stad.title,
              'short_description': stad.shortDescription,
              'long_description': stad.longDescription,
              'price': stad.price,
              'media': stad.media,
              'begin':
                  stad.begin != null ? stad.begin!.toIso8601String() : null,
              'end': stad.end != null ? stad.end!.toIso8601String() : null,
              'display_radius': stad.displayRadius,
              'push_notification_radius': stad.pushNotificationRadius,
              'address_id': stad.addressId,
              'invoice_address_id': stad.invoiceAddressId,
              'subsubcategorys': stad.subsubcategoryIds,
            }),
            options: Options(headers: {
              "Authorization": "Bearer $_tkn",
              "Permission": Enviroment.permissionKey,
            }));

        if (_responseStad.statusCode == 200) {
          if (_responseStad.data[0] != null) {
            if (_responseStad.data[0]["statusCode"] != null) {
              throw HttpException(
                  message: "${_responseStad.data[0]["message"]}");
            }
          }
          final _responseData = await _responseStad.data;
          final updatedStad = Stad(
            id: _responseData["id"],
            title: _responseData["title"],
            latitude: _responseData["latitude"],
            longitude: _responseData["longitude"],
            shortDescription: _responseData["short_description"],
            longDescription: _responseData["long_description"],
            price: double.parse(_responseData["price"].toString()),
            taxPrice: double.parse(_responseData["tax_price"].toString()),
            gross: double.parse(_responseData["gross"].toString()),
            type: _responseData["type"],
            media: _responseData["media"],
            begin: _responseData["begin"] != null
                ? DateTime.parse(_responseData["begin"])
                : null,
            end: _responseData["end"] != null
                ? DateTime.parse(_responseData["end"])
                : null,
            displayRadius:
                double.parse(_responseData["display_radius"].toString()),
            pushNotificationRadius: double.parse(
                _responseData["push_notification_radius"].toString()),
            categoryId: _responseData["category_id"],
            subcategoryId: _responseData["subcategory_id"],
            advertiserId: _responseData["advertiser_id"],
            isActive: _responseData["is_active"],
            isBanned: _responseData["is_banned"],
            isDeleted: _responseData["is_deleted"],
            isArchive: _responseData["is_archive"],
            addressId: _responseData["address_id"],
            createdAt: DateTime.parse(_responseData["created_at"]),
            invoiceAddressId: _responseData["invoice_address_id"],
            completelyDeleted: _responseData["completely_deleted"],
            inInvoice: _responseData["in_invoice"],
            invoiceDate: _responseData["invoice_date"] != null
                ? DateTime.parse(_responseData["invoice_date"])
                : null,
            invoiceId: _responseData["invoice_id"],
            isEditable: DateTime.parse(_responseData["created_at"])
                        .add(Duration(minutes: 3))
                        .difference(DateTime.now().toUtc())
                        .inSeconds >
                    0
                ? true
                : false,
          );
          _stads[_stadIndex] = updatedStad;
          notifyListeners();
          await setStadActive();
        } else {
          throw HttpException(message: _responseStad.statusMessage!);
        }
      } catch (e) {
        throw HttpException(message: e.toString());
      }
    }
  }

  Future<void> deleteStad(String id, double price) async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    final String _url = Enviroment.baseUrl + '/stad/deleteStad';
    final _stadIndex = _stads.indexWhere((std) => std.id == id);
    if (_stadIndex >= 0) {
      Dio _dio = Dio();

      try {
        final Response _response = await _dio.delete(_url,
            data: JSON.json.encode({
              "id": id,
              "price": double.tryParse(price.toStringAsFixed(2)),
            }),
            options: Options(headers: {
              "Authorization": "Bearer $_tkn",
              "Permission": Enviroment.permissionKey,
            }));
        print(_response);
        if (_response.statusCode == 200) {
          if (_response.data[0] != null) {
            if (_response.data[0]["statusCode"] != null) {
              throw HttpException(message: "${_response.data[0]["message"]}");
            }
          }

          Stad? _deletedStad = _stads.firstWhere((std) => std.id == id);
          _deletedStad.isDeleted = true;
          _deletedStad.isActive = false;
          _stads[_stadIndex] = _deletedStad;
          notifyListeners();
          await setStadActive();
        }
      } catch (e) {
        throw HttpException(message: 'Could not delete address.');
      }
    }
  }

  Future<void> deleteStadCompletely(String id) async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    final String _url = Enviroment.baseUrl + '/stad/deleteStadCompletely';
    final _existingStadIndex = _stads.indexWhere((std) => std.id == id);
    Stad? _existingStad = _stads[_existingStadIndex];
    _stads.removeAt(_existingStadIndex);
    Dio _dio = Dio();
    try {
      final Response _response = await _dio.delete(_url,
          data: JSON.json.encode({"id": id}),
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));
      if (_response.statusCode == 200) {
        if (_response.data[0] != null) {
          if (_response.data[0]["statusCode"] != null) {
            _stads.insert(_existingStadIndex, _existingStad);
            notifyListeners();
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }
      }
      _existingStad = null;
    } catch (e) {
      _stads.insert(_existingStadIndex, _existingStad!);
      notifyListeners();
      await setStadActive();
      throw HttpException(message: 'Could not delete address.');
    }
  }
}
