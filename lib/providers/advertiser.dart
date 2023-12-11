import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as secure;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/enviroment.dart';
import '../models/http_exception.dart';

class Advertiser with ChangeNotifier {
  String? id;
  String? email;
  String? password;
  String? gender;
  String? firstname;
  String? lastname;
  DateTime? birthDate;
  String? phone;
  String? taxId;
  String? companyRegistrationNumber;
  String? bic;
  bool? official;
  bool? isBanned;
  bool? autoPlay;
  bool? isDeleted;
  String? _token;
  String? _refreshToken;
  DateTime? _expiryDate;
  Timer? _authTimer;
  int _expiryDateMinusinMinutes = 60;

  Advertiser({
    this.id,
    this.email,
    this.password,
    this.gender,
    this.firstname,
    this.lastname,
    this.birthDate,
    this.phone,
    this.taxId,
    this.companyRegistrationNumber,
    this.bic,
    this.official,
    this.isBanned,
    this.autoPlay,
    this.isDeleted,
  });

  bool get isAuth {
    return _token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now().toUtc()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Advertiser? _me;
  Advertiser get me {
    return _me!;
  }

  Future<Advertiser?> getMe() async {
    String _url = Enviroment.baseUrl + '/advertiser/me';
    Dio _dio = Dio();

    secure.FlutterSecureStorage _storage = secure.FlutterSecureStorage();
    String? tkn = await _storage.read(key: "token");
    String? rfrsh_tkn = await _storage.read(key: "refreshToken");

    try {
      Response _response = await _dio.get(_url,
          options: Options(
            headers: {
              "Authorization": "Bearer $tkn",
              "Refresh": "Bearer $rfrsh_tkn",
              "Permission": Enviroment.permissionKey,
            },
          ));

      if (_response.statusCode == 200) {
        if (_response.data[0] != null) {
          if (_response.data[0]["statusCode"] != null) {
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }

        final _responseData = await _response.data;

        final advertiserData = _responseData["advertiser"];
        _me = Advertiser(
          id: advertiserData["id"],
          firstname: advertiserData["firstname"],
          gender: advertiserData["gender"],
          lastname: advertiserData["lastname"],
          birthDate: advertiserData["birth_date"] != null
              ? DateTime.parse(advertiserData["birth_date"])
              : null,
          email: advertiserData["email"],
          bic: advertiserData["bic"],
          companyRegistrationNumber:
              advertiserData["company_registration_number"],
          // iban: advertiserData["iban"],
          isBanned: advertiserData["is_banned"],
          official: advertiserData["official"],
          autoPlay: advertiserData["autoplay"],
          phone: advertiserData["phone"],
          taxId: advertiserData["tax_id"],
        );

        secure.FlutterSecureStorage _secureStorage =
            secure.FlutterSecureStorage();

        await _secureStorage.deleteAll();

        await _secureStorage.write(
            key: 'token', value: await _responseData['token']);
        await _secureStorage.write(
            key: 'refreshToken', value: await _responseData['refreshToken']);
        _token = await _responseData['token'];
        _refreshToken = await _responseData['refreshToken'];
        _expiryDate =
            await JwtDecoder.getExpirationDate(await _token.toString())
                .toUtc()
                .subtract(Duration(
                  minutes: _expiryDateMinusinMinutes,
                ));
        await _secureStorage.write(
            key: 'expiryDate', value: await _expiryDate!.toIso8601String());
        _autoLogout();
        notifyListeners();

        return _me;
      } else {
        throw HttpException(message: _response.statusMessage!);
      }
    } catch (e) {
      throw HttpException(message: 'fetch Me failed!: ' + e.toString());
    }
  }

  Future<void> signUp({
    required Advertiser advertiser,
  }) async {
    final String _url = Enviroment.baseUrl + '/advertiser/createAdvertiser';
    Dio _dio = Dio();
    try {
      Response _response = await _dio.post(_url,
          data: json.encode({
            'email': advertiser.email!.trim().toLowerCase(),
            'password': advertiser.password,
            'gender': advertiser.gender,
            'firstname': advertiser.firstname,
            'lastname': advertiser.lastname,
            'birth_date': advertiser.birthDate != null
                ? advertiser.birthDate!.toIso8601String()
                : null,
            'phone': advertiser.phone,
            'tax_id': advertiser.taxId,
            'company_registration_number': advertiser.companyRegistrationNumber,
            // 'iban': advertiser.iban,
            'bic': advertiser.bic
          }),
          options: Options(
            headers: {
              "Permission": Enviroment.permissionKey,
            },
          ));

      if (_response.statusCode == 200) {
        final _responseData = await _response.data;

        if (_responseData[0] != null) {
          if (_responseData[0]["statusCode"] != null) {
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }
        final advertiserData = await _responseData["advertiser"];
        _me = Advertiser(
          id: advertiserData["id"],
          firstname: advertiserData["firstname"],
          gender: advertiserData["gender"],
          lastname: advertiserData["lastname"],
          birthDate: advertiserData["birth_date"] != null
              ? DateTime.parse(advertiserData["birth_date"])
              : null,
          email: advertiserData["email"],
          bic: advertiserData["bic"],
          companyRegistrationNumber:
              advertiserData["company_registration_number"],
          // iban: advertiserData["iban"],
          isBanned: advertiserData["is_banned"],
          official: advertiserData["official"],
          autoPlay: advertiserData["autoplay"],
          phone: advertiserData["phone"],
          taxId: advertiserData["tax_id"],
        );
        secure.FlutterSecureStorage _secureStorage =
            secure.FlutterSecureStorage();

        await _secureStorage.deleteAll();

        await _secureStorage.write(
            key: 'token', value: await _responseData['token']);
        await _secureStorage.write(
            key: 'refreshToken', value: await _responseData['refreshToken']);
        _token = await _responseData['token'];
        _refreshToken = await _responseData['refreshToken'];
        _expiryDate =
            await JwtDecoder.getExpirationDate(await _token.toString())
                .toUtc()
                .subtract(Duration(
                  minutes: _expiryDateMinusinMinutes,
                ));
        await _secureStorage.write(
            key: 'expiryDate', value: await _expiryDate!.toIso8601String());
        _autoLogout();
        notifyListeners();
      } else {
        throw HttpException(message: _response.statusMessage!);
      }
    } catch (e) {
      print(e);
      throw HttpException(message: 'Authentication failed!: ' + e.toString());
    }
  }

  Future<void> update({
    required Advertiser advertiser,
  }) async {
    final String _url = Enviroment.baseUrl + '/advertiser/updateAdvertiser';
    Dio _dio = Dio();
    try {
      Response? _response;

      if (advertiser.email == null && advertiser.password == null) {
        _response = await _dio.patch(_url,
            data: json.encode({
              'gender': advertiser.gender,
              'firstname': advertiser.firstname,
              'lastname': advertiser.lastname,
              'birth_date': advertiser.birthDate!.toIso8601String(),
              'phone': advertiser.phone,
              'tax_id': advertiser.taxId,
              'company_registration_number':
                  advertiser.companyRegistrationNumber,
              // 'iban': advertiser.iban,
              'bic': advertiser.bic
            }),
            options: Options(headers: {
              "Authorization": "Bearer $_token",
              "Permission": Enviroment.permissionKey,
            }));
      }
      if (advertiser.email != null &&
          advertiser.password != null &&
          advertiser.gender == null) {
        _response = await _dio.patch(_url,
            data: json.encode({
              'email': advertiser.email!.trim().toLowerCase(),
              'password': advertiser.password,
            }),
            options: Options(headers: {
              "Authorization": "Bearer $_token",
              "Permission": Enviroment.permissionKey,
            }));
      }

      if (advertiser.email != null &&
          advertiser.password == null &&
          advertiser.gender != null) {
        _response = await _dio.patch(_url,
            data: json.encode({
              'email': advertiser.email!.trim().toLowerCase(),
              'gender': advertiser.gender,
              'firstname': advertiser.firstname,
              'lastname': advertiser.lastname,
              'birth_date': advertiser.birthDate!.toIso8601String(),
              'phone': advertiser.phone,
              'tax_id': advertiser.taxId,
              'company_registration_number':
                  advertiser.companyRegistrationNumber,
              // 'iban': advertiser.iban,
              'bic': advertiser.bic
            }),
            options: Options(headers: {
              "Authorization": "Bearer $_token",
              "Permission": Enviroment.permissionKey,
            }));
      }

      if (advertiser.email != null &&
          advertiser.password == null &&
          advertiser.gender == null) {
        _response = await _dio.patch(_url,
            data: json.encode({
              'email': advertiser.email!.trim().toLowerCase(),
            }),
            options: Options(headers: {
              "Authorization": "Bearer $_token",
              "Permission": Enviroment.permissionKey,
            }));
      }

      if (advertiser.email != null &&
          advertiser.password != null &&
          advertiser.gender != null) {
        _response = await _dio.patch(_url,
            data: json.encode({
              'email': advertiser.email!.trim().toLowerCase(),
              'password': advertiser.password,
              'gender': advertiser.gender,
              'firstname': advertiser.firstname,
              'lastname': advertiser.lastname,
              'birth_date': advertiser.birthDate!.toIso8601String(),
              'phone': advertiser.phone,
              'tax_id': advertiser.taxId,
              'company_registration_number':
                  advertiser.companyRegistrationNumber,
              // 'iban': advertiser.iban,
              'bic': advertiser.bic
            }),
            options: Options(headers: {
              "Authorization": "Bearer $_token",
              "Permission": Enviroment.permissionKey,
            }));
      }

      if (_response!.statusCode == 200) {
        final _responseData = await _response.data;
        if (_responseData[0] != null) {
          if (_responseData[0]["statusCode"] != null) {
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }
        final advertiserData = _responseData["advertiser"];
        _me = Advertiser(
          id: advertiserData["id"],
          firstname: advertiserData["firstname"],
          gender: advertiserData["gender"],
          lastname: advertiserData["lastname"],
          birthDate: advertiserData["birth_date"] != null
              ? DateTime.parse(advertiserData["birth_date"])
              : null,
          email: advertiserData["email"],
          bic: advertiserData["bic"],
          companyRegistrationNumber:
              advertiserData["company_registration_number"],
          // iban: advertiserData["iban"],
          isBanned: advertiserData["is_banned"],
          official: advertiserData["official"],
          autoPlay: advertiserData["autoplay"],
          phone: advertiserData["phone"],
          taxId: advertiserData["tax_id"],
        );
        secure.FlutterSecureStorage _secureStorage =
            secure.FlutterSecureStorage();

        await _secureStorage.deleteAll();

        await _secureStorage.write(key: 'token', value: _responseData['token']);
        await _secureStorage.write(
            key: 'refreshToken', value: _responseData['refreshToken']);
        _token = await _responseData['token'];
        _refreshToken = await _responseData['refreshToken'];
        _expiryDate =
            await JwtDecoder.getExpirationDate(await _token.toString())
                .toUtc()
                .subtract(Duration(
                  minutes: _expiryDateMinusinMinutes,
                ));
        await _secureStorage.write(
            key: 'expiryDate', value: await _expiryDate!.toIso8601String());
        _autoLogout();
        notifyListeners();
      } else {
        throw HttpException(message: _response.statusMessage!);
      }
    } catch (e) {
      print(e);
      throw HttpException(message: 'Authentication failed!: ' + e.toString());
    }
  }

  Future<void> delete() async {
    final String _url = Enviroment.baseUrl + '/advertiser/updateAdvertiser';
    Dio _dio = Dio();
    try {
      Response _response = await _dio.patch(_url,
          data: json.encode({
            'is_deleted': true,
          }),
          options: Options(headers: {
            "Authorization": "Bearer $_token",
            "Permission": Enviroment.permissionKey,
          }));

      if (_response.statusCode == 200) {
        final _responseData = await _response.data;
        if (_responseData[0] != null) {
          if (_responseData[0]["statusCode"] != null) {
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }
        final advertiserData = _responseData["advertiser"];
        _me = Advertiser(
          id: advertiserData["id"],
          firstname: advertiserData["firstname"],
          gender: advertiserData["gender"],
          lastname: advertiserData["lastname"],
          birthDate: advertiserData["birth_date"] != null
              ? DateTime.parse(advertiserData["birth_date"])
              : null,
          email: advertiserData["email"],
          bic: advertiserData["bic"],
          companyRegistrationNumber:
              advertiserData["company_registration_number"],
          // iban: advertiserData["iban"],
          isBanned: advertiserData["is_banned"],
          official: advertiserData["official"],
          autoPlay: advertiserData["autoplay"],
          phone: advertiserData["phone"],
          taxId: advertiserData["tax_id"],
          isDeleted: advertiserData["is_deleted"],
        );
        await logout();
      } else {
        throw HttpException(message: _response.statusMessage!);
      }
    } catch (e) {
      print(e);
      throw HttpException(message: 'Authentication failed!: ' + e.toString());
    }
  }

  Future<void> updateAcceptingTerms({
    required bool isTermAccepted,
  }) async {
    final String _url = Enviroment.baseUrl + '/advertiser/updateAdvertiser';
    Dio _dio = Dio();
    try {
      Response _response = await _dio.patch(_url,
          data: json.encode({
            'terms_accepted': isTermAccepted,
          }),
          options: Options(headers: {
            "Authorization": "Bearer $_token",
            "Permission": Enviroment.permissionKey,
          }));

      if (_response.statusCode == 200) {
        final _responseData = await _response.data;
        if (_responseData[0] != null) {
          if (_responseData[0]["statusCode"] != null) {
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }
        final advertiserData = _responseData["advertiser"];
        _me = Advertiser(
          id: advertiserData["id"],
          firstname: advertiserData["firstname"],
          gender: advertiserData["gender"],
          lastname: advertiserData["lastname"],
          birthDate: advertiserData["birth_date"] != null
              ? DateTime.parse(advertiserData["birth_date"])
              : null,
          email: advertiserData["email"],
          bic: advertiserData["bic"],
          companyRegistrationNumber:
              advertiserData["company_registration_number"],
          // iban: advertiserData["iban"],
          isBanned: advertiserData["is_banned"],
          official: advertiserData["official"],
          autoPlay: advertiserData["autoplay"],
          phone: advertiserData["phone"],
          taxId: advertiserData["tax_id"],
        );
        secure.FlutterSecureStorage _secureStorage =
            secure.FlutterSecureStorage();

        await _secureStorage.deleteAll();

        await _secureStorage.write(key: 'token', value: _responseData['token']);
        await _secureStorage.write(
            key: 'refreshToken', value: _responseData['refreshToken']);
        _token = await _responseData['token'];
        _refreshToken = await _responseData['refreshToken'];
        _expiryDate =
            await JwtDecoder.getExpirationDate(await _token.toString())
                .toUtc()
                .subtract(Duration(
                  minutes: _expiryDateMinusinMinutes,
                ));
        await _secureStorage.write(
            key: 'expiryDate', value: await _expiryDate!.toIso8601String());
        _autoLogout();
        notifyListeners();
      } else {
        throw HttpException(message: _response.statusMessage!);
      }
    } catch (e) {
      print(e);
      throw HttpException(message: 'Authentication failed!: ' + e.toString());
    }
  }

  Future<bool?> updatePassword({
    required String password,
    required String table,
    required String route,
  }) async {
    final String _url = Enviroment.baseUrl + '/$table/$route';
    Dio _dio = Dio();
    try {
      Response _response = await _dio.patch(
        _url,
        data: {'password': password},
        options: Options(headers: {
          "Authorization": "Bearer $_token",
          "Permission": Enviroment.permissionKey,
        }),
      );

      if (_response.statusCode == 200) {
        final _responseData = await _response.data;

        if (_responseData[0] != null) {
          if (_responseData[0]["statusCode"] != null) {
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }
        final advertiserData = _responseData["advertiser"];

        _me = Advertiser(
          id: advertiserData["id"],
          firstname: advertiserData["firstname"],
          gender: advertiserData["gender"],
          lastname: advertiserData["lastname"],
          birthDate: DateTime.parse(advertiserData["birth_date"]),
          email: advertiserData["email"],
          bic: advertiserData["bic"],
          companyRegistrationNumber:
              advertiserData["company_registration_number"],
          // iban: advertiserData["iban"],
          isBanned: advertiserData["is_banned"],
          official: advertiserData["official"],
          autoPlay: advertiserData["autoplay"],
          phone: advertiserData["phone"],
          taxId: advertiserData["tax_id"],
        );

        secure.FlutterSecureStorage _secureStorage =
            secure.FlutterSecureStorage();

        await _secureStorage.deleteAll();

        await _secureStorage.write(key: 'token', value: _responseData['token']);
        await _secureStorage.write(
            key: 'refreshToken', value: _responseData['refreshToken']);
        _token = await _responseData['token'];
        _refreshToken = await _responseData['refreshToken'];
        _expiryDate =
            await JwtDecoder.getExpirationDate(await _token.toString())
                .toUtc()
                .subtract(Duration(
                  minutes: _expiryDateMinusinMinutes,
                ));
        await _secureStorage.write(
            key: 'expiryDate', value: await _expiryDate!.toIso8601String());
        _autoLogout();
        notifyListeners();
        return true;
      } else {
        throw HttpException(message: _response.statusMessage!);
      }
    } catch (e) {
      print(e);
      throw HttpException(message: 'Authentication failed!: ' + e.toString());
    }
  }

  Future<Advertiser?> signIn({
    required String email,
    required String password,
    required String table,
    required String route,
  }) async {
    final String _url = Enviroment.baseUrl + '/$table/$route';
    Dio _dio = Dio();
    try {
      Response _response = await _dio.post(_url,
          data: json.encode({
            'email': email.trim().toLowerCase(),
            'password': password,
          }),
          options: Options(headers: {
            "Permission": Enviroment.permissionKey,
          }));

      if (_response.statusCode == 200) {
        if (_response.data[0] != null) {
          if (_response.data[0]["statusCode"] != null) {
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }

        final _responseData = await _response.data;
        final advertiserData = _responseData["advertiser"];
        _me = Advertiser(
          id: advertiserData["id"],
          firstname: advertiserData["firstname"],
          gender: advertiserData["gender"],
          lastname: advertiserData["lastname"],
          birthDate: DateTime.parse(advertiserData["birth_date"]),
          email: advertiserData["email"],
          bic: advertiserData["bic"],
          companyRegistrationNumber:
              advertiserData["company_registration_number"],
          // iban: advertiserData["iban"],
          isBanned: advertiserData["is_banned"],
          official: advertiserData["official"],
          autoPlay: advertiserData["autoplay"],
          phone: advertiserData["phone"],
          taxId: advertiserData["tax_id"],
        );
        secure.FlutterSecureStorage _secureStorage =
            secure.FlutterSecureStorage();

        await _secureStorage.deleteAll();

        await _secureStorage.write(key: 'token', value: _responseData['token']);
        await _secureStorage.write(
            key: 'refreshToken', value: _responseData['refreshToken']);

        _token = await _responseData['token'];
        _refreshToken = await _responseData['refreshToken'];
        _expiryDate =
            await JwtDecoder.getExpirationDate(await _token.toString())
                .toUtc()
                .subtract(Duration(
                  minutes: _expiryDateMinusinMinutes,
                ));

        await _secureStorage.write(
            key: 'expiryDate', value: await _expiryDate!.toIso8601String());
        _autoLogout();
        notifyListeners();
        return _me;
      } else {
        throw HttpException(message: _response.statusMessage!);
      }
    } catch (e) {
      throw HttpException(message: 'Login failed!: ' + e.toString());
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String table,
    required String route,
  }) async {
    final String _url = Enviroment.baseUrl + '/$table/$route';
    Dio _dio = Dio();
    try {
      Response _response = await _dio.post(_url,
          data: json.encode({
            'email': email.trim().toLowerCase(),
          }),
          options: Options(headers: {
            "Permission": Enviroment.permissionKey,
          }));
      if (_response.statusCode == 200) {
        if (_response.data[0] != null) {
          if (_response.data[0]["statusCode"] != null) {
            return false;
          }
        }
      }
      return true;
    } catch (e) {
      throw HttpException(message: 'Reset Password Failed');
    }
  }

  Future<bool> findEmail({
    required String email,
    required String table,
    required String route,
  }) async {
    final String _url = Enviroment.baseUrl + '/$table/$route';
    Dio _dio = Dio();
    try {
      var _response = await _dio.post(_url,
          data: json.encode({
            'email': email.trim().toLowerCase(),
          }),
          options: Options(headers: {
            "Permission": Enviroment.permissionKey,
          }));

      if (_response.statusCode == 200) {
        if (_response.data != null) {
          print(_response.data[0]);
          if (_response.data[0] != null) {
            print("22222");
            return true;
          }
          print(_response);
          return false;
        }
      }
      return true;
    } catch (e) {
      throw HttpException(message: 'Not found Email');
    }
  }

  Future<void> tokenService() async {
    String _url = Enviroment.baseUrlWithoutApi + '/refresh';
    Dio _dio = Dio();

    secure.FlutterSecureStorage _storage = secure.FlutterSecureStorage();
    String? tkn = await _storage.read(key: "token");
    String? rfrsh_tkn = await _storage.read(key: "refreshToken");

    try {
      Response _response = await _dio.get(_url,
          options: Options(
            headers: {
              "Authorization": "Bearer $tkn",
              "Refresh": "Bearer $rfrsh_tkn",
              "Permission": Enviroment.permissionKey,
            },
          ));

      if (_response.statusCode == 200) {
        if (_response.data[0] != null) {
          if (_response.data[0]["statusCode"] != null) {
            await logout();
          }
        }

        final _responseData = await _response.data;

        secure.FlutterSecureStorage _secureStorage =
            secure.FlutterSecureStorage();

        await _secureStorage.deleteAll();

        await _secureStorage.write(
            key: 'token', value: await _responseData['token']);
        await _secureStorage.write(
            key: 'refreshToken', value: await _responseData['refreshToken']);
        _token = await _responseData['token'];
        _refreshToken = await _responseData['refreshToken'];
        _expiryDate =
            await JwtDecoder.getExpirationDate(await _token.toString())
                .toUtc()
                .subtract(Duration(
                  minutes: _expiryDateMinusinMinutes,
                ));
        await _secureStorage.write(
            key: 'expiryDate', value: await _expiryDate!.toIso8601String());
        _autoLogout();
        notifyListeners();
      } else {
        throw HttpException(message: _response.statusMessage!);
      }
    } catch (e) {
      throw HttpException(message: 'fetch tokens failed!: ' + e.toString());
    }
  }

  Future<bool> tryAutoLogin() async {
    secure.FlutterSecureStorage _secureStorage = secure.FlutterSecureStorage();
    String? _token = await _secureStorage.read(key: "token");

    if (_token == null || _token == "") {
      return false;
    }
    String? _expiryDateString = await _secureStorage.read(key: 'expiryDate');
    final _expiryDate = DateTime.parse(_expiryDateString.toString()).toUtc();

    if (_expiryDate.isBefore(DateTime.now().toUtc())) {
      try {
        await tokenService();
      } catch (e) {
        await logout();
        return false;
      }
    }

    return true;
  }

  Future<void> destroy() async {
    String _url = Enviroment.baseUrl + '/advertiser/destroyAdvertiserSelf';
    Dio _dio = Dio();

    try {
      Response _response = await _dio.delete(_url,
          options: Options(headers: {
            "Authorization": "Bearer $_token",
            "Permission": Enviroment.permissionKey,
          }));

      await logout();
    } catch (e) {
      HttpException(message: "Advertiser delete failed: " + e.toString());
    }
  }

  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }

    secure.FlutterSecureStorage _secureStorage = secure.FlutterSecureStorage();
    await _secureStorage.deleteAll();
    _me = null;
    notifyListeners();
  }

  void _autoLogout() async {
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final timeToExpiry =
        _expiryDate!.toUtc().difference(DateTime.now().toUtc()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), () async {
      try {
        await tokenService();
      } catch (e) {
        await logout();
      }
    });
  }
}
