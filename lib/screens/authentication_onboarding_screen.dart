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

class AuthenticationOnboardingScreen extends StatefulWidget {
  static const routeName = '/authOnboarding';

  final int initialPage;
  const AuthenticationOnboardingScreen({Key? key, required this.initialPage})
      : super(key: key);

  @override
  _AuthenticationOnboardingScreenState createState() =>
      _AuthenticationOnboardingScreenState();
}

class _AuthenticationOnboardingScreenState
    extends State<AuthenticationOnboardingScreen>
    with TickerProviderStateMixin {
  late int initialPage;
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

    // if (_authMode == AuthMode.Login) {
    //   _advertiserLogGlobalKey.currentState!.validate();
    //   if (_advertiserLogGlobalKey.currentState!.validate()) {
    //     setState(() {
    //       loading = true;
    //     });
    //     try {
    //       await Provider.of<Advertiser>(context, listen: false).signIn(
    //           email: _emailLoginController.text.trim(),
    //           password: _passwordLoginController.text,
    //           table: 'Advertiser',
    //           route: 'signInAdvertiser');
    //       await Navigator.of(context)
    //           .pushReplacementNamed(HomeScreen.routeName);
    //     } catch (e) {
    //       await showOkAlertDialog(context: context, message: e.toString());
    //     }
    //     setState(() {
    //       loading = false;
    //     });
    //   }
    // }
    // if (_authMode == AuthMode.Signup) {
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
          _radioColor = MaterialStateProperty.all<Color>(_nowNowGeneralColor);
        });
      }
    } else {
      // if (_authMode == AuthMode.Signup) {
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
          _radioColor = MaterialStateProperty.all<Color>(_nowNowGeneralColor);
        });
      }
      if (_advertiserRegEmailGlobalKey.currentState!.validate() == false) {
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

      await showOkAlertDialog(context: context, title: _emptyAlertFieldsString);
      _emptyAlertFieldsString = "Please fill in the empty text fields:\n";
      // }
    }
    // }

    // if (_authMode == AuthMode.ForgotPassword) {
    //   _advertiserForgotGlobalKey.currentState!.validate();
    //   if (_advertiserForgotGlobalKey.currentState!.validate()) {
    //     try {
    //       await Provider.of<Advertiser>(context, listen: false).resetPassword(
    //           email: _forgotEmailController.text.trim(),
    //           table: "advertiser",
    //           route: "resetPassword");
    //     } catch (e) {
    //       setState(() {
    //         _hasException = true;
    //       });
    //     }
    //   }
    // }
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
      // if (_advertiserRegEmailGlobalKey.currentState!.validate()) {
      if (_emailSignUpController.text.isNotEmpty) {
        print("alllaaa");
        try {
          final bool findedEmail =
              await Provider.of<Advertiser>(context, listen: false).findEmail(
            email: _emailSignUpController.text,
            table: 'advertiser',
            route: 'email',
          );
          print(findedEmail);
          if (findedEmail) {
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
        } catch (e) {
          print("hallo");
          setState(() {
            _checkEmail = false;
          });
          _advertiserRegEmailGlobalKey.currentState!.validate();
        }
        // }
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
  int _numPages = 8;
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
      print(placeId);

      List<Locale> languageLocales =
          await Devicelocale.preferredLanguagesAsLocales;
      Locale languageCode = languageLocales.first;
      String lang = languageCode.languageCode.toString();

      String baseUrl =
          'https://maps.googleapis.com/maps/api/place/details/json';
      String request =
          '$baseUrl?place_id=$placeId&key=${Enviroment.googleApiKey}&language=$lang';

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
              if (c['long_name'] != null && c['long_name'] != "") {
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
            _nameController.text = _nameOfStore!;

//Get LatLong

          final resultlatlong = result['result']['geometry']['location'];
          setState(() {
            _lat = resultlatlong['lat'];
            _lng = resultlatlong['lng'];
          });
          if (_lat != null && _lng != null && _countryCode != null) {
            //Address Phone number

            final String? resultphoneNumber =
                result['result']['international_phone_number'];

            if (resultphoneNumber != null && resultphoneNumber != "") {
              _storePhoneController.text = resultphoneNumber;
            }

            if (checkboxActive!) {
              Advertiser? _advertiser =
                  Provider.of<Advertiser>(context, listen: false).me;
              _invoiceStreetController.text = _streetController.text.length > 0
                  ? _streetController.text
                  : "";
              _invoiceCityController.text =
                  _cityController.text.length > 0 ? _cityController.text : "";
              _invoiceCountryController.text =
                  _countryController.text.length > 0
                      ? _countryController.text
                      : "";
              _invoicePostCodeController.text =
                  _postCodeController.text.length > 0
                      ? _postCodeController.text
                      : "";
              _invoiceNameController.text =
                  _nameOfStore != null ? _nameOfStore! : "";

              _invoiceGender = _advertiser.gender;
              _invoiceEmailController.text = _advertiser.email!;
              _invoiceFirstnameController.text = _advertiser.firstname!;
              _invoiceLastnameController.text = _advertiser.lastname!;
              _invoiceLat = _lat;
              _invoiceLng = _lng;
              _invoiceCountryCode = _countryCode;
              _invoicePhoneController.text =
                  _storePhoneController.text.length > 0
                      ? _storePhoneController.text
                      : "";
            }

            //GET OpeningHours

            String requestOpeningHours =
                '$baseUrl?place_id=$placeId&key=${Enviroment.googleApiKey}&language=de';

            Response responseOpeningHours =
                await Dio().get(requestOpeningHours);

            // final resultOpeningHours = result['result']['opening_hours'];
            if (responseOpeningHours.statusCode == 200) {
              _calculateOpeningHours(int weekdayInt, int matches,
                  String textInList, String weekdayText) {
                String? firstOpeningHourText;
                var splitted;
                DateTime now = DateTime(2022, 1, 3, 0, 0, 0, 0, 0);
                List<DateTime> beginList = [];
                List<DateTime> endList = [];
                for (var i = 0; i <= matches; i++) {
                  if (i == 0) {
                    firstOpeningHourText = textInList
                        .replaceFirst(RegExp(weekdayText + ': '), '')
                        .replaceFirst(RegExp(' Uhr'), '');
                  }
                  if (matches > i) {
                    firstOpeningHourText = firstOpeningHourText!
                        .replaceFirst(RegExp(' Uhr'), '')
                        .replaceFirst(RegExp(' '), '');

                    if (i != matches) {
                      splitted = firstOpeningHourText.split(',');
                    }
                  }
                  int? fromHour;
                  int? fromMinute;
                  int? toHour;
                  int? toMinute;
                  if (matches > 0) {
                    fromHour = int.parse(splitted[i]
                        .toString()
                        .split('–')
                        .first
                        .toString()
                        .split(':')
                        .first
                        .toString());

                    fromMinute = int.parse(splitted[i]
                        .toString()
                        .split('–')
                        .first
                        .toString()
                        .split(':')[1]
                        .toString());

                    toHour = int.parse(splitted[i]
                        .toString()
                        .split('–')[1]
                        .toString()
                        .split(':')
                        .first
                        .toString());

                    toMinute = int.parse(splitted[i]
                        .toString()
                        .split('–')[1]
                        .toString()
                        .split(':')[1]
                        .toString());
                  } else {
                    fromHour = int.parse(firstOpeningHourText!
                        .split('–')
                        .first
                        .toString()
                        .split(':')
                        .first
                        .toString());

                    fromMinute = int.parse(firstOpeningHourText
                        .split('–')
                        .first
                        .toString()
                        .split(':')[1]
                        .toString());

                    toHour = int.parse(firstOpeningHourText
                        .split('–')[1]
                        .toString()
                        .split(':')
                        .first
                        .toString());

                    toMinute = int.parse(firstOpeningHourText
                        .split('–')[1]
                        .toString()
                        .split(':')[1]
                        .toString());
                  }
                  for (var j = 0; j < 7; j++) {
                    if (now.add(Duration(days: j)).weekday == weekdayInt) {
                      if (fromHour != null && fromMinute != null) {
                        DateTime begin = DateTime(
                          now.add(Duration(days: j)).year,
                          now.add(Duration(days: j)).month,
                          now.add(Duration(days: j)).day,
                          fromHour,
                          fromMinute,
                          0,
                          0,
                          0,
                        );
                        beginList.add(begin);
                      }

                      if (toHour != null && toMinute != null) {
                        DateTime end = DateTime(
                          now.add(Duration(days: j)).year,
                          now.add(Duration(days: j)).month,
                          now.add(Duration(days: j)).day,
                          toHour,
                          toMinute,
                          0,
                          0,
                          0,
                        );
                        endList.add(end);
                      }
                    }
                  }
                }
                bool isAfter = false;
                bool isNextDay = false;
                for (var i = 0; i < beginList.length; i++) {
                  if (i > 0) {
                    if (!isAfter) {
                      if (isNextDay) {
                        beginList[i] = beginList[i].add(Duration(days: 1));
                        endList[i] = endList[i].add(Duration(days: 1));
                      }
                      if (!isNextDay) {
                        if (beginList[i - 1].isAfter(beginList[i])) {
                          isNextDay = true;
                          beginList[i] = beginList[i].add(Duration(days: 1));
                          endList[i] = endList[i].add(Duration(days: 1));
                        }
                      }
                    }
                  }
                  if (isAfter) {
                    beginList[i] = beginList[i].add(Duration(days: 1));
                    endList[i] = endList[i].add(Duration(days: 1));
                  }
                  if (!isAfter) {
                    if (beginList[i].isAfter(endList[i])) {
                      isAfter = true;
                      endList[i] = endList[i].add(Duration(days: 1));
                    }
                  }
                }
                for (var i = 0; i < beginList.length; i++) {
                  int duration = endList[i].difference(beginList[i]).inMinutes;
                  _openingHoursList.add({
                    "day": beginList.first.weekday,
                    "day_from": beginList[i].weekday,
                    "day_to": endList[i].weekday,
                    "time_from": formatTimeOfDay(TimeOfDay(
                        hour: beginList[i].hour, minute: beginList[i].minute)),
                    "time_to_duration": duration,
                  });
                  _openingHoursListDateTimeRange.add({
                    "day": beginList.first.weekday,
                    "datetimerange":
                        DateTimeRange(start: beginList[i], end: endList[i])
                  });
                }
              }

              _openingHoursList.clear();
              _openingHoursListDateTimeRange.clear();
              final resultForOpeningHours = await responseOpeningHours.data;

              if (resultForOpeningHours['result']['opening_hours'] != null) {
                final List openingHoursTextList =
                    result['result']['opening_hours']["weekday_text"];

                if (openingHoursTextList.isNotEmpty) {
                  DateTime now = DateTime(2022, 1, 3, 0, 0, 0, 0, 0);
                  for (var i = 0; i < openingHoursTextList.length; i++) {
                    String textInList = openingHoursTextList[i];
                    int matches = ','.allMatches(textInList).length;
                    String weekdayText =
                        textInList.substring(0, textInList.indexOf(':'));
                    if (weekdayText == 'Montag') {
                      if (!textInList.contains("Geschlossen")) {
                        if (textInList.contains("24 Stunden geöffnet")) {
                          for (var j = 0; j < 7; j++) {
                            if (now.add(Duration(days: j)).weekday == 1) {
                              DateTime startDate = DateTime(
                                now.add(Duration(days: j)).year,
                                now.add(Duration(days: j)).month,
                                now.add(Duration(days: j)).day,
                                0,
                                0,
                                0,
                                0,
                                0,
                              );
                              DateTime endDate =
                                  startDate.add(const Duration(days: 1));
                              _openingHoursListDateTimeRange.add({
                                "day": 1,
                                "datetimerange": DateTimeRange(
                                    start: startDate, end: endDate)
                              });
                            }
                          }
                          _openingHoursList.add({
                            "day": 1,
                            "day_from": 1,
                            "day_to": 2,
                            "time_from": "00:00",
                            "time_to_duration": 1440,
                          });
                        } else {
                          _calculateOpeningHours(
                              1, matches, textInList, weekdayText);
                        }
                      }
                    }
                    if (weekdayText == 'Dienstag') {
                      if (!textInList.contains("Geschlossen")) {
                        if (textInList.contains("24 Stunden geöffnet")) {
                          for (var j = 0; j < 7; j++) {
                            if (now.add(Duration(days: j)).weekday == 2) {
                              DateTime startDate = DateTime(
                                now.add(Duration(days: j)).year,
                                now.add(Duration(days: j)).month,
                                now.add(Duration(days: j)).day,
                                0,
                                0,
                                0,
                                0,
                                0,
                              );
                              DateTime endDate =
                                  startDate.add(const Duration(days: 1));
                              _openingHoursListDateTimeRange.add({
                                "day": 2,
                                "datetimerange": DateTimeRange(
                                    start: startDate, end: endDate)
                              });
                            }
                          }
                          _openingHoursList.add({
                            "day": 2,
                            "day_from": 2,
                            "day_to": 3,
                            "time_from": "00:00",
                            "time_to_duration": 1440,
                          });
                        } else {
                          _calculateOpeningHours(
                              2, matches, textInList, weekdayText);
                        }
                      }
                    }
                    if (weekdayText == 'Mittwoch') {
                      if (!textInList.contains("Geschlossen")) {
                        if (textInList.contains("24 Stunden geöffnet")) {
                          for (var j = 0; j < 7; j++) {
                            if (now.add(Duration(days: j)).weekday == 3) {
                              DateTime startDate = DateTime(
                                now.add(Duration(days: j)).year,
                                now.add(Duration(days: j)).month,
                                now.add(Duration(days: j)).day,
                                0,
                                0,
                                0,
                                0,
                                0,
                              );
                              DateTime endDate =
                                  startDate.add(const Duration(days: 1));
                              _openingHoursListDateTimeRange.add({
                                "day": 3,
                                "datetimerange": DateTimeRange(
                                    start: startDate, end: endDate)
                              });
                            }
                          }
                          _openingHoursList.add({
                            "day": 3,
                            "day_from": 3,
                            "day_to": 4,
                            "time_from": "00:00",
                            "time_to_duration": 1440,
                          });
                        } else {
                          _calculateOpeningHours(
                              3, matches, textInList, weekdayText);
                        }
                      }
                    }
                    if (weekdayText == 'Donnerstag') {
                      if (!textInList.contains("Geschlossen")) {
                        if (textInList.contains("24 Stunden geöffnet")) {
                          for (var j = 0; j < 7; j++) {
                            if (now.add(Duration(days: j)).weekday == 4) {
                              DateTime startDate = DateTime(
                                now.add(Duration(days: j)).year,
                                now.add(Duration(days: j)).month,
                                now.add(Duration(days: j)).day,
                                0,
                                0,
                                0,
                                0,
                                0,
                              );
                              DateTime endDate =
                                  startDate.add(const Duration(days: 1));
                              _openingHoursListDateTimeRange.add({
                                "day": 4,
                                "datetimerange": DateTimeRange(
                                    start: startDate, end: endDate)
                              });
                            }
                          }
                          _openingHoursList.add({
                            "day": 4,
                            "day_from": 4,
                            "day_to": 5,
                            "time_from": "00:00",
                            "time_to_duration": 1440,
                          });
                        } else {
                          _calculateOpeningHours(
                              4, matches, textInList, weekdayText);
                        }
                      }
                    }
                    if (weekdayText == 'Freitag') {
                      if (!textInList.contains("Geschlossen")) {
                        if (textInList.contains("24 Stunden geöffnet")) {
                          for (var j = 0; j < 7; j++) {
                            if (now.add(Duration(days: j)).weekday == 5) {
                              DateTime startDate = DateTime(
                                now.add(Duration(days: j)).year,
                                now.add(Duration(days: j)).month,
                                now.add(Duration(days: j)).day,
                                0,
                                0,
                                0,
                                0,
                                0,
                              );
                              DateTime endDate =
                                  startDate.add(const Duration(days: 1));
                              _openingHoursListDateTimeRange.add({
                                "day": 5,
                                "datetimerange": DateTimeRange(
                                    start: startDate, end: endDate)
                              });
                            }
                          }
                          _openingHoursList.add({
                            "day": 5,
                            "day_from": 5,
                            "day_to": 6,
                            "time_from": "00:00",
                            "time_to_duration": 1440,
                          });
                        } else {
                          _calculateOpeningHours(
                              5, matches, textInList, weekdayText);
                        }
                      }
                    }
                    if (weekdayText == 'Samstag') {
                      if (!textInList.contains("Geschlossen")) {
                        if (textInList.contains("24 Stunden geöffnet")) {
                          for (var j = 0; j < 7; j++) {
                            if (now.add(Duration(days: j)).weekday == 6) {
                              DateTime startDate = DateTime(
                                now.add(Duration(days: j)).year,
                                now.add(Duration(days: j)).month,
                                now.add(Duration(days: j)).day,
                                0,
                                0,
                                0,
                                0,
                                0,
                              );
                              DateTime endDate =
                                  startDate.add(const Duration(days: 1));
                              _openingHoursListDateTimeRange.add({
                                "day": 6,
                                "datetimerange": DateTimeRange(
                                    start: startDate, end: endDate)
                              });
                            }
                          }
                          _openingHoursList.add({
                            "day": 6,
                            "day_from": 6,
                            "day_to": 7,
                            "time_from": "00:00",
                            "time_to_duration": 1440,
                          });
                        } else {
                          _calculateOpeningHours(
                              6, matches, textInList, weekdayText);
                        }
                      }
                    }
                    if (weekdayText == 'Sonntag') {
                      if (!textInList.contains("Geschlossen")) {
                        if (textInList.contains("24 Stunden geöffnet")) {
                          for (var j = 0; j < 7; j++) {
                            if (now.add(Duration(days: j)).weekday == 7) {
                              DateTime startDate = DateTime(
                                now.add(Duration(days: j)).year,
                                now.add(Duration(days: j)).month,
                                now.add(Duration(days: j)).day,
                                0,
                                0,
                                0,
                                0,
                                0,
                              );
                              DateTime endDate =
                                  startDate.add(const Duration(days: 1));
                              _openingHoursListDateTimeRange.add({
                                "day": 7,
                                "datetimerange": DateTimeRange(
                                    start: startDate, end: endDate)
                              });
                            }
                          }
                          _openingHoursList.add({
                            "day": 7,
                            "day_from": 7,
                            "day_to": 1,
                            "time_from": "00:00",
                            "time_to_duration": 1440,
                          });
                        } else {
                          _calculateOpeningHours(
                              7, matches, textInList, weekdayText);
                        }
                      }
                    }
                  }
                }
              }
            }

            // setState(() {
            // _advertiserRegTaxIdGlobalKey.currentState!.validate();
            // _advertiserRegIbanGlobalKey.currentState!.validate();
            // _advertiserSearchStreetGlobalKey.currentState!.validate();
            // _advertiserNameGlobalKey.currentState!.validate();
            // _advertiserSearchStoreGlobalKey.currentState!.validate();
            // _advertiserNameGlobalKey.currentState!.validate();
            // _advertiserCityGlobalKey.currentState!.validate();
            // _advertiserPostcodeGlobalKey.currentState!.validate();
            // _advertiserCountryGlobalKey.currentState!.validate();
            // });
          }
        }
      }
      setState(() {});
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

  List _openingHoursList = [];

  List _openingHoursListDateTimeRange = [];
  int _firstDay = -2;

  List<String> dayStrings = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  bool _streetOrStoreIsSelected = false;

  late AnimationController _animationController;
  late AnimationController _animationControllerStorePic;

  late bool isAccountRegistrated;

  bool isInit = true;

  @override
  void initState() {
    super.initState();

    initialPage = widget.initialPage;
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

    //ADDRESS
    _searchFocus.addListener(_onSearchFocusChange);
    _nameFocus.addListener(_onNameFocusChange);
    _streetFocus.addListener(_onStreetFocusChange);
    _postcodeFocus.addListener(_onPostcodeFocusChange);
    _cityFocus.addListener(_onCityFocusChange);
    _countryFocus.addListener(_onCountryFocusChange);

    //INVOICE ADDRESS
    _invoiceFirstnameFocus.addListener(_onInvoiceFirstnameFocusChange);
    _invoiceLastnameFocus.addListener(_onInvoiceLastnameFocusChange);
    _invoiceEmailFocus.addListener(_onInvoiceEmailFocusChange);
    _invoiceStreetFocus.addListener(_onInvoiceStreetFocusChange);
    _invoicePostcodeFocus.addListener(_onInvoicePostcodeFocusChange);
    _invoiceCityFocus.addListener(_onInvoiceCityFocusChange);
    _invoiceCountryFocus.addListener(_onInvoiceCountryFocusChange);

    try {
      Provider.of<Categorys>(context, listen: false)
          .fetchAllCategorys()
          .then((_) {
        Provider.of<Subcategorys>(context, listen: false)
            .fetchAllSubcategorys()
            .then((_) {
          Provider.of<Subsubcategorys>(context, listen: false)
              .fetchAllSubsubcategorys()
              .then((_) {});
        });
      });
    } catch (e) {
      showOkAlertDialog(context: context, message: "Can not fetch data")
          .then((value) {
        if (value == OkCancelAlertDefaultType.ok) {
          Navigator.of(context).pushNamed(AuthScreen.routeName);
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (isInit) {
      isInit = false;
      if (initialPage > 0) {
        isAccountRegistrated = true;
        DateFormat formatter = DateFormat('dd.MM.yyyy');

        Provider.of<Advertiser>(context, listen: false)
            .getMe()
            .then((value) async {
          Advertiser advertiser =
              Provider.of<Advertiser>(context, listen: false).me;
          _gender = advertiser.gender;
          _emailSignUpController.text = advertiser.email!;
          _firstnameController.text =
              advertiser.firstname != null ? advertiser.firstname! : "";
          _lastnameController.text =
              advertiser.lastname != null ? advertiser.lastname! : "";
          _birthDate = advertiser.birthDate;
          if (_birthDate != null) {
            _birthDateController.text = formatter.format(_birthDate!);
          }
          // _taxIdController.text =
          //     advertiser.taxId != null ? advertiser.taxId! : "";
          // _ibanController.text =
          //     advertiser.iban != null ? advertiser.iban! : "";
          _phoneController.text =
              advertiser.phone != null ? advertiser.phone! : "";
          _crNumberController.text =
              advertiser.companyRegistrationNumber != null
                  ? advertiser.companyRegistrationNumber!
                  : "";
          _bicController.text = advertiser.bic != null ? advertiser.bic! : "";

          // if (_gender == null) {
          //   _radioColor = MaterialStateProperty.all<Color>(Colors.red);
          // } else {
          //   _radioColor = MaterialStateProperty.all<Color>(_nowNowGeneralColor);
          // }

          _pageController.jumpToPage(initialPage);

          _advertiserRegFirstnameGlobalKey.currentState!.validate();
          _advertiserRegLastnameGlobalKey.currentState!.validate();
          _advertiserRegBirthDateGlobalKey.currentState!.validate();
          _advertiserRegTaxIdGlobalKey.currentState!.validate();
        });
      }

      if (initialPage == 0) {
        isAccountRegistrated = false;
      }
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
        resizeToAvoidBottomInset: true,
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
                              await Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      duration: Duration(
                                        milliseconds: 120,
                                      ),
                                      type: PageTransitionType.leftToRight,
                                      child: AuthScreen()));
                            },
                            child: Text(
                              "Login",
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
                          _buildStoreCategoryPage(context),
                          _buildStoreDataPage(context),
                          if (!checkboxActive!)
                            _buildStoreInvoiceDataPage(context),
                          _buildSocialMediaPage(context),
                          _buildStoreOpeningHoursPage(context),
                          _buildDonePage(context),
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
                                          if (!loading) {
                                            setState(() {
                                              loading = true;
                                            });

                                            if (_currentPage == 7 &&
                                                !checkboxActive!) {
                                              await addOpeningHours();
                                            }
                                            if (_currentPage == 6 &&
                                                checkboxActive!) {
                                              await addOpeningHours();
                                            }
                                            if (_currentPage == 6 &&
                                                !checkboxActive!) {
                                              await addSocialMedia();
                                            }
                                            if (_currentPage == 5 &&
                                                checkboxActive!) {
                                              await addSocialMedia();
                                            }
                                            if (_currentPage == 5 &&
                                                !checkboxActive!) {
                                              await addInvoiceAddress();
                                            }
                                            if (_currentPage == 4) {
                                              await addStoreAddress();
                                            }
                                            if (_currentPage == 3) {
                                              await uploadImageAndCategory();
                                            }
                                            if (_currentPage == 2) {
                                              await updateOptionalPersonalDataAdvertiser();
                                            }
                                            if (_currentPage == 1) {
                                              await updatePersonalDataAdvertiser();
                                            }
                                            if (_currentPage == 0) {
                                              await _signUpAdvertiser();
                                            }

                                            setState(() {
                                              loading = false;
                                            });
                                          }
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
        bottomSheet: _bottonSheet(context),
      ),
    );
  }

  Widget? _bottonSheet(BuildContext context) {
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
            await getStarted();
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
                "Get Started",
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
            "Be an Advertiser",
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
            key: _advertiserRegPasswordGlobalKey,
            nextFocusNode: _repeatPasswordFocus,
            focusNode: _passwordRegFocus,
            textController: _passwordSignUpController,
            obscure: true,
            generalColor: _nowNowGeneralColor,
            errorBorderColor: Colors.red,
            borderColor: _nowNowBorderColor,
            icon: _passwordIcon,
            hintText: "Password",
            textInputType: TextInputType.text,
            validator: MinLengthValidator(6,
                errorText: 'Enter at least 6 Characters.'),
          ),
          _emptySpaceColumTextField,
          _formAndTextFormField(
            key: _advertiserRegRepeatPasswordGlobalKey,
            focusNode: _repeatPasswordFocus,
            textController: _repeatPasswordController,
            obscure: true,
            generalColor: _nowNowGeneralColor,
            errorBorderColor: Colors.red,
            borderColor: _nowNowBorderColor,
            icon: _passwordIcon,
            hintText: "Repeat Password",
            textInputType: TextInputType.text,
            validator: (value) =>
                MatchValidator(errorText: 'Passwords do not match.')
                    .validateMatch(value!, _passwordSignUpController.text),
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

  Widget _buildStoreCategoryPage(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    List<Category> categorys =
        Provider.of<Categorys>(context, listen: true).categorys;
    Widget _emptySpaceColum =
        SizedBox(height: MediaQuery.of(context).size.height * 0.03);
    Widget _emptySpaceColumTextField =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);

    final SizedBox _columnSpaceBetweenTextFields =
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
                'assets/images/store.png',
              ),
              height: _height * 0.18,
              width: _width * 0.7,
            ),
          ),
          Text(
            "Picture & Category of ur store",
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
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 2 / 1.5,
              height: MediaQuery.of(context).size.width / 2 / 4 * 3 / 1.5,
              child: AspectRatio(
                aspectRatio: 2 / 1.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(100),
                    ),
                    border: Border.all(
                        color: _imgBorderColor, width: _imgBorderWidth),
                  ),
                  child: InkWell(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      await _selectTakePic(context);
                    },
                    child: _imageFile != null
                        ? Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(File(_imageFile!.path))),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Platform.isAndroid
                                  ? const Icon(
                                      Icons.photo,
                                      color: Colors.black26,
                                    )
                                  : const Icon(
                                      CupertinoIcons.photo_fill,
                                      color: Colors.black26,
                                    ),
                              const Text(
                                "Picture of your Store",
                                style: TextStyle(
                                  color: Colors.black26,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
          _emptySpaceColumTextField,
          if (rubricActive == true)
            if (Platform.isAndroid)
              Center(
                child: Container(
                  child: DropdownButton<dynamic>(
                    items: categorys.map((dropDownStringItem) {
                      return DropdownMenuItem<dynamic>(
                        child: Text(dropDownStringItem.name.toString(),
                            overflow: TextOverflow.ellipsis),
                        value: dropDownStringItem.id.toString(),
                      );
                    }).toList(),
                    hint: Text(
                      "Select Category",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _rubricDropdownColor),
                    ),
                    onChanged: (dynamic newValueSelected) {
                      setState(() {
                        subsubrubricIndex = 0;
                        _selectedSubrubricId = null;
                        _selectedSubSubrubricId = null;
                        _suggestedSubrubricId = null;
                        _selectedRubricId = null;
                        _dropdownSubrubricHintText = "Select Subcategory";
                        _dropdownSubSubrubricHintText = "Select SubSubcategory";
                        _subrubricDropdownColor = null;
                        _selectedRubricId = newValueSelected;
                        subrubricActive = true;
                        _subrubricValidate = false;

                        subcategorys =
                            Provider.of<Subcategorys>(context, listen: false)
                                .findByCategoryId(_selectedRubricId!);
                      });
                    },
                    value: _selectedRubricId,
                  ),
                ),
              ),
          if (Platform.isIOS)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.05,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: _categoryBorder,
                    primary: _buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23.0),
                    ),
                  ),
                  child: Text(
                    _rubricName!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _categoryColor,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () async {
                    rubricIndex = null;
                    subrubricIndex = null;
                    setState(() {
                      _categoryBorder = null;
                      _categoryColor = Colors.white;
                    });
                    await showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return WillPopScope(
                            onWillPop: () async => false,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.39,
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.045,
                                      color: CupertinoColors.white,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              if (rubricIndex == null) {
                                                setState(() {
                                                  subsubrubricIndex = 0;
                                                  _selectedSubrubricId = null;

                                                  _selectedRubricId = null;
                                                  _selectedSubSubrubricId =
                                                      null;
                                                  rubricIndex = 0;
                                                  _selectedRubricId =
                                                      categorys[rubricIndex!]
                                                          .id;
                                                  _rubricName =
                                                      categorys[rubricIndex!]
                                                          .name;
                                                  subcategorys = Provider.of<
                                                              Subcategorys>(
                                                          context,
                                                          listen: false)
                                                      .findByCategoryId(
                                                          _selectedRubricId!);
                                                  _subrubricName =
                                                      "Select Subcategory";
                                                  _subsubrubricName =
                                                      "Select Subsubcategory";

                                                  subrubricActive = true;
                                                  _subrubricValidate = false;
                                                });

                                                Navigator.of(context).pop();
                                              } else {
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            child: const Text(
                                              "Done",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.345,
                                    color: Colors.white,
                                    child: CupertinoPicker(
                                      backgroundColor: CupertinoColors.white,
                                      itemExtent:
                                          MediaQuery.of(context).size.height *
                                              0.05,
                                      children: categorys
                                          .map(
                                            (item) => Center(
                                                child: Text(item.name,
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                          )
                                          .toList(),
                                      diameterRatio: 1.0,
                                      onSelectedItemChanged: (value) {
                                        setState(() {
                                          subsubrubricIndex = 0;
                                          _selectedSubSubrubricId = null;
                                          _subrubricValidate = false;
                                          _selectedSubrubricId = null;
                                          _selectedRubricId = null;
                                          rubricIndex = value;
                                          _selectedRubricId =
                                              categorys[rubricIndex!].id;

                                          subcategorys =
                                              Provider.of<Subcategorys>(context,
                                                      listen: false)
                                                  .findByCategoryId(
                                                      _selectedRubricId!);

                                          _rubricName =
                                              categorys[rubricIndex!].name;
                                          _subrubricName = "Select Subcategory";
                                          _subsubrubricName =
                                              "Select Subsubcategory";
                                          subrubricActive = true;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  },
                ),
              ),
            ),
          _columnSpaceBetweenTextFields,
          if (rubricActive == true)
            if (subrubricActive == true)
              Center(
                child: Platform.isAndroid
                    ? DropdownButton<dynamic>(
                        items: subcategorys.map((dropDownStringItem) {
                          return DropdownMenuItem(
                            child: Text(dropDownStringItem.name.toString(),
                                overflow: TextOverflow.ellipsis),
                            value: dropDownStringItem.id,
                          );
                        }).toList(),
                        hint: Text(
                          _dropdownSubrubricHintText,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _subrubricDropdownColor),
                        ),
                        onChanged: (dynamic newValueSelected) {
                          setState(() {
                            subsubrubricIndex = 0;
                            _suggestedSubrubricId = null;
                            _subrubricValidate = false;
                            _selectedSubSubrubricId = null;
                            _dropdownSubSubrubricHintText =
                                "Select Subsubrubric";
                            _selectedSubrubricId = newValueSelected;
                            _subrubricValidate = Provider.of<Subcategorys>(
                                    context,
                                    listen: false)
                                .findById(_selectedSubrubricId!)
                                .pickSubsubcategory;
                            subsubcategorys = Provider.of<Subsubcategorys>(
                                    context,
                                    listen: false)
                                .findBySubcategoryId(_selectedSubrubricId!);
                          });
                        },
                        value: _selectedSubrubricId,
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: _subcategoryBorder,
                            primary: _buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23.0),
                            ),
                          ),
                          child: Text(
                            _subrubricName!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: _subcategoryColor),
                          ),
                          onPressed: () async {
                            subrubricIndex = null;
                            setState(() {
                              _subcategoryBorder = null;
                              _subcategoryColor = Colors.white;
                            });
                            await showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) {
                                  return WillPopScope(
                                    onWillPop: () async => false,
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.39,
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.045,
                                              color: CupertinoColors.white,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    right:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.03),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: TextButton(
                                                    onPressed: () {
                                                      if (subrubricIndex ==
                                                          null) {
                                                        setState(() {
                                                          subsubrubricIndex = 0;
                                                          _selectedSubrubricId =
                                                              null;
                                                          _selectedSubSubrubricId =
                                                              null;
                                                          _subrubricValidate =
                                                              false;
                                                          subrubricIndex = 0;
                                                          _selectedSubrubricId =
                                                              subcategorys[
                                                                      subrubricIndex!]
                                                                  .id;
                                                          _subrubricValidate = Provider.of<
                                                                      Subcategorys>(
                                                                  context,
                                                                  listen: false)
                                                              .findById(
                                                                  _selectedSubrubricId!)
                                                              .pickSubsubcategory;
                                                          _subrubricName =
                                                              subcategorys[
                                                                      subrubricIndex!]
                                                                  .name;
                                                          subsubcategorys = Provider.of<
                                                                      Subsubcategorys>(
                                                                  context,
                                                                  listen: false)
                                                              .findBySubcategoryId(
                                                                  _selectedSubrubricId!);
                                                          _subsubrubricName =
                                                              "Select Subsubcategory";
                                                        });

                                                        Navigator.of(context)
                                                            .pop();
                                                      } else {
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    },
                                                    child: Text(
                                                      "Done",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.345,
                                            color: Colors.white,
                                            child: CupertinoPicker(
                                              backgroundColor:
                                                  CupertinoColors.white,
                                              itemExtent: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.05,
                                              children: subcategorys
                                                  .map(
                                                    (item) => Center(
                                                        child: Text(item.name,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis)),
                                                  )
                                                  .toList(),
                                              diameterRatio: 1.0,
                                              onSelectedItemChanged: (value) {
                                                setState(() {
                                                  subsubrubricIndex = 0;
                                                  _selectedSubrubricId = null;
                                                  _selectedSubrubricId = null;
                                                  _selectedSubSubrubricId =
                                                      null;
                                                  _subrubricValidate = false;
                                                  _subsubrubricName =
                                                      "Select Subsubcategory";
                                                  subrubricIndex = value;
                                                  _selectedSubrubricId =
                                                      subcategorys[
                                                              subrubricIndex!]
                                                          .id;
                                                  _subrubricValidate = Provider
                                                          .of<Subcategorys>(
                                                              context,
                                                              listen: false)
                                                      .findById(
                                                          _selectedSubrubricId!)
                                                      .pickSubsubcategory;
                                                  _subrubricName = subcategorys[
                                                          subrubricIndex!]
                                                      .name;

                                                  subsubcategorys = Provider.of<
                                                              Subsubcategorys>(
                                                          context,
                                                          listen: false)
                                                      .findBySubcategoryId(
                                                          _selectedSubrubricId!);
                                                  notFoundYourSubcategory =
                                                      "Not Found Your Subcategory?";
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                        ),
                      ),
              ), //TODO,

          if (subrubricActive == true) _emptySpaceColum,
          if (subrubricActive == true)
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23.0),
                        ),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          padding: EdgeInsets.all(9.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: TextField(
                                  maxLength: 30,
                                  controller: _subrubricSuggestion,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Subrubric suggestion'),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(23.0),
                                        ),
                                        primary:
                                            Color.fromRGBO(107, 176, 62, 1.0),
                                      ),
                                      onPressed: () async {
                                        //Create Sub rubric
                                        if (_subrubricSuggestion.text.length >
                                                30 ||
                                            _subrubricSuggestion.text.length <
                                                3) {
                                          //TODO
                                        } else {
                                          Subcategory suggestion =
                                              await Provider.of<Subcategorys>(
                                                      context,
                                                      listen: false)
                                                  .addSuggestion(Subcategory(
                                                      name: _subrubricSuggestion
                                                          .text,
                                                      categoryId:
                                                          _selectedRubricId!));
                                          setState(() {
                                            subsubrubricIndex = 0;
                                            _subrubricValidate = false;
                                            _subsubrubricName =
                                                "Select Subsubcategory";
                                            _dropdownSubSubrubricHintText =
                                                "Select Subsubcategory";
                                            _selectedSubSubrubricId = null;

                                            _selectedSubrubricId = null;
                                            _suggestedSubrubricId = null;
                                            _suggestedSubrubricId =
                                                suggestion.id;
                                            _dropdownSubrubricHintText =
                                                _subrubricSuggestion.text;
                                            _subrubricName =
                                                _subrubricSuggestion.text;
                                            _subrubricDropdownColor =
                                                Colors.black;
                                          });

                                          subrubricActive = true;
                                          rubricActive = true;

                                          // if (result.hasException) {
                                          //   hasException = true;
                                          // } else {
                                          //   Navigator.of(context).pop();
                                          //   hasException = false;
                                          // }
                                        }
                                      },
                                      child: loadingSubrubric == true
                                          ? Center(
                                              child: Platform.isAndroid
                                                  ? CircularProgressIndicator()
                                                  : CupertinoActivityIndicator(),
                                            )
                                          : Text(
                                              'Confirm',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(23.0),
                                        ),
                                        primary: Colors.red[800],
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Text(
                  notFoundYourSubcategory,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: _nowNowGeneralColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (rubricActive == true)
            if (subrubricActive == true)
              if (_selectedSubrubricId != null)
                if (_subrubricValidate == true)
                  Center(
                    child: Platform.isAndroid
                        ? DropdownButton<dynamic>(
                            items: subsubcategorys.map((dropDownStringItem) {
                              return DropdownMenuItem(
                                child: Text(dropDownStringItem.name.toString(),
                                    overflow: TextOverflow.ellipsis),
                                value: dropDownStringItem.id.toString(),
                              );
                            }).toList(),
                            hint: Text(
                              _dropdownSubSubrubricHintText,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: _subsubrubricDropdownColor),
                            ),
                            onChanged: (dynamic newValueSelected) {
                              setState(() {
                                _suggestedSubSubrubricId = null;
                                _selectedSubSubrubricId = newValueSelected;
                                print(_selectedSubSubrubricId);
                                subsubrubricIndex = 0;
                              });
                            },
                            value: _selectedSubSubrubricId,
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.height * 0.05,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                side: _subsubcategoryBorder,
                                primary: _buttonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(23.0),
                                ),
                              ),
                              child: Text(
                                _subsubrubricName!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: _subsubcategoryColor),
                              ),
                              onPressed: () async {
                                subrubricIndex = null;
                                setState(() {
                                  _subsubcategoryBorder = null;
                                  _subsubcategoryColor = Colors.white;
                                });
                                subsubrubricIndex = 0;
                                await showCupertinoModalPopup(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return WillPopScope(
                                        onWillPop: () async => false,
                                        child: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.39,
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.045,
                                                  color: CupertinoColors.white,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        right: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.03),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: TextButton(
                                                          onPressed: () {
                                                            if (subsubrubricIndex ==
                                                                0) {
                                                              setState(() {
                                                                _selectedSubSubrubricId =
                                                                    null;
                                                                _selectedSubSubrubricId =
                                                                    subsubcategorys[
                                                                            subsubrubricIndex!]
                                                                        .id;
                                                                _subsubrubricName =
                                                                    subsubcategorys[
                                                                            subsubrubricIndex!]
                                                                        .name;
                                                              });

                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            } else {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            }
                                                          },
                                                          child: Text(
                                                            "Done",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16),
                                                          )),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.345,
                                                color: Colors.white,
                                                child: CupertinoPicker(
                                                  backgroundColor:
                                                      CupertinoColors.white,
                                                  itemExtent:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.05,
                                                  children: subsubcategorys
                                                      .map(
                                                        (item) => Center(
                                                            child: Text(
                                                                item.name,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis)),
                                                      )
                                                      .toList(),
                                                  diameterRatio: 1.0,
                                                  onSelectedItemChanged:
                                                      (value) {
                                                    setState(() {
                                                      _selectedSubSubrubricId =
                                                          null;
                                                      subsubrubricIndex = value;
                                                      _selectedSubSubrubricId =
                                                          subsubcategorys[
                                                                  subsubrubricIndex!]
                                                              .id;

                                                      _subsubrubricName =
                                                          subsubcategorys[
                                                                  subsubrubricIndex!]
                                                              .name;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                            ),
                          ), //TODO,
                  ),
          if (subrubricActive == false && rubricActive == false)
            Text(_subrubricSuggestion.text),
        ],
      ),
    );
  }

  Widget _buildStoreDataPage(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    Widget _emptySpaceColum =
        SizedBox(height: MediaQuery.of(context).size.height * 0.03);
    Widget _emptySpaceColumTextField =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);

    final SizedBox _columnSpace =
        SizedBox(height: MediaQuery.of(context).size.height * 0.03);
    final SizedBox _columnSpaceBetweenTextFields =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);
    return Padding(
      padding: EdgeInsets.only(
        right: _width * 0.063,
        left: _width * 0.063,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AnimatedBuilder(
            //   animation: _animationController,
            //   builder: (context, child) => FadeScaleTransition(
            //       animation: _animationControllerStorePic, child: child),
            //   child: Visibility(
            //     visible: _animationControllerStorePic.status !=
            //         AnimationStatus.dismissed,
            // child:
            Row(
              children: [
                Image(
                    image: AssetImage(
                      'assets/images/store.png',
                    ),
                    height: _height * 0.09,
                    width: _width * 0.3),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    "Enter ur store name \nor address",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "Be a part of NowNow-Family",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: !_streetOrStoreIsSelected ? 15 : 9,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(
                    width: _width * 0.51,
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
            //   ),
            // ),
            _emptySpaceColumTextField,
            _formAndTypeAheadFormField(
              formKey: _advertiserSearchStoreGlobalKey,
              validator: (value) {
                if (this._lat == null &&
                    this._lng == null &&
                    this._countryCode == null) {
                  return "Select a suggestion";
                }
              },
              suggestionsCallback: (pattern) async {
                return await BackendServiceStore.getPlaces(pattern);
              },
              itemBuilder: (context, dynamic suggestion) {
                return SingleChildScrollView(
                  child: ListTile(
                    title: Text(suggestion['description']),
                  ),
                );
              },
              onSuggestionSelected: (dynamic suggestion) async {
                _boolStreetSgstn = true;
                await _searchStore(suggestion);
                setState(() {
                  _streetOrStoreIsSelected = true;
                });

                _animationController.forward();
                _animationControllerStorePic.reverse();
              },
              focusNode: _searchFocus,
              nextFocusNode: _nameFocus,
              textController: _searchStoreController,
              icon: _searchIcon,
              hintText: "Search your store",
            ),
            _columnSpace,
            _emptySpaceColumTextField,
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => FadeScaleTransition(
                  animation: _animationController, child: child),
              child: Visibility(
                visible:
                    _animationController.status != AnimationStatus.dismissed,
                child: _formAndTextFormFieldStore(
                  formKey: _advertiserNameGlobalKey,
                  nextFocusNode: _streetFocus,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    }
                  },
                  focusNode: _nameFocus,
                  textController: _nameController,
                  icon: _nameIcon,
                  hintText: "Name of your store",
                ),
              ),
            ),
            if (_streetOrStoreIsSelected) _columnSpaceBetweenTextFields,
            _formAndTypeAheadFormField(
              formKey: _advertiserSearchStreetGlobalKey,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Required";
                } else {
                  if (_lat == null && _lng == null && _countryCode == null) {
                    return "Select a suggested address";
                  }
                }
              },
              suggestionsCallback: (pattern) async {
                return await BackendService.getPlaces(pattern);
              },
              itemBuilder: (context, dynamic suggestion) {
                return SingleChildScrollView(
                  child: ListTile(
                    title: Text(suggestion['name']),
                  ),
                );
              },
              onSuggestionSelected: (dynamic suggestion) async {
                try {
                  _streetController.text =
                      await (suggestion['street_and_number']);

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
                      final components = result['result']['address_components']
                          as List<dynamic>;

                      components.forEach((c) {
                        final List type = c['types'];
                        if (type.contains('locality')) {
                          _cityController.text = c['long_name'];
                          if (checkboxActive!) {
                            _invoiceCityController.text =
                                _cityController.text.length > 0
                                    ? _cityController.text
                                    : "";
                          }
                        }
                        if (type.contains('postal_code')) {
                          _postCodeController.text = c['long_name'];

                          if (checkboxActive!) {
                            _invoicePostCodeController.text =
                                _postCodeController.text.length > 0
                                    ? _postCodeController.text
                                    : "";
                          }
                        }
                        if (type.contains('country')) {
                          _countryController.text = c['long_name'];
                          if (checkboxActive!) {
                            _invoiceCountryController.text =
                                _countryController.text.length > 0
                                    ? _countryController.text
                                    : "";
                          }
                        }
                        if (type.contains('political') &&
                            type.contains('country')) {
                          _countryCode = c['short_name'];

                          if (checkboxActive!) {
                            _invoiceCountryCode = _countryCode;
                          }
                        }
                      });
                    }
                  }

                  String requestLatLong =
                      '$baseUrl?place_id=$placeId&fields=geometry&key=${Enviroment.googleApiKey}';

                  Response responseLatLong = await Dio().get(requestLatLong);
                  if (responseLatLong.statusCode == 200) {
                    final result = await responseLatLong.data;
                    if (result['status'] == 'OK') {
                      final resultlatlong =
                          result['result']['geometry']['location'];
                      setState(() {
                        _lat = resultlatlong['lat'];
                        _lng = resultlatlong['lng'];
                      });

                      if (_lat != null &&
                          _lng != null &&
                          _countryCode != null) {
                        // setState(() {
                        //   _advertiserSearchStreetGlobalKey.currentState!
                        //       .validate();
                        //   _advertiserSearchStoreGlobalKey.currentState!
                        //       .validate();
                        //   _advertiserCityGlobalKey.currentState!.validate();
                        //   _advertiserPostcodeGlobalKey.currentState!.validate();
                        //   _advertiserCountryGlobalKey.currentState!.validate();
                        // });
                        _invoiceLat = _lat;
                        _invoiceLng = _lng;
                      }
                    }
                  }
                } catch (e) {
                  print(e);
                }
                setState(() {
                  _streetOrStoreIsSelected = true;
                });
                _animationController.forward();
                _animationControllerStorePic.reverse();
              },
              focusNode: _streetFocus,
              nextFocusNode: _floorFocus,
              textController: _streetController,
              icon: _nameIcon,
              hintText: "Street & Nr.",
              textInputType: TextInputType.streetAddress,
            ),
            if (_streetOrStoreIsSelected) _columnSpaceBetweenTextFields,
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => FadeScaleTransition(
                  animation: _animationController, child: child),
              child: Visibility(
                visible:
                    _animationController.status != AnimationStatus.dismissed,
                child: _formAndTextFormFieldStore(
                  formKey: _advertiserPostcodeGlobalKey,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    }
                  },
                  nextFocusNode: _cityFocus,
                  focusNode: _postcodeFocus,
                  textController: _postCodeController,
                  icon: _nameIcon,
                  hintText: "Postcode",
                ),
              ),
            ),
            if (_streetOrStoreIsSelected) _columnSpaceBetweenTextFields,
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => FadeScaleTransition(
                  animation: _animationController, child: child),
              child: Visibility(
                visible:
                    _animationController.status != AnimationStatus.dismissed,
                child: _formAndTextFormFieldStore(
                  formKey: _advertiserCityGlobalKey,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    }
                  },
                  nextFocusNode: _countryFocus,
                  focusNode: _cityFocus,
                  textController: _cityController,
                  icon: _cityIcon,
                  hintText: "City",
                ),
              ),
            ),
            if (_streetOrStoreIsSelected) _columnSpaceBetweenTextFields,
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => FadeScaleTransition(
                  animation: _animationController, child: child),
              child: Visibility(
                visible:
                    _animationController.status != AnimationStatus.dismissed,
                child: _formAndTextFormFieldStore(
                  formKey: _advertiserCountryGlobalKey,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    }
                  },
                  nextFocusNode: _ibanFocus,
                  focusNode: _countryFocus,
                  textController: _countryController,
                  icon: _countryIcon,
                  hintText: "Country",
                ),
              ),
            ),
            if (_streetOrStoreIsSelected) _columnSpaceBetweenTextFields,
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => FadeScaleTransition(
                  animation: _animationController, child: child),
              child: Visibility(
                visible:
                    _animationController.status != AnimationStatus.dismissed,
                child: _formAndTextFormField(
                    key: _advertiserRegIbanGlobalKey,
                    focusNode: _ibanFocus,
                    nextFocusNode: _taxIdFocus,
                    textController: _ibanController,
                    generalColor: _nowNowGeneralColor,
                    errorBorderColor: Colors.red,
                    borderColor: _nowNowBorderColor,
                    icon: _ibanIcon,
                    hintText: "IBAN",
                    textInputType: TextInputType.text,
                    validator: (value) {
                      if (value!.isNotEmpty) {
                        if (!isValid(value.trim())) {
                          return 'Invalid IBAN.';
                        } else {
                          return null;
                        }
                      } else {
                        return 'Required';
                      }
                    }),
              ),
            ),
            if (_streetOrStoreIsSelected) _emptySpaceColumTextField,
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => FadeScaleTransition(
                  animation: _animationController, child: child),
              child: Visibility(
                visible:
                    _animationController.status != AnimationStatus.dismissed,
                child: _formAndTextFormField(
                  key: _advertiserRegTaxIdGlobalKey,
                  focusNode: _taxIdFocus,
                  textController: _taxIdController,
                  nextFocusNode: _phoneAddressFocus,
                  generalColor: _nowNowGeneralColor,
                  errorBorderColor: Colors.red,
                  borderColor: _nowNowBorderColor,
                  icon: _taxIdIcon,
                  hintText: "VAT",
                  textInputType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Required";
                    } else {
                      if (value.length < 9) {
                        return "Invalid VAT";
                      }
                    }
                  },
                ),
              ),
            ),
            if (_streetOrStoreIsSelected) _emptySpaceColumTextField,
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => FadeScaleTransition(
                  animation: _animationController, child: child),
              child: Visibility(
                visible:
                    _animationController.status != AnimationStatus.dismissed,
                child: _formAndTextFormField(
                  focusNode: _phoneAddressFocus,
                  textController: _storePhoneController,
                  generalColor: _nowNowGeneralColor,
                  errorBorderColor: Colors.red,
                  borderColor: _nowNowBorderColor,
                  icon: _phoneIcon,
                  hintText: "Phone number of your store",
                  textInputType: TextInputType.phone,
                ),
              ),
            ),
            _emptySpaceColumTextField,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                    fillColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).primaryColor,
                    ),
                    value: checkboxActive,
                    onChanged: (bool? value) {
                      setState(() {
                        checkboxActive = value;
                      });
                      if (value!) {
                        setState(() {
                          _numPages = 8;
                        });
                      } else {
                        setState(() {
                          _numPages = 9;
                        });
                      }
                    }),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Text(
                  "Invoice Address is Address",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInvoiceDataPage(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    Widget _emptySpaceColum =
        SizedBox(height: MediaQuery.of(context).size.height * 0.03);
    Widget _emptySpaceColumTextField =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);

    final SizedBox _columnSpace =
        SizedBox(height: MediaQuery.of(context).size.height * 0.03);
    final SizedBox _columnSpaceBetweenTextFields =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);
    return Padding(
      padding: EdgeInsets.only(
        right: _width * 0.063,
        left: _width * 0.063,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image(
                    image: AssetImage(
                      'assets/images/invoice.png',
                    ),
                    height: _height * 0.09,
                    width: _width * 0.3),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    "Enter invoice address",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "Be a part of NowNow-Family",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: !_streetOrStoreIsSelected ? 15 : 9,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(
                    width: _width * 0.51,
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
            // _emptySpaceColumTextField,
            // _formAndTextFormFieldStore(
            //   formKey: _invoiceAdvertiserNameGlobalKey,
            //   validator: (value) {
            //     if (value!.isEmpty) {
            //       return "Required";
            //     }
            //   },
            //   nextFocusNode: _firstnameFocus,
            //   focusNode: _invoiceNameFocus,
            //   textController: _invoiceNameController,
            //   icon: _nameIcon,
            //   hintText: "Name of your store",
            // ),
            _columnSpaceBetweenTextFields,
            Row(
              children: [
                Radio(
                    value: "Mrs.",
                    fillColor: _invoiceRadioColor,
                    groupValue: _invoiceGender,
                    onChanged: (dynamic value) {
                      setState(() {
                        _invoiceRadioColor = _invoiceErrorRadioColor;
                        _invoiceGender = value.toString();
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
                    fillColor: _invoiceRadioColor,
                    value: "Mr.",
                    groupValue: _invoiceGender,
                    onChanged: (dynamic value) {
                      print(value);
                      setState(() {
                        _invoiceRadioColor = _invoiceErrorRadioColor;
                        _invoiceGender = value.toString();
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
                    fillColor: _invoiceRadioColor,
                    value: "Diverse",
                    groupValue: _invoiceGender,
                    onChanged: (dynamic value) {
                      print(value);
                      setState(() {
                        _invoiceRadioColor = _invoiceErrorRadioColor;
                        _invoiceGender = value.toString();
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
            _formAndTextFormFieldStore(
              formKey: _invoiceAdvertiserFirstnameGlobalKey,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Required";
                }
              },
              nextFocusNode: _invoiceLastnameFocus,
              focusNode: _invoiceFirstnameFocus,
              textController: _invoiceFirstnameController,
              icon: _firstnameIconInvoice,
              hintText: "Firstname",
            ),
            _columnSpaceBetweenTextFields,
            _formAndTextFormFieldStore(
              formKey: _invoiceAdvertiserLastnameGlobalKey,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Required";
                }
              },
              nextFocusNode: _invoiceEmailFocus,
              focusNode: _invoiceLastnameFocus,
              textController: _invoiceLastnameController,
              icon: _firstnameIconInvoice,
              hintText: "Lastname",
            ),
            _columnSpaceBetweenTextFields,
            _formAndTextFormFieldStore(
              formKey: _invoiceAdvertiserEmailGlobalKey,
              validator: _emailValidator,
              nextFocusNode: _invoiceStreetFocus,
              focusNode: _invoiceEmailFocus,
              textController: _invoiceEmailController,
              icon: _emailIconInvoice,
              hintText: "E-Mail",
              textInputType: TextInputType.emailAddress,
            ),
            _columnSpaceBetweenTextFields,
            _formAndTypeAheadFormField(
              formKey: _invoiceAdvertiserSearchStreetGlobalKey,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Required";
                } else {
                  if (_invoiceLat == null &&
                      _invoiceLng == null &&
                      _invoiceCountryCode == null) {
                    return "Select a suggested address";
                  }
                }
              },
              suggestionsCallback: (pattern) async {
                return await BackendService.getPlaces(pattern);
              },
              itemBuilder: (context, dynamic suggestion) {
                return SingleChildScrollView(
                  child: ListTile(
                    title: Text((suggestion as Map)['name']),
                  ),
                );
              },
              onSuggestionSelected: (dynamic suggestion) async {
                try {
                  _invoiceStreetController.text =
                      await (suggestion as Map)['street_and_number'];

                  String? placeId = await (suggestion['id']);

                  String baseUrl =
                      'https://maps.googleapis.com/maps/api/place/details/json';
                  String request =
                      '$baseUrl?place_id=$placeId&fields=address_component&key=${Enviroment.googleApiKey}&language=de';

                  Response response = await Dio().get(request);

                  if (response.statusCode == 200) {
                    final result = response.data;
                    if (result['status'] == 'OK') {
                      final components = result['result']['address_components']
                          as List<dynamic>;

                      components.forEach((c) {
                        final List type = c['types'];
                        if (type.contains('locality')) {
                          _invoiceCityController.text = c['long_name'];
                        }
                        if (type.contains('postal_code')) {
                          _invoicePostCodeController.text = c['long_name'];
                        }
                        if (type.contains('country')) {
                          _invoiceCountryController.text = c['long_name'];
                        }
                        if (type.contains('political') &&
                            type.contains('country')) {
                          _invoiceCountryCode = c['short_name'];
                        }
                      });
                    }
                  }

                  String requestLatLong =
                      '$baseUrl?place_id=$placeId&fields=geometry&key=${Enviroment.googleApiKey}';

                  Response responseLatLong = await Dio().get(requestLatLong);
                  if (responseLatLong.statusCode == 200) {
                    final result = await responseLatLong.data;
                    if (result['status'] == 'OK') {
                      final resultlatlong =
                          result['result']['geometry']['location'];
                      setState(() {
                        _invoiceLat = resultlatlong['lat'];
                        _invoiceLng = resultlatlong['lng'];
                      });

                      if (_invoiceLat != null &&
                          _invoiceLng != null &&
                          _invoiceCountryCode != null) {
                        setState(() {
                          _invoiceAdvertiserSearchStreetGlobalKey.currentState!
                              .validate();

                          _invoiceAdvertiserCityGlobalKey.currentState!
                              .validate();
                          _invoiceAdvertiserPostcodeGlobalKey.currentState!
                              .validate();
                          _invoiceAdvertiserCountryGlobalKey.currentState!
                              .validate();
                        });
                      }
                    }
                  }
                } catch (e) {
                  print(e);
                }
              },
              focusNode: _invoiceStreetFocus,
              nextFocusNode: _invoiceFloorFocus,
              textController: _invoiceStreetController,
              icon: _nameIcon,
              hintText: "Street & Nr.",
              textInputType: TextInputType.streetAddress,
            ),
            _columnSpaceBetweenTextFields,
            _formAndTextFormFieldStore(
              nextFocusNode: _postcodeFocus,
              focusNode: _invoiceFloorFocus,
              textController: _invoiceFloorController,
              icon: _floorIcon,
              hintText: "Floor (Optional)",
            ),
            _columnSpaceBetweenTextFields,
            _formAndTextFormFieldStore(
              formKey: _invoiceAdvertiserPostcodeGlobalKey,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Required";
                }
              },
              nextFocusNode: _invoiceCityFocus,
              focusNode: _invoicePostcodeFocus,
              textController: _invoicePostCodeController,
              icon: _nameIcon,
              hintText: "Postcode",
            ),
            _columnSpaceBetweenTextFields,
            _formAndTextFormFieldStore(
              formKey: _invoiceAdvertiserCityGlobalKey,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Required";
                }
              },
              nextFocusNode: _invoiceCountryFocus,
              focusNode: _invoiceCityFocus,
              textController: _invoiceCityController,
              icon: _cityIcon,
              hintText: "City",
            ),
            _columnSpaceBetweenTextFields,
            _formAndTextFormFieldStore(
              formKey: _invoiceAdvertiserCountryGlobalKey,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Required";
                }
              },
              nextFocusNode: _invoicePhoneFocus,
              focusNode: _invoiceCountryFocus,
              textController: _invoiceCountryController,
              icon: _countryIcon,
              hintText: "Country",
            ),
            _columnSpaceBetweenTextFields,
            _formAndTextFormFieldStore(
              formKey: _invoiceAdvertiserPhoneGlobalKey,
              focusNode: _invoicePhoneFocus,
              textController: _invoicePhoneController,
              icon: _phoneIconInvoice,
              hintText: "Phone",
            ),
            _emptySpaceColum,
          ],
        ),
      ),
    );
  }

  Widget _buildStoreOpeningHoursPage(BuildContext context) {
    DateFormat formatter = DateFormat('HH:mm');
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    List<Category> categorys =
        Provider.of<Categorys>(context, listen: true).categorys;
    Widget _emptySpaceColum =
        SizedBox(height: MediaQuery.of(context).size.height * 0.03);
    Widget _emptySpaceColumTextField =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);

    final SizedBox _columnSpaceBetweenTextFields =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);

    return SingleChildScrollView(
      child: Padding(
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
                  'assets/images/clock.png',
                ),
                height: _height * 0.18,
                width: _width * 0.7,
              ),
            ),
            Text(
              "Opening Hours of ur store",
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
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                List _filteredOpeningHoursDateTimeRange =
                    _openingHoursListDateTimeRange
                        .where((element) => element["day"] == i + 1)
                        .toList();
                List _filteredOpeningHours = _openingHoursList
                    .where((element) => element["day"] == i + 1)
                    .toList();

                return Column(
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: _height * 0.012),
                            child: Text(
                              dayStrings[i],
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontSize: 18,
                                color: _nowNowGeneralColor,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (_filteredOpeningHours.isNotEmpty)
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.05,
                                      child: RawMaterialButton(
                                        shape: CircleBorder(),
                                        fillColor: Colors.red[900],
                                        onPressed: () {
                                          setState(() {
                                            _openingHoursList.removeWhere(
                                                (element) =>
                                                    element ==
                                                    _filteredOpeningHours
                                                        .first);
                                            _openingHoursListDateTimeRange
                                                .removeWhere((element) =>
                                                    element ==
                                                    _filteredOpeningHoursDateTimeRange
                                                        .first);
                                          });
                                          if (_openingHoursList.isEmpty) {
                                            _firstDay = -2;
                                          }
                                          if (_openingHoursList.isNotEmpty) {
                                            List<int> numbers = [];
                                            _openingHoursList
                                                .forEach((element) {
                                              numbers.add(element["day"]);
                                            });
                                            if (numbers
                                                    .toSet()
                                                    .toList()
                                                    .length ==
                                                1) {
                                              _firstDay = numbers.first;
                                            }
                                          }
                                        },
                                        child: Icon(
                                          Icons.close,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  ElevatedButton.icon(
                                    icon: _filteredOpeningHours.isEmpty
                                        ? _mondayOneAddIcon
                                        : _mondayOneEditIcon,
                                    style: ElevatedButton.styleFrom(
                                      primary: _buttonColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadiusDirectional.circular(
                                                33),
                                      ),
                                    ),
                                    onPressed: () async {
                                      TimeRange? result =
                                          // Platform.isIOS
                                          //     ?
                                          await showTimeRangePicker(
                                        context: context,
                                        start:
                                            _filteredOpeningHoursDateTimeRange
                                                    .isNotEmpty
                                                ? TimeOfDay(
                                                    hour:
                                                        _filteredOpeningHoursDateTimeRange
                                                            .first[
                                                                "datetimerange"]
                                                            .start
                                                            .hour,
                                                    minute:
                                                        _filteredOpeningHoursDateTimeRange
                                                            .first[
                                                                "datetimerange"]
                                                            .start
                                                            .minute,
                                                  )
                                                : null,
                                        end: _filteredOpeningHoursDateTimeRange
                                                .isNotEmpty
                                            ? TimeOfDay(
                                                hour:
                                                    _filteredOpeningHoursDateTimeRange
                                                        .first["datetimerange"]
                                                        .end
                                                        .hour,
                                                minute:
                                                    _filteredOpeningHoursDateTimeRange
                                                        .first["datetimerange"]
                                                        .end
                                                        .minute,
                                              )
                                            : null,
                                        disabledTime:
                                            _filteredOpeningHoursDateTimeRange
                                                        .length ==
                                                    3
                                                ? TimeRange(
                                                    startTime: TimeOfDay(
                                                      hour: _filteredOpeningHoursDateTimeRange
                                                              .isNotEmpty
                                                          ? _filteredOpeningHoursDateTimeRange[
                                                                      1][
                                                                  "datetimerange"]
                                                              .start
                                                              .hour
                                                          : null,
                                                      minute: _filteredOpeningHoursDateTimeRange
                                                              .isNotEmpty
                                                          ? _filteredOpeningHoursDateTimeRange[
                                                                      1][
                                                                  "datetimerange"]
                                                              .start
                                                              .minute
                                                          : null,
                                                    ),
                                                    endTime: TimeOfDay(
                                                      hour: _filteredOpeningHoursDateTimeRange
                                                              .isNotEmpty
                                                          ? _filteredOpeningHoursDateTimeRange[
                                                                      2][
                                                                  "datetimerange"]
                                                              .end
                                                              .hour
                                                          : null,
                                                      minute: _filteredOpeningHoursDateTimeRange
                                                              .isNotEmpty
                                                          ? _filteredOpeningHoursDateTimeRange[
                                                                      2][
                                                                  "datetimerange"]
                                                              .end
                                                              .minute
                                                          : null,
                                                    ),
                                                  )
                                                : _filteredOpeningHoursDateTimeRange
                                                            .length ==
                                                        2
                                                    ? TimeRange(
                                                        startTime: TimeOfDay(
                                                          hour: _filteredOpeningHoursDateTimeRange
                                                                  .isNotEmpty
                                                              ? _filteredOpeningHoursDateTimeRange[
                                                                          1][
                                                                      "datetimerange"]
                                                                  .start
                                                                  .hour
                                                              : null,
                                                          minute: _filteredOpeningHoursDateTimeRange
                                                                  .isNotEmpty
                                                              ? _filteredOpeningHoursDateTimeRange[
                                                                          1][
                                                                      "datetimerange"]
                                                                  .start
                                                                  .minute
                                                              : null,
                                                        ),
                                                        endTime: TimeOfDay(
                                                          hour: _filteredOpeningHoursDateTimeRange
                                                                  .isNotEmpty
                                                              ? _filteredOpeningHoursDateTimeRange[
                                                                          1][
                                                                      "datetimerange"]
                                                                  .end
                                                                  .hour
                                                              : null,
                                                          minute: _filteredOpeningHoursDateTimeRange
                                                                  .isNotEmpty
                                                              ? _filteredOpeningHoursDateTimeRange[
                                                                          1][
                                                                      "datetimerange"]
                                                                  .end
                                                                  .minute
                                                              : null,
                                                        ),
                                                      )
                                                    : null,
                                        fromText: _chooseOpeningHoursFrom,
                                        toText: _chooseOpeningHoursTo,
                                        activeTimeTextStyle: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30),
                                        timeTextStyle: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 23),
                                        selectedColor:
                                            Theme.of(context).accentColor,
                                        use24HourFormat: true,
                                        interval: Duration(minutes: _timeSteps),
                                        ticks: _ticks,
                                      );
                                      // : await showCupertinoDialog(
                                      //     barrierDismissible: true,
                                      //     context: context,
                                      //     builder: (BuildContext context) {
                                      //       TimeOfDay _startTime =
                                      //           TimeOfDay.now();
                                      //       TimeOfDay _endTime =
                                      //           TimeOfDay.now();
                                      //       return CupertinoAlertDialog(
                                      //         content: Container(
                                      //           width:
                                      //               MediaQuery.of(context)
                                      //                   .size
                                      //                   .width,
                                      //           height: _height * 0.4153,
                                      //           child: Column(
                                      //             children: [
                                      //               TimeRangePicker(
                                      //                 start:
                                      //                     _filteredOpeningHoursDateTimeRange
                                      //                             .isNotEmpty
                                      //                         ? TimeOfDay(
                                      //                             hour: _filteredOpeningHoursDateTimeRange
                                      //                                 .first[
                                      //                                     "datetimerange"]
                                      //                                 .start
                                      //                                 .hour,
                                      //                             minute: _filteredOpeningHoursDateTimeRange
                                      //                                 .first[
                                      //                                     "datetimerange"]
                                      //                                 .start
                                      //                                 .minute,
                                      //                           )
                                      //                         : null,
                                      //                 end: _filteredOpeningHoursDateTimeRange
                                      //                         .isNotEmpty
                                      //                     ? TimeOfDay(
                                      //                         hour: _filteredOpeningHoursDateTimeRange
                                      //                             .first[
                                      //                                 "datetimerange"]
                                      //                             .end
                                      //                             .hour,
                                      //                         minute: _filteredOpeningHoursDateTimeRange
                                      //                             .first[
                                      //                                 "datetimerange"]
                                      //                             .end
                                      //                             .minute,
                                      //                       )
                                      //                     : null,
                                      //                 disabledTime: _filteredOpeningHoursDateTimeRange
                                      //                             .length ==
                                      //                         3
                                      //                     ? TimeRange(
                                      //                         startTime:
                                      //                             TimeOfDay(
                                      //                           hour: _filteredOpeningHoursDateTimeRange
                                      //                                   .isNotEmpty
                                      //                               ? _filteredOpeningHoursDateTimeRange[1]["datetimerange"]
                                      //                                   .start
                                      //                                   .hour
                                      //                               : null,
                                      //                           minute: _filteredOpeningHoursDateTimeRange
                                      //                                   .isNotEmpty
                                      //                               ? _filteredOpeningHoursDateTimeRange[1]["datetimerange"]
                                      //                                   .start
                                      //                                   .minute
                                      //                               : null,
                                      //                         ),
                                      //                         endTime:
                                      //                             TimeOfDay(
                                      //                           hour: _filteredOpeningHoursDateTimeRange
                                      //                                   .isNotEmpty
                                      //                               ? _filteredOpeningHoursDateTimeRange[2]["datetimerange"]
                                      //                                   .end
                                      //                                   .hour
                                      //                               : null,
                                      //                           minute: _filteredOpeningHoursDateTimeRange
                                      //                                   .isNotEmpty
                                      //                               ? _filteredOpeningHoursDateTimeRange[2]["datetimerange"]
                                      //                                   .end
                                      //                                   .minute
                                      //                               : null,
                                      //                         ),
                                      //                       )
                                      //                     : _filteredOpeningHoursDateTimeRange
                                      //                                 .length ==
                                      //                             2
                                      //                         ? TimeRange(
                                      //                             startTime:
                                      //                                 TimeOfDay(
                                      //                               hour: _filteredOpeningHoursDateTimeRange.isNotEmpty
                                      //                                   ? _filteredOpeningHoursDateTimeRange[1]["datetimerange"].start.hour
                                      //                                   : null,
                                      //                               minute: _filteredOpeningHoursDateTimeRange.isNotEmpty
                                      //                                   ? _filteredOpeningHoursDateTimeRange[1]["datetimerange"].start.minute
                                      //                                   : null,
                                      //                             ),
                                      //                             endTime:
                                      //                                 TimeOfDay(
                                      //                               hour: _filteredOpeningHoursDateTimeRange.isNotEmpty
                                      //                                   ? _filteredOpeningHoursDateTimeRange[1]["datetimerange"].end.hour
                                      //                                   : null,
                                      //                               minute: _filteredOpeningHoursDateTimeRange.isNotEmpty
                                      //                                   ? _filteredOpeningHoursDateTimeRange[1]["datetimerange"].end.minute
                                      //                                   : null,
                                      //                             ),
                                      //                           )
                                      //                         : null,
                                      //                 fromText:
                                      //                     _chooseOpeningHoursFrom,
                                      //                 toText:
                                      //                     _chooseOpeningHoursTo,
                                      //                 activeTimeTextStyle:
                                      //                     TextStyle(
                                      //                         color: Colors
                                      //                             .white,
                                      //                         fontWeight:
                                      //                             FontWeight
                                      //                                 .bold,
                                      //                         fontSize: 30),
                                      //                 timeTextStyle:
                                      //                     TextStyle(
                                      //                         color: Colors
                                      //                             .white,
                                      //                         fontWeight:
                                      //                             FontWeight
                                      //                                 .bold,
                                      //                         fontSize: 23),
                                      //                 selectedColor:
                                      //                     Theme.of(context)
                                      //                         .accentColor,
                                      //                 use24HourFormat: true,
                                      //                 interval: Duration(
                                      //                     minutes:
                                      //                         _timeSteps),
                                      //                 ticks: _ticks,
                                      //                 hideButtons: true,
                                      //                 padding:
                                      //                     _height * 0.021,
                                      //               ),
                                      //             ],
                                      //           ),
                                      //         ),
                                      //         actions: <Widget>[
                                      //           CupertinoDialogAction(
                                      //               child: Text('Cancel',
                                      //                   style: TextStyle(
                                      //                       color: CupertinoColors
                                      //                           .systemRed)),
                                      //               onPressed: () {
                                      //                 Navigator.of(context)
                                      //                     .pop();
                                      //               }),
                                      //           CupertinoDialogAction(
                                      //             child: Text('Ok',
                                      //                 style: TextStyle(
                                      //                     color: Theme.of(
                                      //                             context)
                                      //                         .primaryColor)),
                                      //             onPressed: () {
                                      //               Navigator.of(context)
                                      //                   .pop(
                                      //                 TimeRange(
                                      //                     startTime:
                                      //                         _startTime,
                                      //                     endTime:
                                      //                         _endTime),
                                      //               );
                                      //             },
                                      //           ),
                                      //         ],
                                      //       );
                                      //     },
                                      //   );

                                      if (result != null) {
                                        DateTime now =
                                            DateTime(2022, 1, 3, 0, 0, 0, 0, 0);
                                        DateTime? begin;
                                        DateTime? end;
                                        if (_firstDay == -2) {
                                          _firstDay = i + 1;
                                        }
                                        if (_firstDay != i + 1) {
                                          _firstDay = -3;
                                        }
                                        for (var j = 0; j < 7; j++) {
                                          if (now
                                                  .add(Duration(days: j))
                                                  .weekday ==
                                              i + 1) {
                                            begin = DateTime(
                                              now.add(Duration(days: j)).year,
                                              now.add(Duration(days: j)).month,
                                              now.add(Duration(days: j)).day,
                                              result.startTime.hour,
                                              result.startTime.minute,
                                              0,
                                              0,
                                              0,
                                            );

                                            end = DateTime(
                                              now.add(Duration(days: j)).year,
                                              now.add(Duration(days: j)).month,
                                              now.add(Duration(days: j)).day,
                                              result.endTime.hour,
                                              result.endTime.minute,
                                              0,
                                              0,
                                              0,
                                            );
                                            if (end.isBefore(begin)) {
                                              end = end.add(Duration(days: 1));
                                            }
                                            if (begin.isAtSameMomentAs(end)) {
                                              end = end.add(Duration(days: 1));
                                            }
                                          }
                                        }

                                        int lengthOfOpeningHours =
                                            _filteredOpeningHours.length;

                                        if (lengthOfOpeningHours == 0) {
                                          bool wasInside = false;
                                          int? weekdayBefore;
                                          int? weekdayAfter;
                                          for (var k = 0;
                                              k < _openingHoursList.length;
                                              k++) {
                                            if (_openingHoursList[k]["day"] <
                                                i + 1) {
                                              weekdayBefore = k;
                                            }
                                            if (!wasInside) {
                                              if (_openingHoursList[k]["day"] >
                                                  i + 1) {
                                                wasInside = true;
                                                weekdayAfter = k;
                                              }
                                            }
                                          }
                                          if (weekdayBefore != null &&
                                              weekdayAfter != null) {
                                            _openingHoursList
                                                .insert(weekdayAfter, {
                                              "day": i + 1,
                                              "day_from": begin!.weekday,
                                              "day_to": end!.weekday,
                                              "time_from": formatTimeOfDay(
                                                  TimeOfDay(
                                                      hour: begin.hour,
                                                      minute: begin.minute)),
                                              "time_to_duration": end
                                                  .difference(begin)
                                                  .inMinutes,
                                            });
                                            _openingHoursListDateTimeRange
                                                .insert(weekdayAfter, {
                                              "day": i + 1,
                                              "datetimerange": DateTimeRange(
                                                  start: begin, end: end)
                                            });
                                          }
                                          if (weekdayBefore == null &&
                                              weekdayAfter != null) {
                                            _openingHoursList
                                                .insert(weekdayAfter, {
                                              "day": i + 1,
                                              "day_from": begin!.weekday,
                                              "day_to": end!.weekday,
                                              "time_from": formatTimeOfDay(
                                                  TimeOfDay(
                                                      hour: begin.hour,
                                                      minute: begin.minute)),
                                              "time_to_duration": end
                                                  .difference(begin)
                                                  .inMinutes,
                                            });
                                            _openingHoursListDateTimeRange
                                                .insert(weekdayAfter, {
                                              "day": i + 1,
                                              "datetimerange": DateTimeRange(
                                                  start: begin, end: end)
                                            });
                                          }
                                          if (weekdayBefore != null &&
                                              weekdayAfter == null) {
                                            _openingHoursList.add({
                                              "day": i + 1,
                                              "day_from": begin!.weekday,
                                              "day_to": end!.weekday,
                                              "time_from": formatTimeOfDay(
                                                  TimeOfDay(
                                                      hour: begin.hour,
                                                      minute: begin.minute)),
                                              "time_to_duration": end
                                                  .difference(begin)
                                                  .inMinutes,
                                            });
                                            _openingHoursListDateTimeRange.add({
                                              "day": i + 1,
                                              "datetimerange": DateTimeRange(
                                                  start: begin, end: end)
                                            });
                                          }
                                          if (weekdayBefore == null &&
                                              weekdayAfter == null) {
                                            _openingHoursList.add({
                                              "day": i + 1,
                                              "day_from": begin!.weekday,
                                              "day_to": end!.weekday,
                                              "time_from": formatTimeOfDay(
                                                  TimeOfDay(
                                                      hour: begin.hour,
                                                      minute: begin.minute)),
                                              "time_to_duration": end
                                                  .difference(begin)
                                                  .inMinutes,
                                            });
                                            _openingHoursListDateTimeRange.add({
                                              "day": i + 1,
                                              "datetimerange": DateTimeRange(
                                                  start: begin, end: end)
                                            });
                                          }
                                        } else {
                                          int deletedObjectIndex =
                                              _openingHoursList.indexOf(
                                                  _filteredOpeningHours.first);
                                          _openingHoursList
                                              .removeAt(deletedObjectIndex);
                                          _openingHoursList
                                              .insert(deletedObjectIndex, {
                                            "day": i + 1,
                                            "day_from": begin!.weekday,
                                            "day_to": end!.weekday,
                                            "time_from": formatTimeOfDay(
                                                TimeOfDay(
                                                    hour: begin.hour,
                                                    minute: begin.minute)),
                                            "time_to_duration":
                                                end.difference(begin).inMinutes,
                                          });

                                          _openingHoursListDateTimeRange
                                              .removeAt(deletedObjectIndex);
                                          _openingHoursListDateTimeRange
                                              .insert(deletedObjectIndex, {
                                            "day": i + 1,
                                            "datetimerange": DateTimeRange(
                                                start: begin, end: end),
                                          });
                                        }
                                        print(_openingHoursListDateTimeRange);
                                        print(_openingHoursList);
                                        setState(() {});
                                      }
                                    },
                                    label: Text(_filteredOpeningHoursDateTimeRange
                                            .isNotEmpty
                                        ? "${formatter.format(_filteredOpeningHoursDateTimeRange.first["datetimerange"].start)}:${formatter.format(_filteredOpeningHoursDateTimeRange.first["datetimerange"].end)}"
                                        : _chooseOpeningHoursButtonTextMonday),
                                  ),
                                ],
                              ),
                              //SECOND
                              if (_filteredOpeningHours.length > 0)
                                if (_filteredOpeningHoursDateTimeRange
                                        .first["datetimerange"]
                                        .duration
                                        .inMinutes <
                                    1440)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (_filteredOpeningHours.length > 1)
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                          child: RawMaterialButton(
                                            shape: CircleBorder(),
                                            fillColor: Colors.red[900],
                                            onPressed: () {
                                              setState(() {
                                                _openingHoursList.removeWhere(
                                                    (element) =>
                                                        element ==
                                                        _filteredOpeningHours[
                                                            1]);
                                                _openingHoursListDateTimeRange
                                                    .removeWhere((element) =>
                                                        element ==
                                                        _filteredOpeningHoursDateTimeRange[
                                                            1]);
                                              });
                                            },
                                            child: Icon(
                                              Icons.close,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.03,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left:
                                              _filteredOpeningHours.length == 1
                                                  ? _width * 0.051
                                                  : 0,
                                        ),
                                        child: ElevatedButton.icon(
                                          icon:
                                              _filteredOpeningHours.length == 1
                                                  ? _mondayOneAddIcon
                                                  : _mondayOneEditIcon,
                                          style: ElevatedButton.styleFrom(
                                            primary: _buttonColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadiusDirectional
                                                      .circular(33),
                                            ),
                                          ),
                                          onPressed: () async {
                                            TimeRange? result =
                                                // Platform.isIOS
                                                //     ?
                                                await showTimeRangePicker(
                                              context: context,
                                              start:
                                                  _filteredOpeningHoursDateTimeRange
                                                              .length >
                                                          1
                                                      ? TimeOfDay(
                                                          hour: _filteredOpeningHoursDateTimeRange[
                                                                      1][
                                                                  "datetimerange"]
                                                              .start
                                                              .hour,
                                                          minute: _filteredOpeningHoursDateTimeRange[
                                                                      1][
                                                                  "datetimerange"]
                                                              .start
                                                              .minute,
                                                        )
                                                      : TimeOfDay(
                                                          hour: _filteredOpeningHoursDateTimeRange[
                                                                      0][
                                                                  "datetimerange"]
                                                              .end
                                                              .hour,
                                                          minute: _filteredOpeningHoursDateTimeRange[
                                                                      0][
                                                                  "datetimerange"]
                                                              .end
                                                              .minute,
                                                        ),
                                              end:
                                                  _filteredOpeningHoursDateTimeRange
                                                              .length >
                                                          1
                                                      ? TimeOfDay(
                                                          hour: _filteredOpeningHoursDateTimeRange[
                                                                      1][
                                                                  "datetimerange"]
                                                              .end
                                                              .hour,
                                                          minute: _filteredOpeningHoursDateTimeRange[
                                                                      1][
                                                                  "datetimerange"]
                                                              .end
                                                              .minute,
                                                        )
                                                      : TimeOfDay(
                                                          hour: _filteredOpeningHoursDateTimeRange[
                                                                      0][
                                                                  "datetimerange"]
                                                              .end
                                                              .add(Duration(
                                                                  minutes: 15))
                                                              .hour,
                                                          minute: _filteredOpeningHoursDateTimeRange[
                                                                      0][
                                                                  "datetimerange"]
                                                              .end
                                                              .add(Duration(
                                                                  minutes: 15))
                                                              .minute,
                                                        ),
                                              disabledTime:
                                                  _filteredOpeningHoursDateTimeRange
                                                              .length ==
                                                          3
                                                      ? TimeRange(
                                                          startTime: TimeOfDay(
                                                            hour: _filteredOpeningHoursDateTimeRange
                                                                    .isNotEmpty
                                                                ? _filteredOpeningHoursDateTimeRange[
                                                                            2][
                                                                        "datetimerange"]
                                                                    .start
                                                                    .hour
                                                                : null,
                                                            minute: _filteredOpeningHoursDateTimeRange
                                                                    .isNotEmpty
                                                                ? _filteredOpeningHoursDateTimeRange[
                                                                            2][
                                                                        "datetimerange"]
                                                                    .start
                                                                    .minute
                                                                : null,
                                                          ),
                                                          endTime: TimeOfDay(
                                                            hour: _filteredOpeningHoursDateTimeRange
                                                                    .isNotEmpty
                                                                ? _filteredOpeningHoursDateTimeRange[
                                                                            0][
                                                                        "datetimerange"]
                                                                    .end
                                                                    .hour
                                                                : null,
                                                            minute: _filteredOpeningHoursDateTimeRange
                                                                    .isNotEmpty
                                                                ? _filteredOpeningHoursDateTimeRange[
                                                                            0][
                                                                        "datetimerange"]
                                                                    .end
                                                                    .minute
                                                                : null,
                                                          ),
                                                        )
                                                      : TimeRange(
                                                          startTime: TimeOfDay(
                                                            hour: _filteredOpeningHoursDateTimeRange[
                                                                        0][
                                                                    "datetimerange"]
                                                                .start
                                                                .hour,
                                                            minute: _filteredOpeningHoursDateTimeRange[
                                                                        0][
                                                                    "datetimerange"]
                                                                .start
                                                                .minute,
                                                          ),
                                                          endTime: TimeOfDay(
                                                            hour: _filteredOpeningHoursDateTimeRange[
                                                                        0][
                                                                    "datetimerange"]
                                                                .end
                                                                .hour,
                                                            minute: _filteredOpeningHoursDateTimeRange[
                                                                        0][
                                                                    "datetimerange"]
                                                                .end
                                                                .minute,
                                                          ),
                                                        ),
                                              fromText: _chooseOpeningHoursFrom,
                                              toText: _chooseOpeningHoursTo,
                                              activeTimeTextStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 30),
                                              timeTextStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 23),
                                              selectedColor:
                                                  Theme.of(context).accentColor,
                                              use24HourFormat: true,
                                              interval:
                                                  Duration(minutes: _timeSteps),
                                              ticks: _ticks,
                                            );
                                            // : await showCupertinoDialog(
                                            //     barrierDismissible: true,
                                            //     context: context,
                                            //     builder: (BuildContext context) {
                                            //       TimeOfDay _startTime = TimeOfDay.now();
                                            //       TimeOfDay _endTime = TimeOfDay.now();
                                            //       return CupertinoAlertDialog(
                                            //         content: Container(
                                            //           width: MediaQuery.of(context)
                                            //               .size
                                            //               .width,
                                            //           height: _height * 0.4153,
                                            //           child: Column(
                                            //             children: [
                                            //               TimeRangePicker(
                                            //                 start:
                                            //                     _filteredOpeningHoursDateTimeRange
                                            //                             .isNotEmpty
                                            //                         ? TimeOfDay(
                                            //                             hour: _filteredOpeningHoursDateTimeRange
                                            //                                 .first[
                                            //                                     "datetimerange"]
                                            //                                 .start
                                            //                                 .hour,
                                            //                             minute: _filteredOpeningHoursDateTimeRange
                                            //                                 .first[
                                            //                                     "datetimerange"]
                                            //                                 .start
                                            //                                 .minute,
                                            //                           )
                                            //                         : null,
                                            //                 end:
                                            //                     _filteredOpeningHoursDateTimeRange
                                            //                             .isNotEmpty
                                            //                         ? TimeOfDay(
                                            //                             hour: _filteredOpeningHoursDateTimeRange
                                            //                                 .first[
                                            //                                     "datetimerange"]
                                            //                                 .end
                                            //                                 .hour,
                                            //                             minute: _filteredOpeningHoursDateTimeRange
                                            //                                 .first[
                                            //                                     "datetimerange"]
                                            //                                 .end
                                            //                                 .minute,
                                            //                           )
                                            //                         : null,
                                            //                 disabledTime:
                                            //                     _filteredOpeningHoursDateTimeRange
                                            //                                 .length ==
                                            //                             3
                                            //                         ? TimeRange(
                                            //                             startTime:
                                            //                                 TimeOfDay(
                                            //                               hour: _filteredOpeningHoursDateTimeRange
                                            //                                       .isNotEmpty
                                            //                                   ? _filteredOpeningHoursDateTimeRange[1]
                                            //                                           [
                                            //                                           "datetimerange"]
                                            //                                       .start
                                            //                                       .hour
                                            //                                   : null,
                                            //                               minute: _filteredOpeningHoursDateTimeRange
                                            //                                       .isNotEmpty
                                            //                                   ? _filteredOpeningHoursDateTimeRange[1]
                                            //                                           [
                                            //                                           "datetimerange"]
                                            //                                       .start
                                            //                                       .minute
                                            //                                   : null,
                                            //                             ),
                                            //                             endTime:
                                            //                                 TimeOfDay(
                                            //                               hour: _filteredOpeningHoursDateTimeRange
                                            //                                       .isNotEmpty
                                            //                                   ? _filteredOpeningHoursDateTimeRange[2]
                                            //                                           [
                                            //                                           "datetimerange"]
                                            //                                       .end
                                            //                                       .hour
                                            //                                   : null,
                                            //                               minute: _filteredOpeningHoursDateTimeRange
                                            //                                       .isNotEmpty
                                            //                                   ? _filteredOpeningHoursDateTimeRange[2]
                                            //                                           [
                                            //                                           "datetimerange"]
                                            //                                       .end
                                            //                                       .minute
                                            //                                   : null,
                                            //                             ),
                                            //                           )
                                            //                         : _filteredOpeningHoursDateTimeRange
                                            //                                     .length ==
                                            //                                 2
                                            //                             ? TimeRange(
                                            //                                 startTime:
                                            //                                     TimeOfDay(
                                            //                                   hour: _filteredOpeningHoursDateTimeRange
                                            //                                           .isNotEmpty
                                            //                                       ? _filteredOpeningHoursDateTimeRange[1]["datetimerange"]
                                            //                                           .start
                                            //                                           .hour
                                            //                                       : null,
                                            //                                   minute: _filteredOpeningHoursDateTimeRange
                                            //                                           .isNotEmpty
                                            //                                       ? _filteredOpeningHoursDateTimeRange[1]["datetimerange"]
                                            //                                           .start
                                            //                                           .minute
                                            //                                       : null,
                                            //                                 ),
                                            //                                 endTime:
                                            //                                     TimeOfDay(
                                            //                                   hour: _filteredOpeningHoursDateTimeRange
                                            //                                           .isNotEmpty
                                            //                                       ? _filteredOpeningHoursDateTimeRange[1]["datetimerange"]
                                            //                                           .end
                                            //                                           .hour
                                            //                                       : null,
                                            //                                   minute: _filteredOpeningHoursDateTimeRange
                                            //                                           .isNotEmpty
                                            //                                       ? _filteredOpeningHoursDateTimeRange[1]["datetimerange"]
                                            //                                           .end
                                            //                                           .minute
                                            //                                       : null,
                                            //                                 ),
                                            //                               )
                                            //                             : null,
                                            //                 fromText:
                                            //                     _chooseOpeningHoursFrom,
                                            //                 toText: _chooseOpeningHoursTo,
                                            //                 activeTimeTextStyle:
                                            //                     TextStyle(
                                            //                         color: Colors.white,
                                            //                         fontWeight:
                                            //                             FontWeight.bold,
                                            //                         fontSize: 30),
                                            //                 timeTextStyle: TextStyle(
                                            //                     color: Colors.white,
                                            //                     fontWeight:
                                            //                         FontWeight.bold,
                                            //                     fontSize: 23),
                                            //                 selectedColor:
                                            //                     Theme.of(context)
                                            //                         .accentColor,
                                            //                 use24HourFormat: true,
                                            //                 interval: Duration(
                                            //                     minutes: _timeSteps),
                                            //                 ticks: _ticks,
                                            //                 hideButtons: true,
                                            //                 padding: _height * 0.021,
                                            //               ),
                                            //             ],
                                            //           ),
                                            //         ),
                                            //         actions: <Widget>[
                                            //           CupertinoDialogAction(
                                            //               child: Text('Cancel',
                                            //                   style: TextStyle(
                                            //                       color: CupertinoColors
                                            //                           .systemRed)),
                                            //               onPressed: () {
                                            //                 Navigator.of(context).pop();
                                            //               }),
                                            //           CupertinoDialogAction(
                                            //             child: Text('Ok',
                                            //                 style: TextStyle(
                                            //                     color: Theme.of(context)
                                            //                         .primaryColor)),
                                            //             onPressed: () {
                                            //               Navigator.of(context).pop(
                                            //                 TimeRange(
                                            //                     startTime: _startTime,
                                            //                     endTime: _endTime),
                                            //               );
                                            //             },
                                            //           ),
                                            //         ],
                                            //       );
                                            //     },
                                            //   );

                                            if (result != null) {
                                              DateTime now = DateTime(
                                                  2022, 1, 3, 0, 0, 0, 0, 0);
                                              DateTime? begin;
                                              DateTime? end;
                                              print(result);
                                              for (var j = 0; j < 7; j++) {
                                                if (now
                                                        .add(Duration(days: j))
                                                        .weekday ==
                                                    i + 1) {
                                                  begin = DateTime(
                                                    now
                                                        .add(Duration(days: j))
                                                        .year,
                                                    now
                                                        .add(Duration(days: j))
                                                        .month,
                                                    now
                                                        .add(Duration(days: j))
                                                        .day,
                                                    result.startTime.hour,
                                                    result.startTime.minute,
                                                    0,
                                                    0,
                                                    0,
                                                  );

                                                  end = DateTime(
                                                    now
                                                        .add(Duration(days: j))
                                                        .year,
                                                    now
                                                        .add(Duration(days: j))
                                                        .month,
                                                    now
                                                        .add(Duration(days: j))
                                                        .day,
                                                    result.endTime.hour,
                                                    result.endTime.minute,
                                                    0,
                                                    0,
                                                    0,
                                                  );
                                                  if (end.isBefore(begin)) {
                                                    end = end
                                                        .add(Duration(days: 1));
                                                  }
                                                }
                                              }
                                              DateTimeRange _dayBefore =
                                                  _filteredOpeningHoursDateTimeRange
                                                      .first["datetimerange"];
                                              if (_dayBefore.start
                                                  .isAfter(begin!)) {
                                                begin = begin
                                                    .add(Duration(days: 1));
                                                end =
                                                    end!.add(Duration(days: 1));
                                              }

                                              if (_filteredOpeningHours.length >
                                                  1) {
                                                int deletedObjectIndex =
                                                    _openingHoursList.indexOf(
                                                        _filteredOpeningHours[
                                                            1]);
                                                _openingHoursList.removeAt(
                                                    deletedObjectIndex);
                                                _openingHoursList.insert(
                                                    deletedObjectIndex, {
                                                  "day": i + 1,
                                                  "day_from": begin.weekday,
                                                  "day_to": end!.weekday,
                                                  "time_from": formatTimeOfDay(
                                                      TimeOfDay(
                                                          hour: begin.hour,
                                                          minute:
                                                              begin.minute)),
                                                  "time_to_duration": end
                                                      .difference(begin)
                                                      .inMinutes,
                                                });

                                                _openingHoursListDateTimeRange
                                                    .removeAt(
                                                        deletedObjectIndex);
                                                _openingHoursListDateTimeRange
                                                    .insert(
                                                        deletedObjectIndex, {
                                                  "day": i + 1,
                                                  "datetimerange":
                                                      DateTimeRange(
                                                          start: begin,
                                                          end: end),
                                                });
                                              } else {
                                                int getFirstIndex =
                                                    _openingHoursList.indexOf(
                                                        _filteredOpeningHours
                                                            .first);
                                                _openingHoursList
                                                    .insert(getFirstIndex + 1, {
                                                  "day": i + 1,
                                                  "day_from": begin.weekday,
                                                  "day_to": end!.weekday,
                                                  "time_from": formatTimeOfDay(
                                                      TimeOfDay(
                                                          hour: begin.hour,
                                                          minute:
                                                              begin.minute)),
                                                  "time_to_duration": end
                                                      .difference(begin)
                                                      .inMinutes,
                                                });

                                                _openingHoursListDateTimeRange
                                                    .insert(getFirstIndex + 1, {
                                                  "day": i + 1,
                                                  "datetimerange":
                                                      DateTimeRange(
                                                          start: begin,
                                                          end: end),
                                                });
                                              }
                                            }
                                            print(
                                                _openingHoursListDateTimeRange);
                                            print(_openingHoursList);
                                            setState(() {});
                                          },
                                          label: Text(
                                              _filteredOpeningHoursDateTimeRange
                                                          .length >
                                                      1
                                                  ? "${formatter.format(_filteredOpeningHoursDateTimeRange[1]["datetimerange"].start)}:${formatter.format(_filteredOpeningHoursDateTimeRange[1]["datetimerange"].end)}"
                                                  : _addMoreOpeningHoursMondayTwo),
                                        ),
                                      ),
                                    ],
                                  ),

                              //THIRD
                              if (_filteredOpeningHours.length > 1)
                                if (_filteredOpeningHoursDateTimeRange[1]
                                            ["datetimerange"]
                                        .end
                                        .difference(
                                            _filteredOpeningHoursDateTimeRange
                                                .first["datetimerange"].start)
                                        .inMinutes <
                                    1440)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (_filteredOpeningHours.length > 2)
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                          child: RawMaterialButton(
                                            shape: CircleBorder(),
                                            fillColor: Colors.red[900],
                                            onPressed: () {
                                              setState(() {
                                                _openingHoursList.removeWhere(
                                                    (element) =>
                                                        element ==
                                                        _filteredOpeningHours
                                                            .last);
                                                _openingHoursListDateTimeRange
                                                    .removeWhere((element) =>
                                                        element ==
                                                        _filteredOpeningHoursDateTimeRange
                                                            .last);
                                              });
                                            },
                                            child: Icon(
                                              Icons.close,
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.03,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left:
                                                _filteredOpeningHours.length ==
                                                        2
                                                    ? _width * 0.051
                                                    : 0),
                                        child: ElevatedButton.icon(
                                          icon:
                                              _filteredOpeningHours.length == 2
                                                  ? _mondayOneAddIcon
                                                  : _mondayOneEditIcon,
                                          style: ElevatedButton.styleFrom(
                                            primary: _buttonColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadiusDirectional
                                                      .circular(33),
                                            ),
                                          ),
                                          onPressed: () async {
                                            TimeRange? result =
                                                // Platform.isIOS
                                                //     ?
                                                await showTimeRangePicker(
                                              context: context,
                                              start:
                                                  _filteredOpeningHoursDateTimeRange
                                                              .length >
                                                          2
                                                      ? TimeOfDay(
                                                          hour: _filteredOpeningHoursDateTimeRange[
                                                                      2][
                                                                  "datetimerange"]
                                                              .start
                                                              .hour,
                                                          minute: _filteredOpeningHoursDateTimeRange[
                                                                      2][
                                                                  "datetimerange"]
                                                              .start
                                                              .minute,
                                                        )
                                                      : TimeOfDay(
                                                          hour: _filteredOpeningHoursDateTimeRange[
                                                                      1][
                                                                  "datetimerange"]
                                                              .end
                                                              .hour,
                                                          minute: _filteredOpeningHoursDateTimeRange[
                                                                      1][
                                                                  "datetimerange"]
                                                              .end
                                                              .minute,
                                                        ),
                                              end:
                                                  _filteredOpeningHoursDateTimeRange
                                                              .length >
                                                          2
                                                      ? TimeOfDay(
                                                          hour: _filteredOpeningHoursDateTimeRange[
                                                                      2][
                                                                  "datetimerange"]
                                                              .end
                                                              .hour,
                                                          minute: _filteredOpeningHoursDateTimeRange[
                                                                      2][
                                                                  "datetimerange"]
                                                              .end
                                                              .minute,
                                                        )
                                                      : TimeOfDay(
                                                          hour: _filteredOpeningHoursDateTimeRange[
                                                                      1][
                                                                  "datetimerange"]
                                                              .end
                                                              .add(Duration(
                                                                  minutes: 15))
                                                              .hour,
                                                          minute: _filteredOpeningHoursDateTimeRange[
                                                                      1][
                                                                  "datetimerange"]
                                                              .end
                                                              .add(Duration(
                                                                  minutes: 15))
                                                              .minute,
                                                        ),
                                              disabledTime: TimeRange(
                                                startTime: TimeOfDay(
                                                  hour: _filteredOpeningHoursDateTimeRange
                                                          .isNotEmpty
                                                      ? _filteredOpeningHoursDateTimeRange[
                                                                  0]
                                                              ["datetimerange"]
                                                          .start
                                                          .hour
                                                      : null,
                                                  minute: _filteredOpeningHoursDateTimeRange
                                                          .isNotEmpty
                                                      ? _filteredOpeningHoursDateTimeRange[
                                                                  0]
                                                              ["datetimerange"]
                                                          .start
                                                          .minute
                                                      : null,
                                                ),
                                                endTime: TimeOfDay(
                                                  hour: _filteredOpeningHoursDateTimeRange
                                                          .isNotEmpty
                                                      ? _filteredOpeningHoursDateTimeRange[
                                                                  1]
                                                              ["datetimerange"]
                                                          .end
                                                          .hour
                                                      : null,
                                                  minute: _filteredOpeningHoursDateTimeRange
                                                          .isNotEmpty
                                                      ? _filteredOpeningHoursDateTimeRange[
                                                                  1]
                                                              ["datetimerange"]
                                                          .end
                                                          .minute
                                                      : null,
                                                ),
                                              ),
                                              fromText: _chooseOpeningHoursFrom,
                                              toText: _chooseOpeningHoursTo,
                                              activeTimeTextStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 30),
                                              timeTextStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 23),
                                              selectedColor:
                                                  Theme.of(context).accentColor,
                                              use24HourFormat: true,
                                              interval:
                                                  Duration(minutes: _timeSteps),
                                              ticks: _ticks,
                                            );
                                            // : await showCupertinoDialog(
                                            //     barrierDismissible: true,
                                            //     context: context,
                                            //     builder: (BuildContext context) {
                                            //       TimeOfDay _startTime = TimeOfDay.now();
                                            //       TimeOfDay _endTime = TimeOfDay.now();
                                            //       return CupertinoAlertDialog(
                                            //         content: Container(
                                            //           width: MediaQuery.of(context)
                                            //               .size
                                            //               .width,
                                            //           height: _height * 0.4153,
                                            //           child: Column(
                                            //             children: [
                                            //               TimeRangePicker(
                                            //                 start:
                                            //                     _filteredOpeningHoursDateTimeRange
                                            //                             .isNotEmpty
                                            //                         ? TimeOfDay(
                                            //                             hour: _filteredOpeningHoursDateTimeRange
                                            //                                 .first[
                                            //                                     "datetimerange"]
                                            //                                 .start
                                            //                                 .hour,
                                            //                             minute: _filteredOpeningHoursDateTimeRange
                                            //                                 .first[
                                            //                                     "datetimerange"]
                                            //                                 .start
                                            //                                 .minute,
                                            //                           )
                                            //                         : null,
                                            //                 end:
                                            //                     _filteredOpeningHoursDateTimeRange
                                            //                             .isNotEmpty
                                            //                         ? TimeOfDay(
                                            //                             hour: _filteredOpeningHoursDateTimeRange
                                            //                                 .first[
                                            //                                     "datetimerange"]
                                            //                                 .end
                                            //                                 .hour,
                                            //                             minute: _filteredOpeningHoursDateTimeRange
                                            //                                 .first[
                                            //                                     "datetimerange"]
                                            //                                 .end
                                            //                                 .minute,
                                            //                           )
                                            //                         : null,
                                            //                 disabledTime:
                                            //                     _filteredOpeningHoursDateTimeRange
                                            //                                 .length ==
                                            //                             3
                                            //                         ? TimeRange(
                                            //                             startTime:
                                            //                                 TimeOfDay(
                                            //                               hour: _filteredOpeningHoursDateTimeRange
                                            //                                       .isNotEmpty
                                            //                                   ? _filteredOpeningHoursDateTimeRange[1]
                                            //                                           [
                                            //                                           "datetimerange"]
                                            //                                       .start
                                            //                                       .hour
                                            //                                   : null,
                                            //                               minute: _filteredOpeningHoursDateTimeRange
                                            //                                       .isNotEmpty
                                            //                                   ? _filteredOpeningHoursDateTimeRange[1]
                                            //                                           [
                                            //                                           "datetimerange"]
                                            //                                       .start
                                            //                                       .minute
                                            //                                   : null,
                                            //                             ),
                                            //                             endTime:
                                            //                                 TimeOfDay(
                                            //                               hour: _filteredOpeningHoursDateTimeRange
                                            //                                       .isNotEmpty
                                            //                                   ? _filteredOpeningHoursDateTimeRange[2]
                                            //                                           [
                                            //                                           "datetimerange"]
                                            //                                       .end
                                            //                                       .hour
                                            //                                   : null,
                                            //                               minute: _filteredOpeningHoursDateTimeRange
                                            //                                       .isNotEmpty
                                            //                                   ? _filteredOpeningHoursDateTimeRange[2]
                                            //                                           [
                                            //                                           "datetimerange"]
                                            //                                       .end
                                            //                                       .minute
                                            //                                   : null,
                                            //                             ),
                                            //                           )
                                            //                         : _filteredOpeningHoursDateTimeRange
                                            //                                     .length ==
                                            //                                 2
                                            //                             ? TimeRange(
                                            //                                 startTime:
                                            //                                     TimeOfDay(
                                            //                                   hour: _filteredOpeningHoursDateTimeRange
                                            //                                           .isNotEmpty
                                            //                                       ? _filteredOpeningHoursDateTimeRange[1]["datetimerange"]
                                            //                                           .start
                                            //                                           .hour
                                            //                                       : null,
                                            //                                   minute: _filteredOpeningHoursDateTimeRange
                                            //                                           .isNotEmpty
                                            //                                       ? _filteredOpeningHoursDateTimeRange[1]["datetimerange"]
                                            //                                           .start
                                            //                                           .minute
                                            //                                       : null,
                                            //                                 ),
                                            //                                 endTime:
                                            //                                     TimeOfDay(
                                            //                                   hour: _filteredOpeningHoursDateTimeRange
                                            //                                           .isNotEmpty
                                            //                                       ? _filteredOpeningHoursDateTimeRange[1]["datetimerange"]
                                            //                                           .end
                                            //                                           .hour
                                            //                                       : null,
                                            //                                   minute: _filteredOpeningHoursDateTimeRange
                                            //                                           .isNotEmpty
                                            //                                       ? _filteredOpeningHoursDateTimeRange[1]["datetimerange"]
                                            //                                           .end
                                            //                                           .minute
                                            //                                       : null,
                                            //                                 ),
                                            //                               )
                                            //                             : null,
                                            //                 fromText:
                                            //                     _chooseOpeningHoursFrom,
                                            //                 toText: _chooseOpeningHoursTo,
                                            //                 activeTimeTextStyle:
                                            //                     TextStyle(
                                            //                         color: Colors.white,
                                            //                         fontWeight:
                                            //                             FontWeight.bold,
                                            //                         fontSize: 30),
                                            //                 timeTextStyle: TextStyle(
                                            //                     color: Colors.white,
                                            //                     fontWeight:
                                            //                         FontWeight.bold,
                                            //                     fontSize: 23),
                                            //                 selectedColor:
                                            //                     Theme.of(context)
                                            //                         .accentColor,
                                            //                 use24HourFormat: true,
                                            //                 interval: Duration(
                                            //                     minutes: _timeSteps),
                                            //                 ticks: _ticks,
                                            //                 hideButtons: true,
                                            //                 padding: _height * 0.021,
                                            //               ),
                                            //             ],
                                            //           ),
                                            //         ),
                                            //         actions: <Widget>[
                                            //           CupertinoDialogAction(
                                            //               child: Text('Cancel',
                                            //                   style: TextStyle(
                                            //                       color: CupertinoColors
                                            //                           .systemRed)),
                                            //               onPressed: () {
                                            //                 Navigator.of(context).pop();
                                            //               }),
                                            //           CupertinoDialogAction(
                                            //             child: Text('Ok',
                                            //                 style: TextStyle(
                                            //                     color: Theme.of(context)
                                            //                         .primaryColor)),
                                            //             onPressed: () {
                                            //               Navigator.of(context).pop(
                                            //                 TimeRange(
                                            //                     startTime: _startTime,
                                            //                     endTime: _endTime),
                                            //               );
                                            //             },
                                            //           ),
                                            //         ],
                                            //       );
                                            //     },
                                            //   );

                                            if (result != null) {
                                              DateTime now = DateTime(
                                                  2022, 1, 3, 0, 0, 0, 0, 0);
                                              DateTime? begin;
                                              DateTime? end;
                                              print(result);
                                              for (var j = 0; j < 7; j++) {
                                                if (now
                                                        .add(Duration(days: j))
                                                        .weekday ==
                                                    i + 1) {
                                                  begin = DateTime(
                                                    now
                                                        .add(Duration(days: j))
                                                        .year,
                                                    now
                                                        .add(Duration(days: j))
                                                        .month,
                                                    now
                                                        .add(Duration(days: j))
                                                        .day,
                                                    result.startTime.hour,
                                                    result.startTime.minute,
                                                    0,
                                                    0,
                                                    0,
                                                  );

                                                  end = DateTime(
                                                    now
                                                        .add(Duration(days: j))
                                                        .year,
                                                    now
                                                        .add(Duration(days: j))
                                                        .month,
                                                    now
                                                        .add(Duration(days: j))
                                                        .day,
                                                    result.endTime.hour,
                                                    result.endTime.minute,
                                                    0,
                                                    0,
                                                    0,
                                                  );
                                                  if (end.isBefore(begin)) {
                                                    end = end
                                                        .add(Duration(days: 1));
                                                  }
                                                }
                                              }
                                              DateTimeRange _dayBefore =
                                                  _filteredOpeningHoursDateTimeRange
                                                      .first["datetimerange"];
                                              if (_dayBefore.start
                                                  .isAfter(begin!)) {
                                                begin = begin
                                                    .add(Duration(days: 1));
                                                end =
                                                    end!.add(Duration(days: 1));
                                              }

                                              if (_filteredOpeningHours.length >
                                                  2) {
                                                int deletedObjectIndex =
                                                    _openingHoursList.indexOf(
                                                        _filteredOpeningHours
                                                            .last);
                                                _openingHoursList.removeAt(
                                                    deletedObjectIndex);
                                                _openingHoursList.insert(
                                                    deletedObjectIndex, {
                                                  "day": i + 1,
                                                  "day_from": begin.weekday,
                                                  "day_to": end!.weekday,
                                                  "time_from": formatTimeOfDay(
                                                      TimeOfDay(
                                                          hour: begin.hour,
                                                          minute:
                                                              begin.minute)),
                                                  "time_to_duration": end
                                                      .difference(begin)
                                                      .inMinutes,
                                                });

                                                _openingHoursListDateTimeRange
                                                    .removeAt(
                                                        deletedObjectIndex);
                                                _openingHoursListDateTimeRange
                                                    .insert(
                                                        deletedObjectIndex, {
                                                  "day": i + 1,
                                                  "datetimerange":
                                                      DateTimeRange(
                                                          start: begin,
                                                          end: end),
                                                });
                                              } else {
                                                int getFirstIndex =
                                                    _openingHoursList.indexOf(
                                                        _filteredOpeningHours
                                                            .first);
                                                _openingHoursList
                                                    .insert(getFirstIndex + 2, {
                                                  "day": i + 1,
                                                  "day_from": begin.weekday,
                                                  "day_to": end!.weekday,
                                                  "time_from": formatTimeOfDay(
                                                      TimeOfDay(
                                                          hour: begin.hour,
                                                          minute:
                                                              begin.minute)),
                                                  "time_to_duration": end
                                                      .difference(begin)
                                                      .inMinutes,
                                                });

                                                _openingHoursListDateTimeRange
                                                    .insert(getFirstIndex + 2, {
                                                  "day": i + 1,
                                                  "datetimerange":
                                                      DateTimeRange(
                                                          start: begin,
                                                          end: end),
                                                });
                                              }
                                            }
                                            setState(() {});
                                          },
                                          label: Text(
                                              _filteredOpeningHoursDateTimeRange
                                                          .length >
                                                      2
                                                  ? "${formatter.format(_filteredOpeningHoursDateTimeRange[2]["datetimerange"].start)}:${formatter.format(_filteredOpeningHoursDateTimeRange[2]["datetimerange"].end)}"
                                                  : _addMoreOpeningHoursMondayTwo),
                                        ),
                                      ),
                                    ],
                                  ),
                              if (_openingHoursList.length < 4 &&
                                  _openingHoursList.length > 0 &&
                                  _firstDay == i + 1)
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: _height * 0.012,
                                      left: _width * 0.081),
                                  child: TextButton(
                                      style: TextButton.styleFrom(
                                        minimumSize: Size.zero,
                                        padding: EdgeInsets.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () {
                                        _firstDay = -2;

                                        List _dummyOpeningHour =
                                            _openingHoursList;

                                        List _dummyOpeningHourDateTimeRange =
                                            _openingHoursListDateTimeRange;

                                        int _dummyDay = 0;
                                        for (var l = 0;
                                            l <
                                                _dummyOpeningHourDateTimeRange
                                                    .length;
                                            l++) {
                                          if (l == 0) {
                                            if (_dummyOpeningHourDateTimeRange
                                                    .first["day"] !=
                                                1) {
                                              _dummyDay =
                                                  _dummyOpeningHourDateTimeRange[
                                                          l]["day"] -
                                                      1;
                                              _dummyOpeningHourDateTimeRange[
                                                  l] = {
                                                "day": 1,
                                                "datetimerange": DateTimeRange(
                                                    start:
                                                        _dummyOpeningHourDateTimeRange[
                                                                    l][
                                                                "datetimerange"]
                                                            .start
                                                            .subtract(Duration(
                                                                days:
                                                                    _dummyDay)),
                                                    end: _dummyOpeningHourDateTimeRange[
                                                            l]["datetimerange"]
                                                        .end
                                                        .subtract(Duration(
                                                            days: _dummyDay))),
                                              };
                                            }
                                          } else {
                                            _dummyOpeningHourDateTimeRange[l] =
                                                {
                                              "day": 1,
                                              "datetimerange": DateTimeRange(
                                                  start:
                                                      _dummyOpeningHourDateTimeRange[
                                                                  l]
                                                              ["datetimerange"]
                                                          .start
                                                          .subtract(Duration(
                                                              days: _dummyDay)),
                                                  end:
                                                      _dummyOpeningHourDateTimeRange[
                                                                  l]
                                                              ["datetimerange"]
                                                          .end
                                                          .subtract(Duration(
                                                              days:
                                                                  _dummyDay))),
                                            };
                                          }
                                        }

                                        for (var l = 0; l < 7; l++) {
                                          for (var m = 0;
                                              m < _filteredOpeningHours.length;
                                              m++) {
                                            if (l == 0) {
                                              _openingHoursList
                                                  .replaceRange(m, m + 1, [
                                                {
                                                  "day": l + 1,
                                                  "day_from": _dummyOpeningHour[
                                                              m]["day"] !=
                                                          _dummyOpeningHour[m]
                                                              ["day_from"]
                                                      ? l + 1 == 7
                                                          ? 1
                                                          : l + 1 + 1
                                                      : l + 1,
                                                  "day_to": _dummyOpeningHour[m]
                                                              ["day"] !=
                                                          _dummyOpeningHour[m]
                                                              ["day_to"]
                                                      ? l + 1 == 7
                                                          ? 1
                                                          : l + 1 + 1
                                                      : l + 1,
                                                  "time_from":
                                                      _dummyOpeningHour[m]
                                                          ["time_from"],
                                                  "time_to_duration":
                                                      _dummyOpeningHour[m]
                                                          ["time_to_duration"]
                                                }
                                              ]);

                                              _openingHoursListDateTimeRange
                                                  .replaceRange(m, m + 1, [
                                                {
                                                  "day": l + 1,
                                                  "datetimerange":
                                                      DateTimeRange(
                                                    start:
                                                        _dummyOpeningHourDateTimeRange[
                                                                    m][
                                                                "datetimerange"]
                                                            .start
                                                            .add(Duration(
                                                                days: l)),
                                                    end:
                                                        _dummyOpeningHourDateTimeRange[
                                                                    m][
                                                                "datetimerange"]
                                                            .end
                                                            .add(
                                                              Duration(days: l),
                                                            ),
                                                  )
                                                }
                                              ]);
                                            }
                                            if (l > 0) {
                                              _openingHoursList.add({
                                                "day": l + 1,
                                                "day_from": _dummyOpeningHour[m]
                                                            ["day"] !=
                                                        _dummyOpeningHour[m]
                                                            ["day_from"]
                                                    ? l + 1 == 7
                                                        ? 1
                                                        : l + 1 + 1
                                                    : l + 1,
                                                "day_to": _dummyOpeningHour[m]
                                                            ["day"] !=
                                                        _dummyOpeningHour[m]
                                                            ["day_to"]
                                                    ? l + 1 == 7
                                                        ? 1
                                                        : l + 1 + 1
                                                    : l + 1,
                                                "time_from":
                                                    _dummyOpeningHour[m]
                                                        ["time_from"],
                                                "time_to_duration":
                                                    _dummyOpeningHour[m]
                                                        ["time_to_duration"]
                                              });

                                              _openingHoursListDateTimeRange
                                                  .add({
                                                "day": l + 1,
                                                "datetimerange": DateTimeRange(
                                                  start:
                                                      _dummyOpeningHourDateTimeRange[
                                                                  m]
                                                              ["datetimerange"]
                                                          .start
                                                          .add(Duration(
                                                              days: l)),
                                                  end:
                                                      _dummyOpeningHourDateTimeRange[
                                                                  m]
                                                              ["datetimerange"]
                                                          .end
                                                          .add(
                                                            Duration(days: l),
                                                          ),
                                                )
                                              });
                                            }
                                          }
                                        }

                                        setState(() {});
                                      },
                                      child: Text("Apply for all days")),
                                ),
                            ],
                          ),
                        ]),
                    Divider(),
                  ],
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaPage(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    Widget _emptySpaceColum =
        SizedBox(height: MediaQuery.of(context).size.height * 0.03);
    Widget _emptySpaceColumTextField =
        SizedBox(height: MediaQuery.of(context).size.height * 0.02);
    return SingleChildScrollView(
      child: Padding(
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
                  'assets/images/socialmedia.png',
                ),
                height: _height * 0.18,
                width: _width * 0.7,
              ),
            ),
            SizedBox(
              height: _height * 0.012,
            ),
            Text(
              "Promote ur social media channels",
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
            _formAndTextFormFieldStore(
              nextFocusNode: _facebookFocus,
              focusNode: _homepageFocus,
              textController: _homepageController,
              icon: _homepageIcon,
              hintText: "Homepage",
              textInputType: TextInputType.url,
            ),
            _emptySpaceColumTextField,
            _formAndTextFormFieldStore(
              nextFocusNode: _instagramFocus,
              focusNode: _facebookFocus,
              textController: _facebookController,
              icon: _facebookIcon,
              hintText: "Facebook",
            ),
            _emptySpaceColumTextField,
            _formAndTextFormFieldStore(
              focusNode: _instagramFocus,
              nextFocusNode: _googleMybusinessFocus,
              textController: _instagramController,
              icon: _instagramIcon,
              hintText: "Instagram",
            ),
            _emptySpaceColumTextField,
            _formAndTextFormFieldStore(
              focusNode: _googleMybusinessFocus,
              nextFocusNode: _youtubeFocus,
              textController: _googleMybusinessController,
              icon: _googleMybusinessIcon,
              hintText: "Google my business",
            ),
            _emptySpaceColumTextField,
            _formAndTextFormFieldStore(
              focusNode: _youtubeFocus,
              textController: _youtubeController,
              nextFocusNode: _tiktokFocus,
              icon: _youtubeIcon,
              hintText: "Youtube",
            ),
            _emptySpaceColumTextField,
            _formAndTextFormFieldStore(
              focusNode: _tiktokFocus,
              textController: _tiktokController,
              nextFocusNode: _pinterestFocus,
              icon: _tiktokIcon,
              hintText: "TikTok",
            ),
            _emptySpaceColumTextField,
            _formAndTextFormFieldStore(
              focusNode: _pinterestFocus,
              textController: _pinterestController,
              icon: _pinterestIcon,
              hintText: "Pinterest",
            ),
            _emptySpaceColum,
          ],
        ),
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

  Future<void> _signUpAdvertiser() async {
    _advertiserRegEmailGlobalKey.currentState!.validate();

    _advertiserRegPasswordGlobalKey.currentState!.validate();

    _advertiserRegRepeatPasswordGlobalKey.currentState!.validate();

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
          setState(() {
            _checkEmail = false;
          });
          _advertiserRegEmailGlobalKey.currentState!.validate();
        }
      } catch (e) {
        setState(() {
          _checkEmail = false;
        });
        _advertiserRegEmailGlobalKey.currentState!.validate();
      }
    }

    if (_advertiserRegEmailGlobalKey.currentState!.validate() &&
        _advertiserRegPasswordGlobalKey.currentState!.validate() &&
        _advertiserRegRepeatPasswordGlobalKey.currentState!.validate() &&
        _checkEmail!) {
      try {
        if (isAccountRegistrated) {
          await Provider.of<Advertiser>(context, listen: false).update(
            advertiser: Advertiser(
                email: _emailSignUpController.text.trim(),
                password: _passwordSignUpController.text),
          );
          await _pageController.nextPage(
            duration: Duration(milliseconds: 120),
            curve: Curves.ease,
          );
          setState(() {
            _radioColor = MaterialStateProperty.all<Color>(_nowNowGeneralColor);
          });
        } else {
          await Provider.of<Advertiser>(context, listen: false).signUp(
            advertiser: Advertiser(
              email: _emailSignUpController.text.trim(),
              password: _passwordSignUpController.text,
            ),
          );

          isAccountRegistrated = true;

          await _pageController.nextPage(
            duration: Duration(milliseconds: 120),
            curve: Curves.ease,
          );
        }
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
        await Provider.of<Advertiser>(context, listen: false).update(
          advertiser: Advertiser(
            gender: _gender,
            firstname: _firstnameController.text,
            lastname: _lastnameController.text,
            birthDate: _birthDate,
            // taxId: _taxIdController.text,
            // iban: _ibanController.text,
            phone: _phoneController.text,
            companyRegistrationNumber: _crNumberController.text,
            bic: _bicController.text,
          ),
        );
        await _pageController.nextPage(
          duration: Duration(milliseconds: 120),
          curve: Curves.ease,
        );
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
  }

  Future updateOptionalPersonalDataAdvertiser() async {
    try {
      await Provider.of<Advertiser>(context, listen: false).update(
        advertiser: Advertiser(
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
      await _pageController.nextPage(
        duration: Duration(milliseconds: 120),
        curve: Curves.ease,
      );
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

  Future uploadImageAndCategory() async {
    if (_imageFile == null ||
        _selectedRubricId == null ||
        _selectedSubrubricId == null ||
        (_selectedSubrubricId != null && _subrubricValidate!)) {
      if (_imageFile == null) {
        _emptyAlertFieldsString = _emptyAlertFieldsString + _emptyAlertPicture;
        setState(() {
          _imgBorderColor =
              Platform.isAndroid ? Colors.red : CupertinoColors.systemRed;
          _imgBorderWidth = 2;
        });
      } else {
        setState(() {
          _imgBorderColor = _nowNowGeneralColor;
          _imgBorderWidth = 1;
        });
      }

      if (_selectedRubricId == null) {
        _emptyAlertFieldsString = _emptyAlertFieldsString + _emptyAlertCategory;
        setState(() {
          _rubricDropdownColor = Colors.red;
          _categoryBorder = const BorderSide(width: 1, color: Colors.red);

          _categoryColor = Colors.red;
        });
      } else {
        setState(() {
          _rubricDropdownColor = null;

          _categoryBorder = null;

          _categoryColor = Colors.white;
        });
      }
      if (_selectedSubrubricId == null) {
        _emptyAlertFieldsString =
            _emptyAlertFieldsString + _emptyAlertSubCategory;
        setState(() {
          _subrubricDropdownColor = Colors.red;

          _subcategoryBorder = const BorderSide(width: 1, color: Colors.red);

          _subcategoryColor = Colors.red;
        });
      } else {
        setState(() {
          _subrubricDropdownColor = null;
          _subcategoryBorder = null;
          _subcategoryColor = Colors.white;
        });
      }
      if (_selectedSubrubricId != null) {
        if (_subrubricValidate == true) {
          if (_selectedSubSubrubricId == null) {
            _emptyAlertFieldsString =
                _emptyAlertFieldsString + _emptyAlertSubSubCategory;
            setState(() {
              _subsubrubricDropdownColor = Colors.red;

              _subsubcategoryBorder =
                  const BorderSide(width: 1, color: Colors.red);

              _subsubcategoryColor = Colors.red;
            });
          } else {
            setState(() {
              _subsubrubricDropdownColor = null;
              _subsubcategoryBorder = null;
              _subsubcategoryColor = Colors.white;
            });
          }
        }
      } else {
        setState(() {
          _subsubrubricDropdownColor = Colors.red;

          _subsubcategoryBorder = const BorderSide(width: 1, color: Colors.red);

          _subsubcategoryColor = Colors.red;
        });
      }
    }

    if (_imageFile != null &&
        _selectedRubricId != null &&
        _selectedSubrubricId != null &&
        !_subrubricValidate!) {
      await _pageController.nextPage(
        duration: Duration(milliseconds: 120),
        curve: Curves.ease,
      );
    }

    if (_imageFile != null &&
        _selectedRubricId != null &&
        _selectedSubrubricId != null &&
        _subrubricValidate!) {
      if (_selectedSubSubrubricId != null) {
        await _pageController.nextPage(
          duration: Duration(milliseconds: 120),
          curve: Curves.ease,
        );
      }
    }
  }

  Future addStoreAddress() async {
    if (_streetOrStoreIsSelected) {
      _advertiserNameGlobalKey.currentState!.validate();
      _advertiserSearchStreetGlobalKey.currentState!.validate();
      _advertiserPostcodeGlobalKey.currentState!.validate();
      _advertiserCityGlobalKey.currentState!.validate();
      _advertiserCountryGlobalKey.currentState!.validate();
      _advertiserRegIbanGlobalKey.currentState!.validate();
      _advertiserRegTaxIdGlobalKey.currentState!.validate();

      if (_advertiserNameGlobalKey.currentState!.validate() &&
          _advertiserSearchStreetGlobalKey.currentState!.validate() &&
          _advertiserPostcodeGlobalKey.currentState!.validate() &&
          _advertiserCityGlobalKey.currentState!.validate() &&
          _advertiserCountryGlobalKey.currentState!.validate() &&
          _advertiserRegIbanGlobalKey.currentState!.validate() &&
          _advertiserRegTaxIdGlobalKey.currentState!.validate()) {
        await _pageController.nextPage(
          duration: Duration(milliseconds: 120),
          curve: Curves.ease,
        );
      }
    } else {
      _advertiserSearchStreetGlobalKey.currentState!.validate();
      _advertiserSearchStoreGlobalKey.currentState!.validate();
    }
  }

  Future addSocialMedia() async {
    try {
      await _pageController.nextPage(
        duration: Duration(milliseconds: 120),
        curve: Curves.ease,
      );
    } catch (e) {
      print(e);
    }
  }

  Future addInvoiceAddress() async {
    if (_invoiceGender == null) {
      setState(() {
        _invoiceRadioColor = MaterialStateProperty.all<Color>(Colors.red);
      });
    } else {
      setState(() {
        _invoiceRadioColor =
            MaterialStateProperty.all<Color>(_nowNowGeneralColor);
      });
    }
    _invoiceAdvertiserFirstnameGlobalKey.currentState!.validate();
    _invoiceAdvertiserLastnameGlobalKey.currentState!.validate();
    _invoiceAdvertiserPostcodeGlobalKey.currentState!.validate();
    _invoiceAdvertiserCityGlobalKey.currentState!.validate();
    _invoiceAdvertiserCountryGlobalKey.currentState!.validate();
    _invoiceAdvertiserEmailGlobalKey.currentState!.validate();

    if (_invoiceAdvertiserFirstnameGlobalKey.currentState!.validate() &&
        _invoiceAdvertiserLastnameGlobalKey.currentState!.validate() &&
        _invoiceAdvertiserPostcodeGlobalKey.currentState!.validate() &&
        _invoiceAdvertiserCityGlobalKey.currentState!.validate() &&
        _invoiceAdvertiserCountryGlobalKey.currentState!.validate() &&
        _invoiceAdvertiserEmailGlobalKey.currentState!.validate()) {
      await _pageController.nextPage(
        duration: Duration(milliseconds: 120),
        curve: Curves.ease,
      );
    }
  }

  Future addOpeningHours() async {
    if (_openingHoursListDateTimeRange.isNotEmpty) {
      _openingHoursListDateTimeRange.sort((a, b) =>
          a["datetimerange"].start.compareTo((b["datetimerange"].start)));
      int day = 0;
      bool _mondayExists = false;
      bool _sundayExists = false;
      bool _hasException = false;
      for (var i = 0; i < _openingHoursListDateTimeRange.length; i++) {
        if (_openingHoursListDateTimeRange[i]["day"] == 1) {
          _mondayExists = true;
        }
        if (_openingHoursListDateTimeRange[i]["day"] == 7) {
          _sundayExists = true;
        }
        if (i == 0) {
          day = _openingHoursListDateTimeRange[i]["day"];
        } else {
          if (_openingHoursListDateTimeRange[i]["day"] != day) {
            DateTimeRange getBeforeDateRange =
                _openingHoursListDateTimeRange[i - 1]["datetimerange"];
            DateTimeRange getNowDateRange =
                _openingHoursListDateTimeRange[i]["datetimerange"];
            if (getBeforeDateRange.end.isAfter(getNowDateRange.start)) {
              _hasException = true;
            }
          }
          if (i == _openingHoursListDateTimeRange.length - 1 &&
              _mondayExists &&
              _sundayExists) {
            DateTimeRange getMondayDateRange =
                _openingHoursListDateTimeRange.first["datetimerange"];
            DateTimeRange getSundayDateRange =
                _openingHoursListDateTimeRange.last["datetimerange"];
            getSundayDateRange = DateTimeRange(
                start: getSundayDateRange.start.subtract(Duration(days: 7)),
                end: getSundayDateRange.end.subtract(Duration(days: 7)));
            if (getSundayDateRange.end.isAfter(getMondayDateRange.start)) {
              _hasException = true;
            }
          }
        }
      }
      if (_hasException) {
        await Alert(
          context: context,
          type: AlertType.error,
          title: "Ur opening hours are overlaping",
          buttons: [
            DialogButton(
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              width: 120,
            )
          ],
        ).show();
      } else {
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

  Future getStarted() async {
    if (_acceptTerms == false) {
      _emptyAlertFieldsString =
          _emptyAlertFieldsString + _emptyAlertTermsAndCondition;
      setState(() {
        _checkboxTermsTextColor = Colors.red;
        _checkboxTermsFillColor = MaterialStateProperty.all<Color>(Colors.red);
      });
    } else {
      setState(() {
        _checkboxTermsTextColor = _nowNowGeneralColor;
        _checkboxTermsFillColor =
            MaterialStateProperty.all<Color>(_nowNowGeneralColor);
      });

      if (checkboxActive!) {
        try {
          await Provider.of<Addresses>(context, listen: false).addAddress(
            imageFile: _imageFile!,
            address: Address(
              name: _nameController.text,
              latitude: _lat!,
              longitude: _lng!,
              street: _streetController.text,
              postcode: _postCodeController.text,
              city: _cityController.text,
              country: _countryController.text,
              floor: _floorController.text,
              iban: _ibanController.text,
              vat: _taxIdController.text,
              phone: _storePhoneController.text,
              countryCode: _countryCode!,
              categoryId: _selectedRubricId!,
              subcategoryId: _suggestedSubrubricId == null
                  ? _selectedSubrubricId!
                  : _suggestedSubrubricId!,
              subsubcategoryId: _selectedSubSubrubricId,
              homepage: _homepageController.text,
              facebook: _facebookController.text,
              instagram: _instagramController.text,
              googleMyBusiness: _googleMybusinessController.text,
              pinterest: _pinterestController.text,
              youtube: _youtubeController.text,
              tiktok: _tiktokController.text,
            ),
            openingHours: _openingHoursList,
            invoiceAddress: InvoiceAddress(
              email: _emailSignUpController.text.trim().toLowerCase(),
              gender: _gender!,
              firstname: _firstnameController.text,
              lastname: _lastnameController.text,
              latitude: _lat!,
              longitude: _lng!,
              street: _streetController.text,
              postcode: _postCodeController.text,
              city: _cityController.text,
              country: _countryController.text,
              countryCode: _countryCode!,
              companyName: _nameController.text,
              // phone: _phoneController.text,
              name: _nameController.text,
            ),
          );
        } catch (e) {
          await Provider.of<Advertiser>(context, listen: false).destroy();
          print("Fehler 3: " + e.toString());
          setState(() {
            hasException = true;
          });
        }
      } else {
        try {
          await Provider.of<Addresses>(context, listen: false).addAddress(
            imageFile: _imageFile!,
            address: Address(
              name: _nameController.text,
              latitude: _lat!,
              longitude: _lng!,
              street: _streetController.text,
              postcode: _postCodeController.text,
              city: _cityController.text,
              country: _countryController.text,
              floor: _floorController.text,
              iban: _ibanController.text,
              vat: _taxIdController.text,
              phone: _storePhoneController.text,
              countryCode: _countryCode!,
              categoryId: _selectedRubricId!,
              subcategoryId: _suggestedSubrubricId == null
                  ? _selectedSubrubricId!
                  : _suggestedSubrubricId!,
              subsubcategoryId: _selectedSubSubrubricId,
              homepage: _homepageController.text,
              facebook: _facebookController.text,
              instagram: _instagramController.text,
              googleMyBusiness: _googleMybusinessController.text,
              pinterest: _pinterestController.text,
              youtube: _youtubeController.text,
              tiktok: _tiktokController.text,
            ),
            openingHours: _openingHoursList,
            invoiceAddress: InvoiceAddress(
              email: _invoiceEmailController.text,
              gender: _invoiceGender!,
              firstname: _invoiceFirstnameController.text,
              lastname: _invoiceLastnameController.text,
              latitude: _invoiceLat!,
              longitude: _invoiceLng!,
              street: _invoiceStreetController.text,
              city: _invoiceCityController.text,
              country: _invoiceCountryController.text,
              countryCode: _invoiceCountryCode!,
              companyName: _invoiceNameController.text,
              phone: _invoicePhoneController.text,
              postcode: _invoicePostCodeController.text,
              name: _invoiceNameController.text,
            ),
          );
        } catch (e) {
          await Provider.of<Advertiser>(context, listen: false).destroy();
          print("Fehler 6: " + e.toString());
          setState(() {
            hasException = true;
          });
        }
      }
    }
    if (!hasException && _acceptTerms) {
      await Navigator.push(
          context,
          PageTransition(
              duration: Duration(
                milliseconds: 333,
              ),
              type: PageTransitionType.fade,
              child: HomeScreen(
                isOpen: false,
                stream: streamController.stream,
              )));
    }
  }

  Future _addOpeningHour(
    BuildContext context,
    String addressId,
    TimeOfDay? dayOneFrom,
    TimeOfDay? dayOneTo,
    TimeOfDay? dayTwoFrom,
    TimeOfDay? dayTwoTo,
    TimeOfDay? dayThreeFrom,
    TimeOfDay? dayThreeTo,
    int dayFrom,
    int dayTo,
    int dayConst,
  ) async {
    /////////////////DAY ONE ////////////////////
    if (dayOneFrom != null &&
        dayTwoTo == null &&
        dayTwoFrom == null &&
        dayThreeFrom == null) {
      DateTime now = DateTime.now();
      DateTime from = DateTime(
        now.year,
        now.month,
        now.day,
        dayOneFrom.hour,
        dayOneFrom.minute,
      );

      DateTime to = DateTime(
        now.year,
        now.month,
        now.day,
        dayOneTo!.hour,
        dayOneTo.minute,
      );

      var isNegative = to.difference(from).isNegative;

      int time_to_duration = TimeSpan(
              "${dayOneFrom.hour.toString().padLeft(2, '0')}:${dayOneFrom.minute.toString().padLeft(2, '0')}",
              "${dayOneTo.hour.toString().padLeft(2, '0')}:${dayOneTo.minute.toString().padLeft(2, '0')}")
          .inMinutes;

      if (isNegative) {
        time_to_duration = time_to_duration.abs();
        if (dayConst == 7) {
          dayTo = 1;
        } else {
          dayTo = dayConst + 1;
        }
      }
      if (time_to_duration == 0) {
        time_to_duration = 1440;
      }

      try {
        await Provider.of<OpeningHours>(context, listen: false)
            .addOpeningHour(OpeningHour(
          day: dayConst,
          dayFrom: dayConst,
          timeFrom: dayOneFrom,
          duration: time_to_duration,
          dayTo: isNegative ? dayTo : dayConst,
          addressId: addressId,
        ));
      } catch (e) {
        print("opening Hour 1: " + e.toString());
        setState(() {
          hasException = true;
        });
      }
    }
    ///////////////////////////////////////DAY TWO  /////////////////////////
    if (dayOneFrom != null &&
        dayOneTo != null &&
        dayTwoFrom != null &&
        dayThreeFrom == null) {
      DateTime now = DateTime.now();
      DateTime from = DateTime(
        now.year,
        now.month,
        now.day,
        dayOneFrom.hour,
        dayOneFrom.minute,
      );

      DateTime to = DateTime(
        now.year,
        now.month,
        now.day,
        dayOneTo.hour,
        dayOneTo.minute,
      );

      var isNegative = to.difference(from).isNegative;

      int time_to_duration = TimeSpan(
              "${dayOneFrom.hour.toString().padLeft(2, '0')}:${dayOneFrom.minute.toString().padLeft(2, '0')}",
              "${dayOneTo.hour.toString().padLeft(2, '0')}:${dayOneTo.minute.toString().padLeft(2, '0')}")
          .inMinutes;

      if (isNegative) {
        time_to_duration = time_to_duration.abs();
        if (dayConst == 7) {
          dayTo = 1;
        } else {
          dayTo = dayConst + 1;
        }
      }
      if (time_to_duration == 0) {
        time_to_duration = 1440;
      }

      try {
        await Provider.of<OpeningHours>(context, listen: false)
            .addOpeningHour(OpeningHour(
          day: dayConst,
          dayFrom: dayConst,
          timeFrom: dayOneFrom,
          duration: time_to_duration,
          dayTo: dayTo,
          addressId: addressId,
        ));
      } catch (e) {
        print("opening Hour 2: " + e.toString());
        setState(() {
          hasException = true;
        });
      }

      if (isNegative) {
        int time_to_duration = TimeSpan(
                "${dayTwoFrom.hour.toString().padLeft(2, '0')}:${dayTwoFrom.minute.toString().padLeft(2, '0')}",
                "${dayTwoTo!.hour.toString().padLeft(2, '0')}:${dayTwoTo.minute.toString().padLeft(2, '0')}")
            .inMinutes;

        if (dayConst == 7) {
          dayTo = 1;
        } else {
          dayTo = dayConst + 1;
        }

        try {
          await Provider.of<OpeningHours>(context, listen: false)
              .addOpeningHour(OpeningHour(
            day: dayConst,
            dayFrom: dayTo,
            timeFrom: dayTwoFrom,
            duration: time_to_duration,
            dayTo: dayTo,
            addressId: addressId,
          ));
        } catch (e) {
          print("opening Hour 3: " + e.toString());
          setState(() {
            hasException = true;
          });
        }
      } else {
        DateTime now = DateTime.now();
        DateTime from = DateTime(
          now.year,
          now.month,
          now.day,
          dayTwoFrom.hour,
          dayTwoFrom.minute,
        );

        DateTime to = DateTime(
          now.year,
          now.month,
          now.day,
          dayTwoTo!.hour,
          dayTwoTo.minute,
        );

        var isNegative = to.difference(from).isNegative;

        int time_to_duration = TimeSpan(
                "${dayTwoFrom.hour.toString().padLeft(2, '0')}:${dayTwoFrom.minute.toString().padLeft(2, '0')}",
                "${dayTwoTo.hour.toString().padLeft(2, '0')}:${dayTwoTo.minute.toString().padLeft(2, '0')}")
            .inMinutes;

        if (isNegative) {
          time_to_duration = time_to_duration.abs();
          if (dayConst == 7) {
            dayTo = 1;
          } else {
            dayTo = dayConst + 1;
          }
        }
        if (time_to_duration == 0) {
          time_to_duration = 1440;
        }
        DateTime firstEndingTime = DateTime(
          now.year,
          now.month,
          now.day,
          dayOneTo.hour,
          dayOneTo.minute,
        );

        DateTime secondBeginningTime = DateTime(
          now.year,
          now.month,
          now.day,
          dayTwoFrom.hour,
          dayTwoFrom.minute,
        );

        var isBetweenToOpeningHoursNegativ =
            secondBeginningTime.difference(firstEndingTime).isNegative;

        if (isBetweenToOpeningHoursNegativ) {
          if (dayConst == 7) {
            dayTo = 1;
            dayFrom = 1;
          } else {
            dayFrom = dayConst + 1;
            dayTo = dayConst + 1;
          }
        }
        try {
          await Provider.of<OpeningHours>(context, listen: false)
              .addOpeningHour(OpeningHour(
            day: dayConst,
            dayFrom: dayFrom,
            timeFrom: dayTwoFrom,
            duration: time_to_duration,
            dayTo: dayTo,
            addressId: addressId,
          ));
        } catch (e) {
          print("opening Hour 4: " + e.toString());
          setState(() {
            hasException = true;
          });
        }
      }
    }

    /////////////////////////////////////// DAY THREE /////////////////////////////////////
    if (dayOneFrom != null &&
        dayOneTo != null &&
        dayTwoFrom != null &&
        dayThreeFrom != null) {
      DateTime now = DateTime.now();
      DateTime from = DateTime(
        now.year,
        now.month,
        now.day,
        dayOneFrom.hour,
        dayOneFrom.minute,
      );

      DateTime to = DateTime(
        now.year,
        now.month,
        now.day,
        dayOneTo.hour,
        dayOneTo.minute,
      );

      var isNegative = to.difference(from).isNegative;

      int time_to_duration = TimeSpan(
              "${dayOneFrom.hour.toString().padLeft(2, '0')}:${dayOneFrom.minute.toString().padLeft(2, '0')}",
              "${dayOneTo.hour.toString().padLeft(2, '0')}:${dayOneTo.minute.toString().padLeft(2, '0')}")
          .inMinutes;

      if (isNegative) {
        time_to_duration = time_to_duration.abs();
        if (dayConst == 7) {
          dayTo = 1;
        } else {
          dayTo = dayConst + 1;
        }
      }
      if (time_to_duration == 0) {
        time_to_duration = 1440;
      }
      try {
        await Provider.of<OpeningHours>(context, listen: false)
            .addOpeningHour(OpeningHour(
          day: dayConst,
          dayFrom: dayConst,
          timeFrom: dayOneFrom,
          duration: time_to_duration,
          dayTo: dayTo,
          addressId: addressId,
        ));
      } catch (e) {
        print("opening Hour 5: " + e.toString());
        setState(() {
          hasException = true;
        });
      }

      if (isNegative) {
        int time_to_duration_two = TimeSpan(
                "${dayTwoFrom.hour.toString().padLeft(2, '0')}:${dayTwoFrom.minute.toString().padLeft(2, '0')}",
                "${dayTwoTo!.hour.toString().padLeft(2, '0')}:${dayTwoTo.minute.toString().padLeft(2, '0')}")
            .inMinutes;

        try {
          await Provider.of<OpeningHours>(context, listen: false)
              .addOpeningHour(OpeningHour(
            day: dayConst,
            dayFrom: dayTo,
            timeFrom: dayTwoFrom,
            duration: time_to_duration_two,
            dayTo: dayTo,
            addressId: addressId,
          ));
        } catch (e) {
          print("opening Hour 6: " + e.toString());
          setState(() {
            hasException = true;
          });
        }

        int time_to_duration_three = TimeSpan(
                "${dayThreeFrom.hour.toString().padLeft(2, '0')}:${dayThreeFrom.minute.toString().padLeft(2, '0')}",
                "${dayThreeTo!.hour.toString().padLeft(2, '0')}:${dayThreeTo.minute.toString().padLeft(2, '0')}")
            .inMinutes;

        try {
          await Provider.of<OpeningHours>(context, listen: false)
              .addOpeningHour(OpeningHour(
            day: dayConst,
            dayFrom: dayTo,
            timeFrom: dayThreeFrom,
            duration: time_to_duration_three,
            dayTo: dayTo,
            addressId: addressId,
          ));
        } catch (e) {
          print("opening Hour 7: " + e.toString());
          setState(() {
            hasException = true;
          });
        }
      } else {
        DateTime now = DateTime.now();
        DateTime from = DateTime(
          now.year,
          now.month,
          now.day,
          dayTwoFrom.hour,
          dayTwoFrom.minute,
        );

        DateTime to = DateTime(
          now.year,
          now.month,
          now.day,
          dayTwoTo!.hour,
          dayTwoTo.minute,
        );

        var isNegative = to.difference(from).isNegative;

        int time_to_duration = TimeSpan(
                "${dayTwoFrom.hour.toString().padLeft(2, '0')}:${dayTwoFrom.minute.toString().padLeft(2, '0')}",
                "${dayTwoTo.hour.toString().padLeft(2, '0')}:${dayTwoTo.minute.toString().padLeft(2, '0')}")
            .inMinutes;

        if (isNegative) {
          time_to_duration = time_to_duration.abs();
          if (dayConst == 7) {
            dayTo = 1;
          } else {
            dayTo = dayConst + 1;
          }
        }

        DateTime firstEndingTime = DateTime(
          now.year,
          now.month,
          now.day,
          dayOneTo.hour,
          dayOneTo.minute,
        );

        DateTime secondBeginningTime = DateTime(
          now.year,
          now.month,
          now.day,
          dayTwoFrom.hour,
          dayTwoFrom.minute,
        );

        var isBetweenEndingAndBeginningNegative =
            secondBeginningTime.difference(firstEndingTime).isNegative;

        if (isBetweenEndingAndBeginningNegative) {
          if (dayConst == 7) {
            dayFrom = 1;
            dayTo = 1;
          } else {
            dayFrom = dayConst + 1;
            dayTo = dayConst + 1;
          }
        }

        try {
          await Provider.of<OpeningHours>(context, listen: false)
              .addOpeningHour(OpeningHour(
            day: dayConst,
            dayFrom: dayFrom,
            timeFrom: dayTwoFrom,
            duration: time_to_duration,
            dayTo: dayTo,
            addressId: addressId,
          ));
        } catch (e) {
          print("opening Hour 8: " + e.toString());
          setState(() {
            hasException = true;
          });
        }

        if (isNegative || isBetweenEndingAndBeginningNegative) {
          int time_to_duration_three = TimeSpan(
                  "${dayThreeFrom.hour.toString().padLeft(2, '0')}:${dayThreeFrom.minute.toString().padLeft(2, '0')}",
                  "${dayThreeTo!.hour.toString().padLeft(2, '0')}:${dayThreeTo.minute.toString().padLeft(2, '0')}")
              .inMinutes;

          try {
            await Provider.of<OpeningHours>(context, listen: false)
                .addOpeningHour(OpeningHour(
              day: dayConst,
              dayFrom: dayTo,
              timeFrom: dayThreeFrom,
              duration: time_to_duration_three,
              dayTo: dayTo,
              addressId: addressId,
            ));
          } catch (e) {
            print("opening Hour 9: " + e.toString());
            setState(() {
              hasException = true;
            });
          }
        } else {
          DateTime now = DateTime.now();
          DateTime fromThree = DateTime(
            now.year,
            now.month,
            now.day,
            dayThreeFrom.hour,
            dayThreeFrom.minute,
          );

          DateTime toThree = DateTime(
            now.year,
            now.month,
            now.day,
            dayThreeTo!.hour,
            dayThreeTo.minute,
          );

          var isNegative = toThree.difference(fromThree).isNegative;

          int time_to_duration = TimeSpan(
                  "${dayThreeFrom.hour.toString().padLeft(2, '0')}:${dayThreeFrom.minute.toString().padLeft(2, '0')}",
                  "${dayThreeTo.hour.toString().padLeft(2, '0')}:${dayThreeTo.minute.toString().padLeft(2, '0')}")
              .inMinutes;

          if (isNegative) {
            time_to_duration = time_to_duration.abs();
            if (dayConst == 7) {
              dayTo = 1;
            } else {
              dayTo = dayConst + 1;
            }
          }

          DateTime secondEndingTime = DateTime(
            now.year,
            now.month,
            now.day,
            dayTwoTo.hour,
            dayTwoTo.minute,
          );

          DateTime thirdBeginningTime = DateTime(
            now.year,
            now.month,
            now.day,
            dayThreeFrom.hour,
            dayThreeFrom.minute,
          );

          var isBetweenEndingAndBeginningNegative =
              thirdBeginningTime.difference(secondEndingTime).isNegative;

          if (isBetweenEndingAndBeginningNegative) {
            if (dayConst == 7) {
              dayFrom = 1;
              dayTo = 1;
            } else {
              dayFrom = dayConst + 1;
              dayTo = dayConst + 1;
            }
          }
          try {
            await Provider.of<OpeningHours>(context, listen: false)
                .addOpeningHour(OpeningHour(
              day: dayConst,
              dayFrom: dayFrom,
              timeFrom: dayThreeFrom,
              duration: time_to_duration,
              dayTo: dayTo,
              addressId: addressId,
            ));
          } catch (e) {
            print("opening Hour 10: " + e.toString());
            setState(() {
              hasException = true;
            });
          }
        }
      }
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
