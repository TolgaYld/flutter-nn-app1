import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/enviroment.dart';
import '../providers/invoice_address.dart';
import '../models/http_exception.dart';
import 'package:uuid/uuid.dart';
import '../providers/address.dart';

class Addresses with ChangeNotifier {
  List<Address> _addresses = [];

  final String? _authToken;

  Addresses(this._authToken, this._addresses);

  List<Address> get addresses {
    return [..._addresses];
  }

  List<Address> get findAllActiveAddresses {
    return _addresses.where((address) => address.isActive == true).toList();
  }

  List<Address> get notDeleted {
    return _addresses.where((address) => address.isDeleted == false).toList();
  }

  Address findById(String id) {
    return _addresses.firstWhere((address) => address.id == id);
  }

  Future<void> fetchAllMyAddresses() async {
    String _myAddressesUrl = Enviroment.baseUrl + '/address/myAddresses';
    Dio _dio = Dio();
    try {
      FlutterSecureStorage _secure = FlutterSecureStorage();
      String? _tkn = await _secure.read(key: "token");

      Response _responseAddress = await _dio.get(_myAddressesUrl,
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey
          }));

      if (_responseAddress.statusCode == 200) {
        List _responseData = await _responseAddress.data;
        if (_responseData.isNotEmpty) {
          if (_responseAddress.data[0] != null) {
            if (_responseAddress.data[0]["statusCode"] != null) {
              throw HttpException(
                  message: "${_responseAddress.data[0]["message"]}");
            }
          }

          final List<Address> _loadedAddresses = [];

          for (var address in _responseData) {
            _loadedAddresses.add(
              Address(
                id: address["id"],
                latitude: address["latitude"],
                longitude: address["longitude"],
                street: address["street"],
                city: address["city"],
                country: address["country"],
                timezone: address["timezone"],
                countryCode: address["country_code"],
                media: address["media"],
                categoryId: address["category_id"],
                subcategoryId: address["subcategory_id"],
                subsubcategoryId: address["subsubcategory_id"],
                advertiserId: address["advertiser_id"],
                companyName: address["company_name"],
                facebook: address["facebook"],
                vat: address["vat"],
                iban: address["iban"],
                flatrateDateQroffer:
                    DateTime.parse(address["family_flatrate_qroffer"]),
                flatrateDateStad:
                    DateTime.parse(address["family_flatrate_stad"]),
                floor: address["floor"],
                homepage: address["homepage"],
                instagram: address["instagram"],
                youtube: address["youtube"],
                googleMyBusiness: address["google_my_business"],
                tiktok: address["tiktok"],
                pinterest: address["pinterest"],
                isActive: address["is_active"],
                name: address["name"],
                official: address["official"],
                phone: address["phone"],
                postcode: address["postcode"],
                invoiceAddressId: address["invoice_address_id"],
                createdAt: DateTime.parse(address["created_at"]),
                isDeleted: address["is_deleted"],
              ),
            );
          }
          _loadedAddresses.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
          _addresses = _loadedAddresses;

          notifyListeners();
        }
      }
    } catch (e) {
      throw HttpException(message: "Can not fetch Addresses: " + e.toString());
    }
  }

  Future<Address?> addAddress(
      {required Address address,
      required InvoiceAddress invoiceAddress,
      required List openingHours,
      required File imageFile}) async {
    String _url = Enviroment.baseUrl + '/address/createAddress';
    try {
      Dio _dio = Dio();

      var uuid = const Uuid();
      FlutterSecureStorage _secure = FlutterSecureStorage();
      String? _tkn = await _secure.read(key: "token");

      FormData _formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imageFile.path,
            filename: uuid.v4() + ".jpg".toString()),
        "upload_preset": Enviroment.cloudinaryUploadPreset,
        "cloud_name": Enviroment.cloudinaryCloudName,
      });

      Response _responseImg = await _dio.post(
        Enviroment.imageApi,
        data: _formData,
      );

      var _data = await jsonDecode(_responseImg.toString());

      String _imgUrl = _data['secure_url'];

      if (_responseImg.statusCode == 200) {
        Response _responseAddress = await _dio.post(_url,
            data: {
              "address": {
                "latitude": address.latitude,
                "longitude": address.longitude,
                "street": address.street,
                "city": address.city,
                "country": address.country,
                "timezone": address.timezone,
                "country_code": address.countryCode,
                "media": [_imgUrl],
                "category_id": address.categoryId,
                "subcategory_id": address.subcategoryId,
                "subsubcategory_id": address.subsubcategoryId,
                "company_name": address.companyName,
                "facebook": address.facebook,
                "vat": address.vat,
                "iban": address.iban!.trim(),
                "floor": address.floor,
                "homepage": address.homepage,
                "instagram": address.instagram,
                "google_my_business": address.googleMyBusiness,
                "youtube": address.youtube,
                "tiktok": address.tiktok,
                "pinterest": address.pinterest,
                "name": address.name,
                "phone": address.phone,
                "postcode": address.postcode,
                "qroffer_short_description": address.qrofferShortDescription,
              },
              "invoice_address": {
                "gender": invoiceAddress.gender,
                "firstname": invoiceAddress.firstname,
                "lastname": invoiceAddress.lastname,
                "email": invoiceAddress.email,
                "latitude": invoiceAddress.latitude,
                "longitude": invoiceAddress.longitude,
                "street": invoiceAddress.street,
                "city": invoiceAddress.city,
                "country": invoiceAddress.country,
                "timezone": invoiceAddress.timezone,
                "country_code": invoiceAddress.countryCode,
                "company_name": invoiceAddress.companyName,
                "floor": invoiceAddress.floor,
                "name": invoiceAddress.name,
                "phone": invoiceAddress.phone,
                "postcode": invoiceAddress.postcode,
              },
              "opening_hours": openingHours,
            },
            options: Options(headers: {
              "Authorization": "Bearer $_tkn",
              "Permission": Enviroment.permissionKey,
            }));

        if (_responseAddress.statusCode == 200) {
          if (_responseAddress.data[0] != null) {
            if (_responseAddress.data[0]["statusCode"] != null) {
              throw HttpException(
                  message: "${_responseAddress.data[0]["message"]}");
            }
          }
          final _responseData = _responseAddress.data;
          final newAddress = Address(
            id: _responseData["id"],
            latitude: _responseData["latitude"],
            longitude: _responseData["longitude"],
            street: _responseData["street"],
            city: _responseData["city"],
            country: _responseData["country"],
            timezone: _responseData["timezone"],
            countryCode: _responseData["country_code"],
            media: _responseData["media"],
            categoryId: _responseData["category_id"],
            subcategoryId: _responseData["subcategory_id"],
            advertiserId: _responseData["advertiser_id"],
            companyName: _responseData["company_name"],
            facebook: _responseData["facebook"],
            flatrateDateQroffer:
                DateTime.parse(_responseData["family_flatrate_qroffer"]),
            flatrateDateStad:
                DateTime.parse(_responseData["family_flatrate_stad"]),
            floor: _responseData["floor"],
            homepage: _responseData["homepage"],
            instagram: _responseData["instagram"],
            googleMyBusiness: _responseData["google_my_business"],
            youtube: _responseData["youtube"],
            vat: _responseData["vat"],
            pinterest: _responseData["pinterest"],
            tiktok: _responseData["tiktok"],
            isActive: _responseData["is_active"],
            iban: _responseData["iban"],
            name: _responseData["name"],
            official: _responseData["official"],
            phone: _responseData["phone"],
            postcode: _responseData["postcode"],
            subsubcategoryId: _responseData["subsubcategory_id"],
            qrofferShortDescription: _responseData["qroffer_short_description"],
            activeQroffer: _responseData["active_qroffer"],
            activeQrofferValue: _responseData["active_qroffer_value"],
            activeStad: _responseData["active_stad"],
            isDeleted: _responseData["is_deleted"],
            createdAt: DateTime.parse(_responseData["created_at"]),
          );
          _addresses.add(newAddress);
          notifyListeners();
          return newAddress;
        }
      }
    } catch (e) {
      throw HttpException(message: "Can not create Address: " + e.toString());
    }
  }

  Future<Address?> updateAddress(
      {required String id,
      required Address address,
      required InvoiceAddress invoiceAddress,
      required List openingHours,
      required File? imageFile}) async {
    final _addressIndex = _addresses.indexWhere((addrs) => addrs.id == id);
    if (_addressIndex >= 0) {
      String _url = Enviroment.baseUrl + '/address/updateAddress';
      try {
        String? _imgUrl;
        if (imageFile != null) {
          Dio _dioUplaodPicture = Dio();

          var uuid = const Uuid();
          FlutterSecureStorage _secure = FlutterSecureStorage();
          String? _tkn = await _secure.read(key: "token");

          FormData _formData = FormData.fromMap({
            "file": await MultipartFile.fromFile(imageFile.path,
                filename: uuid.v4() + ".jpg".toString()),
            "upload_preset": Enviroment.cloudinaryUploadPreset,
            "cloud_name": Enviroment.cloudinaryCloudName,
          });

          Response _responseImg = await _dioUplaodPicture.post(
            Enviroment.imageApi,
            data: _formData,
          );

          var _data = await jsonDecode(_responseImg.toString());

          _imgUrl = _data['secure_url'];
        }

        Dio _dio = Dio();

        Response _responseAddress = await _dio.patch(_url,
            data: json.encode({
              "address": {
                "id": id,
                "latitude": address.latitude,
                "longitude": address.longitude,
                "street": address.street,
                "city": address.city,
                "country": address.country,
                "timezone": address.timezone,
                "country_code": address.countryCode,
                "media":
                    await _imgUrl != null ? [await _imgUrl] : address.media,
                "category_id": address.categoryId,
                "subcategory_id": address.subcategoryId,
                "subsubcategory_id": address.subsubcategoryId,
                "company_name": address.companyName,
                "facebook": address.facebook,
                "floor": address.floor,
                "iban": address.iban!.trim(),
                "homepage": address.homepage,
                "instagram": address.instagram,
                "google_my_business": address.googleMyBusiness,
                "youtube": address.youtube,
                "tiktok": address.tiktok,
                "pinterest": address.pinterest,
                "vat": address.vat,
                "name": address.name,
                "phone": address.phone,
                "postcode": address.postcode,
                "qroffer_short_description": address.qrofferShortDescription,
              },
              "invoice_address": {
                "id": invoiceAddress.id,
                "gender": invoiceAddress.gender,
                "firstname": invoiceAddress.firstname,
                "lastname": invoiceAddress.lastname,
                "email": invoiceAddress.email,
                "latitude": invoiceAddress.latitude,
                "longitude": invoiceAddress.longitude,
                "street": invoiceAddress.street,
                "city": invoiceAddress.city,
                "country": invoiceAddress.country,
                "timezone": invoiceAddress.timezone,
                "country_code": invoiceAddress.countryCode,
                "company_name": invoiceAddress.companyName,
                "floor": invoiceAddress.floor,
                "name": invoiceAddress.name,
                "phone": invoiceAddress.phone,
                "postcode": invoiceAddress.postcode,
              },
              "opening_hours": openingHours
            }),
            options: Options(headers: {
              "Authorization": "Bearer $_authToken",
              "Permission": Enviroment.permissionKey,
            }));

        if (_responseAddress.statusCode == 200) {
          if (_responseAddress.data[0] != null) {
            if (_responseAddress.data[0]["statusCode"] != null) {
              throw HttpException(
                  message: "${_responseAddress.data[0]["message"]}");
            }
          }
          final _responseData = await _responseAddress.data;

          final updatedAddress = Address(
            id: _responseData["id"],
            latitude: _responseData["latitude"],
            longitude: _responseData["longitude"],
            street: _responseData["street"],
            city: _responseData["city"],
            country: _responseData["country"],
            timezone: _responseData["timezone"],
            countryCode: _responseData["country_code"],
            media: _responseData["media"],
            categoryId: _responseData["category_id"],
            subcategoryId: _responseData["subcategory_id"],
            advertiserId: _responseData["advertiser_id"],
            companyName: _responseData["company_name"],
            facebook: _responseData["facebook"],
            flatrateDateQroffer:
                DateTime.parse(_responseData["family_flatrate_qroffer"]),
            flatrateDateStad:
                DateTime.parse(_responseData["family_flatrate_stad"]),
            floor: _responseData["floor"],
            homepage: _responseData["homepage"],
            instagram: _responseData["instagram"],
            googleMyBusiness: _responseData["google_my_business"],
            youtube: _responseData["youtube"],
            vat: _responseData["vat"],
            pinterest: _responseData["pinterest"],
            tiktok: _responseData["tiktok"],
            isActive: _responseData["is_active"],
            iban: _responseData["iban"],
            name: _responseData["name"],
            official: _responseData["official"],
            phone: _responseData["phone"],
            postcode: _responseData["postcode"],
            subsubcategoryId: _responseData["subsubcategory_id"],
            qrofferShortDescription: _responseData["qroffer_short_description"],
            activeQroffer: _responseData["active_qroffer"],
            activeQrofferValue: _responseData["active_qroffer_value"],
            activeStad: _responseData["active_stad"],
            isDeleted: _responseData["is_deleted"],
            createdAt: DateTime.parse(_responseData["created_at"]),
          );
          _addresses[_addressIndex] = updatedAddress;

          notifyListeners();

          return updatedAddress;
        }
      } catch (e) {
        print(e);
        throw HttpException(message: "Can not update Address.");
      }
    }
  }

  Future<void> updateQrofferShortDescription(
      {required String addressId, required String shortDescription}) async {
    final _addressIndex =
        _addresses.indexWhere((addrs) => addrs.id == addressId);
    if (_addressIndex >= 0) {
      String _url = Enviroment.baseUrl + '/address/updateAddress';

      Dio _dio = Dio();
      try {
        Response _responseAddress = await _dio.patch(_url,
            data: json.encode({
              "id": addressId,
              "qroffer_short_description": shortDescription
            }),
            options: Options(headers: {
              "Authorization": "Bearer $_authToken",
              "Permission": Enviroment.permissionKey,
            }));

        if (_responseAddress.statusCode == 200) {
          if (_responseAddress.data[0] != null) {
            if (_responseAddress.data[0]["statusCode"] != null) {
              throw HttpException(
                  message: "${_responseAddress.data[0]["message"]}");
            }
          }
          final _responseData = await _responseAddress.data;
          final updatedAddress = Address(
            id: _responseData["id"],
            latitude: _responseData["latitude"],
            longitude: _responseData["longitude"],
            street: _responseData["street"],
            city: _responseData["city"],
            country: _responseData["country"],
            timezone: _responseData["timezone"],
            countryCode: _responseData["country_code"],
            media: _responseData["media"],
            categoryId: _responseData["category_id"],
            subcategoryId: _responseData["subcategory_id"],
            advertiserId: _responseData["advertiser_id"],
            companyName: _responseData["company_name"],
            facebook: _responseData["facebook"],
            vat: _responseData["vat"],
            iban: _responseData["iban"],
            flatrateDateQroffer:
                DateTime.parse(_responseData["family_flatrate_qroffer"]),
            flatrateDateStad:
                DateTime.parse(_responseData["family_flatrate_stad"]),
            floor: _responseData["floor"],
            homepage: _responseData["homepage"],
            instagram: _responseData["instagram"],
            googleMyBusiness: _responseData["google_my_business"],
            youtube: _responseData["youtube"],
            pinterest: _responseData["pinterest"],
            tiktok: _responseData["tiktok"],
            isActive: _responseData["is_active"],
            name: _responseData["name"],
            official: _responseData["official"],
            phone: _responseData["phone"],
            postcode: _responseData["postcode"],
            subsubcategoryId: _responseData["subsubcategory_id"],
            qrofferShortDescription: _responseData["qroffer_short_description"],
            activeQroffer: _responseData["active_qroffer"],
            activeQrofferValue: _responseData["active_qroffer_value"],
            activeStad: _responseData["active_stad"],
            isDeleted: _responseData["is_deleted"],
            invoiceAddressId: _responseData["invoice_address_id"],
            createdAt: DateTime.parse(_responseData["created_at"]),
          );
          _addresses[_addressIndex] = updatedAddress;
          notifyListeners();
        }
      } catch (e) {
        throw HttpException(message: "Can not update Address.");
      }
    }
  }

  Future<void> deleteAddress(String id) async {
    String _url = Enviroment.baseUrl + '/address/destroyAddress';
    final existingAddressIndex =
        _addresses.indexWhere((address) => address.id == id);
    Address? existingAddress = _addresses[existingAddressIndex];
    _addresses.removeAt(existingAddressIndex);
    notifyListeners();
    Dio _dio = Dio();
    try {
      final Response _response = await _dio.delete(_url,
          data: json.encode({"id": id}),
          options: Options(headers: {
            "Authorization": "Bearer $_authToken",
            "Permission": Enviroment.permissionKey,
          }));
      if (_response.statusCode! >= 400) {
        _addresses.insert(existingAddressIndex, existingAddress);
        notifyListeners();
        throw HttpException(message: 'Could not delete address.');
      }
      if (_response.statusCode == 200) {
        if (_response.data[0] != null) {
          if (_response.data[0]["statusCode"] != null) {
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }
      }
    } catch (e) {
      _addresses.insert(existingAddressIndex, existingAddress);
      notifyListeners();
      throw HttpException(message: 'Could not delete address.');
    }

    existingAddress = null;
  }

  void deleteAddressFromList(String id) {
    final existingAddressIndex =
        _addresses.indexWhere((address) => address.id == id);
    Address? existingAddress = _addresses[existingAddressIndex];
    _addresses.removeAt(existingAddressIndex);
    notifyListeners();

    existingAddress = null;
  }

  Future<void> deleteAddressFromDb(String id) async {
    final String _url =
        Enviroment.baseUrl + '/address/destroyAddressFromDb/$id';
    final existingAddressIndex =
        _addresses.indexWhere((address) => address.id == id);
    Address? existingAddress = _addresses[existingAddressIndex];
    _addresses.removeAt(existingAddressIndex);
    notifyListeners();
    Dio _dio = Dio();
    try {
      final Response _response = await _dio.delete(_url,
          options: Options(headers: {
            "Authorization": "Bearer $_authToken",
            "Permission": Enviroment.permissionKey,
          }));
      if (_response.statusCode! >= 400) {
        _addresses.insert(existingAddressIndex, existingAddress);
        notifyListeners();
        throw HttpException(message: 'Could not delete address.');
      }
      if (_response.statusCode == 200) {
        if (_response.data[0] != null) {
          if (_response.data[0]["statusCode"] != null) {
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }
      }
    } catch (e) {
      _addresses.insert(existingAddressIndex, existingAddress);
      notifyListeners();
      throw HttpException(message: 'Could not delete address.');
    }

    existingAddress = null;
  }
}
