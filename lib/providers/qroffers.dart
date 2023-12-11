import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/enviroment.dart';
import '../providers/qroffer.dart';
import '../models/http_exception.dart';

class Qroffers with ChangeNotifier {
  List<Qroffer> _qroffers = [];

  List<Timer> _timers = [];

  final String? authToken;

  Qroffers(this.authToken, this._qroffers);

  List<Qroffer> get qroffers {
    return [..._qroffers];
  }

  List<Qroffer>? activeQroffers(String addressId) {
    return _qroffers
        .where(
          (qroffer) =>
              (qroffer.isActive! ||
                  DateTime.now().toUtc().isAfter(qroffer.begin!)) &&
              DateTime.now().toUtc().isBefore(qroffer.end!) &&
              qroffer.addressId == addressId,
        )
        .toList();
  }

  Qroffer findById(String id) {
    return _qroffers.firstWhere((qrf) => qrf.id == id);
  }

  List<Qroffer> findByAddressId(String addressId) {
    return _qroffers.where((qrf) => qrf.addressId == addressId).toList();
  }

  List<Qroffer> nowAndFuture(String addressId) {
    return _qroffers
        .where((qroffer) => (qroffer.isDeleted == false &&
            qroffer.addressId == addressId &&
            qroffer.isArchive == false &&
            qroffer.isBanned == false))
        .toList();
  }

  List<Qroffer> future(String addressId) {
    return _qroffers
        .where((qroffer) => (qroffer.isDeleted == false &&
            qroffer.addressId == addressId &&
            qroffer.isArchive == false &&
            qroffer.isActive == false &&
            qroffer.begin!.isAfter(DateTime.now().toUtc()) &&
            qroffer.isBanned == false))
        .toList();
  }

  List<Qroffer> now(String addressId) {
    return _qroffers
        .where((qroffer) => (qroffer.isDeleted == false &&
            qroffer.isActive == true &&
            qroffer.addressId == addressId &&
            qroffer.isBanned == false))
        .toList();
  }

  List<Qroffer> addressId(String addressId) {
    return _qroffers
        .where((qroffer) =>
            (qroffer.addressId == addressId && qroffer.isBanned == false))
        .toList();
  }

  List<Qroffer> deleted(String addressId) {
    return _qroffers
        .where((qroffer) => (qroffer.addressId == addressId &&
            qroffer.isBanned == false &&
            qroffer.isDeleted == true))
        .toList();
  }

  Future<void> fetchAllMyQroffers() async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    String _myAddressesUrl = Enviroment.baseUrl + '/qroffer/getAllMyQroffers';

    Dio _dio = Dio();
    try {
      Response _responseQroffers = await _dio.get(_myAddressesUrl,
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseQroffers.statusCode == 200) {
        final List _responseData = await _responseQroffers.data;
        final List<Qroffer> _loadedQroffers = [];
        for (var qroffer in _responseData) {
          _loadedQroffers.add(
            Qroffer(
              id: qroffer["id"],
              title: qroffer["title"],
              latitude: qroffer["latitude"],
              longitude: qroffer["longitude"],
              shortDescription: qroffer["short_description"],
              longDescription: qroffer["long_description"],
              price: double.parse(qroffer["price"].toString()),
              taxPrice: double.parse(qroffer["tax_price"].toString()),
              gross: double.parse(qroffer["gross"].toString()),
              type: qroffer["type"],
              media: qroffer["media"],
              begin: qroffer["begin"] != null
                  ? DateTime.parse(qroffer["begin"])
                  : null,
              end: qroffer["end"] != null
                  ? DateTime.parse(qroffer["end"])
                  : null,
              qrValue: int.parse(qroffer["qr_value"].toString()),
              liveQrValue: int.parse(qroffer["live_qr_value"].toString()),
              redeemedQrValue:
                  int.parse(qroffer["redeemed_qr_value"].toString()),
              expiryDate: qroffer["expiry_date"] != null
                  ? DateTime.parse(qroffer["expiry_date"])
                  : null,
              displayRadius: double.parse(qroffer["display_radius"].toString()),
              pushNotificationRadius:
                  double.parse(qroffer["push_notification_radius"].toString()),
              categoryId: qroffer["category_id"],
              subcategoryId: qroffer["subcategory_id"],
              advertiserId: qroffer["advertiser_id"],
              isActive: qroffer["is_active"],
              isBanned: qroffer["is_banned"],
              isDeleted: qroffer["is_deleted"],
              isArchive: qroffer["is_archive"],
              addressId: qroffer["address_id"],
              createdAt: DateTime.parse(qroffer["created_at"]),
              invoiceAddressId: qroffer["invoice_address_id"],
              completelyDeleted: qroffer["completely_deleted"],
              inInvoice: qroffer["in_invoice"],
              invoiceDate: qroffer["invoice_date"] != null
                  ? DateTime.parse(qroffer["invoice_date"])
                  : null,
              invoiceId: qroffer["invoice_id"],
              isEditable: DateTime.parse(qroffer["created_at"])
                          .add(Duration(minutes: 3))
                          .difference(DateTime.now().toUtc())
                          .inSeconds >
                      0
                  ? true
                  : false,
            ),
          );
        }
        _qroffers = _loadedQroffers;
        notifyListeners();
        await setQrofferActive();
      }
    } catch (e) {
      print(e);
      throw HttpException(message: "Can not fetch Qroffers.");
    }
  }

  Future<void> fetchAllMyActiveQroffers() async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    String _myAddressesUrl =
        Enviroment.baseUrl + '/qroffer/getMyActiveQroffers';

    Dio _dio = Dio();
    try {
      Response _responseQroffers = await _dio.get(_myAddressesUrl,
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseQroffers.statusCode == 200) {
        final List _responseData = await _responseQroffers.data;
        final List<Qroffer> _loadedQroffers = [];
        for (var qroffer in _responseData) {
          _loadedQroffers.add(
            Qroffer(
              id: qroffer["id"],
              title: qroffer["title"],
              latitude: qroffer["latitude"],
              longitude: qroffer["longitude"],
              shortDescription: qroffer["short_description"],
              longDescription: qroffer["long_description"],
              price: double.parse(qroffer["price"].toString()),
              taxPrice: double.parse(qroffer["tax_price"].toString()),
              gross: double.parse(qroffer["gross"].toString()),
              type: qroffer["type"],
              media: qroffer["media"],
              begin: qroffer["begin"] != null
                  ? DateTime.parse(qroffer["begin"])
                  : null,
              end: qroffer["end"] != null
                  ? DateTime.parse(qroffer["end"])
                  : null,
              qrValue: int.parse(qroffer["qr_value"].toString()),
              expiryDate: qroffer["expiry_date"] != null
                  ? DateTime.parse(qroffer["expiry_date"])
                  : null,
              displayRadius: double.parse(qroffer["display_radius"].toString()),
              pushNotificationRadius:
                  double.parse(qroffer["push_notification_radius"].toString()),
              categoryId: qroffer["category_id"],
              subcategoryId: qroffer["subcategory_id"],
              advertiserId: qroffer["advertiser_id"],
              isActive: qroffer["is_active"],
              isBanned: qroffer["is_banned"],
              isDeleted: qroffer["is_deleted"],
              isArchive: qroffer["is_archive"],
              addressId: qroffer["address_id"],
              createdAt: DateTime.parse(qroffer["created_at"]),
              invoiceAddressId: qroffer["invoice_address_id"],
              completelyDeleted: qroffer["completely_deleted"],
              inInvoice: qroffer["in_invoice"],
              invoiceDate: qroffer["invoice_date"] != null
                  ? DateTime.parse(qroffer["invoice_date"])
                  : null,
              invoiceId: qroffer["invoice_id"],
              isEditable: DateTime.parse(qroffer["created_at"])
                          .add(Duration(minutes: 3))
                          .difference(DateTime.now().toUtc())
                          .inSeconds >
                      0
                  ? true
                  : false,
            ),
          );
        }
        _qroffers = _loadedQroffers;
        notifyListeners();
        await setQrofferActive();
      }
    } catch (e) {
      print(e);
      throw HttpException(message: "Can not fetch Qroffers.");
    }
  }

  Future<void> addQroffer(Qroffer qroffer) async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    String _url = Enviroment.baseUrl + '/qroffer/createQroffer';

    Dio _dio = Dio();
    try {
      Response _responseQroffer = await _dio.post(_url,
          data: {
            'title': qroffer.title,
            'short_description': qroffer.shortDescription,
            'long_description': qroffer.longDescription,
            'price': qroffer.price,
            'begin':
                qroffer.begin != null ? qroffer.begin!.toIso8601String() : null,
            'end': qroffer.end != null ? qroffer.end!.toIso8601String() : null,
            'expiry_date': qroffer.expiryDate != null
                ? qroffer.expiryDate!.toUtc().toIso8601String()
                : null,
            'qr_value': qroffer.qrValue,
            'display_radius': qroffer.displayRadius,
            'push_notification_radius': qroffer.pushNotificationRadius,
            'address_id': qroffer.addressId,
            'invoice_address_id': qroffer.invoiceAddressId,
            'subsubcategorys': qroffer.subsubcategoryIds,
          },
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseQroffer.statusCode == 200) {
        if (_responseQroffer.data[0] != null) {
          if (_responseQroffer.data[0]["statusCode"] != null) {
            throw HttpException(
                message: "${_responseQroffer.data[0]["message"]}");
          }
        }
        final _responseData = await _responseQroffer.data;
        final newQroffer = Qroffer(
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
          qrValue: int.parse(_responseData["qr_value"].toString()),
          expiryDate: _responseData["expiry_date"] != null
              ? DateTime.parse(_responseData["expiry_date"])
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
        _qroffers.add(newQroffer);
        notifyListeners();
        await setQrofferActive();
      } else {
        throw HttpException(message: _responseQroffer.statusMessage!);
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> addArchive(Qroffer qroffer) async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    String _url = Enviroment.baseUrl + '/qroffer/createArchive';

    Dio _dio = Dio();
    try {
      Response _responseQroffer = await _dio.post(_url,
          data: json.encode({
            'title': qroffer.title,
            'short_description': qroffer.shortDescription,
            'long_description': qroffer.longDescription,
            'price': qroffer.price,
            'display_radius': qroffer.displayRadius,
            'push_notification_radius': qroffer.pushNotificationRadius,
            'qr_value': qroffer.qrValue,
            'address_id': qroffer.addressId,
            'invoice_address_id': qroffer.invoiceAddressId,
            'subsubcategorys': qroffer.subsubcategoryIds,
          }),
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseQroffer.statusCode == 200) {
        if (_responseQroffer.data[0] != null) {
          if (_responseQroffer.data[0]["statusCode"] != null) {
            throw HttpException(
                message: "${_responseQroffer.data[0]["message"]}");
          }
        }
        final _responseData = await _responseQroffer.data;
        final newQroffer = Qroffer(
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
          qrValue: _responseData["qr_value"],
          expiryDate: _responseData["expiry_date"] != null
              ? DateTime.parse(_responseData["expiry_date"])
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
        _qroffers.add(newQroffer);
        notifyListeners();
      } else {
        throw HttpException(message: _responseQroffer.statusMessage!);
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateQroffer(
      {required String id, required Qroffer qroffer}) async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    final _qrofferIndex = _qroffers.indexWhere((qrf) => qrf.id == id);
    if (_qrofferIndex >= 0) {
      String _url = Enviroment.baseUrl + '/qroffer/updateQroffer';

      Dio _dio = Dio();
      try {
        Response _responseQroffer = await _dio.patch(_url,
            data: {
              'id': id,
              'title': qroffer.title,
              'short_description': qroffer.shortDescription,
              'long_description': qroffer.longDescription,
              'price': qroffer.price,
              'begin': qroffer.begin != null
                  ? qroffer.begin!.toIso8601String()
                  : null,
              'end':
                  qroffer.end != null ? qroffer.end!.toIso8601String() : null,
              'expiry_date': qroffer.expiryDate != null
                  ? qroffer.expiryDate!.toUtc().toIso8601String()
                  : null,
              'qr_value': qroffer.qrValue,
              'display_radius': qroffer.displayRadius,
              'push_notification_radius': qroffer.pushNotificationRadius,
              'address_id': qroffer.addressId,
              'invoice_address_id': qroffer.invoiceAddressId,
              'subsubcategorys': qroffer.subsubcategoryIds,
            },
            options: Options(headers: {
              "Authorization": "Bearer $_tkn",
              "Permission": Enviroment.permissionKey,
            }));

        if (_responseQroffer.statusCode == 200) {
          if (_responseQroffer.data[0] != null) {
            if (_responseQroffer.data[0]["statusCode"] != null) {
              throw HttpException(
                  message: "${_responseQroffer.data[0]["message"]}");
            }
          }
          final _responseData = await _responseQroffer.data;
          print(_responseData);
          final updatedQroffer = Qroffer(
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
            qrValue: int.parse(_responseData["qr_value"].toString()),
            expiryDate: _responseData["expiry_date"] != null
                ? DateTime.parse(_responseData["expiry_date"])
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
          _qroffers[_qrofferIndex] = updatedQroffer;
          notifyListeners();
          await setQrofferActive();
        } else {
          throw HttpException(message: _responseQroffer.statusMessage!);
        }
      } catch (e) {
        throw e;
      }
    }
  }

  Future<void> deleteQroffer(String id, double price) async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    String _url = Enviroment.baseUrl + '/qroffer/deleteQroffer';
    final _qrofferIndex = _qroffers.indexWhere((qrf) => qrf.id == id);
    if (_qrofferIndex >= 0) {
      notifyListeners();
      await setQrofferActive();
      Dio _dio = Dio();
      try {
        final Response _response = await _dio.delete(_url,
            data: json.encode({
              "id": id,
              "price": double.tryParse(price.toStringAsFixed(2)),
            }),
            options: Options(headers: {
              "Authorization": "Bearer $_tkn",
              "Permission": Enviroment.permissionKey,
            }));
        if (_response.statusCode! >= 400) {
          throw HttpException(message: 'Could not delete qroffer.');
        }
        if (_response.statusCode == 200) {
          if (_response.data[0] != null) {
            if (_response.data[0]["statusCode"] != null) {
              throw HttpException(message: "${_response.data[0]["message"]}");
            }
          }
        }
        Qroffer? _deletedQroffer = _qroffers.firstWhere((qrf) => qrf.id == id);
        _deletedQroffer.isActive = false;
        _deletedQroffer.isDeleted = true;

        _qroffers[_qrofferIndex] = _deletedQroffer;
        notifyListeners();
        await setQrofferActive();
      } catch (e) {
        throw HttpException(message: 'Could not delete qroffer.');
      }
    }
  }

  Future<void> deleteQrofferCompletely(String id) async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    final String _url = Enviroment.baseUrl + '/qroffer/deleteQrofferCompletely';
    final _existingQrofferIndex = _qroffers.indexWhere((qrf) => qrf.id == id);
    Qroffer? _existingQroffer = _qroffers[_existingQrofferIndex];
    _qroffers.removeAt(_existingQrofferIndex);
    notifyListeners();
    await setQrofferActive();
    Dio _dio = Dio();
    try {
      final Response _response = await _dio.delete(_url,
          data: json.encode({"id": id}),
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));
      if (_response.statusCode == 200) {
        if (_response.data[0] != null) {
          if (_response.data[0]["statusCode"] != null) {
            _qroffers.insert(_existingQrofferIndex, _existingQroffer);
            notifyListeners();
            await setQrofferActive();
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }
      } else {
        _qroffers.insert(_existingQrofferIndex, _existingQroffer);
        notifyListeners();
        await setQrofferActive();
        throw HttpException(message: 'Could not delete address.');
      }
      _existingQroffer = null;
    } catch (e) {
      _qroffers.insert(_existingQrofferIndex, _existingQroffer!);
      notifyListeners();
      await setQrofferActive();
      throw HttpException(message: 'Could not delete address.');
    }
  }

  Future<void> setQrofferActive() async {
    if (_timers.isNotEmpty) {
      _timers.forEach((element) => element.cancel());
      _timers.clear();
    }
    _qroffers.forEach((qrf) {
      if (!qrf.isActive!) {
        if (!qrf.isArchive!) {
          if (qrf.begin != null) {
            if (!qrf.isDeleted!) {
              Timer(
                  Duration(
                      seconds: qrf.begin!
                          .difference(DateTime.now().toUtc())
                          .inSeconds), () async {
                String _url =
                    Enviroment.baseUrl + '/address//inPanel/${qrf.addressId}';
                Dio _dio = Dio();
                var response = await _dio.get(_url,
                    options: Options(headers: {
                      "Authorization": "Bearer $authToken",
                      "Permission": Enviroment.permissionKey,
                    }));
                if (response.statusCode == 200) {
                  if (response.data != null) {
                    if (!response.data["active_qroffer"]) {
                      qrf.isActive = true;
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

    _qroffers.forEach((qrf) {
      if (qrf.isEditable!) {
        if (!qrf.isDeleted!) {
          Timer(
              Duration(
                  seconds: qrf.begin!
                      .add(Duration(minutes: 3))
                      .difference(DateTime.now().toUtc())
                      .inSeconds), () async {
            qrf.isEditable = false;
            notifyListeners();
          });
        }
      }
    });
  }
}
