import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../screens/auth_screen.dart';

import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  Splash({
    Key? key,
  }) : super(key: key);

  static const routeName = '/splash';

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  dio.Dio _dio = dio.Dio();

  // initMethod(context) async {
  //   String? _token = await secureStorage.read(key: "token");
  //   String? _refreshToken = await secureStorage.read(key: "refreshToken");

  //   if (_token == null ||
  //       _token == "" ||
  //       _refreshToken == null ||
  //       _refreshToken == "" ||
  //       (JwtDecoder.isExpired(_token) && JwtDecoder.isExpired(_refreshToken))) {
  //     Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
  //   } else {
  //     if (JwtDecoder.isExpired(_token)) {
  //       print(JwtDecoder.getExpirationDate(_refreshToken).toString());
  //       if (!JwtDecoder.isExpired(_refreshToken)) {
  //         print(_refreshToken);
  //         try {
  //           var response = await _dio.post("http://85.214.91.232:3999/graphql",
  //               data: {
  //                 "query": "{advertiser{is_banned}}",
  //               },
  //               options: dio.Options(
  //                   headers: {"Authorization": "Bearer $_refreshToken"}));

  //           if (response.data["data"]["advertiser"]["is_banned"] == false) {
  //             // Navigator.of(context).pushReplacementNamed(MainPage.routeName);
  //           } else {
  //             Navigator.of(context).pushReplacementNamed(
  //                 AuthScreen.routeName); // SIE WURDEN GEBANNT
  //           }
  //         } catch (e) {
  //           print(e.toString());
  //         }
  //       } else {
  //         Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
  //       }
  //     } else {
  //       if (!JwtDecoder.isExpired(_token)) {
  //         print(_refreshToken);
  //         try {
  //           var response = await _dio.post("http://85.214.91.232:3999/graphql",
  //               data: {
  //                 "query": "{advertiser{is_banned}}",
  //               },
  //               options:
  //                   dio.Options(headers: {"Authorization": "Bearer $_token"}));
  //           if (response.data["data"]["advertiser"]["is_banned"] == false) {
  //             // Navigator.of(context).pushReplacementNamed(MainPage.routeName);
  //           } else {
  //             Navigator.of(context).pushReplacementNamed(
  //                 AuthScreen.routeName); // SIE WURDEN GEBANNT
  //           }
  //         } catch (e) {
  //           print(e.toString());
  //         }
  //       } else {
  //         Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance!
    //     .addPostFrameCallback((_) async => await initMethod(context));
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(107, 176, 62, 1.0),
                Color.fromRGBO(153, 199, 60, 1.0),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Image.asset(
                      'assets/images/advertiserlogowithoutbackground.png',
                      fit: BoxFit.cover),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Center(
                child: new CircularProgressIndicator(
                  color: Theme.of(context).accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
