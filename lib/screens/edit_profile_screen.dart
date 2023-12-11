import 'dart:async';
import 'dart:io';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:animations/animations.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:iban/iban.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import '../helper/utils.dart';
import '../home.dart';
import '../main.dart';
import '../models/enviroment.dart';
import '../places_backend_service.dart';
import '../places_search_store_backend_service.dart';
import '../providers/address.dart';
import '../providers/addresses.dart';
import '../providers/advertiser.dart';
import '../providers/category.dart';
import '../providers/categorys.dart';
import '../providers/invoice_address.dart';
import '../providers/invoice_addresses.dart';
import '../providers/opening_hour.dart';
import '../providers/opening_hours.dart';
import '../providers/subcategory.dart';
import '../providers/subcategorys.dart';
import '../providers/subsubcategory.dart';
import '../providers/subsubcategorys.dart';
import '../screens/terms_and_conditions.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:time_span/time_span.dart';
import '../screens/auth_screen.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/editProfile';

  const EditProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
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

  //   // if (_authMode == AuthMode.Login) {
  //   //   _advertiserLogGlobalKey.currentState!.validate();
  //   //   if (_advertiserLogGlobalKey.currentState!.validate()) {
  //   //     setState(() {
  //   //       loading = true;
  //   //     });
  //   //     try {
  //   //       await Provider.of<Advertiser>(context, listen: false).signIn(
  //   //           email: _emailLoginController.text.trim(),
  //   //           password: _passwordLoginController.text,
  //   //           table: 'Advertiser',
  //   //           route: 'signInAdvertiser');
  //   //       await Navigator.of(context)
  //   //           .pushReplacementNamed(HomeScreen.routeName);
  //   //     } catch (e) {
  //   //       await showOkAlertDialog(context: context, message: e.toString());
  //   //     }
  //   //     setState(() {
  //   //       loading = false;
  //   //     });
  //   //   }
  //   // }
  //   // if (_authMode == AuthMode.Signup) {
  //   if (_advertiserRegEmailGlobalKey.currentState!.validate() &&
  //       _advertiserRegFirstnameGlobalKey.currentState!.validate() &&
  //       _advertiserRegLastnameGlobalKey.currentState!.validate() &&
  //       _advertiserRegPasswordGlobalKey.currentState!.validate() &&
  //       _advertiserRegIbanGlobalKey.currentState!.validate() &&
  //       _advertiserRegRepeatPasswordGlobalKey.currentState!.validate() &&
  //       _advertiserRegTaxIdGlobalKey.currentState!.validate() &&
  //       _advertiserRegBirthDateGlobalKey.currentState!.validate()) {
  //     if (_gender == null) {
  //       await showOkAlertDialog(
  //           context: context,
  //           title: _emptyAlertFieldsString + _emptyAlertGenderString);
  //       setState(() {
  //         _radioColor = MaterialStateProperty.all<Color>(Colors.red);
  //       });
  //     } else {
  //       setState(() {
  //         _radioColor = MaterialStateProperty.all<Color>(_nowNowGeneralColor);
  //       });

  //       Navigator.of(context).pushNamed(
  //         AuthAddAddress.routeName,
  //         arguments: Advertiser(
  //             email: _emailSignUpController.text,
  //             password: _passwordSignUpController.text,
  //             gender: _gender,
  //             firstname: _firstnameController.text,
  //             lastname: _lastnameController.text,
  //             birthDate: _birthDate,
  //             taxId: _taxIdController.text,
  //             // iban: _ibanController.text,
  //             phone: _phoneController.text,
  //             bic: _bicController.text,
  //             companyRegistrationNumber: _crNumberController.text),
  //       );
  //     }
  //   } else {
  //     // if (_authMode == AuthMode.Signup) {
  //     _advertiserRegEmailGlobalKey.currentState!.validate();
  //     _advertiserRegFirstnameGlobalKey.currentState!.validate();
  //     _advertiserRegLastnameGlobalKey.currentState!.validate();
  //     _advertiserRegPasswordGlobalKey.currentState!.validate();
  //     _advertiserRegIbanGlobalKey.currentState!.validate();
  //     _advertiserRegRepeatPasswordGlobalKey.currentState!.validate();
  //     _advertiserRegTaxIdGlobalKey.currentState!.validate();
  //     _advertiserRegEmailGlobalKey.currentState!.validate();
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
  //     // }
  //   }
  //   // }

  //   // if (_authMode == AuthMode.ForgotPassword) {
  //   //   _advertiserForgotGlobalKey.currentState!.validate();
  //   //   if (_advertiserForgotGlobalKey.currentState!.validate()) {
  //   //     try {
  //   //       await Provider.of<Advertiser>(context, listen: false).resetPassword(
  //   //           email: _forgotEmailController.text.trim(),
  //   //           table: "advertiser",
  //   //           route: "resetPassword");
  //   //     } catch (e) {
  //   //       setState(() {
  //   //         _hasException = true;
  //   //       });
  //   //     }
  //   //   }
  //   // }
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

  var _invoiceRadioColor =
      MaterialStateProperty.all<Color>(const Color.fromRGBO(112, 184, 73, 1.0));
  final _invoiceErrorRadioColor =
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
  String? _invoiceGender;
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

  int pageIndex = 0;

  void _onEmailFocusChange() async {
    if (_emailRegFocus.hasFocus == false) {
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
          } else {
            if (_emailSignUpController.text.toLowerCase().trim() == _email!) {
              setState(() {
                _checkEmail = true;
              });

              _advertiserRegEmailGlobalKey.currentState!.validate();
            } else {
              setState(() {
                _checkEmail = false;
              });
              _advertiserRegEmailGlobalKey.currentState!.validate();
            }
          }
        } catch (e) {
          if (_emailSignUpController.text.toLowerCase().trim() == _email!) {
            setState(() {
              _checkEmail = true;
            });

            _advertiserRegEmailGlobalKey.currentState!.validate();
          } else {
            setState(() {
              _checkEmail = false;
            });
            _advertiserRegEmailGlobalKey.currentState!.validate();
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
        _advertiserRegLastnameGlobalKey.currentState!.validate();
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

  void _onInvoiceFirstnameFocusChange() {
    if (_invoiceFirstnameFocus.hasFocus == false) {
      if (_invoiceFirstnameController.text.isEmpty) {
        _invoiceAdvertiserFirstnameGlobalKey.currentState!.validate();
      } else {
        _invoiceAdvertiserFirstnameGlobalKey.currentState!.validate();
      }
    }
  }

  void _onInvoiceLastnameFocusChange() {
    if (_invoiceLastnameFocus.hasFocus == false) {
      if (_invoiceLastnameController.text.isEmpty) {
        _invoiceAdvertiserLastnameGlobalKey.currentState!.validate();
      } else {
        _invoiceAdvertiserLastnameGlobalKey.currentState!.validate();
      }
    }
  }

  void _onInvoiceEmailFocusChange() {
    if (_invoiceEmailFocus.hasFocus == false) {
      if (_invoiceEmailController.text.isEmpty) {
        _invoiceAdvertiserEmailGlobalKey.currentState!.validate();
      } else {
        _invoiceAdvertiserEmailGlobalKey.currentState!.validate();
      }
    }
  }

  void _onInvoiceStreetFocusChange() {
    if (_invoiceStreetFocus.hasFocus == false) {
      if (_invoiceStreetController.text.isEmpty) {
        _invoiceAdvertiserSearchStreetGlobalKey.currentState!.validate();
      } else {
        _invoiceAdvertiserSearchStreetGlobalKey.currentState!.validate();
      }
    }
  }

  void _onInvoicePostcodeFocusChange() {
    if (_invoicePostcodeFocus.hasFocus == false) {
      if (_invoicePostCodeController.text.isEmpty) {
        _invoiceAdvertiserPostcodeGlobalKey.currentState!.validate();
      } else {
        _invoiceAdvertiserPostcodeGlobalKey.currentState!.validate();
      }
    }
  }

  void _onInvoiceCityFocusChange() {
    if (_invoiceCityFocus.hasFocus == false) {
      if (_invoiceCityController.text.isEmpty) {
        _invoiceAdvertiserCityGlobalKey.currentState!.validate();
      } else {
        _invoiceAdvertiserCityGlobalKey.currentState!.validate();
      }
    }
  }

  void _onInvoiceCountryFocusChange() {
    if (_invoiceCountryFocus.hasFocus == false) {
      if (_invoiceCountryController.text.isEmpty) {
        _invoiceAdvertiserCountryGlobalKey.currentState!.validate();
      } else {
        _invoiceAdvertiserCountryGlobalKey.currentState!.validate();
      }
    }
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

  bool loading = false;
  int _numPages = 3;
  late PageController _pageController;
  int _currentPage = 0;

  List<Widget> _pageIndicator() {
    List<Widget> list = [];
    for (var i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(
        milliseconds: 120,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.021,
      ),
      height: MediaQuery.of(context).size.height * 0.009,
      width: isActive
          ? MediaQuery.of(context).size.width * 0.045
          : MediaQuery.of(context).size.width * 0.021,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
        borderRadius: BorderRadius.all(
          Radius.circular(
            12.0,
          ),
        ),
      ),
    );
  }

  ScrollController _listViewScrollController = ScrollController();

  //ADDRESS

  var _advertiserSearchStoreGlobalKey = GlobalKey<FormState>();
  var _advertiserSearchStreetGlobalKey = GlobalKey<FormState>();
  var _advertiserNameGlobalKey = GlobalKey<FormState>();
  var _advertiserCityGlobalKey = GlobalKey<FormState>();
  var _advertiserPostcodeGlobalKey = GlobalKey<FormState>();
  var _advertiserCountryGlobalKey = GlobalKey<FormState>();
  var _advertiserPhoneGlobalKey = GlobalKey<FormState>();
  var _invoiceAdvertiserSearchStoreGlobalKey = GlobalKey<FormState>();
  var _invoiceAdvertiserFirstnameGlobalKey = GlobalKey<FormState>();
  var _invoiceAdvertiserLastnameGlobalKey = GlobalKey<FormState>();
  var _invoiceAdvertiserEmailGlobalKey = GlobalKey<FormState>();
  var _invoiceAdvertiserSearchStreetGlobalKey = GlobalKey<FormState>();
  var _invoiceAdvertiserNameGlobalKey = GlobalKey<FormState>();
  var _invoiceAdvertiserCityGlobalKey = GlobalKey<FormState>();
  var _invoiceAdvertiserPostcodeGlobalKey = GlobalKey<FormState>();
  var _invoiceAdvertiserCountryGlobalKey = GlobalKey<FormState>();
  var _invoiceAdvertiserPhoneGlobalKey = GlobalKey<FormState>();

  final _searchStoreController = TextEditingController();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _floorController = TextEditingController();
  final _homepageController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _googleMybusinessController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _pinterestController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _storePhoneController = TextEditingController();
  final _invoiceSearchStoreController = TextEditingController();
  final _invoiceNameController = TextEditingController();
  final _invoiceEmailController = TextEditingController();
  final _invoiceStreetController = TextEditingController();
  final _invoiceFloorController = TextEditingController();
  final _invoicePostCodeController = TextEditingController();
  final _invoiceCityController = TextEditingController();
  final _invoiceCountryController = TextEditingController();
  final _invoicePhoneController = TextEditingController();
  final _subrubricSuggestion = TextEditingController();
  final _invoiceFirstnameController = TextEditingController();
  final _invoiceLastnameController = TextEditingController();

  final _invoiceemailValidator = MultiValidator([
    RequiredValidator(errorText: 'Required'),
    EmailValidator(errorText: 'Enter a valid E-Mail')
  ]);

  final _searchFocus = FocusNode();
  final _streetFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _floorFocus = FocusNode();
  final _postcodeFocus = FocusNode();
  final _countryFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _phoneAddressFocus = FocusNode();
  final _homepageFocus = FocusNode();
  final _facebookFocus = FocusNode();
  final _instagramFocus = FocusNode();
  final _googleMybusinessFocus = FocusNode();
  final _youtubeFocus = FocusNode();
  final _pinterestFocus = FocusNode();
  final _tiktokFocus = FocusNode();
  final _invoiceSearchStoreFocus = FocusNode();
  final _invoiceStreetFocus = FocusNode();
  final _invoiceFloorFocus = FocusNode();
  final _invoiceNameFocus = FocusNode();
  final _invoicePostcodeFocus = FocusNode();
  final _invoiceCountryFocus = FocusNode();
  final _invoiceCityFocus = FocusNode();
  final _invoicePhoneFocus = FocusNode();
  final _invoiceEmailFocus = FocusNode();
  final _invoiceFirstnameFocus = FocusNode();
  final _invoiceLastnameFocus = FocusNode();

  String? _streetName;
  String? _streetNumber;
  String? _nameOfStore;
  bool _isLoading = false;

  final String _chooseOpeningHoursFrom = "FROM";
  final String _chooseOpeningHoursTo = "TO";

  String _chooseOpeningHoursButtonTextMonday = "Opening Hours";
  String _addMoreOpeningHoursMondayTwo = "Add";
  String _addMoreOpeningHoursMondayThree = "Add";

  String _chooseOpeningHoursButtonTextTuesday = "Opening Hours";
  String _addMoreOpeningHoursTuesdayTwo = "Add";
  String _addMoreOpeningHoursTuesdayThree = "Add";

  String _chooseOpeningHoursButtonTextWednesday = "Opening Hours";
  String _addMoreOpeningHoursWednesdayTwo = "Add";
  String _addMoreOpeningHoursWednesdayThree = "Add";

  String _chooseOpeningHoursButtonTextThursday = "Opening Hours";
  String _addMoreOpeningHoursThursdayTwo = "Add";
  String _addMoreOpeningHoursThursdayThree = "Add";

  String _chooseOpeningHoursButtonTextFriday = "Opening Hours";
  String _addMoreOpeningHoursFridayTwo = "Add";
  String _addMoreOpeningHoursFridayThree = "Add";

  String _chooseOpeningHoursButtonTextSaturday = "Opening Hours";
  String _addMoreOpeningHoursSaturdayTwo = "Add More";
  String _addMoreOpeningHoursSaturdayThree = "Add More";

  String _chooseOpeningHoursButtonTextSunday = "Opening Hours";
  String _addMoreOpeningHoursSundayTwo = "Add";
  String _addMoreOpeningHoursSundayThree = "Add";

  Color? _buttonColor = Colors.grey[350];

  TimeOfDay? _mondayOneFrom;
  TimeOfDay? _mondayTwoFrom;
  TimeOfDay? _mondayThreeFrom;

  TimeOfDay? _mondayOneTo;
  TimeOfDay? _mondayTwoTo;
  TimeOfDay? _mondayThreeTo;

  TimeOfDay? _tuesdayOneFrom;
  TimeOfDay? _tuesdayTwoFrom;
  TimeOfDay? _tuesdayThreeFrom;

  TimeOfDay? _tuesdayOneTo;
  TimeOfDay? _tuesdayTwoTo;
  TimeOfDay? _tuesdayThreeTo;

  TimeOfDay? _wednesdayOneFrom;
  TimeOfDay? _wednesdayTwoFrom;
  TimeOfDay? _wednesdayThreeFrom;

  TimeOfDay? _wednesdayOneTo;
  TimeOfDay? _wednesdayTwoTo;
  TimeOfDay? _wednesdayThreeTo;

  TimeOfDay? _thursdayOneFrom;
  TimeOfDay? _thursdayTwoFrom;
  TimeOfDay? _thursdayThreeFrom;

  TimeOfDay? _thursdayOneTo;
  TimeOfDay? _thursdayTwoTo;
  TimeOfDay? _thursdayThreeTo;

  TimeOfDay? _fridayOneFrom;
  TimeOfDay? _fridayTwoFrom;
  TimeOfDay? _fridayThreeFrom;

  TimeOfDay? _fridayOneTo;
  TimeOfDay? _fridayTwoTo;
  TimeOfDay? _fridayThreeTo;

  TimeOfDay? _saturdayOneFrom;
  TimeOfDay? _saturdayTwoFrom;
  TimeOfDay? _saturdayThreeFrom;

  TimeOfDay? _saturdayOneTo;
  TimeOfDay? _saturdayTwoTo;
  TimeOfDay? _saturdayThreeTo;

  TimeOfDay? _sundayOneFrom;
  TimeOfDay? _sundayTwoFrom;
  TimeOfDay? _sundayThreeFrom;

  TimeOfDay? _sundayOneTo;
  TimeOfDay? _sundayTwoTo;
  TimeOfDay? _sundayThreeTo;

  final Icon _mondayOneEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _mondayOneAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);
  final Icon _mondayTwoEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _mondayTwoAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);
  final Icon _mondayThreeEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _mondayThreeAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);

  final Icon _tuesdayOneEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _tuesdayOneAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);
  final Icon _tuesdayTwoEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _tuesdayTwoAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);
  final Icon _tuesdayThreeEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _tuesdayThreeAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);

  final Icon _wednesdayOneEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _wednesdayOneAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);
  final Icon _wednesdayTwoEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _wednesdayTwoAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);
  final Icon _wednesdayThreeEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _wednesdayThreeAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);

  final Icon _thursdayOneEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _thursdayOneAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);
  final Icon _thursdayTwoEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _thursdayTwoAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);
  final Icon _thursdayThreeEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _thursdayThreeAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);

  final Icon _fridayOneEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _fridayOneAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);
  final Icon _fridayTwoEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _fridayTwoAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);
  final Icon _fridayThreeEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _fridayThreeAddIcon =
      Platform.isAndroid ? Icon(Icons.add) : const Icon(CupertinoIcons.add);

  final Icon _saturdayOneEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _saturdayOneAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);
  final Icon _saturdayTwoEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _saturdayTwoAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);
  final Icon _saturdayThreeEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _saturdayThreeAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);

  final Icon _sundayOneEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _sundayOneAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);
  final Icon _sundayTwoEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _sundayTwoAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);
  final Icon _sundayThreeEditIcon = Platform.isAndroid
      ? const Icon(Icons.edit)
      : const Icon(CupertinoIcons.pencil);
  Icon _sundayThreeAddIcon = Platform.isAndroid
      ? const Icon(Icons.add)
      : const Icon(CupertinoIcons.add);

  int monday = 1;
  int mondayTo = 1;
  int tuesday = 2;
  int tuesdayTo = 2;
  int wednesday = 3;
  int wednesdayTo = 3;
  int thursday = 4;
  int thursdayTo = 4;
  int friday = 5;
  int fridayTo = 5;
  int saturday = 6;
  int saturdayTo = 6;
  int sunday = 7;
  int sundayTo = 7;

  bool hasException = false;

  static const int mondayConst = 1;
  static const int tuesdayConst = 2;
  static const int wednesdayConst = 3;
  static const int thursdayConst = 4;
  static const int fridayConst = 5;
  static const int saturdayConst = 6;
  static const int sundayConst = 7;

  final int _ticks = 24;
  final int _timeSteps = 15;

  bool? checkboxActive = true;

  double? _lat;
  double? _lng;
  double? _invoiceLat;
  double? _invoiceLng;

  String? _countryCode;
  String? _invoiceCountryCode;

  bool _boolStreetSgstn = false;
  bool _boolSearchSgstn = false;

  Future _searchStore(suggestion) async {
    _boolSearchSgstn = true;
    try {
      _searchStoreController.text = await (suggestion['description']);
      _nameOfStore = await (suggestion['name']);

      String? placeId = await (suggestion['id']);

      List<Locale> languageLocales =
          await Devicelocale.preferredLanguagesAsLocales;
      Locale languageCode = languageLocales.first;
      String lang = languageCode.languageCode.toString();

      String baseUrl =
          'https://maps.googleapis.com/maps/api/place/details/json';
      String request =
          '$baseUrl?place_id=$placeId&fields=address_component&key=${Enviroment.googleApiKey}&language=$lang';

      Response response = await Dio().get(request);

      if (response.statusCode == 200) {
        final result = response.data;
        if (result['status'] == 'OK') {
          final components =
              result['result']['address_components'] as List<dynamic>;

          components.forEach((c) {
            final List type = c['types'];

            if (type.contains('route')) {
              if (c['long_name'] != null) {
                _streetName = c['long_name'];
              }
            }
            if (type.contains('street_number')) {
              if (c['long_name'] != null) {
                _streetNumber = c['long_name'];
              }
            }
            if (type.contains('locality')) {
              if (c['long_name'] != null) {
                _cityController.text = c['long_name'];
              }
            }
            if (type.contains('postal_code')) {
              _postCodeController.text = c['long_name'];
            }
            if (type.contains('country')) {
              _countryController.text = c['long_name'];
            }
            if (type.contains('political') && type.contains('country')) {
              _countryCode = c['short_name'];
            }
          });

          if (_streetName != null && _streetNumber != null) {
            _streetController.text = "$_streetName $_streetNumber";
          }
          if (_streetName != null && _cityController.text.isNotEmpty)
            _nameController.text =
                "$_nameOfStore, $_streetName, ${_cityController.text}";
        }
      }

      String requestLatLong =
          '$baseUrl?place_id=$placeId&fields=geometry&key=${Enviroment.googleApiKey}';

      Response responseLatLong = await Dio().get(requestLatLong);
      if (responseLatLong.statusCode == 200) {
        final result = await responseLatLong.data;
        if (result['status'] == 'OK') {
          final resultlatlong = result['result']['geometry']['location'];
          setState(() {
            _lat = resultlatlong['lat'];
            _lng = resultlatlong['lng'];
          });
          if (_lat != null && _lng != null && _countryCode != null) {
            setState(() {
              _advertiserSearchStreetGlobalKey.currentState!.validate();
              _advertiserSearchStoreGlobalKey.currentState!.validate();
              _advertiserNameGlobalKey.currentState!.validate();
              _advertiserCityGlobalKey.currentState!.validate();
              _advertiserPostcodeGlobalKey.currentState!.validate();
              _advertiserCountryGlobalKey.currentState!.validate();
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _onSearchFocusChange() async {
    if (_searchFocus.hasFocus == false) {
      if (_searchStoreController.text.isNotEmpty) {
        if (_boolSearchSgstn == false) {
          _advertiserSearchStreetGlobalKey.currentState!.validate();
        }
      } else {
        _advertiserSearchStoreGlobalKey.currentState!.validate();
      }
    } else {}
  }

  void _onStreetFocusChange() {
    if (_streetFocus.hasFocus == false) {
      _searchStoreController.text = "";
      if (_streetController.text.isNotEmpty) {
        if (_boolStreetSgstn == false) {
          _advertiserSearchStreetGlobalKey.currentState!.validate();
        }
      } else {
        _advertiserSearchStreetGlobalKey.currentState!.validate();
      }
      _boolStreetSgstn = false;
    } else {
      // this._lat = null;
      // this._lng = null;
      // this._countryCode = null;
      // _searchStoreController.text = "";
      // _streetController.text = "";
      // _cityController.text = "";
      // _postCodeController.text = "";
      // _countryController.text = "";
    }
  }

  void _onNameFocusChange() {
    if (_nameFocus.hasFocus == false) {
      if (_nameController.text.isEmpty) {
        _advertiserNameGlobalKey.currentState!.validate();
      } else {
        _advertiserNameGlobalKey.currentState!.validate();
      }
    }
  }

  void _onCityFocusChange() {
    if (_cityFocus.hasFocus == false) {
      if (_cityController.text.isEmpty) {
        _advertiserCityGlobalKey.currentState!.validate();
      } else {
        _advertiserCityGlobalKey.currentState!.validate();
      }
    }
  }

  void _onPostcodeFocusChange() {
    if (_postcodeFocus.hasFocus == false) {
      if (_postCodeController.text.isEmpty) {
        _advertiserPostcodeGlobalKey.currentState!.validate();
      } else {
        _advertiserPostcodeGlobalKey.currentState!.validate();
      }
    }
  }

  void _onCountryFocusChange() {
    if (_countryFocus.hasFocus == false) {
      if (_countryController.text.isEmpty) {
        _advertiserCountryGlobalKey.currentState!.validate();
      } else {
        _advertiserCountryGlobalKey.currentState!.validate();
      }
    }
  }

  String mondayString = "Monday";
  String tuesdayString = "Tuesday";
  String wednesdayString = "Wednesday";
  String thursdayString = "Thursday";
  String fridayString = "Friday";
  String saturdayString = "Saturday";
  String sundayString = "Sunday";

  String? _selectedRubricId;
  String? _selectedSubrubricId;
  String? _suggestedSubrubricId;
  String _dropdownSubrubricHintText = "Select Subcategory";
  String? _selectedSubSubrubricId;
  bool? _subrubricValidate = false;
  String? _suggestedSubSubrubricId;
  String _dropdownSubSubrubricHintText = "Select Subsubcategory";
  bool subrubricActive = false;
  bool rubricActive = true;
  bool subSubrubricActive = false;

  bool loadingSubrubric = false;

  String notFoundYourSubcategory = 'Not Found Your Subcategory?';
  String? _rubricName = "Select Category";
  String? _subrubricName = "Select Subcategory";
  String? _subsubrubricName = "Select Subsubcategory";
  int? rubricIndex = 0;
  int? subrubricIndex = 0;
  int? subsubrubricIndex = 0;

  File? _imageFile;

  ScrollController _scrollController = ScrollController();

  bool isEditingPassword = false;

  //validate

  double _imgBorderWidth = 1;
  Color? _rubricDropdownColor;
  Color? _subrubricDropdownColor;
  Color? _subsubrubricDropdownColor;
  bool _acceptTerms = false;
  Color _checkboxTermsTextColor = Color.fromRGBO(112, 184, 73, 1.0);
  var _checkboxTermsFillColor =
      MaterialStateProperty.all<Color>(Color.fromRGBO(112, 184, 73, 1.0));

  Color _imgBorderColor = Color.fromRGBO(112, 184, 73, 1.0);
  Color _nowNowIconColor = Colors.white;
  Color _nownowOpeningHourColor = Color.fromRGBO(112, 184, 73, 1.0);

  BorderSide? _categoryBorder;
  BorderSide? _subcategoryBorder;
  BorderSide? _subsubcategoryBorder;
  Color _categoryColor = Colors.white;
  Color _subcategoryColor = Colors.white;
  Color _subsubcategoryColor = Colors.white;

  String _emptyAlertCategory = "\n\n- Category";
  String _emptyAlertSubCategory = "\n\n- Subcategory";
  String _emptyAlertSubSubCategory = "\n\n- Subsubcategory";
  String _emptyAlertNameOfStore = "\n\n- Name of your Store";
  String _emptyAlertStreetAndNumber = "\n\n- Street And Number";
  String _emptyAlertPostcode = "\n\n- Postcode";
  String _emptyAlertCity = "\n\n- City";
  String _emptyAlertCountry = "\n\n- Country";
  String _emptyAlertOpeningHour = "\n\n- At least one opening hour";
  String _emptyAlertPicture = "\n\n- Picture of your Store";
  String _emptyAlertTermsAndCondition = "\n\n- Accept the Terms and Condition";
  String _emptyAlertLatLng =
      "\n\n- Please enter the address of your store in the address field and choose a suggested address.\nYou can also enter the name of your store directly in the first field. Maybe you can find your store in the suggestions? 😉";
  String _emptyAlertInvoiceLatLng =
      "\n\n- Please enter the address of your store in the address field in invoice address and choose a suggested address.";
  String _emptyAlertInvoiceNameOfStore = "\n\n- Invoice Name of your Store";
  String _emptyAlertInvoiceStreetAndNumber =
      "\n\n- Street And Number in invoice address";
  String _emptyAlertInvoiceFirstname = "\n\n- Firstname in invoice address";
  String _emptyAlertInvoiceLastname = "\n\n- Lastname in invoice address";
  String _emptyAlertInvoiceEmail = "\n\n- E-Mail in invoice address";
  String _emptyAlertInvoicePostcode = "\n\n- Postcode in invoice address";
  String _emptyAlertInvoiceCity = "\n\n- City in invoice address";
  String _emptyAlertInvoiceCountry = "\n\n- Country in invoice address";
  String _emptyAlertInvoiceGender = "\n\n- Gender in invoice address";
  String _confirmDataString =
      "Just a tap away from being part of the NowNow family as an advertiser.\n\nAll we have to do is check and confirm the details you have entered.\n\nAfter the confirmation you can start to advertise.";

  final IconData _searchIcon = Icons.search;
  final IconData _nameIcon = Icons.storefront;
  final IconData _floorIcon = Icons.stairs;
  final IconData _cityIcon = Icons.location_city;
  final IconData _countryIcon = Icons.flag;
  final IconData _homepageIcon = Icons.home;
  final IconData _facebookIcon = FontAwesomeIcons.facebookF;
  final IconData _instagramIcon = FontAwesomeIcons.instagram;
  final IconData _googleMybusinessIcon = FontAwesomeIcons.google;
  final IconData _youtubeIcon = FontAwesomeIcons.youtube;
  final IconData _tiktokIcon = FontAwesomeIcons.tiktok;
  final IconData _pinterestIcon = FontAwesomeIcons.pinterestP;
  final IconData _searchIconInvoice = Icons.search;
  final IconData _nameIconInvoice = Icons.storefront;
  final IconData _floorIconInvoice = Icons.stairs;
  final IconData _cityIconInvoice = Icons.location_city;
  final IconData _countryIconInvoice = Icons.flag;
  final IconData _phoneIconInvoice = Icons.phone;
  final IconData _homepageIconInvoice = Icons.home;
  final IconData _facebookIconInvoice = Icons.facebook;
  final IconData _instagramIconInvoice = Icons.camera;
  final IconData _firstnameIconInvoice = Icons.person;
  final IconData _emailIconInvoice = Icons.email;
  List<Subcategory> subcategorys = [];
  List<Subsubcategory> subsubcategorys = [];

  bool _streetOrStoreIsSelected = false;

  late AnimationController _animationController;
  late AnimationController _animationControllerStorePic;

  late bool isAccountRegistrated;

  bool isInit = true;

  String? _email;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: 0,
    );
    _streetOrStoreIsSelected = false;
    _animationController = AnimationController(
      vsync: this,
      value: 0,
      duration: Duration(
        milliseconds: 333,
      ),
    )..addStatusListener((status) => setState(() {}));

    _animationControllerStorePic = AnimationController(
      vsync: this,
      value: 1.0,
      duration: Duration(
        milliseconds: 333,
      ),
    )..addStatusListener((status) => setState(() {}));

    _emailRegFocus.addListener(_onEmailFocusChange);
    _passwordRegFocus.addListener(_onPasswordFocusChange);
    _repeatPasswordFocus.addListener(_onRepeatPasswordFocusChange);
    _firstnameFocus.addListener(_onFirstnameFocusChange);
    _lastnameFocus.addListener(_onLastnameFocusChange);
    _ibanFocus.addListener(_onIbanFocusChange);
    _taxIdFocus.addListener(_onTaxIdFocusChange);
    _birthDateFocus.addListener(_onbirthDateFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (isInit) {
      isInit = false;
      isAccountRegistrated = true;
      DateFormat formatter = DateFormat('dd.MM.yyyy');
      Provider.of<Advertiser>(context, listen: false)
          .getMe()
          .then((value) async {
        Advertiser advertiser =
            Provider.of<Advertiser>(context, listen: false).me;
        _gender = advertiser.gender;
        _emailSignUpController.text = advertiser.email!;
        _email = advertiser.email!;
        _firstnameController.text =
            advertiser.firstname != null ? advertiser.firstname! : "";
        _lastnameController.text =
            advertiser.lastname != null ? advertiser.lastname! : "";
        _birthDate = advertiser.birthDate;
        if (_birthDate != null) {
          _birthDateController.text = formatter.format(_birthDate!);
        }
        _taxIdController.text =
            advertiser.taxId != null ? advertiser.taxId! : "";
        // _ibanController.text = advertiser.iban != null ? advertiser.iban! : "";
        _phoneController.text =
            advertiser.phone != null ? advertiser.phone! : "";
        _crNumberController.text = advertiser.companyRegistrationNumber != null
            ? advertiser.companyRegistrationNumber!
            : "";
        _bicController.text = advertiser.bic != null ? advertiser.bic! : "";
      }).catchError((error) {
        Navigator.of(context).pop();
      });
    }
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

    //ADDRESS
    _searchFocus.dispose();
    _nameFocus.dispose();
    _streetFocus.dispose();
    _floorFocus.dispose();
    _postcodeFocus.dispose();
    _cityFocus.dispose();
    _countryFocus.dispose();
    _phoneFocus.dispose();
    _homepageFocus.dispose();
    _facebookFocus.dispose();
    _instagramFocus.dispose();
    _googleMybusinessFocus.dispose();
    _youtubeFocus.dispose();
    _tiktokFocus.dispose();
    _pinterestFocus.dispose();
    _searchStoreController.dispose();
    _nameController.dispose();
    _streetController.dispose();
    _floorController.dispose();
    _postCodeController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _homepageController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _googleMybusinessController.dispose();
    _youtubeController.dispose();
    _tiktokController.dispose();
    _pinterestController.dispose();
    _phoneController.dispose();
    _scrollController.dispose();

    _firstnameController.dispose();
    _lastnameController.dispose();
    _invoiceSearchStoreController.dispose();
    _invoiceNameController.dispose();
    _invoiceEmailController.dispose();
    _invoiceStreetController.dispose();
    _invoiceFloorController.dispose();
    _invoicePostCodeController.dispose();
    _invoiceCityController.dispose();
    _invoiceCountryController.dispose();
    _invoicePhoneController.dispose();

    _advertiserCityGlobalKey.currentState!.dispose();
    _advertiserSearchStoreGlobalKey.currentState!.dispose();
    _advertiserSearchStreetGlobalKey.currentState!.dispose();
    _advertiserNameGlobalKey.currentState!.dispose();
    _advertiserCityGlobalKey.currentState!.dispose();
    _advertiserPostcodeGlobalKey.currentState!.dispose();
    _advertiserCountryGlobalKey.currentState!.dispose();
    _advertiserPhoneGlobalKey.currentState!.dispose();
    _invoiceAdvertiserSearchStoreGlobalKey.currentState!.dispose();
    _invoiceAdvertiserFirstnameGlobalKey.currentState!.dispose();
    _invoiceAdvertiserLastnameGlobalKey.currentState!.dispose();
    _invoiceAdvertiserEmailGlobalKey.currentState!.dispose();
    _invoiceAdvertiserNameGlobalKey.currentState!.dispose();
    _invoiceAdvertiserCityGlobalKey.currentState!.dispose();
    _invoiceAdvertiserPostcodeGlobalKey.currentState!.dispose();
    _invoiceAdvertiserCountryGlobalKey.currentState!.dispose();
    _invoiceAdvertiserPhoneGlobalKey.currentState!.dispose();
    _storePhoneController.dispose();

    _pageController.dispose();
    _listViewScrollController.dispose();
    _animationController.dispose();
    isEditingPassword = false;

    super.dispose();
  }

  _deletePicture() async {
    if (_imageFile != null) {
      setState(() {
        _imageFile = null;
      });
    }
  }

  _selectTakePic(BuildContext context) async {
    await showAdaptiveActionSheet(
      bottomSheetColor: Colors.white,
      context: context,
      actions: <BottomSheetAction>[
        BottomSheetAction(
            title: Text(
              "Take a photo",
              style: TextStyle(color: Theme.of(context).accentColor),
              textAlign: TextAlign.center,
            ),
            onPressed: () async {
              onTap(false);
              Navigator.pop(context);
            }),
        BottomSheetAction(
            title: Text(
              "Select a photo",
              style: TextStyle(color: Theme.of(context).accentColor),
              textAlign: TextAlign.center,
            ),
            onPressed: () {
              onTap(true);
              Navigator.pop(context);
            }),
        if (_imageFile != null)
          BottomSheetAction(
              title: Text(
                "Delete",
                style: TextStyle(
                  color: Platform.isAndroid
                      ? Colors.red[700]
                      : CupertinoColors.systemRed,
                ),
                textAlign: TextAlign.center,
              ),
              onPressed: () async {
                await _deletePicture();
                Navigator.of(context).pop();
              }),
      ],
      cancelAction: CancelAction(
        title: Text("Cancel",
            style: TextStyle(color: Theme.of(context).accentColor)),
      ),
    );
  }

  Future onTap(bool isGallery) async {
    try {
      final file = await Utils.pickMedia(
        isGallery: isGallery,
        cropImage: cropImage,
      );

      if (file == null) return null;
      setState(() {
        _imageFile = file;
        print(_imageFile!.path);
        _imgBorderColor = Color.fromRGBO(112, 184, 73, 1.0);
        _imgBorderWidth = 1;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<File?> cropImage(File _imageFile) async {
    try {
      return await ImageCropper.cropImage(
          sourcePath: _imageFile.path,
          cropStyle: CropStyle.rectangle,
          aspectRatio: CropAspectRatio(ratioX: 2, ratioY: 1.5),
          aspectRatioPresets: [CropAspectRatioPreset.ratio3x2],
          compressQuality: 80,
          maxHeight: 500,
          maxWidth: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Theme.of(context).accentColor,
          ),
          iosUiSettings: IOSUiSettings(
              rotateButtonsHidden: true, rotateClockwiseButtonHidden: true));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: Container(
              height: _height,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: _height * 0.012,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: _currentPage != _numPages - 1
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage == _numPages - 1)
                          Container(
                            margin: EdgeInsets.only(
                              top: _height * 0.03,
                              right: _width * 0.021,
                            ),
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                _pageController.previousPage(
                                  duration: Duration(milliseconds: 120),
                                  curve: Curves.ease,
                                );
                                FocusScope.of(context).unfocus();
                              },
                              child: Text(
                                "Back",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                              ),
                            ),
                          ),
                        Container(
                          margin: EdgeInsets.only(
                            top: _height * 0.03,
                            right: _width * 0.021,
                          ),
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 15,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              splashFactory: NoSplash.splashFactory,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: _height * 0.801,
                      child: PageView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        onPageChanged: (pageIndex) {
                          setState(() {
                            _currentPage = pageIndex;
                          });
                          print("page Index: " + pageIndex.toString());
                        },
                        children: [
                          _buildEmailPage(context),
                          _buildPersonalDataPage(context),
                          _buildOptionalPersonalDataPage(context),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _pageIndicator(),
                    ),
                    _currentPage != _numPages - 1
                        ? Flexible(
                            fit: FlexFit.loose,
                            child: Row(
                              mainAxisAlignment: _currentPage != 0
                                  ? MainAxisAlignment.spaceBetween
                                  : MainAxisAlignment.end,
                              children: [
                                if (_currentPage != 0)
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        splashFactory: NoSplash.splashFactory),
                                    onPressed: () {
                                      _pageController.previousPage(
                                        duration: Duration(milliseconds: 120),
                                        curve: Curves.ease,
                                      );
                                      FocusScope.of(context).unfocus();
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.arrowLeft,
                                          color: Theme.of(context).primaryColor,
                                          size: 21.0,
                                        ),
                                        SizedBox(
                                          width: _width * 0.01,
                                        ),
                                        Text(
                                          "Back",
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                loading
                                    ? Platform.isAndroid
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                              top: _height * 0.021,
                                              right: _width * 0.1,
                                            ),
                                            child:
                                                const CircularProgressIndicator(),
                                          )
                                        : Padding(
                                            padding: EdgeInsets.only(
                                              top: _height * 0.021,
                                              right: _width * 0.1,
                                            ),
                                            child:
                                                const CupertinoActivityIndicator(),
                                          )
                                    : TextButton(
                                        style: TextButton.styleFrom(
                                          splashFactory: NoSplash.splashFactory,
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            loading = true;
                                          });

                                          if (_currentPage == 1) {
                                            await updatePersonalDataAdvertiser();
                                          }
                                          if (_currentPage == 0) {
                                            await _updateAdvertiser();
                                          }

                                          setState(() {
                                            loading = false;
                                          });
                                          FocusScope.of(context).unfocus();
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Next",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize: 18,
                                              ),
                                            ),
                                            SizedBox(
                                              width: _width * 0.01,
                                            ),
                                            Icon(
                                              FontAwesomeIcons.arrowRight,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: 21.0,
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          )
                        : Text(""),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomSheet: _bottomSheet(context),
      ),
    );
  }

  Widget? _bottomSheet(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    if (_isLoading && _currentPage == _numPages - 1) {
      return Container(
        height: _height * 0.081,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(114, 180, 62, 1.0),
              Color.fromRGBO(153, 199, 60, 1.0),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: _height * 0.012,
            ),
            child: Platform.isAndroid
                ? const CircularProgressIndicator(
                    color: Color.fromRGBO(253, 166, 41, 1.0),
                  )
                : const CupertinoActivityIndicator(),
          ),
        ),
      );
    }
    if (!_isLoading && _currentPage == _numPages - 1) {
      return GestureDetector(
        onTap: () async {
          if (!_isLoading) {
            setState(() {
              _isLoading = true;
            });
            await updateOptionalPersonalDataAdvertiser();
            setState(() {
              _isLoading = false;
            });
          }
        },
        child: Container(
          height: _height * 0.081,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(114, 180, 62, 1.0),
                Color.fromRGBO(153, 199, 60, 1.0),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: _height * 0.012,
              ),
              child: Text(
                "Edit Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildEmailPage(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    Widget _emptySpaceColum =
        SizedBox(height: MediaQuery.of(context).size.height * 0.03);
    Widget _emptySpaceColumTextField =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);
    return Padding(
      padding: EdgeInsets.only(
        right: _width * 0.063,
        left: _width * 0.063,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image(
              image: AssetImage(
                'assets/images/signupmail.png',
              ),
              height: _height * 0.18,
              width: _width * 0.7,
            ),
          ),
          Text(
            "Edit Profile",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
          SizedBox(
            height: _height * 0.012,
          ),
          Text(
            "Be a part of NowNow-Family",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          SizedBox(
            height: _height * 0.005,
          ),
          Text(
            "Advertise STAD and QROFFER in real time, promote ur store and grow up",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 15,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          _emptySpaceColum,
          _emptySpaceColumTextField,
          _formAndTextFormField(
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
                  if (_checkEmail == false) {
                    return "Email address assigned";
                  }
                }
              }
            },
            autoFillHints: _emailAutoFillHints,
          ),
          _emptySpaceColumTextField,
          _formAndTextFormField(
            enabled: isEditingPassword,
            key: _advertiserRegPasswordGlobalKey,
            nextFocusNode: _repeatPasswordFocus,
            focusNode: _passwordRegFocus,
            textController: _passwordSignUpController,
            obscure: true,
            generalColor: _nowNowGeneralColor,
            errorBorderColor:
                !isEditingPassword ? _nowNowGeneralColor : Colors.red,
            borderColor: _nowNowBorderColor,
            icon: _passwordIcon,
            hintText: !isEditingPassword ? "******" : "Password",
            textInputType: TextInputType.text,
            validator: MinLengthValidator(6,
                errorText: 'Enter at least 6 Characters.'),
          ),
          _emptySpaceColumTextField,
          if (!isEditingPassword)
            TextButton(
              style:
                  TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
              onPressed: () {
                _passwordSignUpController.text = "";
                setState(() {
                  isEditingPassword = true;
                });
              },
              child: Text(
                "Change Password",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isEditingPassword)
            _formAndTextFormField(
              enabled: isEditingPassword,
              key: _advertiserRegRepeatPasswordGlobalKey,
              focusNode: _repeatPasswordFocus,
              textController: _repeatPasswordController,
              obscure: true,
              generalColor: _nowNowGeneralColor,
              errorBorderColor:
                  !isEditingPassword ? _nowNowGeneralColor : Colors.red,
              borderColor: _nowNowBorderColor,
              icon: _passwordIcon,
              hintText: "Repeat Password",
              textInputType: TextInputType.text,
              validator: (value) =>
                  MatchValidator(errorText: 'Passwords do not match.')
                      .validateMatch(value!, _passwordSignUpController.text),
            ),
          _emptySpaceColumTextField,
          if (isEditingPassword)
            TextButton(
              style:
                  TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
              onPressed: () {
                _passwordSignUpController.text = "";
                setState(() {
                  isEditingPassword = false;
                });
              },
              child: Text(
                "Cancel Change Password",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDonePage(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    Widget _emptySpaceColum =
        SizedBox(height: MediaQuery.of(context).size.height * 0.03);
    Widget _emptySpaceColumTextField =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);
    return Padding(
      padding: EdgeInsets.only(
        right: _width * 0.063,
        left: _width * 0.063,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image(
              image: AssetImage(
                'assets/images/done.png',
              ),
              height: _height * 0.270,
              width: _width * 0.81,
            ),
          ),
          Text(
            "DONE! 🤯🤯🥳🥳🥳",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
          SizedBox(
            height: _height * 0.012,
          ),
          Text(
            "U are an Advertiser and a part of NowNow-Family! 😍",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          SizedBox(
            height: _height * 0.005,
          ),
          Text(
            "Advertise STAD and QROFFER in real time, promote ur store and grow up 📈 🛫",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 15,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          _emptySpaceColum,
          Container(
            child: Text(
              _confirmDataString,
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          _emptySpaceColumTextField,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                  fillColor: _checkboxTermsFillColor,
                  checkColor: Colors.white,
                  value: _acceptTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      _acceptTerms = value!;
                    });
                    if (value = true) {
                      setState(() {
                        _checkboxTermsTextColor = _nowNowGeneralColor;
                        _checkboxTermsFillColor =
                            MaterialStateProperty.all<Color>(
                          _nowNowGeneralColor,
                        );
                      });
                    }
                  }),
              Row(
                children: [
                  Text(
                    "I accept the",
                    style: TextStyle(
                      color: _checkboxTermsTextColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigator.of(context).pushNamed(
                      //     TermsAndConditions.routeName);
                    },
                    child: Text(
                      "Terms and Conditions.",
                      style: TextStyle(
                          color: _checkboxTermsTextColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDataPage(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    Widget _emptySpaceColum =
        SizedBox(height: MediaQuery.of(context).size.height * 0.03);
    Widget _emptySpaceColumTextField =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);
    return Padding(
      padding: EdgeInsets.only(
        right: _width * 0.063,
        left: _width * 0.063,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image(
                image: AssetImage(
                  'assets/images/profile.png',
                ),
                height: _height * 0.09,
                width: _width * 0.3,
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  "Ur personal data",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: _height * 0.012,
                ),
                Text(
                  "Be a part of NowNow-Family",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
                SizedBox(
                  height: _height * 0.005,
                ),
                SizedBox(
                  width: _width * 0.54,
                  child: Text(
                    "Advertise STAD and QROFFER in real time, promote ur store and grow up",
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 9,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
              ]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
              Text(
                'Diverse',
                style: TextStyle(color: _nowNowGeneralColor),
              ),
            ],
          ),
          _formAndTextFormField(
            key: _advertiserRegFirstnameGlobalKey,
            nextFocusNode: _lastnameFocus,
            focusNode: _firstnameFocus,
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
              nextFocusNode: _taxIdFocus,
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
        ],
      ),
    );
  }

  Widget _buildOptionalPersonalDataPage(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    Widget _emptySpaceColum =
        SizedBox(height: MediaQuery.of(context).size.height * 0.03);
    Widget _emptySpaceColumTextField =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);
    return Padding(
      padding: EdgeInsets.only(
        right: _width * 0.063,
        left: _width * 0.063,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image(
              image: AssetImage(
                'assets/images/profile.png',
              ),
              height: _height * 0.18,
              width: _width * 0.7,
            ),
          ),
          SizedBox(
            height: _height * 0.012,
          ),
          Text(
            "Ur personal data",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
          SizedBox(
            height: _height * 0.012,
          ),
          Text(
            "Be a part of NowNow-Family",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          SizedBox(
            height: _height * 0.005,
          ),
          Text(
            "Advertise STAD and QROFFER in real time, promote ur store and grow up",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: 15,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          _emptySpaceColumTextField,
          _emptySpaceColumTextField,
          Text(
            "This fields are Optional",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
          _emptySpaceColumTextField,
          _formAndTextFormField(
            key: _advertiserRegPhoneGlobalKey,
            nextFocusNode: _cRNrFocus,
            focusNode: _phoneFocus,
            textController: _phoneController,
            generalColor: _nowNowGeneralColor,
            errorBorderColor: Colors.red,
            borderColor: _nowNowBorderColor,
            icon: _phoneIcon,
            hintText: "Phone",
            textInputType: TextInputType.phone,
          ),
          _emptySpaceColumTextField,
          _formAndTextFormField(
            nextFocusNode: _bicFocus,
            focusNode: _cRNrFocus,
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
            focusNode: _bicFocus,
            textController: _bicController,
            generalColor: _nowNowGeneralColor,
            errorBorderColor: Colors.red,
            borderColor: _nowNowBorderColor,
            icon: _crnIcon,
            hintText: "BIC (SWIFT-Code)",
            textInputType: TextInputType.text,
          ),
        ],
      ),
    );
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

  Widget _formAndTypeAheadFormField({
    required Key formKey,
    required String? Function(String?)? validator,
    required FutureOr<Iterable<dynamic>> Function(String) suggestionsCallback,
    required Widget Function(BuildContext, dynamic) itemBuilder,
    required void Function(dynamic) onSuggestionSelected,
    required FocusNode focusNode,
    required FocusNode nextFocusNode,
    required TextEditingController textController,
    required IconData icon,
    required String hintText,
    TextInputType textInputType = TextInputType.text,
  }) {
    return Form(
      key: formKey,
      child: TypeAheadFormField(
        hideOnEmpty: true,
        validator: validator,
        transitionBuilder: (context, suggestionsBox, controller) {
          return suggestionsBox;
        },
        suggestionsCallback: suggestionsCallback,
        itemBuilder: itemBuilder,
        onSuggestionSelected: onSuggestionSelected,
        noItemsFoundBuilder: (value) {
          return SingleChildScrollView(
            child: ListTile(
              title: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
        },
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: focusNode,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          },
          controller: textController,
          style: TextStyle(
              fontWeight: FontWeight.w400, color: _nowNowGeneralColor),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16.0),
            prefixIcon: Container(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              margin: const EdgeInsets.only(right: 8.0),
              decoration: BoxDecoration(
                  color: _nowNowBorderColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      topRight: Radius.circular(10.0),
                      bottomRight: Radius.circular(30.0))),
              child: Icon(
                icon,
                color: _nowNowIconColor,
              ),
            ),
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black26),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _nowNowBorderColor, width: 2.0),
              borderRadius: BorderRadius.circular(30.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _nowNowBorderColor, width: 1.0),
              borderRadius: BorderRadius.circular(25.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
              borderRadius: BorderRadius.circular(30.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
              borderRadius: BorderRadius.circular(30.0),
            ),
            filled: true,
            fillColor: Colors.black.withOpacity(0.1),
          ),
          keyboardType: textInputType,
        ),
      ),
    );
  }

  Widget _formAndTextFormFieldStore({
    Key? formKey,
    String? Function(String?)? validator,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    required TextEditingController textController,
    required IconData icon,
    required String hintText,
    TextInputType textInputType = TextInputType.text,
  }) {
    return Form(
      key: formKey,
      child: TextFormField(
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        },
        focusNode: focusNode,
        validator: validator,
        controller: textController,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: _nowNowGeneralColor,
        ),
        decoration: InputDecoration(
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          prefixIcon: Container(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
                color: _nowNowBorderColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    topRight: Radius.circular(10.0),
                    bottomRight: Radius.circular(30.0))),
            child: Icon(
              icon,
              color: _nowNowIconColor,
            ),
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black26),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _nowNowBorderColor, width: 2.0),
            borderRadius: BorderRadius.circular(30.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _nowNowBorderColor, width: 1.0),
            borderRadius: BorderRadius.circular(25.0),
          ),
          filled: true,
          fillColor: Colors.black.withOpacity(0.1),
        ),
        keyboardType: textInputType,
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

      FocusScope.of(context).requestFocus(_taxIdFocus);
    }
  }

  Future<void> _updateAdvertiser() async {
    if (isEditingPassword) {
      _advertiserRegEmailGlobalKey.currentState!.validate();

      _advertiserRegPasswordGlobalKey.currentState!.validate();

      _advertiserRegRepeatPasswordGlobalKey.currentState!.validate();

      if (_advertiserRegEmailGlobalKey.currentState!.validate() &&
          _advertiserRegPasswordGlobalKey.currentState!.validate() &&
          _advertiserRegRepeatPasswordGlobalKey.currentState!.validate() &&
          _checkEmail!) {
        try {
          await _pageController.nextPage(
            duration: Duration(milliseconds: 120),
            curve: Curves.ease,
          );
        } catch (e) {
          print(e);
        }
      }
    } else {
      _advertiserRegEmailGlobalKey.currentState!.validate();
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
          } else {
            if (_emailSignUpController.text.toLowerCase().trim() == _email!) {
              setState(() {
                _checkEmail = true;
              });

              _advertiserRegEmailGlobalKey.currentState!.validate();
            } else {
              setState(() {
                _checkEmail = false;
              });
              _advertiserRegEmailGlobalKey.currentState!.validate();
            }
          }
        } catch (e) {
          if (_emailSignUpController.text.toLowerCase().trim() == _email!) {
            setState(() {
              _checkEmail = true;
            });

            _advertiserRegEmailGlobalKey.currentState!.validate();
          } else {
            setState(() {
              _checkEmail = false;
            });
            _advertiserRegEmailGlobalKey.currentState!.validate();
          }
        }
      }
      if (_advertiserRegEmailGlobalKey.currentState!.validate() &&
          _checkEmail!) {
        try {
          await _pageController.nextPage(
            duration: Duration(milliseconds: 120),
            curve: Curves.ease,
          );
        } catch (e) {
          print(e);
        }
      }
    }
  }

  Future updatePersonalDataAdvertiser() async {
    if (_gender == null) {
      setState(() {
        _radioColor = MaterialStateProperty.all<Color>(Colors.red);
      });
    } else {
      setState(() {
        _radioColor = MaterialStateProperty.all<Color>(_nowNowGeneralColor);
      });
    }
    _advertiserRegFirstnameGlobalKey.currentState!.validate();
    _advertiserRegLastnameGlobalKey.currentState!.validate();
    _advertiserRegBirthDateGlobalKey.currentState!.validate();

    if (_advertiserRegFirstnameGlobalKey.currentState!.validate() &&
        _advertiserRegLastnameGlobalKey.currentState!.validate() &&
        _advertiserRegBirthDateGlobalKey.currentState!.validate()) {
      try {
        await _pageController.nextPage(
          duration: Duration(milliseconds: 120),
          curve: Curves.ease,
        );
      } catch (e) {
        print(e);
      }
    }
  }

  Future updateOptionalPersonalDataAdvertiser() async {
    try {
      await Provider.of<Advertiser>(context, listen: false).update(
        advertiser: Advertiser(
          email: _emailSignUpController.text.trim(),
          password: isEditingPassword ? _passwordSignUpController.text : null,
          gender: _gender,
          firstname: _firstnameController.text,
          lastname: _lastnameController.text,
          birthDate: _birthDate,
          taxId: _taxIdController.text,
          // iban: _ibanController.text,
          phone: _phoneController.text,
          companyRegistrationNumber: _crNumberController.text,
          bic: _bicController.text,
        ),
      );
      Navigator.of(context).pop();

      await Fluttertoast.showToast(
          msg: "Profile edited!",
          backgroundColor: Theme.of(context).accentColor,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_LONG);
    } catch (e) {
      await Alert(
        context: context,
        type: AlertType.error,
        title: "An Error Occured",
        desc: "Try Again",
        buttons: [
          DialogButton(
            child: Text(
              "Close",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            width: MediaQuery.of(context).size.width * 0.3,
          ),
        ],
      ).show();
      print(e);
    }
  }

  Future addOpeningHours() async {
    try {
      await _pageController.nextPage(
        duration: Duration(milliseconds: 120),
        curve: Curves.ease,
      );
    } catch (e) {
      print(e);
    }
  }
}
