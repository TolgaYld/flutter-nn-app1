import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../providers/address.dart';
import '../providers/addresses.dart';
import '../providers/opening_hours.dart';
import 'package:provider/provider.dart';

class AddressGeneralScreen extends StatelessWidget {
  List _openingHoursListDateTimeRange = [];
  static const routeName = '/addressGeneral';
  AddressGeneralScreen({Key? key, this.id}) : super(key: key);
  String? id;
  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;
    final Address address =
        Provider.of<Addresses>(context, listen: true).findById(id!);
    return Scaffold(
      body: NestedScrollView(
          // floatHeaderSlivers: true,
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
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: _width * 0.09,
                          child: AspectRatio(
                            aspectRatio: 2 / 1.5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(100),
                                ),
                                border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 1),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image:
                                          NetworkImage(address.media!.first)),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(100),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.name!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "${address.street}, ",
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.45),
                                    fontSize: 8.1,
                                  ),
                                ),
                                Text(
                                  "${address.postcode!}, ",
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.45),
                                    fontSize: 8.1,
                                  ),
                                ),
                                Text(
                                  "${address.city}, ",
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.45),
                                    fontSize: 8.1,
                                  ),
                                ),
                                Text(
                                  address.country,
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.45),
                                    fontSize: 8.1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
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
          body: bodyWidgetGeneral(address, context)),
    );
  }

  bodyWidgetGeneral(Address address, BuildContext context) {
    DateFormat formatter = DateFormat('HH:mm');
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;

    final _openingHours = Provider.of<OpeningHours>(context, listen: true)
        .findByAddressId(address.id!);

    List daysString = [];
    List mondayList = [];
    List tuesdayList = [];
    List wednesdayList = [];
    List thursdayList = [];
    List fridayList = [];
    List saturdayList = [];
    List sundayList = [];

    _openingHoursListDateTimeRange.clear();
    for (var i = 0; i < _openingHours.length; i++) {
      DateTime helper = DateTime(2022, 01, 03, 00, 00, 0, 0, 0);

      for (var j = 0; j < 7; j++) {
        if (helper.add(Duration(days: j)).weekday == _openingHours[i].day) {
          DateTime begin = DateTime(
            2022,
            01,
            helper
                .add(Duration(days: j))
                .add(Duration(
                    days: _openingHours[i].day != _openingHours[i].dayFrom
                        ? 1
                        : 0))
                .day,
            _openingHours[i].timeFrom.hour,
            _openingHours[i].timeFrom.minute,
            0,
            0,
            0,
          );
          DateTime end =
              begin.add(Duration(minutes: _openingHours[i].duration));

          if (_openingHours[i].day == 1) {
            mondayList.add({
              "day": _openingHours[i].day,
              "time_from": formatter.format(begin),
              "time_to": formatter.format(end)
            });
          }
          if (_openingHours[i].day == 2) {
            tuesdayList.add({
              "day": _openingHours[i].day,
              "time_from": formatter.format(begin),
              "time_to": formatter.format(end)
            });
          }
          if (_openingHours[i].day == 3) {
            wednesdayList.add({
              "day": _openingHours[i].day,
              "time_from": formatter.format(begin),
              "time_to": formatter.format(end)
            });
          }
          if (_openingHours[i].day == 4) {
            thursdayList.add({
              "day": _openingHours[i].day,
              "time_from": formatter.format(begin),
              "time_to": formatter.format(end)
            });
          }
          if (_openingHours[i].day == 5) {
            fridayList.add({
              "day": _openingHours[i].day,
              "time_from": formatter.format(begin),
              "time_to": formatter.format(end)
            });
          }
          if (_openingHours[i].day == 6) {
            saturdayList.add({
              "day": _openingHours[i].day,
              "time_from": formatter.format(begin),
              "time_to": formatter.format(end)
            });
          }

          if (_openingHours[i].day == 7) {
            sundayList.add({
              "day": _openingHours[i].day,
              "time_from": formatter.format(begin),
              "time_to": formatter.format(end)
            });
          }
        }
      }
    }
    if (mondayList.isNotEmpty) {
      daysString.add(mondayList);
    } else {
      daysString.add([
        {"day": 1}
      ]);
    }

    if (tuesdayList.isNotEmpty) {
      daysString.add(tuesdayList);
    } else {
      daysString.add([
        {"day": 2}
      ]);
    }
    if (wednesdayList.isNotEmpty) {
      daysString.add(wednesdayList);
    } else {
      daysString.add([
        {"day": 3}
      ]);
    }
    if (thursdayList.isNotEmpty) {
      daysString.add(thursdayList);
    } else {
      daysString.add([
        {"day": 4}
      ]);
    }
    if (fridayList.isNotEmpty) {
      daysString.add(fridayList);
    } else {
      daysString.add([
        {"day": 5}
      ]);
    }
    if (saturdayList.isNotEmpty) {
      daysString.add(saturdayList);
    } else {
      daysString.add([
        {"day": 6}
      ]);
    }
    if (sundayList.isNotEmpty) {
      daysString.add(sundayList);
    } else {
      daysString.add([
        {"day": 7}
      ]);
    }
    if (_openingHoursListDateTimeRange.isNotEmpty) {
      _openingHoursListDateTimeRange.sort((a, b) =>
          a["datetimerange"].start.compareTo((b["datetimerange"].start)));
    }

    return GestureDetector(
      onTap: () {
        streamController.add(false);
      },
      child: SafeArea(
        top: false,
        bottom: false,
        child: Builder(
          builder: (context) => CustomScrollView(
            slivers: [
              SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: _height * 0.012,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: _width * 0.333,
                            child: AspectRatio(
                              aspectRatio: 2 / 1.5,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(100),
                                  ),
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image:
                                            NetworkImage(address.media!.first)),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                address.street,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                address.postcode!,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                address.city,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                address.country,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                              if (!address.isActive!)
                                Text(
                                  "Address will be activated",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: _height * 0.012,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Opening Hours"),
                          SizedBox(
                            height: _height * 0.06,
                          ),
                          Column(
                            children: List.generate(7, (index) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (daysString[index][0]["time_from"] == null)
                                    if (index == 0) Text("Monday: Closed"),
                                  if (daysString[index][0]["time_from"] == null)
                                    if (index == 1) Text("Tuesday: Closed"),
                                  if (daysString[index][0]["time_from"] == null)
                                    if (index == 2) Text("Wednesday: Closed"),
                                  if (daysString[index][0]["time_from"] == null)
                                    if (index == 3) Text("Thursday: Closed"),
                                  if (daysString[index][0]["time_from"] == null)
                                    if (index == 4) Text("Friday: Closed"),
                                  if (daysString[index][0]["time_from"] == null)
                                    if (index == 5) Text("Saturday: Closed"),
                                  if (daysString[index][0]["time_from"] == null)
                                    if (index == 6) Text("Sunday: Closed"),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  if (daysString[index][0]["time_from"] != null)
                                    Row(
                                      children: [
                                        if (index == 0) Text("Monday: "),
                                        if (index == 1) Text("Tuesday: "),
                                        if (index == 2) Text("Wednesday: "),
                                        if (index == 3) Text("Thursday: "),
                                        if (index == 4) Text("Friday: "),
                                        if (index == 5) Text("Saturday: "),
                                        if (index == 6) Text("Sunday: "),
                                        if (daysString[index].length == 1)
                                          Text(
                                              "${daysString[index][0]["time_from"]}-${daysString[index][0]["time_to"]}"),
                                        if (daysString[index].length == 2)
                                          Text(
                                              "${daysString[index][0]["time_from"]}-${daysString[index][0]["time_to"]}, ${daysString[index][1]["time_from"]}:${daysString[index][1]["time_to"]}"),
                                        if (daysString[index].length == 3)
                                          Text(
                                              "${daysString[index][0]["time_from"]}-${daysString[index][0]["time_to"]}, ${daysString[index][1]["time_from"]}:${daysString[index][1]["time_to"]}, ${daysString[index][2]["time_from"]}:${daysString[index][2]["time_to"]}"),
                                      ],
                                    )
                                ],
                              );
                            }),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
