import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mime/mime.dart';
import '../main.dart';
import '../providers/qroffer.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../helper/home_or_permission_screen.dart';
import '../providers/stad.dart';
import 'package:permission_handler/permission_handler.dart';
import '../home.dart';
import '../widgets/countdown_widget.dart';
import '../widgets/shimmer_widget.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../helper/utils.dart';
import 'package:path/path.dart' as path;
import '../screens/splash.dart';
import '../widgets/video_widget.dart';
import '../widgets/videoplayer_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';
import 'package:uuid/uuid.dart';
import '../helper/checkbox_state.dart';
import '../providers/address.dart';
import '../providers/addresses.dart';
import '../providers/categorys.dart';
import '../providers/opening_hour.dart';
import '../providers/opening_hours.dart';
import '../providers/qroffers.dart';
import '../providers/stads.dart';
import '../providers/subcategorys.dart';
import '../providers/subsubcategory.dart';
import '../providers/subsubcategorys.dart';
import 'package:provider/provider.dart';
import 'package:timezone/standalone.dart' as tz;

class AddQrofferScreen extends StatefulWidget {
  const AddQrofferScreen({Key? key}) : super(key: key);

  static const routeName = '/add_qroffer';
  @override
  _AddQrofferScreenState createState() => _AddQrofferScreenState();
}

class _AddQrofferScreenState extends State<AddQrofferScreen> {
  final _formKeyShort = GlobalKey<FormState>();
  final _formKeyLong = GlobalKey<FormState>();

  late Address _address;

  bool uploadFinished = false;

  final String _closeScreenTitle =
      "Are u sure? - The annoying question, u know... 😅😆";

  final String _closeScreen = "Yes";
  final String _notCloseScreen = "Cancel";

  final String closeScreen = "Close";

  bool _isLoading = false;

  int _durationAdvertisement = 0;
  Color fileBorderColor = Colors.grey;
  Color checkboxColor = Color.fromRGBO(112, 184, 73, 1.0);

  bool _hasSubSubrubric = false;

  bool hasFlatrate = false;

  bool _isTimeActive = false;
  bool _previewIsOpen = false;
  bool _previewHomeFeedIsOpen = false;
  bool _previewDetailIsOpen = false;
  double price = 3.33;
  bool _cupertinoPickerSelectAddressChange = false;
  int? _addressIndex;
  bool _loading = false;
  bool _hasQrAdvertisement = false;
  double? _myLongitude;
  double? _myLatitude;

  List<dynamic> _files = [];

  DateTime? _minTimeFrom;
  DateTime? _maxTimeFrom;
  DateTime? _minTimeTo;
  DateTime? _maxTimeTo;
  DateTime? _setMinTimeFrom;
  DateTime? _setMinTimeTo;
  DateTime? _dummyTimeFrom;
  DateTime? _dummyTimeTo;

  late tz.Location timeZoneOfStore;
  late DateTime nowTz;

  List<DateTimeRange> _openingHoursInDates = [];

  List<DateTimeRange> calculatedDates = [];

  bool noOpeningHours = false;

  TextEditingController _counterController = TextEditingController();

  int _counterOne = 1;

  String getTimeStringFromDouble(double value) {
    if (value < 0) return 'Invalid Value';
    int flooredValue = value.floor();
    double decimalValue = value - flooredValue;
    String hourValue = getHourString(flooredValue);
    String minuteString = getMinuteString(decimalValue);

    return '$hourValue : $minuteString';
  }

  double? getMinute(double decimalValue) {
    if (decimalValue != null) {
      return (decimalValue * 60);
    }
  }

  String getMinuteString(double decimalValue) {
    return '${(decimalValue * 60).toInt()}'.padLeft(2, '0');
  }

  String getHourString(int flooredValue) {
    return '${flooredValue % 24}'.padLeft(2, '0');
  }

  TextEditingController _shortDescriptionController = TextEditingController();
  TextEditingController _longDescriptionController = TextEditingController();

  TimeOfDay timeNow = TimeOfDay.now();

  var now = DateTime.now();
  String? resultOpeningHourTimeFrom;
  int? resultOpeningHourTimeTo;

  List<String> uploadedImageUrl = [];

  List<Address> _myAddresses = [];
  Address? _setAddress;

  List<Subsubcategory> _subsubcategorys = [];
  String? _subsubcategoryId;
  late DateTime _familyFlatrate;
  bool _hasFlatrate = false;

  late List<OpeningHour> _openingHours;
  Completer<GoogleMapController> _mapsController = Completer();

  Color? _buttonColor = Colors.grey[350];

  CameraPosition _cameraPosition() {
    return CameraPosition(
      target: LatLng(_address.latitude, _address.longitude), //TODO
      zoom: 11.1,
    );
  }

  CameraPosition animateCameraToNextStore() {
    return CameraPosition(
        target: LatLng(_address.latitude, _address.longitude), zoom: 12);
  }

  Future<void> _goToNextStore() async {
    GoogleMapController controller = await _mapsController.future;
    await controller.animateCamera(
        CameraUpdate.newCameraPosition(animateCameraToNextStore()));
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services

      print("testing");

      await Alert(
        context: context,
        type: AlertType.error,
        title: "Allow location service",
        desc: "We need to know the location so that you can create STAD",
        buttons: [
          DialogButton(
            child: Text(
              "Open Settings",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            onPressed: () async {
              await openAppSettings();
              Navigator.pop(context);
            },
            width: MediaQuery.of(context).size.width * 0.3,
          ),
          DialogButton(
            child: Text(
              "Go back",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            onPressed: () async {
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            },
            width: MediaQuery.of(context).size.width * 0.3,
          )
        ],
      ).show();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      await Alert(
        context: context,
        type: AlertType.error,
        title: "Allow location service",
        desc: "We need to know the location so that you can create STAD",
        buttons: [
          DialogButton(
            child: Text(
              "Open Settings",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            onPressed: () async {
              await openAppSettings();
              Navigator.pop(context);
            },
            width: MediaQuery.of(context).size.width * 0.3,
          ),
          DialogButton(
            child: Text(
              "Go back",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            onPressed: () async {
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            },
            width: MediaQuery.of(context).size.width * 0.3,
          )
        ],
      ).show();
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      await Alert(
        context: context,
        type: AlertType.error,
        title: "Allow location service",
        desc: "We need to know the location so that you can create STAD",
        buttons: [
          DialogButton(
            child: Text(
              "Open Settings",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            onPressed: () async {
              await openAppSettings();
              Navigator.pop(context);
            },
            width: MediaQuery.of(context).size.width * 0.3,
          ),
          DialogButton(
            child: Text(
              "Go back",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            onPressed: () async {
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            },
            width: MediaQuery.of(context).size.width * 0.3,
          )
        ],
      ).show();
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      return Future.error('Location permissions are denied');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Position position = await Geolocator.getCurrentPosition(
          timeLimit: const Duration(seconds: 3),
          desiredAccuracy: LocationAccuracy.low);

      if (position != null) {
        _myLatitude = position.latitude;
        _myLongitude = position.longitude;
      }
      return position;
    } catch (e) {
      try {
        var lastKnownPosition = await Geolocator.getLastKnownPosition();

        if (lastKnownPosition != null) {
          _myLatitude = lastKnownPosition.latitude;
          _myLongitude = lastKnownPosition.longitude;
          return lastKnownPosition;
        } else {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low);

          if (position != null) {
            _myLatitude = position.latitude;
            _myLongitude = position.longitude;
          }
          return position;
        }
      } catch (e) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low);

        if (position != null) {
          _myLatitude = position.latitude;
          _myLongitude = position.longitude;
        }
        return position;
      }
    }
  }

  late String _timezone;
  late List<String> _availableTimezones;

  String? _setAddressName;

  List<CheckboxState> checkboxListSubSubRubric = [];
  CheckboxState selectAllCheckboxes = CheckboxState(title: "Select All");
  List<String> pickedCheckboxIds = [];
  List<String> _imgOrVidUrls = [];
  double _visibleMeters = 3000.0;
  double _notificationMeters = 2500.0;

  DateRangePickerController _controller = DateRangePickerController();
  void _onShortDescriptionFocusChange() {
    if (_shortDescriptionFocusNode.hasFocus == false) {
      if (_shortDescriptionController.text.isEmpty) {
        _formKeyShort.currentState!.validate();
      } else {
        _formKeyShort.currentState!.validate();
      }
    }
  }

  void _onLongDescriptionFocusChange() {
    if (_longDescriptionFocusNode.hasFocus == false) {
      if (_longDescriptionController.text.isEmpty) {
        _formKeyLong.currentState!.validate();
      } else {
        _formKeyLong.currentState!.validate();
      }
    }
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
    });

    String id = _address.id!;
    await Provider.of<Addresses>(context, listen: false).fetchAllMyAddresses();
    _address =
        await Provider.of<Addresses>(context, listen: false).findById(id);

    if (_shortDescriptionController.text.length < 3 ||
        _shortDescriptionController.text.length > 60 ||
        _longDescriptionController.text.length < 3 ||
        _longDescriptionController.text.length > 600 ||
        _expiryDate == null ||
        _address.isActive! == false ||
        (pickedCheckboxIds.isEmpty && _address.subsubcategoryId == null) ||
        noOpeningHours ||
        !_timesAreValid) {
      String errorDialogText = "Your advertisement could not be created!";

      String errorDetailText = "";

      if (_shortDescriptionController.text.length < 3) {
        errorDetailText = errorDetailText +
            "Short description: Should be at least 3 characters";
      }
      if (_shortDescriptionController.text.length > 60) {
        errorDetailText = errorDetailText +
            "\n- Short description: Should be maximum 60 characters.";
      }
      if (_longDescriptionController.text.length < 3) {
        errorDetailText = errorDetailText +
            "\n- Long Description: Should be at least 3 characters.";
      }
      if (_longDescriptionController.text.length > 600) {
        errorDetailText = errorDetailText +
            "\n- Long description: Should be maximum 600 characters.";
      }
      if (_expiryDate == null) {
        errorDetailText =
            errorDetailText + "\n- Select Expiry Date for QR-Code.";
        setState(() {
          _expiryDateButtonTextColor = Colors.red;
        });
      }
      if (_address.isActive == false) {
        errorDetailText = errorDetailText + "\n- Address is not activated.";
      }

      if (pickedCheckboxIds.isEmpty) {
        errorDetailText =
            errorDetailText + "\n- Select minimum one SubSubCategory.";
        setState(() {
          checkboxColor = Colors.red;
        });
      }

      if (noOpeningHours) {
        errorDetailText = errorDetailText +
            "\n- Your selected Store has not opening hours. Edit your Store.";
      }

      if (!_timesAreValid) {
        errorDetailText = errorDetailText + "\n- Selected times are not valid.";
      }

      await Alert(
        context: context,
        type: AlertType.error,
        title: errorDialogText,
        desc: errorDetailText,
        buttons: [
          DialogButton(
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
      setState(() {
        _loading = false;
      });
    } else {
      double? parsedPrice = double.tryParse(price.toStringAsFixed(2));

      if (parsedPrice != null) {
        List<String> subsubcategorys = [];

        if (_address.subsubcategoryId != null) {
          subsubcategorys.clear();

          subsubcategorys.add(_address.subsubcategoryId!);
        }
        print("asdf");

        if (!hasException) {
          try {
            await Provider.of<Qroffers>(context, listen: false).addQroffer(
              Qroffer(
                latitude: _address.latitude,
                longitude: _address.longitude,
                shortDescription: _shortDescriptionController.text,
                longDescription: _longDescriptionController.text,
                price: parsedPrice,
                displayRadius: _visibleMeters.roundToDouble(),
                pushNotificationRadius: _notificationMeters.roundToDouble(),
                addressId: _address.id!,
                subsubcategoryIds: _address.subsubcategoryId != null
                    ? subsubcategorys
                    : pickedCheckboxIds,
                begin: _dateTimeRange!.start.toUtc(),
                end: _dateTimeRange!.end.toUtc(),
                invoiceAddressId: _address.invoiceAddressId.toString(),
                qrValue: _counterOne,
                expiryDate: tz.TZDateTime(
                  timeZoneOfStore,
                  _expiryDate!.year,
                  _expiryDate!.month,
                  _expiryDate!.day,
                  23,
                  59,
                  59,
                  999,
                  999,
                ),
              ),
            );
          } catch (e) {
            setState(() {
              hasException = true;
            });
            await Alert(
              context: context,
              type: AlertType.error,
              title: "QROFFER could not advertised.",
              desc: e.toString(),
              buttons: [
                DialogButton(
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                  width: 120,
                )
              ],
            ).show();
          }
        }
        if (!hasException) {
          await Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => HomeScreen(
                      isOpen: false, stream: streamController.stream)),
              (route) => false);
        }
        setState(() {
          _loading = false;
        });
        hasException = false;
      } else {
        await Alert(
          context: context,
          type: AlertType.error,
          title: "QROFFER could not advertised.",
          buttons: [
            DialogButton(
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () async {
                Navigator.pop(context);
              },
              width: 120,
            )
          ],
        ).show();

        // await Navigator.of(context)
        //     .pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false);
        setState(() {
          _loading = false;
        });
        hasException = false;
      }
    }
  }

  final _shortDescriptionFocusNode = FocusNode();
  final _longDescriptionFocusNode = FocusNode();

  final _counterFocusNode = FocusNode();

  DateTime? _expiryDate;
  String _expiryDateString = "Select expiry date of QR-Code";
  Color _expiryDateButtonTextColor = Colors.white;

  bool _isInit = true;
  bool hasException = false;

  DateTimeRange? _dateTimeRange;
  List openingHoursAndDays = [];
  bool _calendarDatesSelected = true;
  bool _timeSpinnerIsLoading = true;

  List<DateTimeRange> addedRanges = [];

  Future<void> _initData() async {
    try {
      _timezone = await FlutterNativeTimezone.getLocalTimezone();
    } catch (e) {
      print('Could not get the local timezone');
    }
    try {
      _availableTimezones = await FlutterNativeTimezone.getAvailableTimezones();
      _availableTimezones.sort();
    } catch (e) {
      print('Could not get available timezones');
    }
    if (mounted) {
      setState(() {});
    }
  }

  var _counterKey = GlobalKey();

  bool _timesAreValid = true;

  void _onCounterFocusChange() {
    if (_counterFocusNode.hasFocus == false) {
      _counterController.text.trim();
      if (_counterController.text.isEmpty) {
        setState(() {
          _counterOne = 1;
          _counterController.text = _counterOne.toString();
        });
      } else {
        if (int.parse(_counterController.text) <= 50 ||
            int.parse(_counterController.text) >= 1) {
          setState(() {
            _counterOne = int.parse(_counterController.text);
            _counterController.text = _counterOne.toString();
          });
        }
        if (int.parse(_counterController.text) < 1) {
          setState(() {
            _counterOne = 1;
            _counterController.text = _counterOne.toString();
          });
        }
        if (int.parse(_counterController.text) > 50) {
          setState(() {
            _counterOne = 50;
            _counterController.text = _counterOne.toString();
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _shortDescriptionController.dispose();
    _longDescriptionController.dispose();
    _shortDescriptionFocusNode.dispose();
    _longDescriptionFocusNode.dispose();
    pickedCheckboxIds.clear();
    checkboxListSubSubRubric.clear();
    selectAllCheckboxes.value = false;
    _counterFocusNode.dispose();
    _counterController.dispose();
    _isInit = true;
    _previewIsOpen = false;
    _loading = false;

    super.dispose();
  }

  bool _pageIsLoading = false;
  bool _calendarChange = true;
  bool _dateRangePickerIsLoading = false;

  int totalDurationInMinutes = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _pageIsLoading = true;
      });
      pickedCheckboxIds.clear();

      checkboxListSubSubRubric.clear();
      Provider.of<Categorys>(context, listen: false)
          .fetchAllCategorys()
          .then((_) {
        Provider.of<Subcategorys>(context, listen: false)
            .fetchAllSubcategorys()
            .then((_) {
          Provider.of<Subsubcategorys>(context, listen: false)
              .fetchAllSubsubcategorys()
              .then((_) {
            Provider.of<Addresses>(context, listen: false)
                .fetchAllMyAddresses()
                .then((_) {
              checkboxListSubSubRubric.clear();
              _myAddresses =
                  Provider.of<Addresses>(context, listen: false).notDeleted;
              _address = _myAddresses.first;
              timeZoneOfStore = tz.getLocation(_address.timezone![0]);
              nowTz = tz.TZDateTime.now(timeZoneOfStore);

              if (_address.subsubcategoryId == null) {
                setState(() {
                  _hasSubSubrubric = false;
                });
              } else {
                setState(() {
                  _hasSubSubrubric = true;
                });
              }

              _subsubcategorys =
                  Provider.of<Subsubcategorys>(context, listen: false)
                      .findBySubcategoryId(_address.subcategoryId);

              _subsubcategorys.forEach((sbctgrs) {
                checkboxListSubSubRubric.add(
                  CheckboxState(
                    id: sbctgrs.id,
                    title: sbctgrs.name,
                  ),
                );
              });

              Provider.of<OpeningHours>(context, listen: false)
                  .fetchAllMyOpeningHours()
                  .then((_) {
                _openingHours =
                    Provider.of<OpeningHours>(context, listen: false)
                        .findByAddressId(_address.id!);
                if (_openingHours.isEmpty) {
                  setState(() {
                    noOpeningHours = true;
                  });
                } else {
                  setState(() {
                    noOpeningHours = false;
                  });
                  calculateDates();
                  minimumTimeFrom();
                  maximumTimeFrom();
                  minimumTimeTo();
                  maximumTimeTo();

                  DateTime? start = calculatedDates.first.start;
                  DateTime? end = calculatedDates.first.duration.inMinutes < 15
                      ? calculatedDates[1].start.add(Duration(
                          minutes:
                              15 - calculatedDates.first.duration.inMinutes))
                      : calculatedDates.first.start
                          .add(const Duration(minutes: 15));

                  _dateTimeRange = DateTimeRange(start: start, end: end);

                  calculateAdvertisedTime(
                      dateTimeRange: _dateTimeRange!, hasException: false);
                  _hasFlatrateMethod();
                  initialDates();
                }
                Provider.of<Stads>(context, listen: false)
                    .fetchAllMyStads()
                    .then((_) {
                  Provider.of<Qroffers>(context, listen: false)
                      .fetchAllMyQroffers()
                      .then((_) {
                    try {
                      _determinePosition().then((_) {
                        _initData().then((_) {
                          setState(() {
                            _pageIsLoading = false;
                            _isInit = false;
                            _timeSpinnerIsLoading = false;
                          });
                        });
                      });
                    } catch (e) {
                      print("hier schau mal: " + e.toString());
                    }
                  });
                });
              });
            });
          });
        });
      });
    }
  }

  _hasFlatrateMethod() {
    if (DateTime.now().toUtc().isBefore(_address.flatrateDateStad!.toUtc())) {
      _hasFlatrate = false;
    } else {
      _hasFlatrate = false;
    }
  }

  _selectAddress({
    required BuildContext context,
    required double width,
    required double height,
  }) {
    if (Platform.isAndroid) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: DropdownButton<dynamic>(
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              _dateRangePickerIsLoading = true;
            });
          },
          isExpanded: true,
          items: _myAddresses.map((Address dropDownItem) {
            return DropdownMenuItem<dynamic>(
              value: dropDownItem,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dropDownItem.name!,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${dropDownItem.street}, ${dropDownItem.postcode}, ${dropDownItem.city}, ${dropDownItem.country}",
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (dynamic newValueSelected) async {
            _dummyTimeFrom = null;
            _dummyTimeTo = null;

            setState(() {
              checkboxListSubSubRubric.clear();
              pickedCheckboxIds.clear();
            });
            setState(() {
              selectAllCheckboxes.value = false;
            });
            setState(() {
              _address = newValueSelected;
            });
            timeZoneOfStore = tz.getLocation(_address.timezone![0]);
            nowTz = tz.TZDateTime.now(timeZoneOfStore);

            if (_address.subsubcategoryId == null) {
              setState(() {
                _hasSubSubrubric = false;
              });
            } else {
              setState(() {
                _hasSubSubrubric = true;
              });
            }

            _subsubcategorys.clear();
            _subsubcategorys =
                Provider.of<Subsubcategorys>(context, listen: false)
                    .findBySubcategoryId(_address.subcategoryId);

            _subsubcategorys.forEach((sbctgrs) {
              checkboxListSubSubRubric.add(
                CheckboxState(
                  id: sbctgrs.id,
                  title: sbctgrs.name,
                ),
              );
            });
            setState(() {
              _calendarDatesSelected = false;
            });
            _openingHours.clear();
            setState(() {
              _openingHours = Provider.of<OpeningHours>(context, listen: false)
                  .findByAddressId(_address.id!);
            });

            if (_openingHours.isEmpty) {
              setState(() {
                noOpeningHours = true;
              });
            } else {
              setState(() {
                noOpeningHours = false;
              });

              calculateDates();
              minimumTimeFrom();
              maximumTimeFrom();
              minimumTimeTo();
              maximumTimeTo();

              DateTime start = calculatedDates.first.start;
              DateTime end = calculatedDates.first.duration.inMinutes < 15
                  ? calculatedDates[1].start.add(Duration(
                      minutes: 15 - calculatedDates.first.duration.inMinutes))
                  : calculatedDates.first.start
                      .add(const Duration(minutes: 15));
              _dateTimeRange = DateTimeRange(start: start, end: end);

              setState(() {
                _controller.selectedRange = PickerDateRange(start, end);
              });

              calculateAdvertisedTime(
                  dateTimeRange: _dateTimeRange!, hasException: false);
              _hasFlatrateMethod();

              setState(() {
                _calendarDatesSelected = true;
              });
              setState(() {
                _dateRangePickerIsLoading = false;
              });
            }
            try {
              await _goToNextStore();
            } catch (e) {
              print(e);
            }
          },
          value: _address,
        ),
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width * 0.7,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: _buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(23.1),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _address.name!,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              Text(
                "${_address.street}, ${_address.postcode}, ${_address.city}, ${_address.country}",
                style: const TextStyle(
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          onPressed: () async {
            setState(() {
              _cupertinoPickerSelectAddressChange = false;
              _addressIndex = null;
            });

            await showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.045,
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.only(
                                right:
                                    MediaQuery.of(context).size.width * 0.03),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                  onPressed: () async {
                                    _dummyTimeFrom = null;
                                    _dummyTimeTo = null;
                                    if (checkboxListSubSubRubric.isNotEmpty) {
                                      setState(() {
                                        checkboxListSubSubRubric.clear();
                                      });
                                    }
                                    setState(() {
                                      selectAllCheckboxes.value = false;
                                    });

                                    pickedCheckboxIds.clear();

                                    setState(() {
                                      selectAllCheckboxes.value = false;
                                    });
                                    if (_cupertinoPickerSelectAddressChange ==
                                        true) {
                                      setState(() {
                                        _address = _myAddresses[_addressIndex!];
                                      });
                                      timeZoneOfStore =
                                          tz.getLocation(_address.timezone![0]);
                                      nowTz =
                                          tz.TZDateTime.now(timeZoneOfStore);

                                      _subsubcategorys.clear();

                                      _subsubcategorys =
                                          Provider.of<Subsubcategorys>(context,
                                                  listen: false)
                                              .findBySubcategoryId(
                                                  _address.subcategoryId);

                                      _subsubcategorys.forEach((sbctgrs) {
                                        checkboxListSubSubRubric.add(
                                          CheckboxState(
                                            id: sbctgrs.id,
                                            title: sbctgrs.name,
                                          ),
                                        );
                                      });
                                      _openingHours.clear();
                                      _openingHours = Provider.of<OpeningHours>(
                                              context,
                                              listen: false)
                                          .findByAddressId(_address.id!);

                                      if (_myAddresses[_addressIndex!]
                                              .subsubcategoryId ==
                                          null) {
                                        setState(() {
                                          _hasSubSubrubric = false;
                                        });
                                      } else {
                                        setState(() {
                                          _hasSubSubrubric = true;
                                        });
                                      }
                                      if (_openingHours.isEmpty) {
                                        setState(() {
                                          noOpeningHours = true;
                                        });
                                      } else {
                                        setState(() {
                                          noOpeningHours = false;
                                        });

                                        calculateDates();
                                        minimumTimeFrom();
                                        maximumTimeFrom();
                                        minimumTimeTo();
                                        maximumTimeTo();

                                        DateTime start =
                                            calculatedDates.first.start;
                                        DateTime end = calculatedDates
                                                    .first.duration.inMinutes <
                                                15
                                            ? calculatedDates[1].start.add(
                                                Duration(
                                                    minutes: 15 -
                                                        calculatedDates
                                                            .first
                                                            .duration
                                                            .inMinutes))
                                            : calculatedDates.first.start.add(
                                                const Duration(minutes: 15));
                                        _dateTimeRange = DateTimeRange(
                                            start: start, end: end);
                                        setState(() {
                                          _controller.selectedRange =
                                              PickerDateRange(start, end);
                                        });

                                        calculateAdvertisedTime(
                                            dateTimeRange: _dateTimeRange!,
                                            hasException: false);
                                        _hasFlatrateMethod();
                                        initialDates();
                                        setState(() {
                                          _calendarDatesSelected = false;
                                        });
                                      }
                                      Navigator.of(context).pop();

                                      if (_myAddresses[_addressIndex!].name !=
                                          null) {
                                        setState(() {
                                          _setAddressName =
                                              _myAddresses[_addressIndex!].name;
                                        });
                                      }
                                      try {
                                        await _goToNextStore();
                                      } catch (e) {
                                        print(e);
                                      }
                                    } else {
                                      setState(() {
                                        _address = _myAddresses.first;
                                      });
                                      timeZoneOfStore =
                                          tz.getLocation(_address.timezone![0]);
                                      nowTz =
                                          tz.TZDateTime.now(timeZoneOfStore);

                                      if (_address.subsubcategoryId == null) {
                                        setState(() {
                                          _hasSubSubrubric = false;
                                        });
                                      } else {
                                        setState(() {
                                          _hasSubSubrubric = true;
                                        });
                                      }

                                      if (_myAddresses.first.name != null) {
                                        setState(() {
                                          _setAddressName =
                                              _myAddresses.first.name;
                                        });
                                      }
                                      _subsubcategorys.clear();
                                      _subsubcategorys =
                                          Provider.of<Subsubcategorys>(context,
                                                  listen: false)
                                              .findBySubcategoryId(
                                                  _address.subcategoryId);

                                      _subsubcategorys.forEach((sbctgrs) {
                                        checkboxListSubSubRubric.add(
                                          CheckboxState(
                                            id: sbctgrs.id,
                                            title: sbctgrs.name,
                                          ),
                                        );
                                      });
                                      _openingHours.clear();

                                      setState(() {
                                        _openingHours =
                                            Provider.of<OpeningHours>(context,
                                                    listen: false)
                                                .findByAddressId(_address.id!);
                                      });

                                      if (_openingHours.isEmpty) {
                                        setState(() {
                                          noOpeningHours = true;
                                        });
                                      } else {
                                        setState(() {
                                          _calendarDatesSelected = false;
                                        });

                                        calculateDates();
                                        minimumTimeFrom();
                                        maximumTimeFrom();
                                        minimumTimeTo();
                                        maximumTimeTo();

                                        DateTime start =
                                            calculatedDates.first.start;
                                        DateTime end = calculatedDates
                                                    .first.duration.inMinutes <
                                                15
                                            ? calculatedDates[1].start.add(
                                                Duration(
                                                    minutes: 15 -
                                                        calculatedDates
                                                            .first
                                                            .duration
                                                            .inMinutes))
                                            : calculatedDates.first.start.add(
                                                const Duration(minutes: 15));
                                        _dateTimeRange = DateTimeRange(
                                            start: start, end: end);

                                        setState(() {
                                          _controller.selectedRange =
                                              PickerDateRange(start, end);
                                        });

                                        calculateAdvertisedTime(
                                            dateTimeRange: _dateTimeRange!,
                                            hasException: false);
                                        _hasFlatrateMethod();
                                        initialDates();
                                      }
                                      Navigator.of(context).pop();
                                      try {
                                        await _goToNextStore();
                                      } catch (e) {
                                        print(e);
                                      }
                                    }
                                  },
                                  child: const Text("Done")),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.345,
                        color: Colors.white,
                        child: CupertinoPicker(
                          itemExtent: MediaQuery.of(context).size.height * 0.05,
                          diameterRatio: 1.0,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _addressIndex = index;
                              _cupertinoPickerSelectAddressChange = true;
                            });
                          },
                          children: _myAddresses
                              .map(
                                (item) => Center(
                                  child: Container(
                                    width: width * 0.9,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.name!,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          "${item.street}, ${item.postcode}, ${item.city}, ${item.country}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      )
                    ],
                  );
                });
          },
        ),
      );
    }
  }

  bool _textFieldsEnabled = true;

  Set<Marker> marker() {
    return Set.from(List.generate(1, (index) {
      return Marker(
        markerId: MarkerId(_address.id!),
        position: LatLng(_address.latitude, _address.longitude), //TODO
      );
    }));
    // return Set.from(List.generate(_myAddresses.length, (index) {
    //   return Marker(
    //     markerId: MarkerId(_myAddresses[index].id!),
    //     position: LatLng(
    //         _myAddresses[index].latitude, _myAddresses[index].longitude), //TODO
    //   );
    // }));
  }

  Set<Circle> circles() {
    return {
      Circle(
        circleId: const CircleId("1"),
        center: LatLng(_address.latitude, _address.longitude),
        radius: _notificationMeters,
        fillColor: const Color.fromRGBO(254, 166, 42, 0.6),
        strokeWidth: 1,
        strokeColor: Colors.black87,
      ),
      Circle(
        circleId: const CircleId("2"),
        center: LatLng(_address.latitude, _address.longitude), //TODO
        radius: _visibleMeters,
        fillColor: const Color.fromRGBO(245, 231, 62, 0.3),
        strokeWidth: 1,
        strokeColor: Colors.black87,
      )
    };
  }

  @override
  void initState() {
    super.initState();
    _shortDescriptionFocusNode.addListener(_onShortDescriptionFocusChange);
    _longDescriptionFocusNode.addListener(_onLongDescriptionFocusChange);
    _counterFocusNode.addListener(_onCounterFocusChange);
    _counterController = TextEditingController(text: _counterOne.toString());
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverSafeArea(
                    top: false,
                    bottom: false,
                    sliver: SliverAppBar(
                      floating: true,
                      snap: true,
                      pinned: true,
                      systemOverlayStyle: SystemUiOverlayStyle.light,

                      // collapsedHeight: MediaQuery.of(context).size.height * 0.061,
                      toolbarHeight: MediaQuery.of(context).size.height * 0.06,
                      actions: [
                        TextButton(
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _previewIsOpen = true;
                              _previewHomeFeedIsOpen = true;
                              _previewDetailIsOpen = false;
                            });

                            await showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return _previewScreen();
                                });
                          },
                          child: const Text(
                            "Preview",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                            alignment: Alignment.center,
                            primary: Color.fromRGBO(253, 166, 41, 1.0),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadiusDirectional.circular(33),
                            ),
                          ),
                        ),
                      ],
                      bottom: PreferredSize(
                        preferredSize: Size.fromHeight(0),
                        child: Container(),
                      ),
                      leading: IconButton(
                        onPressed: () async =>
                            await _closeScreenDialog(context),
                        icon: Icon(
                          FontAwesomeIcons.angleLeft,
                        ),
                      ),
                      title: const Text('Create QROFFER',
                          style: TextStyle(color: Colors.white)),
                      flexibleSpace: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Color.fromRGBO(107, 176, 62, 1.0),
                              Color.fromRGBO(153, 199, 58, 1.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ];
            },
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                _videoIsThere = false;
              },
              child: SafeArea(
                top: false,
                bottom: true,
                child: Builder(
                  builder: (context) => CustomScrollView(
                    slivers: [
                      SliverOverlapInjector(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.only(
                          top: _height * 0.021,
                          right: _width * 0.0333,
                          left: _width * 0.0333,
                        ),
                        sliver: SliverStack(
                          children: [
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        color: Theme.of(context).primaryColor,
                                        width: _width * 0.21,
                                        height: _height * 0.00072,
                                      ),
                                      SizedBox(
                                        width: _width * 0.03,
                                      ),
                                      Text(
                                        "Selected Store:",
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      SizedBox(
                                        width: _width * 0.03,
                                      ),
                                      Container(
                                        color: Theme.of(context).primaryColor,
                                        width: _width * 0.21,
                                        height: _height * 0.00072,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: _height * 0.01,
                                  ),
                                  Center(
                                    child: _pageIsLoading
                                        ? ShimmerWidget.circular(
                                            width: _width * 0.7,
                                            height: _height * 0.045,
                                            shapeBorder:
                                                const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(23.1),
                                              ),
                                            ),
                                          )
                                        : _myAddresses.isEmpty
                                            ? Text(
                                                'Either you already have current advertisements for all your addresses, or your addresses have not yet been confirmed by our NN-Team')
                                            : _selectAddress(
                                                context: context,
                                                height: _height,
                                                width: _width),
                                  ),
                                  SizedBox(
                                    height: _height * 0.03,
                                  ),
                                  _pageIsLoading || _dateRangePickerIsLoading
                                      ? ShimmerWidget.rectengular(
                                          height: _height * 0.36,
                                        )
                                      : noOpeningHours
                                          ? Center(
                                              child: Text(
                                                "Keine Öffnungszeiten",
                                                style: TextStyle(
                                                  fontSize: 21,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : dateRangePicker(context),
                                  if (_isTimeActive == true && !noOpeningHours)
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01,
                                    ),
                                  _formAndTextFormField(
                                    enabled: _textFieldsEnabled,
                                    maxLines: null,
                                    nextFocusNode: _longDescriptionFocusNode,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter a Short Description';
                                      }
                                      if (value.length < 3) {
                                        return 'Should be at least 3 characters';
                                      }
                                      if (value.length > 60) {
                                        return 'Maximum 60 characters';
                                      }
                                      return null;
                                    },
                                    key: _formKeyShort,
                                    focusNode: _shortDescriptionFocusNode,
                                    textController: _shortDescriptionController,
                                    maxLength: 60,
                                    labelText: 'Short Description',
                                    textInputType: TextInputType.text,
                                  ),
                                  _formAndTextFormField(
                                    enabled: _textFieldsEnabled,
                                    maxLines: null,
                                    textInputAction: null,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter a Long Description';
                                      }
                                      if (value.length < 3) {
                                        return 'Should be at least 3 characters long';
                                      }
                                      if (value.length > 600) {
                                        return 'Maximum 600 charackters';
                                      }
                                    },
                                    key: _formKeyLong,
                                    focusNode: _longDescriptionFocusNode,
                                    textController: _longDescriptionController,
                                    maxLength: 600,
                                    labelText: 'Long Description',
                                    textInputType: TextInputType.multiline,
                                  ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      NumberPicker(
                                        selectedTextStyle: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 21,
                                        ),
                                        itemHeight: _height * 0.0405,
                                        textStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10.2,
                                        ),
                                        infiniteLoop: true,
                                        minValue: 1,
                                        maxValue: 50,
                                        value: _counterOne,
                                        onChanged: (value) => setState(
                                          () => _counterOne = value,
                                        ),
                                      ),
                                      SizedBox(width: _width * 0.0012),
                                      Text(
                                        "Value of QR´s",
                                        style: TextStyle(
                                            fontSize: 21, color: Colors.grey),
                                      )
                                    ],
                                  ),

                                  // Padding(
                                  //   padding: EdgeInsets.only(left: _width * 0.15),
                                  //   child: Center(
                                  //     child: Column(
                                  //       crossAxisAlignment: CrossAxisAlignment.start,
                                  //       children: [
                                  //         IconButton(
                                  //             onPressed: () {
                                  //               if (_counterOne == 50) {
                                  //                 setState(() {
                                  //                   _counterOne = 0;
                                  //                   _counterController =
                                  //                       TextEditingController(
                                  //                           text:
                                  //                               _counterOne.toString());
                                  //                 });
                                  //               }
                                  //               setState(() {
                                  //                 _counterOne++;
                                  //                 _counterController =
                                  //                     TextEditingController(
                                  //                         text: _counterOne.toString());
                                  //               });
                                  //             },
                                  //             icon: Icon(
                                  //                 Icons.add_circle_outline_rounded)),
                                  //         Padding(
                                  //           padding:
                                  //               EdgeInsets.only(left: _width * 0.045),
                                  //           child: Row(
                                  //             mainAxisAlignment:
                                  //                 MainAxisAlignment.start,
                                  //             children: [
                                  //               Container(
                                  //                 width: _width * 0.07,
                                  //                 child: TextField(
                                  //                   decoration:
                                  //                       InputDecoration.collapsed(
                                  //                     hintText: "",
                                  //                     border: InputBorder.none,
                                  //                   ),
                                  //                   maxLines: 1,
                                  //                   focusNode: _counterFocusNode,
                                  //                   controller: _counterController,
                                  //                   keyboardType: TextInputType.number,
                                  //                 ),
                                  //               ),
                                  //               SizedBox(width: _width * 0.1),
                                  //               Text(
                                  //                 "Value of QR´s",
                                  //                 style: TextStyle(
                                  //                     fontSize: 21, color: Colors.grey),
                                  //               )
                                  //             ],
                                  //           ),
                                  //         ),
                                  //         IconButton(
                                  //             onPressed: () {
                                  //               if (_counterOne == 1) {
                                  //                 setState(() {
                                  //                   _counterOne = 51;
                                  //                   _counterController =
                                  //                       TextEditingController(
                                  //                           text:
                                  //                               _counterOne.toString());
                                  //                 });
                                  //               }

                                  //               setState(() {
                                  //                 _counterOne--;
                                  //                 _counterController =
                                  //                     TextEditingController(
                                  //                         text: _counterOne.toString());
                                  //               });
                                  //             },
                                  //             icon: Icon(
                                  //                 Icons.remove_circle_outline_rounded)),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  Center(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: _buttonColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(23.0),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await _showDatePicker();
                                      },
                                      child: Text(
                                        _expiryDateString,
                                        style: TextStyle(
                                          color: _expiryDateButtonTextColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_hasSubSubrubric == false)
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .viewPadding
                                                  .top *
                                              0.5),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Text(
                                                "Zu welchen Unterkategorien passt dein QROFFER?"),
                                            SizedBox(
                                              height: _height * 0.03,
                                            ),
                                            Container(
                                              height: 333,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(9.0)),
                                                border: Border.all(
                                                  color: checkboxColor,
                                                ),
                                              ),
                                              child: Builder(
                                                builder: (context) =>
                                                    CustomScrollView(
                                                        shrinkWrap: true,
                                                        physics:
                                                            const ClampingScrollPhysics(),
                                                        slivers: [
                                                      SliverOverlapInjector(
                                                        handle: NestedScrollView
                                                            .sliverOverlapAbsorberHandleFor(
                                                                context),
                                                      ),
                                                      SliverList(
                                                        delegate:
                                                            SliverChildListDelegate(
                                                          [
                                                            buildAllSelectedCheckbox(
                                                                selectAllCheckboxes),
                                                            const Divider(
                                                              color: Colors
                                                                  .black45,
                                                            ),
                                                            ...checkboxListSubSubRubric
                                                                .map(
                                                                    buildCheckBox)
                                                                .toList(),
                                                          ],
                                                        ),
                                                      ),
                                                    ]),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  SizedBox(
                                    height: _height * 0.03,
                                  ),
                                  //Select Address
                                  _pageIsLoading
                                      ? ShimmerWidget.rectengular(
                                          height: _height * 0.4,
                                          width: _width * 0.97,
                                        )
                                      : SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.97,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                          child: GoogleMap(
                                            onTap: (value) {
                                              FocusScope.of(context).unfocus();
                                            },
                                            gestureRecognizers: Set()
                                              ..add(Factory<
                                                      PanGestureRecognizer>(
                                                  () =>
                                                      PanGestureRecognizer())),
                                            zoomControlsEnabled: true,
                                            zoomGesturesEnabled: true,
                                            scrollGesturesEnabled: true,
                                            initialCameraPosition:
                                                _cameraPosition(),
                                            markers: marker(),
                                            circles: circles(),
                                            mapType: MapType.normal,
                                            onMapCreated: (GoogleMapController
                                                controller) {
                                              if (!_mapsController
                                                  .isCompleted) {
                                                //first calling is false
                                                //call "completer()"
                                                _mapsController
                                                    .complete(controller);
                                              }
                                            },
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: SfSliderTheme(
                                      data: SfSliderThemeData(
                                        thumbColor: Colors.white,
                                        activeTrackColor: const Color.fromRGBO(
                                            245, 231, 62, 1.0),
                                        inactiveTrackColor:
                                            const Color.fromRGBO(
                                                    245, 231, 62, 1.0)
                                                .withOpacity(0.5),
                                        activeDividerColor:
                                            const Color.fromRGBO(
                                                245, 231, 62, 1.0),
                                        activeTickColor: const Color.fromRGBO(
                                            245, 231, 62, 1.0),
                                        inactiveTickColor: const Color.fromRGBO(
                                                245, 231, 62, 1.0)
                                            .withOpacity(0.5),
                                        inactiveDividerColor:
                                            const Color.fromRGBO(
                                                    245, 231, 62, 1.0)
                                                .withOpacity(0.6),
                                        overlayColor: const Color.fromRGBO(
                                                245, 231, 62, 1.0)
                                            .withOpacity(0.5),
                                        disabledThumbColor: Colors.white,
                                        thumbStrokeColor: Colors.white,
                                        thumbRadius: 15,
                                        activeLabelStyle: const TextStyle(
                                            color: Colors.black, fontSize: 8.1),
                                        inactiveLabelStyle: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 8.1,
                                        ),
                                      ),
                                      child: SfSlider(
                                        min: 500.0,
                                        max: 5000.0,
                                        value: _visibleMeters,
                                        interval: 500,
                                        stepSize: 500,
                                        showLabels: true,
                                        showTicks: true,
                                        thumbIcon: Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.005),
                                            child: const Icon(
                                              FontAwesomeIcons.solidEye,
                                              color: Color.fromRGBO(
                                                  245, 231, 62, 1.0),
                                              size: 21,
                                            ),
                                          ),
                                        ),
                                        labelFormatterCallback:
                                            (dynamic actualValue,
                                                String formattedText) {
                                          double distanceInKiloMeters =
                                              actualValue / 1000;
                                          String roundDistanceInKM =
                                              distanceInKiloMeters
                                                  .toStringAsFixed(1);

                                          return '$roundDistanceInKM km';
                                        },
                                        onChanged: (dynamic newValue) {
                                          setState(() {
                                            _visibleMeters = newValue;
                                            if (_visibleMeters <=
                                                _notificationMeters) {
                                              _notificationMeters =
                                                  _visibleMeters;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3.0),
                                    child: SfSliderTheme(
                                      data: SfSliderThemeData(
                                        thumbColor: Colors.white,
                                        activeTrackColor: const Color.fromRGBO(
                                            254, 166, 42, 1.0),
                                        inactiveTrackColor:
                                            const Color.fromRGBO(
                                                    254, 166, 42, 1.0)
                                                .withOpacity(0.5),
                                        activeDividerColor:
                                            const Color.fromRGBO(
                                                254, 166, 42, 1.0),
                                        activeTickColor: const Color.fromRGBO(
                                            254, 166, 42, 1.0),
                                        inactiveTickColor: const Color.fromRGBO(
                                                254, 166, 42, 1.0)
                                            .withOpacity(0.5),
                                        inactiveDividerColor:
                                            const Color.fromRGBO(
                                                    254, 166, 42, 1.0)
                                                .withOpacity(0.6),
                                        overlayColor: const Color.fromRGBO(
                                                254, 166, 42, 1.0)
                                            .withOpacity(0.5),
                                        disabledThumbColor: Colors.white,
                                        thumbStrokeColor: Colors.white,
                                        thumbRadius: 15,
                                        activeLabelStyle: const TextStyle(
                                            color: Colors.black, fontSize: 8.1),
                                        inactiveLabelStyle: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 8.1,
                                        ),
                                      ),
                                      child: SfSlider(
                                        min: 500.0,
                                        max: 5000.0,
                                        value: _notificationMeters,
                                        interval: 500,
                                        stepSize: 500,
                                        showLabels: true,
                                        showTicks: true,
                                        thumbIcon: const Center(
                                          child: Icon(
                                            FontAwesomeIcons.solidBell,
                                            color: Color.fromRGBO(
                                                254, 166, 42, 1.0),
                                            size: 21,
                                          ),
                                        ),
                                        labelFormatterCallback:
                                            (dynamic actualValue,
                                                String formattedText) {
                                          double distanceInKiloMeters =
                                              actualValue / 1000;
                                          String roundDistanceInKM =
                                              distanceInKiloMeters
                                                  .toStringAsFixed(1);

                                          return '$roundDistanceInKM km';
                                        },
                                        onChanged: (dynamic newValue) {
                                          setState(() {
                                            _notificationMeters = newValue;
                                            if (_notificationMeters >
                                                _visibleMeters) {
                                              _visibleMeters =
                                                  _notificationMeters;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.03,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: _width * 0.21,
                                      right: _width * 0.21,
                                    ),
                                    // child: _selectDay(),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  //DATE range picker
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      if (_calendarDatesSelected &&
                                          !noOpeningHours)
                                        if (!_timeSpinnerIsLoading) _timeFrom(),
                                      if (_calendarDatesSelected &&
                                          !noOpeningHours)
                                        if (!_timeSpinnerIsLoading) _timeTo(),
                                      if (_timeSpinnerIsLoading)
                                        ShimmerWidget.circular(
                                          shapeBorder: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.333,
                                        ),
                                      if (_timeSpinnerIsLoading)
                                        ShimmerWidget.circular(
                                          shapeBorder: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.333,
                                        )
                                    ],
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  if (!_timeSpinnerIsLoading)
                                    if (_calendarDatesSelected)
                                      if (!noOpeningHours) textCardUnderTime()!,
                                  if (!noOpeningHours)
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03,
                                    ),
                                  if (_timesAreValid &&
                                      _calendarDatesSelected &&
                                      !_pageIsLoading &&
                                      !_timeSpinnerIsLoading &&
                                      !noOpeningHours)
                                    Center(
                                      child: Text(priceMethod() + " €",
                                          style: TextStyle(
                                              fontSize: 29,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold)),
                                    ),

                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(context).size.height *
                                              0.012,
                                      top: MediaQuery.of(context).size.height *
                                          0.0333,
                                    ),
                                    child: Center(
                                      child: _loading
                                          ? Center(
                                              child: Platform.isAndroid
                                                  ? const CircularProgressIndicator()
                                                  : const CupertinoActivityIndicator(),
                                            )
                                          : _pageIsLoading
                                              ? ShimmerWidget.circular(
                                                  shapeBorder:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            45),
                                                  ),
                                                  width: 300,
                                                  height: 70)
                                              : ConfirmationSlider(
                                                  text: "Advertise!",
                                                  foregroundColor:
                                                      Theme.of(context)
                                                          .primaryColor,
                                                  sliderButtonContent:
                                                      const Icon(
                                                    FontAwesomeIcons
                                                        .shoppingCart,
                                                    color: Colors.white,
                                                  ),
                                                  onConfirmation: () async {
                                                    await Alert(
                                                      context: context,
                                                      type: AlertType.info,
                                                      title:
                                                          "Press Confirm to purchase",
                                                      buttons: [
                                                        DialogButton(
                                                          child: Text(
                                                            "Confirm",
                                                          ),
                                                          onPressed: () async {
                                                            Navigator.pop(
                                                                context);
                                                            await _submit();
                                                          },
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.15,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                        DialogButton(
                                                            child: Text(
                                                              "Cancel purchase",
                                                            ),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.15,
                                                            color: Colors.red)
                                                      ],
                                                    ).show();
                                                  }),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // if (_previewIsOpen == true) _previewScreen(),

                            // if (resultCurrentOpeningHour.isLoading)
                            //   Center(
                            //     child: Platform.isAndroid
                            //         ? CircularProgressIndicator()
                            //         : CupertinoActivityIndicator(),
                            //   ),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: _height * 0.051,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formAndTextFormField({
    Key? key,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    required TextEditingController textController,
    required int maxLength,
    int? maxLines = null,
    required String labelText,
    required TextInputType textInputType,
    String? Function(String?)? validator,
    bool? enabled = true,
    bool obscure = false,
    bool filled = true,
    TextInputAction? textInputAction,
  }) {
    return Form(
      key: key,
      child: TextFormField(
          enabled: enabled,
          focusNode: focusNode,
          keyboardType: textInputType,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            decorationColor: Theme.of(context).primaryColor,
            decoration: TextDecoration.none,
          ),
          cursorColor: Theme.of(context).primaryColor,
          decoration: InputDecoration(
            counterStyle: TextStyle(color: Theme.of(context).primaryColor),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.5)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
            ),
            labelStyle: TextStyle(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                decoration: TextDecoration.none),
            labelText: labelText,
            fillColor: Theme.of(context).primaryColor,
            focusColor: Theme.of(context).primaryColor,
            hoverColor: Theme.of(context).primaryColor,
          ),
          textInputAction: textInputAction,
          controller: textController,
          maxLength: maxLength,
          maxLines: maxLines,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          },
          validator: validator),
    );
  }

  Widget _previewScreen() {
    int? distance;
    if (_myLatitude != null && _myLongitude != null) {
      double distanceDouble = Geolocator.distanceBetween(
          _myLatitude!, _myLongitude!, _address.latitude, _address.longitude);
      distance = distanceDouble.round();
    }

    Stad? stad =
        Provider.of<Stads>(context, listen: false).activeStad(_address.id!);

    DateTime? tillDate;

    int compareDate(DateTime value1, DateTime value2) =>
        value1.compareTo(value2);

    for (var i = 0; i < openingHoursAndDays.length; i++) {
      if (_dateTimeRange!.start.weekday == openingHoursAndDays[i]["day"] ||
          _dateTimeRange!.start.weekday == openingHoursAndDays[i]["day_from"] ||
          _dateTimeRange!.start.weekday == openingHoursAndDays[i]["day_to"]) {
        if (_dateTimeRange!.start
                .isAtSameMomentAs(openingHoursAndDays[i]["datetime_from"]) ||
            _dateTimeRange!.start
                .isAfter(openingHoursAndDays[i]["datetime_from"]) ||
            _dateTimeRange!.start
                .isBefore(openingHoursAndDays[i]["datetime_to"])) {
          List filteredList = openingHoursAndDays
              .where(
                  (element) => element["day"] == openingHoursAndDays[i]["day"])
              .toList();

          filteredList.sort((obj1, obj2) =>
              compareDate(obj1["datetime_from"], obj2["datetime_from"]));

          tillDate = filteredList.last["datetime_to"];
        }
      }
    }

    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.99,
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                      primary: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.circular(33),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _previewIsOpen = false;
                        _previewHomeFeedIsOpen = false;
                        _previewDetailIsOpen = false;
                      });
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text("Close Preview")),
              ),
              if (_previewDetailIsOpen == false &&
                  _previewHomeFeedIsOpen == true)
                Container(
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.03),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.01,
                      right: MediaQuery.of(context).size.width * 0.01,
                      top: MediaQuery.of(context).size.height * 0.01,
                    ),
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        setState(() {
                          _previewHomeFeedIsOpen = false;
                          _previewDetailIsOpen = true;
                        });
                      }, //selectAdvertisement(context),
                      child: Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  child: stad != null
                                      ? Image.network(
                                          stad.media.first!,
                                          // advertisement.imagesPath[0].toString(),
                                          width: double.infinity,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4 *
                                              3,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          _address.media!.first,
                                          width: double.infinity,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4 *
                                              3,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              if (Platform.isAndroid &&
                                  _hasQrAdvertisement == true)
                                Padding(
                                  padding:
                                      MediaQuery.of(context).viewPadding * 1,
                                  child: const Icon(
                                    FontAwesomeIcons.qrcode,
                                    size: 45,
                                    color: Colors.white,
                                  ),
                                ),
                              if (!Platform.isAndroid &&
                                  _hasQrAdvertisement == true)
                                Padding(
                                  padding:
                                      MediaQuery.of(context).viewPadding * 1,
                                  child: const Icon(
                                    FontAwesomeIcons.qrcode,
                                    size: 45,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.04,
                            color: Colors.white,
                            child: Text(
                              _address.name!,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 25,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.003,
                          ),
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height:
                                  MediaQuery.of(context).size.height * 0.002,
                              color: Colors.black12,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left:
                                    MediaQuery.of(context).viewPadding.left * 1,
                                right:
                                    MediaQuery.of(context).viewPadding.right *
                                        1,
                                top: MediaQuery.of(context).viewPadding.top * 1,
                                bottom:
                                    MediaQuery.of(context).viewPadding.bottom *
                                        0.005),
                            child: Text(
                              _shortDescriptionController.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 21),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).viewPadding.top *
                                    0.5,
                                right: MediaQuery.of(context).size.width * 0.03,
                                left: MediaQuery.of(context).size.width * 0.03),
                            child: Container(
                              color: Colors.black12,
                              width: double.infinity,
                              height:
                                  MediaQuery.of(context).size.height * 0.002,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top:
                                    MediaQuery.of(context).size.height * 0.002),
                            child: Container(
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                  color: Colors.purple // TODO rubric color!!!,
                                  ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.height *
                                        0.015,
                                    top: MediaQuery.of(context).size.height *
                                        0.01),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        const Icon(
                                          FontAwesomeIcons.solidEye,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.01,
                                        ),
                                        if (distance == null)
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.01,
                                            ),
                                            child: const Text(
                                              "...Loading",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        if (distance != null)
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.01,
                                            ),
                                            child: Text(
                                              distance.toString() + " m",
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        const Icon(
                                          FontAwesomeIcons.clock,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.01,
                                        ),
                                        _dateTimeRange != null &&
                                                _dateTimeRange!
                                                        .duration.inMinutes >=
                                                    15
                                            ? CountdownWidget(
                                                startTime: DateTime.now()
                                                        .toUtc()
                                                        .isBefore(
                                                            _dateTimeRange!
                                                                .start)
                                                    ? _dateTimeRange!.start
                                                    : tz.TZDateTime.now(
                                                        tz.getLocation(_address
                                                            .timezone!.first)),
                                                endTime: _dateTimeRange!.end,
                                              )

                                            // SlideCountdownClock(
                                            //     duration: Duration(
                                            //       minutes:
                                            //           _durationAdvertisement,
                                            //     ),
                                            //     separator: ":",
                                            //     shouldShowDays: false,
                                            //     tightLabel: false,
                                            //     slideDirection:
                                            //         SlideDirection.Up,
                                            //     textStyle: TextStyle(
                                            //       color: Colors.white,
                                            //     ),
                                            //   )
                                            : Text(
                                                "00:00:00",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                        // advertisement.remainingTime,
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }

  DateTime? initialDateFrom;
  DateTime? initialDateTo;

  void initialDates() {
    initialDateFrom = calculatedDates.first.start;
    initialDateFrom = calculatedDates.first.duration.inMinutes < 15
        ? calculatedDates[1].start.add(
            Duration(minutes: 15 - calculatedDates.first.duration.inMinutes))
        : calculatedDates.first.start.add(const Duration(minutes: 15));
  }

  DateTime calculateMaxDateForDateRangePicker() {
    if (calculatedDates.last.end.hour == 0 &&
        calculatedDates.last.end.minute <= 00 &&
        calculatedDates.last.end.minute < 15) {
      return calculatedDates[calculatedDates.length - 2].end;
    }
    return calculatedDates.last.end;
  }

  Widget dateRangePicker(BuildContext context) {
    return SfDateRangePicker(
      controller: _controller,
      minDate: calculatedDates.first.start,
      maxDate: calculateMaxDateForDateRangePicker(),
      rangeSelectionColor: Theme.of(context).primaryColor.withOpacity(0.21),
      todayHighlightColor: Theme.of(context).primaryColor,
      startRangeSelectionColor: Theme.of(context).primaryColor,
      endRangeSelectionColor: Theme.of(context).primaryColor,
      enablePastDates: false,
      enableMultiView: false,
      monthCellStyle: DateRangePickerMonthCellStyle(
        todayTextStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 13,
        ),
        blackoutDateTextStyle: const TextStyle(
          fontStyle: FontStyle.normal,
          decoration: TextDecoration.lineThrough,
          fontSize: 13,
          color: Colors.black,
        ),
        blackoutDatesDecoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.scaleDown,
            scale: 5.1,
            alignment: Alignment.bottomRight,
            image: AssetImage(
              "assets/images/lock.png",
            ),
          ),
        ),
      ),
      view: DateRangePickerView.month,
      selectionMode: DateRangePickerSelectionMode.range,
      monthViewSettings: DateRangePickerMonthViewSettings(
          firstDayOfWeek: 1,
          blackoutDates: calculateDisabledDates(),
          dayFormat: 'EEE'),
      initialSelectedRange: PickerDateRange(
        initialDateFrom,
        initialDateTo,
      ),
      onSelectionChanged: (dateRangePickerSelectionChangedArgs) async {
        setState(() {
          _calendarDatesSelected = false;
          _calendarChange = true;
          _dummyTimeFrom = null;
          _dummyTimeTo = null;
          _setMinTimeFrom = null;
          _setMinTimeTo = null;
        });

        if (_controller.selectedRange != null) {
          if (_controller.selectedRange!.startDate != null &&
              _controller.selectedRange!.endDate != null) {
            setState(() {
              _timeSpinnerIsLoading = true;
            });

//

            bool isMinimumTimeFromWithoutException = minimumTimeFrom();
            bool isMaximumTimeFromWithoutException = maximumTimeFrom();
            bool isMinimumTimeToWithoutException = minimumTimeTo();
            bool isMaximumTimeToWithoutException = maximumTimeTo();

            if (!isMinimumTimeFromWithoutException ||
                !isMaximumTimeFromWithoutException ||
                !isMinimumTimeToWithoutException ||
                !isMaximumTimeToWithoutException) {
              await Future.delayed(const Duration(milliseconds: 99))
                  .then((_) async {
                setState(() {
                  _calendarDatesSelected = false;
                });
                setState(() {
                  _timeSpinnerIsLoading = false;
                });
                await Alert(
                  context: context,
                  type: AlertType.error,
                  title: "Select calendar dates again",
                  desc: "A mistake happened. Try again.",
                  buttons: [
                    DialogButton(
                      child: Text(
                        "Close",
                      ),
                      onPressed: () => Navigator.pop(context),
                      width: MediaQuery.of(context).size.width * 0.15,
                    )
                  ],
                ).show();
              });
            }

            if (isMinimumTimeFromWithoutException &&
                isMaximumTimeFromWithoutException &&
                isMinimumTimeToWithoutException &&
                isMaximumTimeToWithoutException) {
              await Future.delayed(const Duration(milliseconds: 99))
                  .then((_) async {
                setState(() {
                  _calendarDatesSelected = true;
                });

                setState(() {
                  _timeSpinnerIsLoading = false;
                });

                setState(() {
                  _dateTimeRange =
                      DateTimeRange(start: _minTimeFrom!, end: _minTimeTo!);
                });
                print(_dateTimeRange);
              });
            }
          }
          if (_controller.selectedRange!.startDate == null ||
              _controller.selectedRange!.endDate == null) {
            setState(() {
              _calendarDatesSelected = false;
            });
          }
        }
        if (_controller.selectedRange == null) {
          setState(() {
            _calendarDatesSelected = false;
          });
        }
        setState(() {
          calculateAdvertisedTime(
              dateTimeRange: _dateTimeRange!, hasException: false);
        });
      },
    );
  }

  List<DateTime> calculateDisabledDates() {
    List<DateTime> disabledDates = [];
    disabledDates.clear();

    DateTime tzNow = tz.TZDateTime.now(timeZoneOfStore);

    List<int> weekdays = [1, 2, 3, 4, 5, 6, 7];
    List<int> weekdaysInOpeningHours = [];

    _openingHours.forEach((element) {
      weekdaysInOpeningHours.add(element.day);
      weekdaysInOpeningHours.add(element.dayFrom);
      weekdaysInOpeningHours.add(element.dayTo);
    });

    weekdaysInOpeningHours = weekdaysInOpeningHours.toSet().toList();

    List<int> closedWeekdays = weekdays
        .where((element) => !weekdaysInOpeningHours.contains(element))
        .toList();
    for (int i = 0; i < 7; i++) {
      if (closedWeekdays.contains(tzNow.add(Duration(days: i)).weekday)) {
        disabledDates.add(tzNow.add(Duration(days: i)));
      }
    }
    return disabledDates;
  }

  void calculateDates() {
    calculatedDates.clear();
    openingHoursAndDays.clear();
    List<DateTime> fromList = [];
    List<DateTime> toList = [];
    List<DateTimeRange> dateRange = [];
    fromList.clear();
    toList.clear();
    dateRange.clear();

    for (int j = 0; j < _openingHours.length; j++) {
      for (int i = -1; i < 7; i++) {
        if (nowTz.add(Duration(days: i)).weekday == _openingHours[j].day) {
          if (_openingHours[j].dayFrom == _openingHours[j].day) {
            DateTime fromDate = tz.TZDateTime(
              timeZoneOfStore,
              nowTz.add(Duration(days: i)).year,
              nowTz.add(Duration(days: i)).month,
              nowTz.add(Duration(days: i)).day,
              _openingHours[j].timeFrom.hour,
              _openingHours[j].timeFrom.minute,
              0,
              0,
              0,
            );

            DateTime toDate =
                fromDate.add(Duration(minutes: _openingHours[j].duration));

            if ((nowTz.isAtSameMomentAs(fromDate) ||
                nowTz.isAfter(fromDate) && nowTz.isBefore(toDate))) {
              if (_openingHours.length == 1) {
                if (toDate.difference(fromDate).inMinutes > 15) {
                  fromList.add(tz.TZDateTime(
                    timeZoneOfStore,
                    nowTz.year,
                    nowTz.month,
                    nowTz.day,
                    nowTz.hour,
                    nowTz.minute,
                    0,
                    0,
                    0,
                  ));

                  toList.add(toDate);

                  openingHoursAndDays.add({
                    "day": _openingHours[j].day,
                    "day_from": _openingHours[j].dayFrom,
                    "day_to": _openingHours[j].dayTo,
                    "datetime_from": tz.TZDateTime(
                      timeZoneOfStore,
                      nowTz.year,
                      nowTz.month,
                      nowTz.day,
                      nowTz.hour,
                      nowTz.minute,
                      0,
                      0,
                      0,
                    ),
                    "datetime_to": toDate,
                  });
                }
              } else {
                fromList.add(tz.TZDateTime(
                  timeZoneOfStore,
                  nowTz.year,
                  nowTz.month,
                  nowTz.day,
                  nowTz.hour,
                  nowTz.minute,
                  0,
                  0,
                  0,
                ));

                toList.add(toDate);

                openingHoursAndDays.add({
                  "day": _openingHours[j].day,
                  "day_from": _openingHours[j].dayFrom,
                  "day_to": _openingHours[j].dayTo,
                  "datetime_from": tz.TZDateTime(
                    timeZoneOfStore,
                    nowTz.year,
                    nowTz.month,
                    nowTz.day,
                    nowTz.hour,
                    nowTz.minute,
                    0,
                    0,
                    0,
                  ),
                  "datetime_to": toDate,
                });
              }
            }

            if (nowTz.isBefore(fromDate) || nowTz.isAtSameMomentAs(fromDate)) {
              fromList.add(fromDate);
              toList.add(toDate);

              openingHoursAndDays.add({
                "day": _openingHours[j].day,
                "day_from": _openingHours[j].dayFrom,
                "day_to": _openingHours[j].dayTo,
                "datetime_from": fromDate,
                "datetime_to": toDate,
              });
            }
          } else {
            DateTime fromDate = tz.TZDateTime(
              timeZoneOfStore,
              nowTz.year,
              nowTz.month,
              nowTz.day,
              _openingHours[j].timeFrom.hour,
              _openingHours[j].timeFrom.minute,
              0,
              0,
              0,
            ).add(Duration(days: i)).add(const Duration(days: 1));
            DateTime toDate =
                fromDate.add(Duration(minutes: _openingHours[j].duration));

            if ((nowTz.isAtSameMomentAs(fromDate) ||
                nowTz.isAfter(fromDate) && nowTz.isBefore(toDate))) {
              if (toDate.difference(fromDate).inMinutes > 15) {
                fromList.add(tz.TZDateTime(
                  timeZoneOfStore,
                  nowTz.year,
                  nowTz.month,
                  nowTz.day,
                  nowTz.hour,
                  nowTz.minute,
                  0,
                  0,
                  0,
                ));
                toList.add(toDate);

                openingHoursAndDays.add({
                  "day": _openingHours[j].day,
                  "day_from": _openingHours[j].dayFrom,
                  "day_to": _openingHours[j].dayTo,
                  "datetime_from": tz.TZDateTime(
                    timeZoneOfStore,
                    nowTz.year,
                    nowTz.month,
                    nowTz.day,
                    nowTz.hour,
                    nowTz.minute,
                    0,
                    0,
                    0,
                  ),
                  "datetime_to": toDate,
                });
              }
            }

            if (nowTz.isBefore(fromDate) || nowTz.isAtSameMomentAs(fromDate)) {
              fromList.add(fromDate);
              toList.add(toDate);

              openingHoursAndDays.add({
                "day": _openingHours[j].day,
                "day_from": _openingHours[j].dayFrom,
                "day_to": _openingHours[j].dayTo,
                "datetime_from": fromDate,
                "datetime_to": toDate,
              });
            }
          }
        }
      }
    }
    fromList..sort();
    toList..sort();
    openingHoursAndDays
        .sort((a, b) => a["datetime_from"].compareTo((b["datetime_from"])));

    for (int i = 0; i < fromList.length; i++) {
      dateRange.add(DateTimeRange(start: fromList[i], end: toList[i]));
    }
    _openingHoursInDates.clear();

    _openingHoursInDates = dateRange;
    calculatedDates = dateRange;
  }

  Widget _timeFrom() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width * 0.333,
      child: CupertinoDatePicker(
        initialDateTime:
            _setMinTimeFrom == null ? _minTimeFrom : _setMinTimeFrom,
        use24hFormat: true,
        onDateTimeChanged: (time) {
          DateTime timeFromUtc = time.toUtc();
          _dummyTimeFrom = tz.TZDateTime.from(timeFromUtc, timeZoneOfStore);
          _setMinTimeFrom = _dummyTimeFrom;
          if (_dummyTimeFrom!.isAfter(
              _dummyTimeTo != null ? _dummyTimeTo! : _dateTimeRange!.end)) {
            setState(() {
              _timesAreValid = false;
            });
          } else {
            if (_dummyTimeTo != null) {
              if (_dummyTimeTo!.difference(_dateTimeRange!.end).inMinutes !=
                  0) {
                _dateTimeRange = DateTimeRange(
                    start: DateTime(
                      _dummyTimeFrom!.year,
                      _dummyTimeFrom!.month,
                      _dummyTimeFrom!.day,
                      _dummyTimeFrom!.hour,
                      _dummyTimeFrom!.minute,
                      0,
                      0,
                      0,
                    ),
                    end: DateTime(
                      _dummyTimeTo!.year,
                      _dummyTimeTo!.month,
                      _dummyTimeTo!.day,
                      _dummyTimeTo!.hour,
                      _dummyTimeTo!.minute,
                      0,
                      0,
                      0,
                    ));
              } else {
                _dateTimeRange = DateTimeRange(
                    start: DateTime(
                      _dummyTimeFrom!.year,
                      _dummyTimeFrom!.month,
                      _dummyTimeFrom!.day,
                      _dummyTimeFrom!.hour,
                      _dummyTimeFrom!.minute,
                      0,
                      0,
                      0,
                    ),
                    end: _dateTimeRange!.end);
              }
            } else {
              _dateTimeRange = DateTimeRange(
                  start: DateTime(
                    _dummyTimeFrom!.year,
                    _dummyTimeFrom!.month,
                    _dummyTimeFrom!.day,
                    _dummyTimeFrom!.hour,
                    _dummyTimeFrom!.minute,
                    0,
                    0,
                    0,
                  ),
                  end: _dateTimeRange!.end);
            }
            minimumTimeFrom();
            maximumTimeFrom();
            minimumTimeTo();
            maximumTimeTo();
            setState(() {
              calculateAdvertisedTime(
                  dateTimeRange: _dateTimeRange!, hasException: false);
            });
          }
        },
        mode: CupertinoDatePickerMode.time,
      ),
    );
  }

  Widget _timeTo() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width * 0.333,
      child: CupertinoDatePicker(
        initialDateTime: _setMinTimeTo == null ? _minTimeTo : _setMinTimeTo,
        use24hFormat: true,
        onDateTimeChanged: (time) {
          DateTime timeToUtc = time.toUtc();
          _dummyTimeTo = tz.TZDateTime.from(timeToUtc, timeZoneOfStore);

          _setMinTimeTo = _dummyTimeTo;
          if (_dummyTimeTo!.isBefore(_dummyTimeFrom != null
              ? _dummyTimeFrom!
              : _dateTimeRange!.start)) {
            setState(() {
              _timesAreValid = false;
            });
          } else {
            if (_dummyTimeFrom != null) {
              if (_dummyTimeFrom!.difference(_dateTimeRange!.start).inMinutes !=
                  0) {
                _dateTimeRange = DateTimeRange(
                  start: DateTime(
                    _dummyTimeFrom!.year,
                    _dummyTimeFrom!.month,
                    _dummyTimeFrom!.day,
                    _dummyTimeFrom!.hour,
                    _dummyTimeFrom!.minute,
                    0,
                    0,
                    0,
                  ),
                  end: DateTime(
                    _dummyTimeTo!.year,
                    _dummyTimeTo!.month,
                    _dummyTimeTo!.day,
                    _dummyTimeTo!.hour,
                    _dummyTimeTo!.minute,
                    0,
                    0,
                    0,
                  ),
                );
              } else {
                _dateTimeRange = DateTimeRange(
                  start: _dateTimeRange!.start,
                  end: DateTime(
                    _dummyTimeTo!.year,
                    _dummyTimeTo!.month,
                    _dummyTimeTo!.day,
                    _dummyTimeTo!.hour,
                    _dummyTimeTo!.minute,
                    0,
                    0,
                    0,
                  ),
                );
              }
            } else {
              _dateTimeRange = DateTimeRange(
                start: _dateTimeRange!.start,
                end: DateTime(
                  _dummyTimeTo!.year,
                  _dummyTimeTo!.month,
                  _dummyTimeTo!.day,
                  _dummyTimeTo!.hour,
                  _dummyTimeTo!.minute,
                  0,
                  0,
                  0,
                ),
              );
            }
            minimumTimeFrom();
            maximumTimeFrom();
            minimumTimeTo();
            maximumTimeTo();
            setState(() {
              calculateAdvertisedTime(
                  dateTimeRange: _dateTimeRange!, hasException: false);
            });
          }
        },
        mode: CupertinoDatePickerMode.time,
      ),
    );
  }

  bool minimumTimeTo() {
    DateTime? start;
    DateTime? end;
    if (_controller.selectedRange != null) {
      start = _controller.selectedRange!.startDate;
      end = _controller.selectedRange!.endDate;
    } else {
      start = calculatedDates.first.start;
      end = calculatedDates.first.duration.inMinutes < 15
          ? calculatedDates[1].start.add(
              Duration(minutes: 15 - calculatedDates.first.duration.inMinutes))
          : calculatedDates.first.start.add(const Duration(minutes: 15));
    }

    final timeZoneOfStore = tz.getLocation(_address.timezone![0]);
    List<DateTimeRange> getDates = calculatedDates;
    List<DateTime> matchedDates = [];
    matchedDates.clear();
    final nowTimezone = tz.TZDateTime.now(timeZoneOfStore);

    if (start != null && end != null) {
      for (int i = 0; i < getDates.length; i++) {
        if (end.day != getDates[i].start.day &&
            end.day == getDates[i].end.day) {
          matchedDates.add(tz.TZDateTime(
            timeZoneOfStore,
            getDates[i].end.year,
            getDates[i].end.month,
            getDates[i].end.day,
            0,
            0,
            0,
            0,
            0,
          ).add(Duration(minutes: start.day == end.day ? 15 : 1)));
        }

        if (end.day == getDates[i].start.day &&
            end.day == getDates[i].end.day) {
          matchedDates.add(getDates[i]
              .start
              .add(Duration(minutes: start.day == end.day ? 15 : 1)));
        }

        if (end.day == getDates[i].start.day &&
            end.day != getDates[i].end.day) {
          matchedDates.add(getDates[i]
              .start
              .add(Duration(minutes: start.day == end.day ? 15 : 1)));
        }
      }
    }
    if (matchedDates.isEmpty) {
      return false;
    } else {
      matchedDates..sort();
      for (var i = 0; i < getDates.length; i++) {
        if (i > 0) {
          if (matchedDates.first.isAfter(getDates[i - 1].end) &&
              matchedDates.first.isBefore(getDates[i].start)) {
            int differenceInMinutes =
                getDates[i - 1].end.difference(_minTimeFrom!).inMinutes;
            _minTimeTo = getDates[i].start.add(Duration(
                  minutes: 15 - differenceInMinutes,
                ));
            _minTimeTo = matchedDates.last;
            return true;
          }
        }
      }

      _minTimeTo = matchedDates.first;
      print("mintime to: " + _minTimeTo.toString());
      return true;
    }
  }

  bool maximumTimeTo() {
    DateTime? start;
    DateTime? end;
    if (_controller.selectedRange != null) {
      start = _controller.selectedRange!.startDate;
      end = _controller.selectedRange!.endDate;
    } else {
      start = calculatedDates.first.start;
      end = calculatedDates.first.duration.inMinutes < 15
          ? calculatedDates[1].start.add(
              Duration(minutes: 15 - calculatedDates.first.duration.inMinutes))
          : calculatedDates.first.start.add(const Duration(minutes: 15));
    }

    List<DateTimeRange> getDates = calculatedDates;
    List<DateTime> matchedDates = [];
    matchedDates.clear();

    if (start != null && end != null) {
      for (int i = 0; i < getDates.length; i++) {
        if (getDates[i].end.day == end.day) {
          matchedDates.add(getDates[i].end);
        }
        if (getDates[i].end.day != end.day &&
            getDates[i].start.day == end.day) {
          print("lalala1");
          print(getDates[i].end.day);
          print(getDates[i].start.day);
          print(end.day);
          matchedDates.add(tz.TZDateTime(
            timeZoneOfStore,
            getDates[i].start.year,
            getDates[i].start.month,
            getDates[i].start.day,
            0,
            0,
            0,
            0,
            0,
          )
              .add(const Duration(days: 1))
              .subtract(const Duration(microseconds: 1)));
        }
        if (getDates[i].end.day == end.day &&
            getDates[i].start.day == end.day) {
          print("lalala2");
          print(getDates[i].end.day);
          print(getDates[i].start.day);
          print(end.day);
          matchedDates.add(getDates[i].end);
        }

        if (getDates[i].end.day == end.day &&
            getDates[i].start.day != end.day) {
          matchedDates.add(getDates[i].end);
        }
      }
    }
    if (matchedDates.isEmpty) {
      return false;
    } else {
      matchedDates..sort();

      if (matchedDates.last.isBefore(_minTimeTo!)) {
        _maxTimeTo = matchedDates.last
            .add(Duration(days: 1))
            .subtract(Duration(microseconds: 1));

        return true;
      }

      _maxTimeTo = matchedDates.last;

      return true;
    }
  }

  bool minimumTimeFrom() {
    DateTime? start;
    DateTime? end;
    if (_controller.selectedRange != null) {
      start = _controller.selectedRange!.startDate;
      end = _controller.selectedRange!.endDate;
    } else {
      start = calculatedDates.first.start;
      end = calculatedDates.first.duration.inMinutes < 15
          ? calculatedDates[1].start.add(
              Duration(minutes: 15 - calculatedDates.first.duration.inMinutes))
          : calculatedDates.first.start.add(const Duration(minutes: 15));
    }

    final timeZoneOfStore = tz.getLocation(_address.timezone![0]);
    List<DateTimeRange> getDates = calculatedDates;
    List<DateTime> matchedDates = [];
    final nowTimezone = tz.TZDateTime.now(timeZoneOfStore);
    matchedDates.clear();

    if (start != null && end != null) {
      for (int i = 0; i < getDates.length; i++) {
        if (start.day != getDates[i].start.day &&
            start.day == getDates[i].end.day) {
          if (nowTimezone.isBefore(tz.TZDateTime(
                timeZoneOfStore,
                getDates[i].end.year,
                getDates[i].end.month,
                getDates[i].end.day,
                0,
                0,
                0,
                0,
                0,
              )) ||
              nowTimezone.isAtSameMomentAs(tz.TZDateTime(
                timeZoneOfStore,
                getDates[i].end.year,
                getDates[i].end.month,
                getDates[i].end.day,
                0,
                0,
                0,
                0,
                0,
              ))) {
            matchedDates.add(tz.TZDateTime(
              timeZoneOfStore,
              getDates[i].end.year,
              getDates[i].end.month,
              getDates[i].end.day,
              0,
              0,
              0,
              0,
              0,
            ));
          }

          if (nowTimezone.isAfter(tz.TZDateTime(
            timeZoneOfStore,
            getDates[i].end.year,
            getDates[i].end.month,
            getDates[i].end.day,
            0,
            0,
            0,
            0,
            0,
          ))) {
            matchedDates.add(nowTimezone);
          }
        }

        if (start.day == getDates[i].start.day &&
            start.day == getDates[i].end.day) {
          if (nowTimezone.isBefore(getDates[i].start) ||
              nowTimezone.isAtSameMomentAs(getDates[i].start)) {
            matchedDates.add(getDates[i].start);
          }

          if (nowTimezone.isAfter(getDates[i].start)) {
            matchedDates.add(nowTimezone);
          }
        }

        if (start.day == getDates[i].start.day &&
            start.day != getDates[i].end.day) {
          if (nowTimezone.isBefore(getDates[i].start) ||
              nowTimezone.isAtSameMomentAs(getDates[i].start)) {
            matchedDates.add(getDates[i].start);
          }

          if (nowTimezone.isAfter(getDates[i].start)) {
            matchedDates.add(nowTimezone);
          }
        }
      }
    }

    if (matchedDates.isEmpty) {
      return false;
    } else {
      matchedDates..sort();

      _minTimeFrom = DateTime(
        matchedDates.first.year,
        matchedDates.first.month,
        matchedDates.first.day,
        matchedDates.first.hour,
        matchedDates.first.minute,
        0,
        0,
        0,
      );

      return true;
    }
  }

  bool maximumTimeFrom() {
    DateTime? start;
    DateTime? end;
    if (_controller.selectedRange != null) {
      start = _controller.selectedRange!.startDate;
      end = _controller.selectedRange!.endDate;
    } else {
      start = calculatedDates.first.start;
      end = calculatedDates.first.duration.inMinutes < 15
          ? calculatedDates[1].start.add(
              Duration(minutes: 15 - calculatedDates.first.duration.inMinutes))
          : calculatedDates.first.start.add(const Duration(minutes: 15));
    }

    List<DateTimeRange> getDates = calculatedDates;
    List<DateTime> matchedDates = [];
    matchedDates.clear();

    if (start != null && end != null) {
      for (int i = 0; i < getDates.length; i++) {
        if (start.day == getDates[i].start.day &&
            start.day != getDates[i].end.day) {
          matchedDates.add(tz.TZDateTime(
            timeZoneOfStore,
            getDates[i].start.year,
            getDates[i].start.month,
            getDates[i].start.day,
            23,
            59,
            59,
            999,
            999,
          ).subtract(Duration(minutes: start.day == end.day ? 15 : 0)));
        }

        if (start.day == getDates[i].start.day &&
            start.day == getDates[i].end.day) {
          matchedDates.add(getDates[i]
              .end
              .subtract(Duration(minutes: start.day == end.day ? 15 : 0)));
        }

        if (start.day != getDates[i].start.day &&
            start.day == getDates[i].end.day) {
          matchedDates.add(getDates[i]
              .end
              .subtract(Duration(minutes: start.day == end.day ? 15 : 0)));
        }
      }
    }

    if (matchedDates.isEmpty) {
      return false;
    } else {
      matchedDates..sort();
      _maxTimeFrom = matchedDates.last;
      return true;
    }
  }

  Widget? textCardUnderTime() {
    if (_calendarDatesSelected && !_timeSpinnerIsLoading) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Column(
          children: List.generate(
              _timesAreValid
                  ? addedRanges.isNotEmpty
                      ? addedRanges.length
                      : 1
                  : 1,
              (index) => widgetInCard(index)),
        ),
      );
    }
  }

  void calculateAdvertisedTime(
      {required DateTimeRange dateTimeRange, bool hasException = false}) {
    addedRanges.clear();
    List<DateTimeRange> getDays = calculatedDates;
    int? startIndex;
    int? endIndex;
    startIndex = null;
    endIndex = null;
    _timesAreValid = true;

    if (!hasException) {
      if (dateTimeRange.duration.inMinutes < 15) {
        setState(() {
          _timesAreValid = false;
        });
      }
      if (_timesAreValid) {
        if (dateTimeRange.end.isAfter(getDays.last.end)) {
          setState(() {
            _timesAreValid = false;
          });
        }
      }
      if (_timesAreValid) {
        if (dateTimeRange.end.isBefore(getDays.last.end) ||
            dateTimeRange.end.isAtSameMomentAs(getDays.last.end)) {
          setState(() {
            _timesAreValid = true;
          });
        }
      }
      if (_timesAreValid) {
        if (dateTimeRange.start.isBefore(getDays.first.start)) {
          setState(() {
            _timesAreValid = false;
          });
        }
      }
      if (_timesAreValid) {
        if (dateTimeRange.start.isAfter(getDays.first.start) ||
            dateTimeRange.start.isAtSameMomentAs(getDays.first.start)) {
          setState(() {
            _timesAreValid = true;
          });
        }
      }

      if (_timesAreValid) {
        if (dateTimeRange.duration.inMinutes >= 15) {
          for (int i = 0; i < getDays.length; i++) {
            if (dateTimeRange.start.isAfter(getDays[i].start) ||
                dateTimeRange.start.isAtSameMomentAs(getDays[i].start)) {
              startIndex = i;
            }

            if (dateTimeRange.end.isAfter(getDays[i].start)) {
              endIndex = i;
            }
          }
          if (endIndex != getDays.length - 1) {
            if (dateTimeRange.end.isAfter(getDays[endIndex!].end)) {
              setState(() {
                _timesAreValid = false;
              });

              if (dateTimeRange.start.isAfter(getDays[endIndex].end)) {
                setState(() {
                  _timesAreValid = false;
                });
              } else {
                _dateTimeRange = DateTimeRange(
                    start: dateTimeRange.start, end: getDays[endIndex].end);
              }
            }
          }
          if (endIndex != getDays.length - 1) {
            if (dateTimeRange.end.isAtSameMomentAs(getDays[endIndex!].start)) {
              setState(() {
                _timesAreValid = false;
              });
              _dateTimeRange = DateTimeRange(
                  start: dateTimeRange.start, end: getDays[endIndex - 1].end);
            }
          }

          startIndex ??= 0;

          int firstIndex = startIndex;

          for (int i = startIndex; i <= endIndex!; i++) {
            addedRanges.add(DateTimeRange(
              start: i == firstIndex ? _dateTimeRange!.start : getDays[i].start,
              end: endIndex == startIndex
                  ? _dateTimeRange!.end
                  : i == endIndex
                      ? _dateTimeRange!.end
                      : getDays[i].end.isAfter(_dateTimeRange!.start)
                          ? getDays[i].end
                          : getDays[i + 1].end,
            ));
          }
        }
      }
    }

    for (var i = 0; i < getDays.length; i++) {
      if (i > 0) {
        if (_timesAreValid) {
          if ((dateTimeRange.start.isAfter(getDays[i - 1].end) ||
                  dateTimeRange.start.isAtSameMomentAs(getDays[i - 1].end)) &&
              dateTimeRange.start.isBefore(getDays[i].start)) {
            setState(() {
              _timesAreValid = false;
            });
          }

          if (dateTimeRange.end.isAfter(getDays[i - 1].end) &&
              (dateTimeRange.end.isBefore(getDays[i].start) ||
                  dateTimeRange.end.isAtSameMomentAs(getDays[i].start))) {
            setState(() {
              _timesAreValid = false;
            });
          }
        }
      }
    }

    if (_timesAreValid) {
      if (addedRanges.isEmpty) {
        setState(() {
          _timesAreValid = false;
        });
      } else {
        bool flag = true;
        for (var i = 0; i < addedRanges.length; i++) {
          if (flag) {
            if (addedRanges[i].duration.inMinutes == 0) {
              setState(() {
                _timesAreValid = false;
              });
              flag = false;
              return;
            }
          }
        }

        if (flag) {
          setState(() {
            _timesAreValid = true;
          });
        }
        int duration = 0;
        for (var i = 0; i < addedRanges.length; i++) {
          duration = duration + addedRanges[i].duration.inMinutes;
        }
        if (duration < 15) {
          setState(() {
            _timesAreValid = false;
          });
        }
      }
    }
  }

  Widget widgetInCard(int index) {
    DateFormat formatter = DateFormat('dd.MM.yyyy - HH:mm');
    totalDurationInMinutes = 0;
    for (int i = 0; i < addedRanges.length; i++) {
      totalDurationInMinutes =
          totalDurationInMinutes + addedRanges[i].duration.inMinutes;
    }
    String _printDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
    }

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.009,
        bottom: MediaQuery.of(context).size.height * 0.009,
      ),
      child: Column(
        children: [
          // TextButton(
          //     onPressed: () {
          //       print("start: " + _dateTimeRange!.start.toString());
          //       print("ende: " + _dateTimeRange!.end.toString());
          //     },
          //     child: Text("test")),
          if (_timesAreValid)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(color: Theme.of(context).primaryColor)),
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.03,
                      left: MediaQuery.of(context).size.width * 0.03,
                    ),
                    child: Text(
                      !noOpeningHours
                          ? formatter.format(addedRanges[index].start)
                          : "",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                Platform.isAndroid
                    ? Icon(Icons.arrow_forward,
                        color: Theme.of(context).primaryColor)
                    : Icon(CupertinoIcons.arrow_right,
                        color: Theme.of(context).primaryColor),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(color: Theme.of(context).primaryColor)),
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.03,
                      left: MediaQuery.of(context).size.width * 0.03,
                    ),
                    child: Text(
                      !noOpeningHours
                          ? formatter.format(addedRanges[index].end)
                          : "",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          if (_timesAreValid && !noOpeningHours)
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.009),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Theme.of(context).primaryColor)),
                child: Padding(
                  padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.03,
                    left: MediaQuery.of(context).size.width * 0.03,
                  ),
                  child: Text(
                    "Duration: " +
                        addedRanges[index].duration.inMinutes.toString() +
                        " Minutes",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ),
          if (index == addedRanges.length - 1 && _timesAreValid)
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.027,
                right: MediaQuery.of(context).size.width * 0.03,
                left: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Theme.of(context).primaryColor)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Total advertisement duration in hours: ",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    Text(
                      _printDuration(Duration(minutes: totalDurationInMinutes)),
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    )
                  ],
                ),
              ),
            ),
          if (!_timesAreValid)
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.027,
                right: MediaQuery.of(context).size.width * 0.03,
                left: MediaQuery.of(context).size.width * 0.03,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Platform.isAndroid
                        ? Colors.red
                        : CupertinoColors.systemRed,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Time(s) outside of stores opening hour",
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                          color: Platform.isAndroid
                              ? Colors.red
                              : CupertinoColors.systemRed),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Icon selectPhotoIcon = Platform.isAndroid
      ? Icon(Icons.photo_camera_outlined)
      : Icon(CupertinoIcons.camera);
  String _selectPhotoText = "+";

  List<Container> _imageContainers = [];

  _createImageContainers() {
    if (_imageContainers.isNotEmpty) {
      _imageContainers.clear();
    }
    for (int i = 0; i < _files.length; i++) {
      _imageContainers.add(_imageContainerWithFile(context, _files[i]));
    }
  }

  Container _imageContainerWithFile(BuildContext context, File? file) {
    double _width = MediaQuery.of(context).size.width;

    return Container(
      width: _width / 3.6,
      height: _width / 3.6 / 4 * 3,
      child: AspectRatio(
        aspectRatio: 2 / 1.5,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: const BorderRadius.all(
              Radius.circular(100),
            ),
            border: Border.all(
                color: file == _files[0]
                    ? Theme.of(context).primaryColor
                    : fileBorderColor,
                width: file == _files[0] ? 3 : 1),
          ),
          child: InkWell(
            onTap: () {
              _onPressedOnSelectPhoto(file);
            },
            child: _checkPictureOrVideo(file),
          ),
        ),
      ),
    );
  }

  Container _imageContainerWithoutFile(BuildContext context, File? file) {
    double _width = MediaQuery.of(context).size.width;

    return Container(
      width: _width / 3.6,
      height: _width / 3.6 / 4 * 3,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: const BorderRadius.all(
            Radius.circular(100),
          ),
          border: Border.all(color: fileBorderColor, width: 1),
        ),
        child: InkWell(
            onTap: () {
              _onPressedOnSelectPhoto(file);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "+",
                  style: TextStyle(color: Colors.black26, fontSize: 18),
                ),
                Platform.isAndroid
                    ? Icon(
                        Icons.photo,
                        color: Colors.black26,
                      )
                    : Icon(
                        CupertinoIcons.photo_fill,
                        color: Colors.black26,
                      ),
              ],
            )),
      ),
    );
  }

  Widget _checkPictureOrVideo(File? file) {
    late var fileType;
    if (file != null) {
      String mimeStr = lookupMimeType(file.path)!;
      fileType = mimeStr.split('/');
    }
    if (fileType.contains("image")) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover, image: FileImage(File(file!.path))),
          borderRadius: const BorderRadius.all(
            Radius.circular(100),
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: _videoWidget,
      );
    }
  }

  _onPressedOnSelectPhoto(File? file) async {
    String _displayText = "Display";
    String _displayPicture = " Picture";
    String _displayVideo = " Video";
    bool _isVideoForText = false;
    bool _videoExist = false;
    if (_files.isNotEmpty) {
      if (_files[_files.length - 1] != null) {
        String mimeStr = lookupMimeType(_file1!.path)!;
        var fileType = mimeStr.split('/');
        print('file type $fileType');
        if (fileType.contains("video")) {
          setState(() {
            _videoExist = true;
          });
        }
      }
    }

    String? mimeStr;
    if (_files.isNotEmpty) {
      if (file != null) {
        mimeStr = lookupMimeType(file.path);
        var fileType = mimeStr!.split('/');
        if (fileType.contains("video")) {
          setState(() {
            _isVideoForText = true;
          });
        }
      }
    }

    return await showAdaptiveActionSheet(
      context: context,
      actions: <BottomSheetAction>[
        if (file != null)
          if (file.path != _files[0]!.path)
            BottomSheetAction(
                title: Text(
                  _displayText +
                      (_isVideoForText == true
                          ? _displayVideo
                          : _displayPicture),
                  style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                onPressed: () async {
                  setState(() {
                    _onTapDisplayPicVideo(file);
                  });
                  Navigator.pop(context);
                }),
        if (file == null)
          BottomSheetAction(
              title: Text(
                "Camera",
                style: TextStyle(color: Theme.of(context).accentColor),
                textAlign: TextAlign.center,
              ),
              onPressed: () async {
                setState(() {
                  onTap(file, false, false);
                });
                Navigator.pop(context);
              }),
        if (file == null)
          BottomSheetAction(
              title: Text(
                "Select a picture",
                style: TextStyle(color: Theme.of(context).accentColor),
                textAlign: TextAlign.center,
              ),
              onPressed: () {
                setState(() {
                  onTap(file, true, false);
                });
                Navigator.pop(context);
              }),
        if (file == null)
          if (_videoExist == false)
            BottomSheetAction(
                title: Text(
                  "Select a video",
                  style: TextStyle(color: Theme.of(context).accentColor),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  setState(() {
                    onTap(file, true, true);
                  });
                  Navigator.pop(context);
                }),
        if (file != null)
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
                await _deletePicture(file);

                Navigator.of(context).pop();
              }),
      ],
      cancelAction: CancelAction(
        title: Text("Cancel",
            style: TextStyle(color: Theme.of(context).accentColor)),
      ),
    );
  }

  var uuid = Uuid();

  Future<Widget?> _showDatePicker() async {
    DateFormat formatter = DateFormat('dd.MM.yyyy');
    final initialDate =
        tz.TZDateTime.now(tz.getLocation(_address.timezone!.first))
            .add(Duration(days: 3));
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: tz.TZDateTime.now(tz.getLocation(_address.timezone!.first))
          .add(Duration(days: 180)),
    );

    if (newDate != null) {
      _expiryDate = null;
      _expiryDateString = "";

      _expiryDate = newDate;

      setState(() {
        _expiryDateString = "Expiry Date: " + formatter.format(newDate);
        _expiryDateButtonTextColor = Colors.white;
      });
    }
  }

  VideoWidget? _videoWidget;

  _onTapDisplayPicVideo(File file) {
    if (_file2 != null) {
      if (file.path == _file2!.path) {
        File? _replacementFile1 = _file1;
        File? _replacementFile2 = _file2;

        if (_file1 != null) {
          String mimeStr = lookupMimeType(_file1!.path)!;
          var fileType = mimeStr.split('/');
          if (fileType.contains("video")) {
            setState(() {
              _file1 = _replacementFile2;
              _file2 = _replacementFile1;
            });
            setState(() {
              _files[0] = _file1;
              _files[1] = _file2;
            });
            setState(() {
              _createImageContainers();
            });
          } else {
            setState(() {
              _file2 = _replacementFile1;
              _file1 = _replacementFile2;
            });
            setState(() {
              _files[0] = _file1;
              _files[1] = _file2;
            });
            setState(() {
              _createImageContainers();
            });
          }
        }

        _replacementFile1 = null;
        _replacementFile2 = null;
      }
    }
    if (_file3 != null) {
      if (file.path == _file3!.path) {
        File? _replacementFile1 = _file1;
        File? _replacementFile3 = _file3;

        if (_file1 != null) {
          String mimeStr = lookupMimeType(_file1!.path)!;
          var fileType = mimeStr.split('/');
          if (fileType.contains("video")) {
            setState(() {
              _file1 = _replacementFile3;
              _file3 = _replacementFile1;
            });

            setState(() {
              _files[0] = _file1;
              _files[2] = _file3;
            });
            setState(() {
              _createImageContainers();
            });
          } else {
            setState(() {
              _file3 = _replacementFile1;
              _file1 = _replacementFile3;
            });
            setState(() {
              _files[0] = _file1;
              _files[2] = _file3;
            });
            setState(() {
              _createImageContainers();
            });
          }
        }

        _replacementFile1 = null;
        _replacementFile3 = null;
      }
    }
    if (_file4 != null) {
      if (file.path == _file4!.path) {
        File? _replacementFile1 = _file1;
        File? _replacementFile4 = _file4;

        if (_file1 != null) {
          String mimeStr = lookupMimeType(_file1!.path)!;
          var fileType = mimeStr.split('/');
          if (fileType.contains("video")) {
            setState(() {
              _file1 = _replacementFile4;
              _file4 = _replacementFile1;
            });
            setState(() {
              _files[0] = _file1;
              _files[3] = _file4;
            });
            setState(() {
              _createImageContainers();
            });
          } else {
            setState(() {
              _file4 = _replacementFile1;
              _file1 = _replacementFile4;
            });
            setState(() {
              _files[0] = _file1;
              _files[3] = _file4;
            });
            setState(() {
              _createImageContainers();
            });
          }
        }

        _replacementFile1 = null;
        _replacementFile4 = null;
      }
    }
    if (_file5 != null) {
      if (file.path == _file5!.path) {
        File? _replacementFile1 = _file1;
        File? _replacementFile5 = _file5;

        if (_file1 != null) {
          String mimeStr = lookupMimeType(_file1!.path)!;
          var fileType = mimeStr.split('/');
          if (fileType.contains("video")) {
            setState(() {
              _file1 = _replacementFile5;
              _file5 = _replacementFile1;
            });

            setState(() {
              _files[0] = _file1;
              _files[4] = _file5;
            });
            setState(() {
              _createImageContainers();
            });
          } else {
            setState(() {
              _file5 = _replacementFile1;
              _file1 = _replacementFile5;
            });
            setState(() {
              _files[0] = _file1;
              _files[4] = _file5;
            });
            setState(() {
              _createImageContainers();
            });
          }
        }

        _replacementFile1 = null;
        _replacementFile5 = null;
      }
    }
    if (_file6 != null) {
      if (file.path == _file6!.path) {
        File? _replacementFile1 = _file1;
        File? _replacementFile6 = _file6;

        if (_file1 != null) {
          String mimeStr = lookupMimeType(_file1!.path)!;
          var fileType = mimeStr.split('/');
          if (fileType.contains("video")) {
            setState(() {
              _file1 = _replacementFile6;
              _file6 = _replacementFile1;
            });
            setState(() {
              _files[0] = _file1;
              _files[5] = _file6;
            });
            setState(() {
              _createImageContainers();
            });
          } else {
            setState(() {
              _file6 = _replacementFile1;
              _file1 = _replacementFile6;
            });
            setState(() {
              _files[0] = _file1;
              _files[5] = _file6;
            });
            setState(() {
              _createImageContainers();
            });
          }
        }

        _replacementFile1 = null;
        _replacementFile6 = null;
      }
    }
  }

  Future onTap(File? file, bool isGallery, bool isVideo) async {
    if (isVideo == false) {
      final file = await Utils.pickMedia(
        isGallery: isGallery,
        cropImage: _cropImage,
      );

      String dir = (await getApplicationDocumentsDirectory()).path;
      String newPath = path.join(dir, "${uuid.v4()}.jpg");
      File renamedFile = await File(file!.path).copy(newPath);

      if (renamedFile == null) {
        return null;
      } else {
        setState(() {
          _files.add(renamedFile);
        });
        setState(() {
          _createImageContainers();
        });
        if (file != null) {
          if (_file1 == null) {
            setState(() {
              _file1 = renamedFile;
              fileBorderColor = Colors.grey;
            });
          } else {
            if (_file2 == null) {
              setState(() {
                _file2 = renamedFile;
              });
            } else {
              if (_file3 == null) {
                setState(() {
                  _file3 = renamedFile;
                });
              } else {
                if (_file4 == null) {
                  setState(() {
                    _file4 = renamedFile;
                  });
                } else {
                  if (_file5 == null) {
                    setState(() {
                      _file5 = renamedFile;
                    });
                  } else {
                    if (_file6 == null) {
                      setState(() {
                        _file6 = renamedFile;
                      });
                    }
                  }
                }
              }
            }
          }
        } else {
          if (_file1 == null &&
              _file2 == null &&
              _file3 == null &&
              _file4 == null &&
              _file5 == null) {
            setState(() {
              _file1 = renamedFile;
              print(_file1!.path);
            });
          } else {
            if (_file1 != null &&
                _file2 == null &&
                _file3 == null &&
                _file4 == null &&
                _file5 == null) {
              setState(() {
                _file2 = renamedFile;

                print(_file2!.path);
              });
            } else {
              if (_file1 != null &&
                  _file2 != null &&
                  _file3 == null &&
                  _file4 == null &&
                  _file5 == null) {
                setState(() {
                  _file3 = file;
                });
              } else {
                if (_file1 != null &&
                    _file2 != null &&
                    _file3 != null &&
                    _file4 == null &&
                    _file5 == null) {
                  setState(() {
                    _file4 = file;
                  });
                } else {
                  if (_file1 != null &&
                      _file2 != null &&
                      _file3 != null &&
                      _file4 != null &&
                      _file5 == null) {
                    setState(() {
                      _file5 = file;
                    });
                  }
                }
              }
            }
          }
        }
      }
    } else {
      var pickedVideo = await ImagePicker().pickVideo(
          maxDuration: Duration(seconds: 30),
          source: isGallery == true ? ImageSource.gallery : ImageSource.camera);

      if (pickedVideo != null) {
        String dir = (await getApplicationDocumentsDirectory()).path;
        String newPath = path.join(dir, "${uuid.v4()}.mp4");
        File renamedFile = await File(pickedVideo.path).copy(newPath);
        print(renamedFile.path);

        if (renamedFile != null) {
          if (_file1 == null) {
            setState(() {
              _file1 = renamedFile;
              _previewFile = renamedFile;
              _videoWidget = VideoWidget(_file1);
              _videoIsThere = true;
            });
          } else {
            if (_file2 == null) {
              setState(() {
                _file2 = renamedFile;
                _previewFile = renamedFile;
                _videoWidget = VideoWidget(_file2);
                _videoIsThere = true;
              });
            } else {
              if (_file3 == null) {
                setState(() {
                  _file3 = renamedFile;
                  _previewFile = renamedFile;
                  _videoWidget = VideoWidget(_file3);
                  _videoIsThere = true;
                });
              } else {
                if (_file4 == null) {
                  setState(() {
                    _file4 = renamedFile;
                    _previewFile = renamedFile;
                    _videoWidget = VideoWidget(_file4);
                    _videoIsThere = true;
                  });
                } else {
                  if (_file5 == null) {
                    setState(() {
                      _file5 = renamedFile;
                      _previewFile = renamedFile;
                      _videoWidget = VideoWidget(_file5);
                      _videoIsThere = true;
                    });
                  } else {
                    if (_file6 == null) {
                      setState(() {
                        _file6 = renamedFile;
                        _previewFile = renamedFile;
                        _videoWidget = VideoWidget(_file6);
                        _videoIsThere = true;
                      });
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  bool _videoIsThere = false;

  _deletePicture(File file) async {
    if (_file1 != null) {
      if (_file1!.path == file.path) {
        if (_file2 != null &&
            _file3 != null &&
            _file4 != null &&
            _file5 != null &&
            _file6 != null) {
          setState(() {
            _file1 = _file2;
            _file2 = _file3;
            _file3 = _file4;
            _file4 = _file5;
            _file5 = _file6;
            _file6 = null;
          });

          if (_files.isNotEmpty) {
            _files.clear();
            if (_file1 != null) {
              _files.add(_file1);
            }
            if (_file2 != null) {
              _files.add(_file2);
            }
            if (_file3 != null) {
              _files.add(_file3);
            }
            if (_file4 != null) {
              _files.add(_file4);
            }
            if (_file5 != null) {
              _files.add(_file5);
            }
            if (_file6 != null) {
              _files.add(_file6);
            }
            setState(() {
              _createImageContainers();
            });
          }
        } else {
          if (_file2 != null &&
              _file3 != null &&
              _file4 != null &&
              _file5 != null &&
              _file6 == null) {
            setState(() {
              _file1 = _file2;
              _file2 = _file3;
              _file3 = _file4;
              _file4 = _file5;
              _file5 = null;
              _file6 = null;
            });
            if (_files.isNotEmpty) {
              _files.clear();
              if (_file1 != null) {
                _files.add(_file1);
              }
              if (_file2 != null) {
                _files.add(_file2);
              }
              if (_file3 != null) {
                _files.add(_file3);
              }
              if (_file4 != null) {
                _files.add(_file4);
              }
              if (_file5 != null) {
                _files.add(_file5);
              }
              if (_file6 != null) {
                _files.add(_file6);
              }
              setState(() {
                _createImageContainers();
              });
            }
          } else {
            if (_file2 != null &&
                _file3 != null &&
                _file4 != null &&
                _file5 == null &&
                _file6 == null) {
              setState(() {
                _file1 = _file2;
                _file2 = _file3;
                _file3 = _file4;
                _file4 = null;
                _file5 = null;
                _file6 = null;
              });
              if (_files.isNotEmpty) {
                _files.clear();
                if (_file1 != null) {
                  _files.add(_file1);
                }
                if (_file2 != null) {
                  _files.add(_file2);
                }
                if (_file3 != null) {
                  _files.add(_file3);
                }
                if (_file4 != null) {
                  _files.add(_file4);
                }
                if (_file5 != null) {
                  _files.add(_file5);
                }
                if (_file6 != null) {
                  _files.add(_file6);
                }
                setState(() {
                  _createImageContainers();
                });
              }
            } else {
              if (_file2 != null &&
                  _file3 != null &&
                  _file4 == null &&
                  _file5 == null &&
                  _file6 == null) {
                setState(() {
                  _file1 = _file2;
                  _file2 = _file3;
                  _file3 = null;
                  _file4 = null;
                  _file5 = null;
                  _file6 = null;
                });
                if (_files.isNotEmpty) {
                  _files.clear();
                  if (_file1 != null) {
                    _files.add(_file1);
                  }
                  if (_file2 != null) {
                    _files.add(_file2);
                  }
                  if (_file3 != null) {
                    _files.add(_file3);
                  }
                  if (_file4 != null) {
                    _files.add(_file4);
                  }
                  if (_file5 != null) {
                    _files.add(_file5);
                  }
                  if (_file6 != null) {
                    _files.add(_file6);
                  }
                  setState(() {
                    _createImageContainers();
                  });
                }
              } else {
                if (_file2 != null &&
                    _file3 == null &&
                    _file4 == null &&
                    _file5 == null &&
                    _file6 == null) {
                  setState(() {
                    _file1 = _file2;
                    _file2 = null;
                    _file3 = null;
                    _file4 = null;
                    _file5 = null;
                    _file6 = null;
                  });

                  if (_files.isNotEmpty) {
                    _files.clear();
                    if (_file1 != null) {
                      _files.add(_file1);
                    }
                    if (_file2 != null) {
                      _files.add(_file2);
                    }
                    if (_file3 != null) {
                      _files.add(_file3);
                    }
                    if (_file4 != null) {
                      _files.add(_file4);
                    }
                    if (_file5 != null) {
                      _files.add(_file5);
                    }
                    if (_file6 != null) {
                      _files.add(_file6);
                    }
                    setState(() {
                      _createImageContainers();
                    });
                  }
                } else {
                  if (_file2 == null &&
                      _file3 == null &&
                      _file4 == null &&
                      _file5 == null &&
                      _file6 == null) {
                    setState(() {
                      _file1 = null;
                      _file2 = null;
                      _file3 = null;
                      _file4 = null;
                      _file5 = null;
                      _file6 = null;
                      _files.clear();
                    });

                    setState(() {
                      _createImageContainers();
                    });
                  }
                }
              }
            }
          }
        }
      }
    }

    ///
    if (_file2 != null) {
      if (_file2!.path == file.path) {
        if (_file3 != null &&
            _file4 != null &&
            _file5 != null &&
            _file6 != null) {
          setState(() {
            _file2 = _file3;
            _file3 = _file4;
            _file4 = _file5;
            _file5 = _file6;
            _file6 = null;
          });
          if (_files.isNotEmpty) {
            _files.clear();
            if (_file1 != null) {
              _files.add(_file1);
            }
            if (_file2 != null) {
              _files.add(_file2);
            }
            if (_file3 != null) {
              _files.add(_file3);
            }
            if (_file4 != null) {
              _files.add(_file4);
            }
            if (_file5 != null) {
              _files.add(_file5);
            }
            if (_file6 != null) {
              _files.add(_file6);
            }
            setState(() {
              _createImageContainers();
            });
          }
        } else {
          if (_file3 != null &&
              _file4 != null &&
              _file5 != null &&
              _file6 == null) {
            setState(() {
              _file2 = _file3;
              _file3 = _file4;
              _file4 = _file5;
              _file5 = null;
              _file6 = null;
            });
            if (_files.isNotEmpty) {
              _files.clear();
              if (_file1 != null) {
                _files.add(_file1);
              }
              if (_file2 != null) {
                _files.add(_file2);
              }
              if (_file3 != null) {
                _files.add(_file3);
              }
              if (_file4 != null) {
                _files.add(_file4);
              }
              if (_file5 != null) {
                _files.add(_file5);
              }
              if (_file6 != null) {
                _files.add(_file6);
              }
              setState(() {
                _createImageContainers();
              });
            }
          } else {
            if (_file3 != null &&
                _file4 != null &&
                _file5 == null &&
                _file6 == null) {
              setState(() {
                _file2 = _file3;
                _file3 = _file4;
                _file4 = null;
                _file5 = null;
                _file6 = null;
              });
              if (_files.isNotEmpty) {
                _files.clear();
                if (_file1 != null) {
                  _files.add(_file1);
                }
                if (_file2 != null) {
                  _files.add(_file2);
                }
                if (_file3 != null) {
                  _files.add(_file3);
                }
                if (_file4 != null) {
                  _files.add(_file4);
                }
                if (_file5 != null) {
                  _files.add(_file5);
                }
                if (_file6 != null) {
                  _files.add(_file6);
                }
                setState(() {
                  _createImageContainers();
                });
              }
            } else {
              if (_file3 != null &&
                  _file4 == null &&
                  _file5 == null &&
                  _file6 == null) {
                setState(() {
                  _file2 = _file3;
                  _file3 = null;
                  _file4 = null;
                  _file5 = null;
                  _file6 = null;
                });
                if (_files.isNotEmpty) {
                  _files.clear();
                  if (_file1 != null) {
                    _files.add(_file1);
                  }
                  if (_file2 != null) {
                    _files.add(_file2);
                  }
                  if (_file3 != null) {
                    _files.add(_file3);
                  }
                  if (_file4 != null) {
                    _files.add(_file4);
                  }
                  if (_file5 != null) {
                    _files.add(_file5);
                  }
                  if (_file6 != null) {
                    _files.add(_file6);
                  }
                  setState(() {
                    _createImageContainers();
                  });
                }
              } else {
                if (_file3 == null &&
                    _file4 == null &&
                    _file5 == null &&
                    _file6 == null) {
                  setState(() {
                    _file2 = null;
                    _file3 = null;
                    _file4 = null;
                    _file5 = null;
                    _file6 = null;
                  });
                  if (_files.isNotEmpty) {
                    _files.clear();
                    if (_file1 != null) {
                      _files.add(_file1);
                    }
                    if (_file2 != null) {
                      _files.add(_file2);
                    }
                    if (_file3 != null) {
                      _files.add(_file3);
                    }
                    if (_file4 != null) {
                      _files.add(_file4);
                    }
                    if (_file5 != null) {
                      _files.add(_file5);
                    }
                    if (_file6 != null) {
                      _files.add(_file6);
                    }
                    setState(() {
                      _createImageContainers();
                    });
                  }
                }
              }
            }
          }
        }
      }
    }

    ///
    if (_file3 != null) {
      if (_file3!.path == file.path) {
        if (_file4 != null && _file5 != null && _file6 != null) {
          setState(() {
            _file3 = _file4;
            _file4 = _file5;
            _file5 = _file6;
            _file6 = null;
          });
          if (_files.isNotEmpty) {
            _files.clear();
            if (_file1 != null) {
              _files.add(_file1);
            }
            if (_file2 != null) {
              _files.add(_file2);
            }
            if (_file3 != null) {
              _files.add(_file3);
            }
            if (_file4 != null) {
              _files.add(_file4);
            }
            if (_file5 != null) {
              _files.add(_file5);
            }
            if (_file6 != null) {
              _files.add(_file6);
            }
            setState(() {
              _createImageContainers();
            });
          }
        } else {
          if (_file4 != null && _file5 != null && _file6 == null) {
            setState(() {
              _file3 = _file4;
              _file4 = _file5;
              _file5 = null;
              _file6 = null;
            });
            if (_files.isNotEmpty) {
              _files.clear();
              if (_file1 != null) {
                _files.add(_file1);
              }
              if (_file2 != null) {
                _files.add(_file2);
              }
              if (_file3 != null) {
                _files.add(_file3);
              }
              if (_file4 != null) {
                _files.add(_file4);
              }
              if (_file5 != null) {
                _files.add(_file5);
              }
              if (_file6 != null) {
                _files.add(_file6);
              }
              setState(() {
                _createImageContainers();
              });
            }
          } else {
            if (_file4 != null && _file5 == null && _file6 == null) {
              setState(() {
                _file3 = _file4;
                _file4 = null;
                _file5 = null;
                _file6 = null;
              });
              if (_files.isNotEmpty) {
                _files.clear();
                if (_file1 != null) {
                  _files.add(_file1);
                }
                if (_file2 != null) {
                  _files.add(_file2);
                }
                if (_file3 != null) {
                  _files.add(_file3);
                }
                if (_file4 != null) {
                  _files.add(_file4);
                }
                if (_file5 != null) {
                  _files.add(_file5);
                }
                if (_file6 != null) {
                  _files.add(_file6);
                }
                setState(() {
                  _createImageContainers();
                });
              }
            } else {
              if (_file4 == null && _file5 == null && _file6 == null) {
                setState(() {
                  _file3 = null;
                  _file4 = null;
                  _file5 = null;
                  _file6 = null;
                });
                if (_files.isNotEmpty) {
                  _files.clear();
                  if (_file1 != null) {
                    _files.add(_file1);
                  }
                  if (_file2 != null) {
                    _files.add(_file2);
                  }
                  if (_file3 != null) {
                    _files.add(_file3);
                  }
                  if (_file4 != null) {
                    _files.add(_file4);
                  }
                  if (_file5 != null) {
                    _files.add(_file5);
                  }
                  if (_file6 != null) {
                    _files.add(_file6);
                  }
                  setState(() {
                    _createImageContainers();
                  });
                }
              }
            }
          }
        }
      }
    }

    ///
    if (_file4 != null) {
      if (_file4!.path == file.path) {
        if (_file5 != null && _file6 != null) {
          setState(() {
            _file4 = _file5;
            _file5 = _file6;
            _file6 = null;
          });
          if (_files.isNotEmpty) {
            _files.clear();
            if (_file1 != null) {
              _files.add(_file1);
            }
            if (_file2 != null) {
              _files.add(_file2);
            }
            if (_file3 != null) {
              _files.add(_file3);
            }
            if (_file4 != null) {
              _files.add(_file4);
            }
            if (_file5 != null) {
              _files.add(_file5);
            }
            if (_file6 != null) {
              _files.add(_file6);
            }
            setState(() {
              _createImageContainers();
            });
          }
        } else {
          if (_file5 != null && _file6 == null) {
            setState(() {
              _file4 = _file5;
              _file5 = null;
              _file6 = null;
            });
            if (_files.isNotEmpty) {
              _files.clear();
              if (_file1 != null) {
                _files.add(_file1);
              }
              if (_file2 != null) {
                _files.add(_file2);
              }
              if (_file3 != null) {
                _files.add(_file3);
              }
              if (_file4 != null) {
                _files.add(_file4);
              }
              if (_file5 != null) {
                _files.add(_file5);
              }
              if (_file6 != null) {
                _files.add(_file6);
              }
              setState(() {
                _createImageContainers();
              });
            }
          } else {
            if (_file5 == null && _file6 == null) {
              setState(() {
                _file4 = null;
                _file5 = null;
                _file6 = null;
              });
              if (_files.isNotEmpty) {
                _files.clear();
                if (_file1 != null) {
                  _files.add(_file1);
                }
                if (_file2 != null) {
                  _files.add(_file2);
                }
                if (_file3 != null) {
                  _files.add(_file3);
                }
                if (_file4 != null) {
                  _files.add(_file4);
                }
                if (_file5 != null) {
                  _files.add(_file5);
                }
                if (_file6 != null) {
                  _files.add(_file6);
                }
                setState(() {
                  _createImageContainers();
                });
              }
            }
          }
        }
      }
    }

    ///
    if (_file5 != null) {
      if (_file5!.path == file.path) {
        if (_file6 != null) {
          setState(() {
            _file5 = _file6;
            _file6 = null;
          });
          if (_files.isNotEmpty) {
            _files.clear();
            if (_file1 != null) {
              _files.add(_file1);
            }
            if (_file2 != null) {
              _files.add(_file2);
            }
            if (_file3 != null) {
              _files.add(_file3);
            }
            if (_file4 != null) {
              _files.add(_file4);
            }
            if (_file5 != null) {
              _files.add(_file5);
            }
            if (_file6 != null) {
              _files.add(_file6);
            }
            setState(() {
              _createImageContainers();
            });
          }
        } else {
          if (_file6 == null) {
            setState(() {
              _file5 = null;
              _file6 = null;
            });
            if (_files.isNotEmpty) {
              _files.clear();
              if (_file1 != null) {
                _files.add(_file1);
              }
              if (_file2 != null) {
                _files.add(_file2);
              }
              if (_file3 != null) {
                _files.add(_file3);
              }
              if (_file4 != null) {
                _files.add(_file4);
              }
              if (_file5 != null) {
                _files.add(_file5);
              }
              if (_file6 != null) {
                _files.add(_file6);
              }
              setState(() {
                _createImageContainers();
              });
            }
          }
        }
      }
    }

    ///
    if (_file6 != null) {
      if (_file6!.path == file.path) {
        if (_file6 != null) {
          setState(() {
            _file6 = null;
          });
          if (_files.isNotEmpty) {
            _files.clear();
            if (_file1 != null) {
              _files.add(_file1);
            }
            if (_file2 != null) {
              _files.add(_file2);
            }
            if (_file3 != null) {
              _files.add(_file3);
            }
            if (_file4 != null) {
              _files.add(_file4);
            }
            if (_file5 != null) {
              _files.add(_file5);
            }
            if (_file6 != null) {
              _files.add(_file6);
            }
            setState(() {
              _createImageContainers();
            });
          }
        }
      }
    }
  }

  File? _file1;
  File? _file2;
  File? _file3;
  File? _file4;
  File? _file5;
  File? _file6;
  File? _previewFile;

  void _onReorder(int oldIndex, int newIndex) {
    int counter = 1;

    var files = _files.removeAt(oldIndex);

    _files.insert(newIndex, files);

    for (int i = 0; i < _files.length; i++) {
      if (counter == 1) {
        if (_file1 != null) {
          _file1 = _files[0];
        }
      }

      if (counter == 2) {
        if (_file2 != null) {
          _file2 = _files[1];
        }
      }

      if (counter == 3) {
        if (_file3 != null) {
          _file3 = _files[2];
        }
      }

      if (counter == 4) {
        if (_file4 != null) {
          _file4 = _files[3];
        }
      }

      if (counter == 5) {
        if (_file5 != null) {
          _file5 = _files[4];
        }
      }

      if (counter == 6) {
        if (_file6 != null) {
          _file6 = _files[5];
        }
      }
      setState(() {
        _createImageContainers();
      });

      counter++;
    }
  }

  _imgContainers() {
    if (_files.isNotEmpty) {
      fileBorderColor = Colors.grey;
    }
    return ReorderableWrap(
      children: _imageContainers.isNotEmpty ? _imageContainers : [Container()],
      onReorder: _onReorder,
      alignment: WrapAlignment.center,
      spacing: 9.0,
      runSpacing: 3.0,
      needsLongPressDraggable: true,
      footer:
          _files.length < 6 ? _imageContainerWithoutFile(context, null) : null,
    );
  }

  Future<File?> _cropImage(File _file1) async => await ImageCropper.cropImage(
      sourcePath: _file1.path,
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

  Widget buildAllSelectedCheckbox(CheckboxState checkbox) => Theme(
        data: ThemeData(
          unselectedWidgetColor: Theme.of(context).primaryColor,
        ),
        child: CheckboxListTile(
          value: checkbox.value,
          controlAffinity: ListTileControlAffinity.platform,
          checkColor: Colors.white,
          activeColor: Theme.of(context).primaryColor,
          title: Text(checkbox.title!),
          onChanged: toggleSelectAll,
        ),
      );

  void toggleSelectAll(bool? value) {
    if (value == null) return;

    setState(() {
      selectAllCheckboxes.value = value;
      checkboxListSubSubRubric
          .forEach((checkboxes) => checkboxes.value = value);
      checkboxColor = Theme.of(context).primaryColor;
    });
    if (value == false) {
      pickedCheckboxIds.clear();
    } else {
      pickedCheckboxIds.clear();
      checkboxListSubSubRubric
          .forEach((checkboxes) => pickedCheckboxIds.add(checkboxes.id!));
    }
    print("all: " + pickedCheckboxIds.toString());
  }

  MaterialColor white = const MaterialColor(
    0xFFFFFFFF,
    const <int, Color>{
      50: const Color(0xFFFFFFFF),
      100: const Color(0xFFFFFFFF),
      200: const Color(0xFFFFFFFF),
      300: const Color(0xFFFFFFFF),
      400: const Color(0xFFFFFFFF),
      500: const Color(0xFFFFFFFF),
      600: const Color(0xFFFFFFFF),
      700: const Color(0xFFFFFFFF),
      800: const Color(0xFFFFFFFF),
      900: const Color(0xFFFFFFFF),
    },
  );

  Widget buildCheckBox(CheckboxState checkbox) => Theme(
        data: ThemeData(
          unselectedWidgetColor: Theme.of(context).primaryColor,
        ),
        child: CheckboxListTile(
          value: checkbox.value,
          controlAffinity: ListTileControlAffinity.platform,
          checkColor: Colors.white,
          activeColor: Theme.of(context).primaryColor,
          title: Text(checkbox.title!),
          onChanged: (value) {
            print(value);
            setState(() {
              checkbox.value = value;
              selectAllCheckboxes.value = checkboxListSubSubRubric
                  .every((checkbox) => checkbox.value == true);
            });
            if (pickedCheckboxIds.contains(checkbox.id)) {
              pickedCheckboxIds.remove(checkbox.id);
            } else {
              pickedCheckboxIds.add(checkbox.id!);
              setState(() {
                checkboxColor = Theme.of(context).primaryColor;
              });
            }
            print(checkbox.id);

            print(pickedCheckboxIds);
          },
        ),
      );

  _closeScreenDialog(BuildContext context) async {
    FocusScope.of(context).unfocus();
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.circular(11),
            ),
            title: Text(
              _closeScreenTitle,
              style: TextStyle(),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(253, 166, 41, 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(33),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  _closeScreen,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  _previewIsOpen = false;
                  _previewHomeFeedIsOpen = false;
                  _previewDetailIsOpen = false;
                  _controller.dispose();
                  _shortDescriptionController.text = "";
                  _longDescriptionController.text = "";
                  _isInit = true;
                  _previewIsOpen = false;
                  _loading = false;
                  _files.clear();
                  await Navigator.of(context, rootNavigator: false)
                      .pushReplacementNamed(HomeScreen.routeName);
                },
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(112, 184, 73, 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(33),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  _notCloseScreen,
                  style: TextStyle(),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  String priceMethod() {
    price = 0;
    List<int> durations = [];
    int duration = -1;
    int dayFlag = 0;
    for (var i = 0; i < openingHoursAndDays.length; i++) {
      int day = openingHoursAndDays[i]["day"];
      if (dayFlag != day && duration > -1) {
        durations.add(duration);
      }
      if (dayFlag != day) {
        duration = 0;
      }
      dayFlag = openingHoursAndDays[i]["day"];
      DateTime from = openingHoursAndDays[i]["datetime_from"];
      DateTime to = openingHoursAndDays[i]["datetime_to"];

      for (var j = 0; j < addedRanges.length; j++) {
        // print("object");
        // print(addedRanges[j].start);
        // print(addedRanges[j].end);
        // print(from);
        // print(to);
        if ((addedRanges[j].start.isAtSameMomentAs(from) ||
                addedRanges[j].start.isAfter(from)) &&
            (addedRanges[j].end.isAtSameMomentAs(to) ||
                addedRanges[j].start.isBefore(to))) {
          duration = duration + addedRanges[j].duration.inMinutes;
          if (i == openingHoursAndDays.length - 1) {
            durations.add(duration);
          }
        }
      }
    }
    durations.removeWhere((element) => element == 0);

    for (int i = 0; i < durations.length; i++) {
      double prc = price;
      price = ((_visibleMeters / 100 * 0.1) +
              (_notificationMeters / 100 * 0.05) +
              ((durations[i] / 60) * 0.85)) /
          3.51;

      if (price < 0.99) {
        price = 0.99;
      }

      if (price > 4.99) {
        price = 4.99;
      }

      price = prc + price;
    }

    if (_hasFlatrate) {
      price = 0;
    }

    return price.toStringAsFixed(2);
  }
}
