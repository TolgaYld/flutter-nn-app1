import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/enviroment.dart';
import '../models/http_exception.dart';
import '../providers/opening_hour.dart';

class OpeningHours with ChangeNotifier {
  List<OpeningHour> _openingHours = [];

  final String? authToken;

  OpeningHours(this.authToken, this._openingHours);

  List<OpeningHour> get openingHours {
    return [..._openingHours];
  }

  List<OpeningHour> findByAddressId(String addressId) {
    return _openingHours
        .where((opnghrs) => opnghrs.addressId == addressId)
        .toList();
  }

  Future<void> fetchAllMyOpeningHours() async {
    final String _url = Enviroment.baseUrl + '/openingHour/my';
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    Dio _dio = Dio();
    try {
      Response _responseOpeningHours = await _dio.get(_url,
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseOpeningHours.statusCode == 200) {
        final List _responseData = await _responseOpeningHours.data;
        if (_responseData.isNotEmpty) {
          if (_responseOpeningHours.data[0]["statusCode"] != null) {
            throw HttpException(
                message: _responseOpeningHours.data[0]["message"]);
          }

          final List<OpeningHour> _loadedOpeningHour = [];
          for (var openingHour in _responseData) {
            _loadedOpeningHour.add(
              OpeningHour(
                id: openingHour["id"],
                addressId: openingHour["address_id"],
                day: openingHour["day"],
                dayFrom: openingHour["day_from"],
                duration: openingHour["time_to_duration"],
                dayTo: openingHour["day_to"],
                advertiserId: openingHour["advertiser_id"],
                isDeleted: openingHour["is_deleted"],
                timeFrom: TimeOfDay(
                    hour: int.parse(openingHour["time_from"].split(":")[0]),
                    minute: int.parse(openingHour["time_from"].split(":")[1])),
              ),
            );
          }
          print("des da: " + _loadedOpeningHour.toString());
          _openingHours = _loadedOpeningHour;
          notifyListeners();
        }
      } else {
        throw HttpException(message: _responseOpeningHours.statusMessage!);
      }
    } catch (e) {
      throw HttpException(
          message: "Can not fetch Opening Hours: " + e.toString());
    }
  }

  Future<void> addOpeningHour(OpeningHour openingHour) async {
    String _url = Enviroment.baseUrl + '/openingHour/createOpeningHour';

    Dio _dio = Dio();

    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    try {
      Response _responseOpeningHour = await _dio.post(_url,
          data: json.encode({
            'day': openingHour.day,
            'day_from': openingHour.dayFrom,
            'time_from': formatTimeOfDay(openingHour.timeFrom),
            'time_to_duration': openingHour.duration,
            'day_to': openingHour.dayTo,
            'address_id': openingHour.addressId,
          }),
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseOpeningHour.statusCode == 200) {
        if (_responseOpeningHour.data[0] != null) {
          if (_responseOpeningHour.data[0]["statusCode"] != null) {
            throw HttpException(
                message: "${_responseOpeningHour.data[0]["message"]}");
          }
        }
        final _responseData = await _responseOpeningHour.data;
        final _newOpeningHour = OpeningHour(
          id: _responseData["id"],
          addressId: _responseData["address_id"],
          day: _responseData["day"],
          dayFrom: _responseData["day_from"],
          duration: _responseData["time_to_duration"],
          dayTo: _responseData["day_to"],
          advertiserId: _responseData["advertiser_id"],
          isDeleted: _responseData["is_deleted"],
          timeFrom: TimeOfDay(
              hour: int.parse(_responseData["time_from"].split(":")[0]),
              minute: int.parse(_responseData["time_from"].split(":")[1])),
        );
        _openingHours.add(_newOpeningHour);
        notifyListeners();
      } else {
        throw HttpException(message: _responseOpeningHour.statusMessage!);
      }
    } catch (e) {
      throw HttpException(
          message: "Can not create opening hours for address: " + e.toString());
    }
  }

  void deleteOpeningHourWhere(String addressId) {
    _openingHours.removeWhere((oph) => oph.addressId == addressId);
    notifyListeners();
  }

  Future<void> deleteOpeningHours(String addressId) async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    String _url = Enviroment.baseUrl + '/openingHour/deleteOpeningHour';
    Iterable<OpeningHour>? _existingOpeningHours =
        _openingHours.where((opngHr) => opngHr.addressId == addressId);

    _openingHours.removeWhere((opngHr) => opngHr.addressId == addressId);

    notifyListeners();
    Dio _dio = Dio();

    try {
      final Response _response = await _dio.delete(_url,
          data: json.encode({"address_id": addressId}),
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));
      if (_response.statusCode! >= 400) {
        _openingHours.addAll(_existingOpeningHours);
        notifyListeners();
        throw HttpException(message: 'Could not delete Opening Hours.');
      }
      if (_response.statusCode == 200) {
        if (_response.data != null) {
          if (_response.data[0] != null) {
            if (_response.data[0]["statusCode"] != null) {
              _openingHours.addAll(_existingOpeningHours);
              notifyListeners();
              throw HttpException(message: "${_response.data[0]["message"]}");
            }
          }
        }
      }
      _existingOpeningHours = null;
    } catch (e) {
      _openingHours.addAll(_existingOpeningHours!);
      notifyListeners();
      _existingOpeningHours = null;
      throw HttpException(message: 'Could not delete Opening Hours.');
    }
  }

  String? formatTimeOfDay(TimeOfDay timeOfDay,
      {bool alwaysUse24HourFormat = true}) {
    // Not using intl.DateFormat for two reasons:
    //
    // - DateFormat supports more formats than our material time picker does,
    //   and we want to be consistent across time picker format and the string
    //   formatting of the time of day.
    // - DateFormat operates on DateTime, which is sensitive to time eras and
    //   time zones, while here we want to format hour and minute within one day
    //   no matter what date the day falls on.
    final StringBuffer buffer = StringBuffer();

    // Add hour:minute.
    buffer
      ..write(
          formatHour(timeOfDay, alwaysUse24HourFormat: alwaysUse24HourFormat))
      ..write(':')
      ..write(formatMinute(timeOfDay));

    if (alwaysUse24HourFormat) {
      // There's no AM/PM indicator in 24-hour format.
      return '$buffer';
    }
  }

  Object formatHour(TimeOfDay timeOfDay, {bool? alwaysUse24HourFormat}) {
    return timeOfDay.hour.toString().padLeft(2, '0');
  }

  Object formatMinute(TimeOfDay timeOfDay) {
    return timeOfDay.minute.toString().padLeft(2, '0');
  }
}
