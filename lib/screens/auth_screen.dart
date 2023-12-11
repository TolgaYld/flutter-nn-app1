import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:iban/iban.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/enviroment.dart';
import '../providers/address.dart';
import '../providers/addresses.dart';
import 'package:page_transition/page_transition.dart';
import '../screens/authentication_onboarding_screen.dart';
import '../home.dart';
import '../helper/email_assigned_validator.dart';
import 'package:provider/provider.dart';
import '../providers/advertiser.dart';

enum AuthMode { Signup, Login, ForgotPassword }
enum ResetPasswordResult { Fine, Error }

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _authMode = AuthMode.Login;
  ResetPasswordResult? _resetPasswordResult;
  final _advertiserForgotGlobalKey = GlobalKey<FormState>();
  final _advertiserLogGlobalKey = GlobalKey<FormState>();
  final _advertiserRegEmailGlobalKey = GlobalKey<FormState>();
  final _advertiserRegFirstnameGlobalKey = GlobalKey<FormState>();
  final _advertiserRegLastnameGlobalKey = GlobalKey<FormState>();
  final _advertiserRegPasswordGlobalKey = GlobalKey<FormState>();
  final _advertiserRegIbanGlobalKey = GlobalKey<FormState>();
  final _advertiserRegPhoneGlobalKey = GlobalKey<FormState>();
  final _advertiserRegBirthDateGlobalKey = GlobalKey<FormState>();
  final _advertiserRegRepeatPasswordGlobalKey = GlobalKey<FormState>();
  final _advertiserRegTaxIdGlobalKey = GlobalKey<FormState>();

  bool _hasException = false;

  void _submit() async {
    FocusScope.of(context).unfocus();
    FlutterSecureStorage _secure = FlutterSecureStorage();

    _secure.deleteAll().then((value) async {
      if (_authMode == AuthMode.Login) {
        _advertiserLogGlobalKey.currentState!.validate();
        if (_advertiserLogGlobalKey.currentState!.validate()) {
          setState(() {
            loading = true;
          });
          try {
            Advertiser? advertiser =
                await Provider.of<Advertiser>(context, listen: false).signIn(
                    email: _emailLoginController.text.trim(),
                    password: _passwordLoginController.text,
                    table: 'Advertiser',
                    route: 'signInAdvertiser');

            if (advertiser!.firstname == null ||
                advertiser.lastname == null ||
                advertiser.birthDate == null ||
                advertiser.taxId == null ||
                advertiser.gender == null) {
              return await Navigator.pushReplacement(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade,
                      child: AuthenticationOnboardingScreen(
                        initialPage: 1,
                      )));
            }
            FlutterSecureStorage _storage = FlutterSecureStorage();
            String? token = await _storage.read(key: "token");
            final String _myAddressesUrl =
                Enviroment.baseUrl + '/address/myAddresses';
            Dio _dio = Dio();
            Response response = await _dio.get(_myAddressesUrl,
                options: Options(headers: {
                  "Authorization": "Bearer $token",
                  "Permission": Enviroment.permissionKey,
                }));

            List addresses = await response.data;

            if (addresses.isEmpty) {
              return await Navigator.pushReplacement(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade,
                      child: AuthenticationOnboardingScreen(
                        initialPage: 3,
                      )));
            }
            return await Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: HomeScreen(
                      isOpen: false,
                      stream: streamController.stream,
                    )));
          } catch (e) {
            await showOkAlertDialog(context: context, message: e.toString());
          }
          setState(() {
            loading = false;
          });
        }
      }
      if (_authMode == AuthMode.Signup) {
        if (_advertiserRegEmailGlobalKey.currentState!.validate() &&
            _advertiserRegFirstnameGlobalKey.currentState!.validate() &&
            _advertiserRegLastnameGlobalKey.currentState!.validate() &&
            _advertiserRegPasswordGlobalKey.currentState!.validate() &&
            _advertiserRegIbanGlobalKey.currentState!.validate() &&
            _advertiserRegRepeatPasswordGlobalKey.currentState!.validate() &&
            _advertiserRegTaxIdGlobalKey.currentState!.validate() &&
            _advertiserRegBirthDateGlobalKey.currentState!.validate()) {
          if (_gender == null) {
            await showOkAlertDialog(
                context: context,
                title: _emptyAlertFieldsString + _emptyAlertGenderString);
            setState(() {
              _radioColor = MaterialStateProperty.all<Color>(Colors.red);
            });
          } else {
            setState(() {
              _radioColor =
                  MaterialStateProperty.all<Color>(_nowNowGeneralColor);
            });
          }
        } else {
          if (_authMode == AuthMode.Signup) {
            _advertiserRegEmailGlobalKey.currentState!.validate();
            _advertiserRegFirstnameGlobalKey.currentState!.validate();
            _advertiserRegLastnameGlobalKey.currentState!.validate();
            _advertiserRegPasswordGlobalKey.currentState!.validate();
            _advertiserRegIbanGlobalKey.currentState!.validate();
            _advertiserRegRepeatPasswordGlobalKey.currentState!.validate();
            _advertiserRegTaxIdGlobalKey.currentState!.validate();
            _advertiserRegEmailGlobalKey.currentState!.validate();
            _advertiserRegBirthDateGlobalKey.currentState!.validate();

            if (_gender == null) {
              setState(() {
                _emptyAlertFieldsString =
                    _emptyAlertFieldsString + _emptyAlertGenderString;
                _radioColor = MaterialStateProperty.all<Color>(Colors.red);
              });
            } else {
              setState(() {
                _radioColor =
                    MaterialStateProperty.all<Color>(_nowNowGeneralColor);
              });
            }
            if (_advertiserRegEmailGlobalKey.currentState!.validate() ==
                false) {
              _emptyAlertFieldsString =
                  _emptyAlertFieldsString + _emptyAlertEmailString;
            }
            if (_passwordSignUpController.text.isEmpty) {
              _emptyAlertFieldsString =
                  _emptyAlertFieldsString + _emptyAlertPasswordString;
            }

            if (_repeatPasswordController.text.isEmpty) {
              _emptyAlertFieldsString =
                  _emptyAlertFieldsString + _emptyAlertRepeatPasswordString;
            }
            if (_firstnameController.text.isEmpty) {
              _emptyAlertFieldsString =
                  _emptyAlertFieldsString + _emptyAlertFirstnameString;
            }

            if (_lastnameController.text.isEmpty) {
              _emptyAlertFieldsString =
                  _emptyAlertFieldsString + _emptyAlertLastnameString;
            }

            if (_birthDateController.text.isEmpty) {
              _emptyAlertFieldsString =
                  _emptyAlertFieldsString + _emptyBirthDateAlertString;
            }

            if (_taxIdController.text.isEmpty) {
              _emptyAlertFieldsString =
                  _emptyAlertFieldsString + _emptyTaxIdAlertString;
            } else {
              if (_taxIdController.text.length < 9) {
                _emptyAlertFieldsString =
                    _emptyAlertFieldsString + _invalidTaxIdAlertString;
              }
            }

            if (_ibanController.text.isEmpty) {
              _emptyAlertFieldsString =
                  _emptyAlertFieldsString + _emptyAlertIbanString;
            } else {
              if (!isValid(_ibanController.text)) {
                _emptyAlertFieldsString =
                    _emptyAlertFieldsString + _invalidIbanAlertString;
              }
            }

            await showOkAlertDialog(
                context: context, title: _emptyAlertFieldsString);
            _emptyAlertFieldsString = "Please fill in the empty text fields:\n";
          }
        }
      }

      if (_authMode == AuthMode.ForgotPassword) {
        _advertiserForgotGlobalKey.currentState!.validate();
        if (_advertiserForgotGlobalKey.currentState!.validate()) {
          try {
            await Provider.of<Advertiser>(context, listen: false).resetPassword(
                email: _forgotEmailController.text.trim(),
                table: "advertiser",
                route: "resetPassword");
          } catch (e) {
            setState(() {
              _hasException = true;
            });
          }
        }
      }
    });
  }

  final Icon _emailIcon =
      const Icon(Icons.alternate_email, color: Colors.white);

  final _emailAutoFillHints = [AutofillHints.email];

  final _emailValidator = MultiValidator([
    RequiredValidator(errorText: 'Required'),
    EmailValidator(errorText: 'Enter a valid E-Mail'),
  ]);

  final Icon _passwordIcon = const Icon(Icons.lock, color: Colors.white);

  final Icon _firstnameIcon = const Icon(Icons.person, color: Colors.white);

  final Icon _birthDayIcon = const Icon(Icons.event, color: Colors.white);

  final Icon _phoneIcon = const Icon(Icons.phone, color: Colors.white);

  final Icon _taxIdIcon = const Icon(Icons.menu_book, color: Colors.white);

  final Icon _crnIcon = const Icon(Icons.store, color: Colors.white);

  final Icon _ibanIcon = const Icon(Icons.credit_card, color: Colors.white);

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _resetPasswordResult = null;
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _resetPasswordResult = null;
        _authMode = AuthMode.Login;
      });
    }
  }

  var _radioColor =
      MaterialStateProperty.all<Color>(const Color.fromRGBO(112, 184, 73, 1.0));
  final _errorRadioColor =
      MaterialStateProperty.all<Color>(const Color.fromRGBO(112, 184, 73, 1.0));

//Focus
  final _emailFocus = FocusNode();
  final _emailRegFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _passwordRegFocus = FocusNode();
  final _repeatPasswordFocus = FocusNode();
  final _firstnameFocus = FocusNode();
  final _lastnameFocus = FocusNode();
  final _birthDateFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _taxIdFocus = FocusNode();
  final _cRNrFocus = FocusNode();
  final _ibanFocus = FocusNode();
  final _bicFocus = FocusNode();

  //Controller
  final _forgotEmailController = TextEditingController();
  String? _gender;
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailLoginController = TextEditingController();
  final _passwordLoginController = TextEditingController();
  final _emailSignUpController = TextEditingController();
  final _passwordSignUpController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _crNumberController = TextEditingController();
  final _ibanController = TextEditingController();
  final _bicController = TextEditingController();
  DateTime? _birthDate;

  void _onEmailFocusChange() async {
    if (_emailRegFocus.hasFocus == false) {
      if (_advertiserRegEmailGlobalKey.currentState!.validate()) {
        if (_emailSignUpController.text.isNotEmpty) {
          try {
            final bool findedEmail =
                await Provider.of<Advertiser>(context, listen: false).findEmail(
              email: _emailSignUpController.text,
              table: "advertiser",
              route: 'email',
            );
            if (findedEmail) {
              setState(() {
                _checkEmail = true;
              });
              _advertiserRegEmailGlobalKey.currentState!.validate();

              _checkEmail = null;
            } else {
              setState(() {
                _checkEmail = false;
              });
              _advertiserRegEmailGlobalKey.currentState!.validate();
              _checkEmail = null;
            }
          } catch (e) {
            setState(() {
              _checkEmail = false;
            });
            _advertiserRegEmailGlobalKey.currentState!.validate();
            _checkEmail = null;
          }
        }
      }
    }
  }

  void _onFirstnameFocusChange() {
    if (_firstnameFocus.hasFocus == false) {
      if (_firstnameController.text.isEmpty) {
        _advertiserRegFirstnameGlobalKey.currentState!.validate();
      } else {
        _advertiserRegFirstnameGlobalKey.currentState!.validate();
      }
    }
  }

  void _onLastnameFocusChange() {
    if (_lastnameFocus.hasFocus == false) {
      if (_lastnameController.text.isEmpty) {
        _advertiserRegFirstnameGlobalKey.currentState!.validate();
      } else {
        _advertiserRegLastnameGlobalKey.currentState!.validate();
      }
    }
  }

  void _onPasswordFocusChange() {
    if (_passwordRegFocus.hasFocus == false) {
      if (_passwordSignUpController.text.isEmpty) {
        _advertiserRegPasswordGlobalKey.currentState!.validate();
      } else {
        _advertiserRegPasswordGlobalKey.currentState!.validate();
        if (_repeatPasswordController.text.isNotEmpty) {
          _advertiserRegRepeatPasswordGlobalKey.currentState!.validate();
        }
      }
    }
  }

  void _onRepeatPasswordFocusChange() {
    if (_repeatPasswordFocus.hasFocus == false) {
      if (_repeatPasswordController.text.isEmpty) {
        _advertiserRegRepeatPasswordGlobalKey.currentState!.validate();
      } else {
        _advertiserRegPasswordGlobalKey.currentState!.validate();
        _advertiserRegRepeatPasswordGlobalKey.currentState!.validate();
      }
    }
  }

  void _onIbanFocusChange() {
    if (_ibanFocus.hasFocus == false) {
      if (_ibanController.text.isEmpty) {
        _advertiserRegIbanGlobalKey.currentState!.validate();
      } else {
        _advertiserRegIbanGlobalKey.currentState!.validate();
      }
    }
  }

  void _onTaxIdFocusChange() {
    if (_taxIdFocus.hasFocus == false) {
      if (_taxIdController.text.isEmpty) {
        _advertiserRegTaxIdGlobalKey.currentState!.validate();
      } else {
        _advertiserRegTaxIdGlobalKey.currentState!.validate();
      }
    }
  }

  void _onbirthDateFocusChange() {
    if (_birthDateFocus.hasFocus == false) {
      if (_birthDateController.text.isEmpty) {
        _advertiserRegBirthDateGlobalKey.currentState!.validate();
      } else {
        _advertiserRegBirthDateGlobalKey.currentState!.validate();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _emailRegFocus.addListener(_onEmailFocusChange);
    _passwordRegFocus.addListener(_onPasswordFocusChange);
    _repeatPasswordFocus.addListener(_onRepeatPasswordFocusChange);
    _firstnameFocus.addListener(_onFirstnameFocusChange);
    _lastnameFocus.addListener(_onLastnameFocusChange);
    _ibanFocus.addListener(_onIbanFocusChange);
    _taxIdFocus.addListener(_onTaxIdFocusChange);
    _birthDateFocus.addListener(_onbirthDateFocusChange);
  }

  String _emptyAlertFieldsString = "Please fill in the empty text fields:\n";
  final String _emptyAlertEmailString = "\n\n- E-Mail";
  final String _emptyAlertFirstnameString = "\n\n- Firstname";
  final String _emptyAlertLastnameString = "\n\n- Lastname";
  final String _emptyAlertIbanString = "\n\n- IBAN";
  final String _invalidIbanAlertString = "\n\n- Invalid IBAN";
  final String _invalidTaxIdAlertString = "\n\n- Invalid Tax-ID";
  final String _emptyTaxIdAlertString = "\n\n- Tax-ID";
  final String _emptyBirthDateAlertString = "\n\n- Birth Date";
  final String _emptyAlertGenderString = "\n\n- Gender";
  final String _emptyAlertPasswordString = "\n\n- Password";
  final String _emptyAlertRepeatPasswordString = "\n\n- Repeat Password";

  final Color _emailBorderColor = const Color.fromRGBO(112, 184, 73, 1.0);
  final _emailErrorBorderColor = Colors.red;

  final Color _nowNowGeneralColor = const Color.fromRGBO(112, 184, 73, 1.0);
  final Color _nowNowBorderColor = const Color.fromRGBO(112, 184, 73, 1.0);

  bool? _checkEmail;

  @override
  void dispose() {
    _emailFocus.dispose();
    _emailRegFocus.dispose();
    _passwordFocus.dispose();
    _passwordRegFocus.dispose();
    _repeatPasswordFocus.dispose();
    _firstnameFocus.dispose();
    _lastnameFocus.dispose();
    _birthDateFocus.dispose();
    _phoneFocus.dispose();
    _taxIdFocus.dispose();
    _cRNrFocus.dispose();
    _ibanFocus.dispose();
    _bicFocus.dispose();

    _forgotEmailController.dispose();
    _emailSignUpController.dispose();
    _passwordSignUpController.dispose();
    _emailLoginController.dispose();
    _passwordLoginController.dispose();
    _repeatPasswordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _taxIdController.dispose();
    _crNumberController.dispose();
    _ibanController.dispose();
    _bicController.dispose();

    super.dispose();
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Widget _emptySpaceColum =
        SizedBox(height: MediaQuery.of(context).size.height * 0.03);
    Widget _emptySpaceColumTextField =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: null,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(114, 180, 62, 1.0),
                    Color.fromRGBO(153, 199, 60, 1.0),
                  ]),
              color: Color.fromRGBO(107, 176, 62, 1.0),
            ),
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.045,
              ),
              child: Image.asset(
                "assets/images/advertiserlogowithoutbackground.png",
                scale: MediaQuery.of(context).size.height * 0.0048,
              ),
            ),
          ),
          toolbarHeight: MediaQuery.of(context).size.height * 0.081,
        ),
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            children: [
              // Container(
              //   decoration: const BoxDecoration(
              //     gradient: LinearGradient(
              //         begin: Alignment.topCenter,
              //         end: Alignment.bottomCenter,
              //         colors: [
              //           Color.fromRGBO(114, 180, 62, 1.0),
              //           Color.fromRGBO(153, 199, 60, 1.0),
              //         ]),
              //     color: Color.fromRGBO(107, 176, 62, 1.0),
              //   ),
              //   width: double.infinity,
              //   height: MediaQuery.of(context).size.height * 0.13,
              //   child: Column(
              //     children: [
              //       _emptySpaceColum,

              //       _emptySpaceColum,
              //     ],
              //   ),
              // ),
              _emptySpaceColum,
              Padding(
                padding: const EdgeInsets.only(bottom: 9, left: 9, right: 9),
                child: Column(
                  children: <Widget>[
                    if (_authMode == AuthMode.Login ||
                        _authMode == AuthMode.ForgotPassword)
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.21),
                    if (_authMode == AuthMode.Login)
                      Form(
                        key: _advertiserLogGlobalKey,
                        child: Column(
                          children: [
                            _formAndTextFormField(
                              enabled: _authMode == AuthMode.Login,
                              nextFocusNode: _passwordFocus,
                              focusNode: _emailFocus,
                              textController: _emailLoginController,
                              generalColor: _nowNowGeneralColor,
                              errorBorderColor: _emailErrorBorderColor,
                              borderColor: _nowNowBorderColor,
                              icon: _emailIcon,
                              hintText: "E-Mail",
                              textInputType: TextInputType.emailAddress,
                              autoFillHints: _emailAutoFillHints,
                              validator: _emailValidator,
                            ),
                            _emptySpaceColumTextField,
                            _formAndTextFormField(
                              enabled: _authMode == AuthMode.Login,
                              obscure: true,
                              focusNode: _passwordFocus,
                              textController: _passwordLoginController,
                              generalColor: _nowNowGeneralColor,
                              errorBorderColor: Colors.red,
                              borderColor: _nowNowBorderColor,
                              icon: _passwordIcon,
                              hintText: "Password",
                              textInputType: TextInputType.text,
                              validator: RequiredValidator(
                                  errorText: _authMode == AuthMode.Login
                                      ? 'Required'
                                      : ''),
                            ),
                          ],
                        ),
                      ),
                    if (_authMode == AuthMode.ForgotPassword)
                      Column(
                        children: [
                          Text(
                            "Request e-mail to reset password.",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 18,
                            ),
                          ),
                          if (_resetPasswordResult == ResetPasswordResult.Fine)
                            Column(
                              children: [
                                _emptySpaceColumTextField,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Platform.isAndroid
                                          ? Icons.check_circle_outline
                                          : CupertinoIcons.checkmark_alt_circle,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    _emptySpaceColum,
                                    Text("Email sent!",
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 15,
                                        ))
                                  ],
                                )
                              ],
                            ),
                          if (_resetPasswordResult == ResetPasswordResult.Error)
                            Column(
                              children: [
                                _emptySpaceColumTextField,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        Platform.isAndroid
                                            ? Icons.highlight_off
                                            : CupertinoIcons.xmark_circle,
                                        color: Platform.isAndroid
                                            ? Colors.red
                                            : CupertinoColors.systemRed),
                                    _emptySpaceColum,
                                    Text("Email not exist!",
                                        style: TextStyle(
                                          color: Platform.isAndroid
                                              ? Colors.red
                                              : CupertinoColors.systemRed,
                                          fontSize: 15,
                                        ))
                                  ],
                                )
                              ],
                            ),
                          _emptySpaceColumTextField,
                          _formAndTextFormField(
                            key: _advertiserForgotGlobalKey,
                            textController: _forgotEmailController,
                            generalColor: _nowNowGeneralColor,
                            errorBorderColor: Colors.red,
                            enabled: _authMode == AuthMode.ForgotPassword,
                            borderColor: _nowNowBorderColor,
                            icon: _emailIcon,
                            hintText: "E-Mail",
                            textInputType: TextInputType.emailAddress,
                            validator: _emailValidator,
                          ),
                        ],
                      ),
                    if (_authMode == AuthMode.Signup)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _nowNowGeneralColor,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    if (_authMode == AuthMode.Signup)
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                    if (_authMode == AuthMode.Signup)
                      Column(
                        children: [
                          if (_authMode == AuthMode.Signup)
                            Row(
                              children: [
                                Radio(
                                    value: "Mrs.",
                                    fillColor: _radioColor,
                                    groupValue: _gender,
                                    onChanged: (dynamic value) {
                                      setState(() {
                                        _radioColor = _errorRadioColor;
                                        _gender = value;
                                      });
                                    }),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.0007,
                                ),
                                Text(
                                  'Mrs.',
                                  style: TextStyle(color: _nowNowGeneralColor),
                                ),
                                Radio(
                                    fillColor: _radioColor,
                                    value: "Mr.",
                                    groupValue: _gender,
                                    onChanged: (dynamic value) {
                                      setState(() {
                                        _radioColor = _errorRadioColor;
                                        _gender = value;
                                      });
                                    }),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.0007,
                                ),
                                Text(
                                  'Mr.',
                                  style: TextStyle(color: _nowNowGeneralColor),
                                ),
                                Radio(
                                    fillColor: _radioColor,
                                    value: "Diverse",
                                    groupValue: _gender,
                                    onChanged: (dynamic value) {
                                      setState(() {
                                        _radioColor = _errorRadioColor;
                                        _gender = value;
                                      });
                                    }),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.0007,
                                ),
                                Text(
                                  'Diverse',
                                  style: TextStyle(color: _nowNowGeneralColor),
                                ),
                              ],
                            ),
                          _formAndTextFormField(
                            enabled: _authMode == AuthMode.Signup,
                            key: _advertiserRegEmailGlobalKey,
                            nextFocusNode: _passwordRegFocus,
                            focusNode: _emailRegFocus,
                            textController: _emailSignUpController,
                            generalColor: _nowNowGeneralColor,
                            errorBorderColor: _emailErrorBorderColor,
                            borderColor: _emailBorderColor,
                            icon: _emailIcon,
                            hintText: "E-Mail",
                            textInputType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Required";
                              } else {
                                bool _emailValid = RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value);
                                if (_emailValid == false) {
                                  return "Invalid E-Mail";
                                } else {
                                  if (_checkEmail == true) {
                                    return "Email address assigned";
                                  }
                                }
                              }
                            },
                            autoFillHints: _emailAutoFillHints,
                          ),
                          _emptySpaceColumTextField,
                          _formAndTextFormField(
                            key: _advertiserRegPasswordGlobalKey,
                            nextFocusNode: _repeatPasswordFocus,
                            focusNode: _passwordRegFocus,
                            enabled: _authMode == AuthMode.Signup,
                            textController: _passwordSignUpController,
                            obscure: true,
                            generalColor: _nowNowGeneralColor,
                            errorBorderColor: Colors.red,
                            borderColor: _nowNowBorderColor,
                            icon: _passwordIcon,
                            hintText: "Password",
                            textInputType: TextInputType.text,
                            validator: MinLengthValidator(6,
                                errorText: _authMode == AuthMode.Signup
                                    ? 'Enter at least 6 Characters.'
                                    : ''),
                          ),
                          _emptySpaceColumTextField,
                          _formAndTextFormField(
                            key: _advertiserRegRepeatPasswordGlobalKey,
                            nextFocusNode: _repeatPasswordFocus,
                            focusNode: _repeatPasswordFocus,
                            enabled: _authMode == AuthMode.Signup,
                            textController: _repeatPasswordController,
                            obscure: true,
                            generalColor: _nowNowGeneralColor,
                            errorBorderColor: Colors.red,
                            borderColor: _nowNowBorderColor,
                            icon: _passwordIcon,
                            hintText: "Repeat Password",
                            textInputType: TextInputType.text,
                            validator: _authMode == AuthMode.Signup
                                ? (value) => MatchValidator(
                                        errorText: 'Passwords do not match.')
                                    .validateMatch(
                                        value!, _passwordSignUpController.text)
                                : null,
                          ),
                          _emptySpaceColumTextField,
                          _formAndTextFormField(
                            key: _advertiserRegFirstnameGlobalKey,
                            nextFocusNode: _lastnameFocus,
                            focusNode: _firstnameFocus,
                            enabled: _authMode == AuthMode.Signup,
                            textController: _firstnameController,
                            generalColor: _nowNowGeneralColor,
                            errorBorderColor: Colors.red,
                            borderColor: _nowNowBorderColor,
                            icon: _firstnameIcon,
                            hintText: "Firstname",
                            textInputType: TextInputType.text,
                            validator: RequiredValidator(
                              errorText: _authMode == AuthMode.Signup
                                  ? 'Required'
                                  : "",
                            ),
                          ),
                          _emptySpaceColumTextField,
                          _formAndTextFormField(
                            key: _advertiserRegLastnameGlobalKey,
                            nextFocusNode: _birthDateFocus,
                            focusNode: _lastnameFocus,
                            enabled: _authMode == AuthMode.Signup,
                            textController: _lastnameController,
                            generalColor: _nowNowGeneralColor,
                            errorBorderColor: Colors.red,
                            borderColor: _nowNowBorderColor,
                            icon: _firstnameIcon,
                            hintText: "Lastname",
                            textInputType: TextInputType.text,
                            validator: RequiredValidator(
                              errorText: _authMode == AuthMode.Signup
                                  ? 'Required'
                                  : "",
                            ),
                          ),
                          _emptySpaceColumTextField,
                          InkWell(
                            onTap: _showDatePicker,
                            child: _formAndTextFormField(
                              key: _advertiserRegBirthDateGlobalKey,
                              nextFocusNode: _phoneFocus,
                              focusNode: _birthDateFocus,
                              enabled: false,
                              textController: _birthDateController,
                              generalColor: _nowNowGeneralColor,
                              errorBorderColor: Colors.red,
                              borderColor: _nowNowBorderColor,
                              icon: _birthDayIcon,
                              hintText: "Birth Date: 01.01.1971",
                              textInputType: TextInputType.text,
                              validator: RequiredValidator(
                                errorText: _authMode == AuthMode.Signup
                                    ? 'Required'
                                    : "",
                              ),
                            ),
                          ),
                          _emptySpaceColumTextField,
                          _formAndTextFormField(
                            key: _advertiserRegPhoneGlobalKey,
                            nextFocusNode: _taxIdFocus,
                            focusNode: _phoneFocus,
                            textController: _phoneController,
                            generalColor: _nowNowGeneralColor,
                            errorBorderColor: Colors.red,
                            enabled: _authMode == AuthMode.Signup,
                            borderColor: _nowNowBorderColor,
                            icon: _phoneIcon,
                            hintText: "Phone",
                            textInputType: TextInputType.phone,
                          ),
                          _emptySpaceColumTextField,
                          _formAndTextFormField(
                            key: _advertiserRegTaxIdGlobalKey,
                            nextFocusNode: _cRNrFocus,
                            focusNode: _taxIdFocus,
                            enabled: _authMode == AuthMode.Signup,
                            textController: _taxIdController,
                            generalColor: _nowNowGeneralColor,
                            errorBorderColor: Colors.red,
                            borderColor: _nowNowBorderColor,
                            icon: _taxIdIcon,
                            hintText: "Tax-ID",
                            textInputType: TextInputType.text,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Required";
                              } else {
                                if (value.length < 9) {
                                  return "Invalid Tax-ID";
                                }
                              }
                            },
                          ),
                          _emptySpaceColumTextField,
                          _formAndTextFormField(
                            nextFocusNode: _ibanFocus,
                            focusNode: _cRNrFocus,
                            enabled: _authMode == AuthMode.Signup,
                            textController: _crNumberController,
                            generalColor: _nowNowGeneralColor,
                            errorBorderColor: Colors.red,
                            borderColor: _nowNowBorderColor,
                            icon: _crnIcon,
                            hintText: "Company Registration Number",
                            textInputType: TextInputType.text,
                          ),
                          _emptySpaceColumTextField,
                          _formAndTextFormField(
                            key: _advertiserRegIbanGlobalKey,
                            nextFocusNode: _bicFocus,
                            focusNode: _ibanFocus,
                            enabled: _authMode == AuthMode.Signup,
                            textController: _ibanController,
                            generalColor: _nowNowGeneralColor,
                            errorBorderColor: Colors.red,
                            borderColor: _nowNowBorderColor,
                            icon: _ibanIcon,
                            hintText: "IBAN",
                            textInputType: TextInputType.text,
                            validator: _authMode == AuthMode.Signup
                                ? (value) {
                                    if (value!.isNotEmpty) {
                                      if (!isValid(value)) {
                                        return 'Invalid IBAN.';
                                      } else {
                                        return null;
                                      }
                                    } else {
                                      return 'Required';
                                    }
                                  }
                                : null,
                          ),
                          _emptySpaceColumTextField,
                          _formAndTextFormField(
                            focusNode: _bicFocus,
                            enabled: _authMode == AuthMode.Signup,
                            textController: _bicController,
                            generalColor: _nowNowGeneralColor,
                            errorBorderColor: Colors.red,
                            borderColor: _nowNowBorderColor,
                            icon: _crnIcon,
                            hintText: "BIC (SWIFT-Code)",
                            textInputType: TextInputType.text,
                          ),
                          _emptySpaceColumTextField,
                        ],
                      ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: loading == true
                          ? Center(
                              child: Platform.isAndroid
                                  ? const CircularProgressIndicator()
                                  : const CupertinoActivityIndicator(),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary:
                                    const Color.fromRGBO(253, 166, 41, 1.0),
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(20.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  side: const BorderSide(
                                      color: Colors.white, width: 2.0),
                                ),
                              ),
                              child: Text(
                                _authMode == AuthMode.Login
                                    ? "Login".toUpperCase()
                                    : _authMode == AuthMode.Signup
                                        ? "Sign Up".toUpperCase()
                                        : "Reset Password".toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              onPressed: _submit,
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.05),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.width * 0.04),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          TextButton(
                              style: TextButton.styleFrom(
                                primary: _nowNowGeneralColor,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                _authMode == AuthMode.Login
                                    ? "Sign Up".toUpperCase()
                                    : "Sign In".toUpperCase(),
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              onPressed:
                                  // _switchAuthMode
                                  () async {
                                print("object");
                                if (_authMode == AuthMode.Login) {
                                  FlutterSecureStorage _storage =
                                      FlutterSecureStorage();

                                  String? token =
                                      await _storage.read(key: "token");
                                  if (token == null || token == "") {
                                    await Navigator.pushReplacement(
                                        context,
                                        PageTransition(
                                            duration: Duration(
                                              milliseconds: 120,
                                            ),
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child:
                                                AuthenticationOnboardingScreen(
                                                    initialPage: 0)));
                                  }
                                  if (token != null && token != "") {
                                    try {
                                      Advertiser? advertiser =
                                          await Provider.of<Advertiser>(context,
                                                  listen: false)
                                              .getMe();

                                      if (advertiser != null) {
                                        await Provider.of<Addresses>(context,
                                                listen: false)
                                            .fetchAllMyAddresses();

                                        List<Address> addresses =
                                            Provider.of<Addresses>(context,
                                                    listen: false)
                                                .addresses;
                                        if (advertiser.firstname == null ||
                                            advertiser.lastname == null ||
                                            advertiser.birthDate == null ||
                                            advertiser.taxId == null ||
                                            // advertiser.iban == null ||
                                            advertiser.gender == null) {
                                          await Navigator.pushReplacement(
                                              context,
                                              PageTransition(
                                                  duration: Duration(
                                                    milliseconds: 120,
                                                  ),
                                                  type: PageTransitionType
                                                      .rightToLeft,
                                                  child:
                                                      AuthenticationOnboardingScreen(
                                                    initialPage: 0,
                                                  )));
                                        }
                                        if (addresses.isEmpty) {
                                          await Navigator.pushReplacement(
                                              context,
                                              PageTransition(
                                                  duration: Duration(
                                                    milliseconds: 120,
                                                  ),
                                                  type: PageTransitionType
                                                      .rightToLeft,
                                                  child:
                                                      AuthenticationOnboardingScreen(
                                                    initialPage: 3,
                                                  )));
                                        }
                                      } else {
                                        _storage.delete(key: "token").then(
                                            (value) async =>
                                                await Navigator.pushReplacement(
                                                    context,
                                                    PageTransition(
                                                        duration: Duration(
                                                          milliseconds: 120,
                                                        ),
                                                        type: PageTransitionType
                                                            .rightToLeft,
                                                        child:
                                                            AuthenticationOnboardingScreen(
                                                                initialPage:
                                                                    0))));
                                      }
                                    } catch (e) {
                                      await Provider.of<Advertiser>(context,
                                              listen: false)
                                          .logout();
                                      await Navigator.pushReplacement(
                                          context,
                                          PageTransition(
                                              duration: Duration(
                                                milliseconds: 120,
                                              ),
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              child:
                                                  AuthenticationOnboardingScreen(
                                                      initialPage: 0)));
                                    }
                                  }
                                }
                                if (_authMode == AuthMode.ForgotPassword) {
                                  setState(() {
                                    _authMode = AuthMode.Login;
                                  });
                                }
                              }),
                          if (_authMode == AuthMode.Login)
                            TextButton(
                              style: TextButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  primary: _nowNowGeneralColor),
                              child: Text(
                                "Forgot Password?".toUpperCase(),
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onPressed: () {
                                if (_authMode == AuthMode.Login) {
                                  setState(() {
                                    _resetPasswordResult = null;
                                    _authMode = AuthMode.ForgotPassword;
                                  });
                                } else {
                                  setState(() {
                                    _resetPasswordResult = null;
                                    _authMode = AuthMode.Login;
                                  });
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Widget?> _showDatePicker() async {
    DateFormat formatter = DateFormat('dd.MM.yyyy');
    final initialDate = DateTime.now().subtract(Duration(days: 6575));
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year - 150),
      lastDate: DateTime.now().subtract(Duration(days: 6575)),
    );

    if (newDate != null) {
      _birthDate = null;
      _birthDateController.text = "";
      setState(() {
        _birthDateController.text = formatter.format(newDate);
        _advertiserRegBirthDateGlobalKey.currentState!.validate();
      });

      _birthDate = newDate;

      FocusScope.of(context).requestFocus(_phoneFocus);
    }
  }

  Widget _formAndTextFormField({
    Key? key,
    FocusNode? nextFocusNode,
    FocusNode? focusNode,
    required TextEditingController textController,
    required Color generalColor,
    required Color errorBorderColor,
    required Color borderColor,
    required Icon icon,
    required String hintText,
    required TextInputType textInputType,
    Iterable<String>? autoFillHints,
    String? Function(String?)? validator,
    bool? enabled = true,
    bool obscure = false,
    bool filled = true,
  }) {
    return Form(
      key: key,
      child: TextFormField(
        obscureText: obscure,
        enabled: enabled,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        },
        focusNode: focusNode,
        controller: textController,
        style: TextStyle(fontWeight: FontWeight.w400, color: generalColor),
        decoration: InputDecoration(
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: 1.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: errorBorderColor, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: errorBorderColor, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          prefixIcon: Container(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              color: generalColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
            child: icon,
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black26),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: 1.0),
            borderRadius: BorderRadius.circular(25.0),
          ),
          filled: filled,
          fillColor: Colors.black.withOpacity(0.1),
        ),
        keyboardType: textInputType,
        autofillHints: autoFillHints,
        validator: validator,
      ),
    );
  }
}
