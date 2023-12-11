import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:iban/iban.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../home.dart';
import '../helper/email_assigned_validator.dart';
import 'package:provider/provider.dart';
import '../providers/advertiser.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  // void _submit() async {
  //   FocusScope.of(context).unfocus();

  //   if (_advertiserRegEmailGlobalKey.currentState!.validate() &&
  //       _advertiserRegFirstnameGlobalKey.currentState!.validate() &&
  //       _advertiserRegLastnameGlobalKey.currentState!.validate() &&
  //       _advertiserRegPasswordGlobalKey.currentState!.validate() &&
  //       _advertiserRegIbanGlobalKey.currentState!.validate() &&
  //       _advertiserRegRepeatPasswordGlobalKey.currentState!.validate() &&
  //       _advertiserRegTaxIdGlobalKey.currentState!.validate()) {
  //     try {
  //       if (_editPasswordIsActive) {
  //         await Provider.of<Advertiser>(context, listen: false).updatePassword(
  //             password: _passwordSignUpController.text,
  //             table: "advertiser",
  //             route: "updatePw");
  //       }

  //       await Provider.of<Advertiser>(context, listen: false).update(
  //         advertiser: Advertiser(
  //           email: _emailSignUpController.text,
  //           gender: _gender,
  //           firstname: _firstnameController.text,
  //           lastname: _lastnameController.text,
  //           birthDate: _birthDate,
  //           taxId: _taxIdController.text,
  //           iban: _ibanController.text,
  //           phone: _phoneController.text,
  //           bic: _bicController.text,
  //           companyRegistrationNumber: _crNumberController.text,
  //         ),
  //       );
  //     } catch (e) {
  //       await Alert(
  //         context: context,
  //         type: AlertType.error,
  //         title: "Update Advertiser Failed",
  //         desc: e.toString(),
  //         buttons: [
  //           DialogButton(
  //             child: const Text(
  //               "OK",
  //               style: TextStyle(color: Colors.white, fontSize: 20),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context, rootNavigator: true).pop();
  //             },
  //             width: MediaQuery.of(context).size.width * 0.2,
  //           )
  //         ],
  //       ).show();
  //     }
  //     Navigator.of(context).pop();
  //   } else {
  //     _advertiserRegEmailGlobalKey.currentState!.validate();
  //     _advertiserRegFirstnameGlobalKey.currentState!.validate();
  //     _advertiserRegLastnameGlobalKey.currentState!.validate();
  //     _advertiserRegPasswordGlobalKey.currentState!.validate();
  //     _advertiserRegIbanGlobalKey.currentState!.validate();
  //     _advertiserRegRepeatPasswordGlobalKey.currentState!.validate();
  //     _advertiserRegTaxIdGlobalKey.currentState!.validate();
  //     _advertiserRegBirthDateGlobalKey.currentState!.validate();

  //     if (_gender == null) {
  //       setState(() {
  //         _emptyAlertFieldsString =
  //             _emptyAlertFieldsString + _emptyAlertGenderString;
  //         _radioColor = MaterialStateProperty.all<Color>(Colors.red);
  //       });
  //     } else {
  //       setState(() {
  //         _radioColor = MaterialStateProperty.all<Color>(_nowNowGeneralColor);
  //       });
  //     }
  //     if (_advertiserRegEmailGlobalKey.currentState!.validate() == false) {
  //       _emptyAlertFieldsString =
  //           _emptyAlertFieldsString + _emptyAlertEmailString;
  //     }
  //     if (_passwordSignUpController.text.isEmpty) {
  //       _emptyAlertFieldsString =
  //           _emptyAlertFieldsString + _emptyAlertPasswordString;
  //     }

  //     if (_repeatPasswordController.text.isEmpty) {
  //       _emptyAlertFieldsString =
  //           _emptyAlertFieldsString + _emptyAlertRepeatPasswordString;
  //     }
  //     if (_firstnameController.text.isEmpty) {
  //       _emptyAlertFieldsString =
  //           _emptyAlertFieldsString + _emptyAlertFirstnameString;
  //     }

  //     if (_lastnameController.text.isEmpty) {
  //       _emptyAlertFieldsString =
  //           _emptyAlertFieldsString + _emptyAlertLastnameString;
  //     }

  //     if (_birthDateController.text.isEmpty) {
  //       _emptyAlertFieldsString =
  //           _emptyAlertFieldsString + _emptyBirthDateAlertString;
  //     }

  //     if (_taxIdController.text.isEmpty) {
  //       _emptyAlertFieldsString =
  //           _emptyAlertFieldsString + _emptyTaxIdAlertString;
  //     } else {
  //       if (_taxIdController.text.length < 9) {
  //         _emptyAlertFieldsString =
  //             _emptyAlertFieldsString + _invalidTaxIdAlertString;
  //       }
  //     }

  //     if (_ibanController.text.isEmpty) {
  //       _emptyAlertFieldsString =
  //           _emptyAlertFieldsString + _emptyAlertIbanString;
  //     } else {
  //       if (!isValid(_ibanController.text)) {
  //         _emptyAlertFieldsString =
  //             _emptyAlertFieldsString + _invalidIbanAlertString;
  //       }
  //     }

  //     await showOkAlertDialog(context: context, title: _emptyAlertFieldsString);
  //     _emptyAlertFieldsString = "Please fill in the empty text fields:\n";
  //   }
  // }

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
  TextEditingController _firstnameController = TextEditingController();
  TextEditingController _lastnameController = TextEditingController();
  TextEditingController _emailLoginController = TextEditingController();
  TextEditingController _passwordLoginController = TextEditingController();
  TextEditingController _emailSignUpController = TextEditingController();
  TextEditingController _passwordSignUpController = TextEditingController();
  TextEditingController _repeatPasswordController = TextEditingController();
  TextEditingController _birthDateController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _taxIdController = TextEditingController();
  TextEditingController _crNumberController = TextEditingController();
  TextEditingController _ibanController = TextEditingController();
  TextEditingController _bicController = TextEditingController();
  DateTime? _birthDate;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

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

    // FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
    // _secureStorage.deleteAll();

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
  bool _isInit = true;
  bool _editPasswordIsActive = false;

  bool _pageIsLoading = false;
  late Advertiser advertiser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _pageIsLoading = true;
    });

    Provider.of<Advertiser>(context, listen: false).getMe().then((me) {
      me = advertiser;
      DateFormat formatter = DateFormat('dd.MM.yyyy');
      _gender = advertiser.gender;

      _firstnameController = TextEditingController(text: advertiser.firstname);
      _firstnameController = TextEditingController(text: advertiser.firstname);
      _birthDate = advertiser.birthDate;
      _birthDateController =
          TextEditingController(text: formatter.format(_birthDate!));
      _emailSignUpController = TextEditingController(text: advertiser.email);
      _phoneController = TextEditingController(text: advertiser.phone);
      _taxIdController = TextEditingController(text: advertiser.taxId);
      _crNumberController =
          TextEditingController(text: advertiser.companyRegistrationNumber);
      // _ibanController = TextEditingController(text: advertiser.iban);
      _bicController = TextEditingController(text: advertiser.bic);
      setState(() {
        _pageIsLoading = false;
        _isInit = false;
      });
    });
  }

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
    _isInit = true;
    _editPasswordIsActive = false;

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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(107, 176, 62, 1.0),
                  Color.fromRGBO(114, 180, 62, 1.0),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              Container(
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
                child: Column(
                  children: [
                    _emptySpaceColum,
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Image.asset(
                        'assets/images/advertiserlogowithoutbackground.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    _emptySpaceColum,
                  ],
                ),
              ),
              _emptySpaceColum,
              Padding(
                padding: const EdgeInsets.only(bottom: 9, left: 9, right: 9),
                child: Column(
                  children: <Widget>[
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Column(children: [
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
                            width: MediaQuery.of(context).size.width * 0.0007,
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
                            width: MediaQuery.of(context).size.width * 0.0007,
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
                            width: MediaQuery.of(context).size.width * 0.0007,
                          ),
                          Text(
                            'Diverse',
                            style: TextStyle(color: _nowNowGeneralColor),
                          ),
                        ],
                      ),
                      _formAndTextFormField(
                        enabled: true,
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
                        enabled: true,
                        textController: _passwordSignUpController,
                        obscure: true,
                        generalColor: _nowNowGeneralColor,
                        errorBorderColor: Colors.red,
                        borderColor: _nowNowBorderColor,
                        icon: _passwordIcon,
                        hintText: _editPasswordIsActive == false
                            ? "*********"
                            : "Password",
                        textInputType: TextInputType.text,
                        validator: MinLengthValidator(6,
                            errorText: 'Enter at least 6 Characters.'),
                      ),
                      if (!_editPasswordIsActive)
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _editPasswordIsActive = true;
                              });
                            },
                            child: const Text("Edit Password"),
                          ),
                        ),
                      if (_editPasswordIsActive) _emptySpaceColumTextField,
                      if (_editPasswordIsActive)
                        _formAndTextFormField(
                          key: _advertiserRegRepeatPasswordGlobalKey,
                          nextFocusNode: _repeatPasswordFocus,
                          focusNode: _repeatPasswordFocus,
                          enabled: true,
                          textController: _repeatPasswordController,
                          obscure: true,
                          generalColor: _nowNowGeneralColor,
                          errorBorderColor: Colors.red,
                          borderColor: _nowNowBorderColor,
                          icon: _passwordIcon,
                          hintText: "Repeat Password",
                          textInputType: TextInputType.text,
                          validator: _editPasswordIsActive
                              ? (value) => MatchValidator(
                                      errorText: 'Passwords do not match.')
                                  .validateMatch(
                                      value!, _passwordSignUpController.text)
                              : null,
                        ),
                      if (_editPasswordIsActive)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _editPasswordIsActive = false;
                                  _passwordSignUpController.text = "";
                                  _repeatPasswordController.text = "";
                                });
                              },
                              child: const Text(
                                "Cancel editting pasword",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _editPasswordIsActive = false;
                                  _passwordSignUpController.text = "";
                                  _repeatPasswordController.text = "";
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      if (_editPasswordIsActive) _emptySpaceColumTextField,
                      _formAndTextFormField(
                        key: _advertiserRegFirstnameGlobalKey,
                        nextFocusNode: _lastnameFocus,
                        focusNode: _firstnameFocus,
                        enabled: true,
                        textController: _firstnameController,
                        generalColor: _nowNowGeneralColor,
                        errorBorderColor: Colors.red,
                        borderColor: _nowNowBorderColor,
                        icon: _firstnameIcon,
                        hintText: "Firstname",
                        textInputType: TextInputType.text,
                        validator: RequiredValidator(
                          errorText: 'Required',
                        ),
                      ),
                      _emptySpaceColumTextField,
                      _formAndTextFormField(
                        key: _advertiserRegLastnameGlobalKey,
                        nextFocusNode: _birthDateFocus,
                        focusNode: _lastnameFocus,
                        enabled: true,
                        textController: _lastnameController,
                        generalColor: _nowNowGeneralColor,
                        errorBorderColor: Colors.red,
                        borderColor: _nowNowBorderColor,
                        icon: _firstnameIcon,
                        hintText: "Lastname",
                        textInputType: TextInputType.text,
                        validator: RequiredValidator(
                          errorText: 'Required',
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
                            errorText: 'Required',
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
                        enabled: true,
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
                        enabled: true,
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
                        enabled: true,
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
                          enabled: true,
                          textController: _ibanController,
                          generalColor: _nowNowGeneralColor,
                          errorBorderColor: Colors.red,
                          borderColor: _nowNowBorderColor,
                          icon: _ibanIcon,
                          hintText: "IBAN",
                          textInputType: TextInputType.text,
                          validator: (value) {
                            if (value!.isNotEmpty) {
                              if (!isValid(value)) {
                                return 'Invalid IBAN.';
                              } else {
                                return null;
                              }
                            } else {
                              return 'Required';
                            }
                          }),
                      _emptySpaceColumTextField,
                      _formAndTextFormField(
                        focusNode: _bicFocus,
                        enabled: true,
                        textController: _bicController,
                        generalColor: _nowNowGeneralColor,
                        errorBorderColor: Colors.red,
                        borderColor: _nowNowBorderColor,
                        icon: _crnIcon,
                        hintText: "BIC (SWIFT-Code)",
                        textInputType: TextInputType.text,
                      ),
                      _emptySpaceColumTextField,
                    ]),
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
                                "Edit Profile".toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              onPressed: () {}),
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
