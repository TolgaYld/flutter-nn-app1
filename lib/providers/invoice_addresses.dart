import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/enviroment.dart';
import '../models/http_exception.dart';
import '../providers/invoice_address.dart';

class InvoiceAddresses with ChangeNotifier {
  List<InvoiceAddress> _invoiceAddresses = [];

  final String? authToken;

  InvoiceAddresses(this.authToken, this._invoiceAddresses);

  List<InvoiceAddress> get addresses {
    return [..._invoiceAddresses];
  }

  InvoiceAddress? findInvoiceAddressFromAddress(String addressId) {
    print(_invoiceAddresses.first.id);

    return _invoiceAddresses
        .firstWhere((invcaddrs) => invcaddrs.addressId == addressId);
  }

  InvoiceAddress findById(String id) {
    if (_invoiceAddresses.isEmpty) {
      fetchAllMyAddresses().then((value) {
        return _invoiceAddresses.firstWhere((invadd) => invadd.id == id);
      });
    } else {
      return _invoiceAddresses.firstWhere((invadd) => invadd.id == id);
    }
    return _invoiceAddresses.firstWhere((invadd) => invadd.id == id);
  }

  void deleteAddressFromList(String addressId) {
    final existingAddressIndex = _invoiceAddresses
        .indexWhere((address) => address.addressId == addressId);
    InvoiceAddress? existingAddress = _invoiceAddresses[existingAddressIndex];
    _invoiceAddresses.removeAt(existingAddressIndex);
    notifyListeners();

    existingAddress = null;
  }

  Future<void> fetchAllMyAddresses() async {
    String _myAddressesUrl =
        Enviroment.baseUrl + '/invoiceAddress/myInvoiceAddresses';

    Dio _dio = Dio();
    try {
      Response _responseAddress = await _dio.get(_myAddressesUrl,
          options: Options(headers: {
            "Authorization": "Bearer $authToken",
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseAddress.statusCode == 200) {
        if (_responseAddress.data[0] != null) {
          if (_responseAddress.data[0]["statusCode"] != null) {
            throw HttpException(
                message: "${_responseAddress.data[0]["message"]}");
          }
        }

        final List _responseData = await _responseAddress.data;
        final List<InvoiceAddress> _loadedAddresses = [];
        for (var address in _responseData) {
          _loadedAddresses.add(
            InvoiceAddress(
              id: address["id"],
              latitude: address["latitude"],
              longitude: address["longitude"],
              street: address["street"],
              city: address["city"],
              country: address["country"],
              timezone: address["timezone"],
              countryCode: address["country_code"],
              advertiserId: address["advertiser_id"],
              companyName: address["company_name"],
              flatrateDateQroffer: address["family_flatrate_qroffer"] != null
                  ? DateTime.parse(address["family_flatrate_qroffer"])
                  : null,
              flatrateDateStad: address["family_flatrate_stad"] != null
                  ? DateTime.parse(address["family_flatrate_stad"])
                  : null,
              floor: address["floor"],
              isDeleted: address["is_deleted"],
              name: address["name"],
              phone: address["phone"],
              postcode: address["postcode"],
              addressId: address["address_id"],
              email: address["email"],
              firstname: address["firstname"],
              lastname: address["lastname"],
              gender: address["gender"],
              wantEmail: address["want_email"],
              wantLetter: address["want_letter"],
            ),
          );
        }
        _invoiceAddresses = _loadedAddresses;
        notifyListeners();
      } else {
        throw HttpException(message: _responseAddress.statusMessage!);
      }
    } catch (e) {
      throw HttpException(message: "Can not fetch Invoice Addresses.");
    }
  }

  Future<void> addInvoiceAddress(InvoiceAddress address) async {
    String _url = Enviroment.baseUrl + '/invoiceAddress/createInvoiceAddress';

    Dio _dio = Dio();
    try {
      Response _responseAddress = await _dio.post(_url,
          data: json.encode({
            "gender": address.gender,
            "firstname": address.firstname,
            "lastname": address.lastname,
            "email": address.email,
            "latitude": address.latitude,
            "longitude": address.longitude,
            "street": address.street,
            "city": address.city,
            "country": address.country,
            "timezone": address.timezone,
            "country_code": address.countryCode,
            "company_name": address.companyName,
            "floor": address.floor,
            "name": address.name,
            "phone": address.phone,
            "postcode": address.postcode,
            "address_id": address.addressId,
          }),
          options: Options(headers: {
            "Authorization": "Bearer $authToken",
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
        final newAddress = InvoiceAddress(
          id: _responseData["id"],
          latitude: _responseData["latitude"],
          longitude: _responseData["longitude"],
          street: _responseData["street"],
          city: _responseData["city"],
          country: _responseData["country"],
          timezone: _responseData["timezone"],
          countryCode: _responseData["country_code"],
          advertiserId: _responseData["advertiser_id"],
          companyName: _responseData["company_name"],
          flatrateDateQroffer: _responseData["family_flatrate_qroffer"] != null
              ? DateTime.parse(_responseData["family_flatrate_qroffer"])
              : null,
          flatrateDateStad: _responseData["family_flatrate_stad"] != null
              ? DateTime.parse(_responseData["family_flatrate_stad"])
              : null,
          floor: _responseData["floor"],
          isDeleted: _responseData["is_deleted"],
          name: _responseData["name"],
          phone: _responseData["phone"],
          postcode: _responseData["postcode"],
          addressId: _responseData["postcode"],
          email: _responseData["email"],
          firstname: _responseData["firstname"],
          lastname: _responseData["lastname"],
          gender: _responseData["gender"],
          wantEmail: _responseData["want_email"],
          wantLetter: _responseData["want_letter"],
        );
        _invoiceAddresses.add(newAddress);
        notifyListeners();
      } else {
        throw HttpException(message: _responseAddress.statusMessage!);
      }
    } catch (e) {
      throw HttpException(
          message: "Can not create Invoice Address;" + e.toString());
    }
  }

  Future<void> updateInvoiceAddress(
      {required String id, required InvoiceAddress address}) async {
    final _addressIndex =
        _invoiceAddresses.indexWhere((addrs) => addrs.id == id);
    if (_addressIndex >= 0) {
      String _url = Enviroment.baseUrl + '/invoiceAddress/updateInvoiceAddress';

      Dio _dio = Dio();
      try {
        Response _responseAddress = await _dio.patch(_url,
            data: json.encode({
              "id": id,
              "gender": address.gender,
              "firstname": address.firstname,
              "lastname": address.lastname,
              "email": address.email,
              "latitude": address.latitude,
              "longitude": address.longitude,
              "street": address.street,
              "city": address.city,
              "country": address.country,
              "timezone": address.timezone,
              "country_code": address.countryCode,
              "company_name": address.companyName,
              "floor": address.floor,
              "name": address.name,
              "phone": address.phone,
              "postcode": address.postcode,
              "address_id": address.addressId,
            }),
            options: Options(headers: {
              "Authorization": "Bearer $authToken",
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
          final updatedAddress = InvoiceAddress(
            id: _responseData["id"],
            latitude: _responseData["latitude"],
            longitude: _responseData["longitude"],
            street: _responseData["street"],
            city: _responseData["city"],
            country: _responseData["country"],
            timezone: _responseData["timezone"],
            countryCode: _responseData["country_code"],
            advertiserId: _responseData["advertiser_id"],
            companyName: _responseData["company_name"],
            flatrateDateQroffer:
                _responseData["family_flatrate_qroffer"] != null
                    ? DateTime.parse(_responseData["family_flatrate_qroffer"])
                    : null,
            flatrateDateStad: _responseData["family_flatrate_stad"] != null
                ? DateTime.parse(_responseData["family_flatrate_stad"])
                : null,
            floor: _responseData["floor"],
            isDeleted: _responseData["is_deleted"],
            name: _responseData["name"],
            phone: _responseData["phone"],
            postcode: _responseData["postcode"],
            addressId: _responseData["postcode"],
            email: _responseData["email"],
            firstname: _responseData["firstname"],
            lastname: _responseData["lastname"],
            gender: _responseData["gender"],
            wantEmail: _responseData["want_email"],
            wantLetter: _responseData["want_letter"],
          );
          _invoiceAddresses[_addressIndex] = updatedAddress;
          notifyListeners();
        } else {
          throw HttpException(message: _responseAddress.statusMessage!);
        }
      } catch (e) {
        print(e);
        throw HttpException(message: "Can not update Invoice Address.");
      }
    }
  }
}
