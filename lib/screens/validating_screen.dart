import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../home.dart';
import '../main.dart';
import '../models/enviroment.dart';
import '../screens/authentication_onboarding_screen.dart';
import 'package:page_transition/page_transition.dart';
import '../providers/advertiser.dart';
import 'package:provider/provider.dart';
import '../screens/auth_screen.dart';

class ValidatingScreen extends StatefulWidget {
  static const routeName = '/validateScreen';
  const ValidatingScreen({Key? key}) : super(key: key);

  @override
  _ValidatingScreenState createState() => _ValidatingScreenState();
}

class _ValidatingScreenState extends State<ValidatingScreen> {
  @override
  void initState() {
    super.initState();
    FlutterSecureStorage _storage = FlutterSecureStorage();
    _storage.read(key: "token").then((token) {
      Provider.of<Advertiser>(context, listen: false)
          .getMe()
          .then((advertiser) {
        final String _myAddressesUrl =
            Enviroment.baseUrl + '/address/myAddresses';
        Dio _dio = Dio();
        _dio
            .get(_myAddressesUrl,
                options: Options(headers: {
                  "Authorization": "Bearer $token",
                  "Permission": Enviroment.permissionKey,
                }))
            .then((response) {
          List addresses = response.data;

          if (token == null || token == "") {
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade, child: AuthScreen()));
          }
          if (token != null && token != "") {
            if (advertiser != null) {
              if (advertiser.firstname == null ||
                  advertiser.lastname == null ||
                  advertiser.birthDate == null ||
                  advertiser.taxId == null ||
                  // advertiser.iban == null ||
                  advertiser.gender == null) {
                return Navigator.pushReplacement(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade,
                        child: AuthenticationOnboardingScreen(
                          initialPage: 1,
                        )));
              }
              if (addresses.isEmpty) {
                return Navigator.pushReplacement(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade,
                        child: AuthenticationOnboardingScreen(
                          initialPage: 3,
                        )));
              }
            } else {
              _storage.deleteAll().then((value) async =>
                  await Navigator.pushReplacement(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade, child: AuthScreen())));
            }
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: HomeScreen(
                      isOpen: false,
                      stream: streamController.stream,
                    )));
          }
        });
      }).catchError((error) {
        Provider.of<Advertiser>(context, listen: false).logout();
      });
    });
  }

  Future initMethod() async {
    FlutterSecureStorage _storage = FlutterSecureStorage();
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance!
    //     .addPostFrameCallback((_) async => await initMethod());
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
