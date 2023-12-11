// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:time_range_picker/time_range_picker.dart';

// class SelectOpeningHoursWidget extends StatefulWidget {
//   const SelectOpeningHoursWidget({ Key? key }) : super(key: key);

//   @override
//   _SelectOpeningHoursWidgetState createState() => _SelectOpeningHoursWidgetState();
// }

// class _SelectOpeningHoursWidgetState extends State<SelectOpeningHoursWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
      
//     );



    
//   }
//     Widget _daysOpeningHour({
//       required String dayString,
//       required dynamic dayOpeningHours,
//       required dynamic secondDayEnum,
//       required dynamic thirdDayEnum,
//       required TimeOfDay? firstFrom,
//       required TimeOfDay? firstTo,
//       required TimeOfDay? secondFrom,
//       required TimeOfDay? secondTo,
//       required TimeOfDay? thirdFrom,
//       required TimeOfDay? thirdTo,
//       required Icon dayOneAddIcon,
//       required Icon dayTwoAddIcon,
//       required Icon dayThreeAddIcon,
//       required String chooseOpeningHoursButtonTextDay,
//       required String addMoreOpeningHoursDayTwo,
//       required String addMoreOpeningHoursDayThree,
//     }) {
//       return Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 dayString,
//                 overflow: TextOverflow.clip,
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: _nowNowGeneralColor,
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   if (dayOpeningHours == secondDayEnum ||
//                       dayOpeningHours == thirdDayEnum)
//                     SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.05,
//                       child: RawMaterialButton(
//                         shape: const CircleBorder(),
//                         fillColor: Colors.red[900],
//                         onPressed: () {
//                           if (dayOpeningHours == secondDayEnum &&
//                               secondFrom == null &&
//                               secondTo == null &&
//                               thirdFrom == null &&
//                               thirdTo == null) {
//                             setState(() {
//                               firstFrom = null;
//                               firstTo = null;
//                               dayOneAddIcon = Platform.isAndroid
//                                   ? const Icon(Icons.add)
//                                   : const Icon(CupertinoIcons.add);
//                               chooseOpeningHoursButtonTextDay = "Opening Hours";
//                               dayOpeningHours = null;
//                             });
//                           }
//                           if (dayOpeningHours == thirdDayEnum &&
//                               secondFrom != null &&
//                               secondTo != null &&
//                               thirdFrom == null &&
//                               thirdTo == null) {
//                             setState(() {
//                               firstFrom = secondFrom;
//                               firstTo = secondTo;

//                               secondFrom = null;
//                               secondTo = null;
//                               addMoreOpeningHoursDayTwo = "Add";
//                               thirdFrom = null;
//                               thirdTo = null;
//                               dayOneAddIcon = Platform.isAndroid
//                                   ? const Icon(Icons.edit)
//                                   : const Icon(CupertinoIcons.pencil);
//                               dayTwoAddIcon = Platform.isAndroid
//                                   ? const Icon(Icons.add)
//                                   : const Icon(CupertinoIcons.add);
//                               dayThreeAddIcon = Platform.isAndroid
//                                   ? const Icon(Icons.add)
//                                   : const Icon(CupertinoIcons.add);
//                               addMoreOpeningHoursDayThree = "Add";
//                               chooseOpeningHoursButtonTextDay =
//                                   "${firstFrom!.format(context)} - ${firstTo!.format(context)}";
//                               dayOpeningHours = secondDayEnum;
//                             });
//                           }

//                           if (dayOpeningHours == thirdDayEnum &&
//                               secondFrom != null &&
//                               secondTo != null &&
//                               thirdFrom != null &&
//                               thirdTo != null) {
//                             setState(() {
//                               firstFrom = secondFrom;
//                               firstTo = secondTo;
//                               chooseOpeningHoursButtonTextDay =
//                                   "${firstFrom!.format(context)} - ${firstTo!.format(context)}";
//                               dayOneAddIcon = Platform.isAndroid
//                                   ? const Icon(Icons.edit)
//                                   : const Icon(CupertinoIcons.pencil);
//                               dayTwoAddIcon = Platform.isAndroid
//                                   ? const Icon(Icons.edit)
//                                   : const Icon(CupertinoIcons.pencil);

//                               dayThreeAddIcon = Platform.isAndroid
//                                   ? const Icon(Icons.add)
//                                   : const Icon(CupertinoIcons.add);
//                               secondFrom = thirdFrom;
//                               secondTo = thirdTo;
//                               addMoreOpeningHoursDayTwo =
//                                   "${secondFrom!.format(context)} - ${secondTo!.format(context)}";
//                               thirdFrom = null;
//                               thirdTo = null;
//                               addMoreOpeningHoursDayThree = "Add";
//                               dayOpeningHours = thirdDayEnum;
//                             });
//                           }
//                         },
//                         child: Icon(
//                           Icons.close,
//                           size: MediaQuery.of(context).size.width * 0.04,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width * 0.03,
//                   ),
//                   ElevatedButton.icon(
//                     icon: dayOneAddIcon,
//                     style: ElevatedButton.styleFrom(
//                       primary: _buttonColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadiusDirectional.circular(33),
//                       ),
//                     ),
//                     onPressed: () async {
//                       TimeRange? result = await showTimeRangePicker(
//                         context: context,
//                         start: firstFrom,
//                         end: firstTo,
//                         disabledTime: secondFrom != null && thirdTo != null
//                             ? TimeRange(
//                                 startTime: secondFrom!, endTime: thirdTo!)
//                             : thirdTo == null && secondFrom != null
//                                 ? TimeRange(
//                                     startTime: secondFrom!, endTime: secondTo!)
//                                 : null,
//                         fromText: _chooseOpeningHoursFrom,
//                         toText: _chooseOpeningHoursTo,
//                         activeTimeTextStyle: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 33),
//                         timeTextStyle: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 23),
//                         selectedColor: Theme.of(context).accentColor,
//                         use24HourFormat: true,
//                         interval: Duration(minutes: _timeSteps),
//                         ticks: _ticks,
//                       );
//                       setState(() {
//                         _nownowOpeningHourColor =
//                             const Color.fromRGBO(112, 184, 73, 1.0);
//                         firstFrom = result!.startTime;

//                         firstTo = result.endTime;
//                         chooseOpeningHoursButtonTextDay =
//                             "${firstFrom!.format(context)} - ${firstTo!.format(context)}";
//                         dayOneAddIcon = Platform.isAndroid
//                             ? const Icon(Icons.edit)
//                             : const Icon(CupertinoIcons.pencil);

//                         if (secondFrom == null && thirdFrom == null) {
//                           dayOpeningHours = secondDayEnum;
//                         }
//                       });

//                       print("hadi bakalim one from " + firstFrom.toString());
//                       print("hadi bakalim one to " + firstTo.toString());

//                       print("hadi bakalim two from " + secondFrom.toString());
//                       print("hadi bakalim two to " + secondTo.toString());
//                       print("hadi bakalim three from " + thirdFrom.toString());
//                       print("hadi bakalim three to " + thirdTo.toString());
//                     },
//                     label: Text(
//                       chooseOpeningHoursButtonTextDay,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),

//           //Opening Hours Monday Two/////////////////////////////////////////

//           if ((dayOpeningHours == secondDayEnum ||
//                   dayOpeningHours == thirdDayEnum) &&
//               firstFrom != firstTo)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Visibility(
//                   visible: false,
//                   child: Text(
//                     "",
//                     overflow: TextOverflow.clip,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     if (dayOpeningHours == secondDayEnum &&
//                             secondFrom != null &&
//                             secondTo != null ||
//                         dayOpeningHours == thirdDayEnum)
//                       SizedBox(
//                         width: MediaQuery.of(context).size.width * 0.05,
//                         child: RawMaterialButton(
//                           shape: const CircleBorder(),
//                           fillColor: Colors.red[900],
//                           onPressed: () {
//                             if (dayOpeningHours == thirdDayEnum &&
//                                 secondFrom != null &&
//                                 secondTo != null &&
//                                 thirdFrom == null &&
//                                 thirdTo == null) {
//                               setState(() {
//                                 secondFrom = null;
//                                 secondTo = null;

//                                 addMoreOpeningHoursDayTwo = "Add";
//                                 dayOpeningHours = secondDayEnum;

//                                 dayTwoAddIcon = Platform.isAndroid
//                                     ? const Icon(Icons.add)
//                                     : const Icon(CupertinoIcons.add);
//                               });
//                             }
//                             if (dayOpeningHours == thirdDayEnum &&
//                                 thirdFrom != null &&
//                                 thirdTo != null) {
//                               setState(() {
//                                 secondFrom = thirdFrom;
//                                 secondTo = thirdTo;
//                                 thirdFrom = null;
//                                 thirdTo = null;

//                                 dayTwoAddIcon = Platform.isAndroid
//                                     ? const Icon(Icons.edit)
//                                     : const Icon(CupertinoIcons.pencil);
//                                 dayThreeAddIcon = Platform.isAndroid
//                                     ? const Icon(Icons.add)
//                                     : const Icon(CupertinoIcons.add);
//                                 addMoreOpeningHoursDayThree = "Add";
//                                 addMoreOpeningHoursDayTwo =
//                                     "${secondFrom!.format(context)} - ${secondTo!.format(context)}";
//                                 dayOpeningHours = thirdDayEnum;
//                               });
//                             }
//                           },
//                           child: Icon(
//                             Icons.close,
//                             color: Colors.white,
//                             size: MediaQuery.of(context).size.width * 0.04,
//                           ),
//                         ),
//                       ),
//                     SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.03,
//                     ),
//                     ElevatedButton.icon(
//                       icon: dayTwoAddIcon,
//                       style: ElevatedButton.styleFrom(
//                         primary: _buttonColor,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadiusDirectional.circular(33),
//                         ),
//                       ),
//                       onPressed: () async {
//                         TimeRange? result = await showTimeRangePicker(
//                           context: context,
//                           start: TimeOfDay(
//                             hour: firstTo!.hour,
//                             minute: firstTo!.minute + 15,
//                           ),
//                           end: TimeOfDay(
//                             hour: firstTo!.hour,
//                             minute: firstTo!.minute + 30,
//                           ),
//                           disabledTime: thirdFrom != null && firstTo != null
//                               ? TimeRange(
//                                   startTime: thirdFrom!, endTime: firstTo!)
//                               : TimeRange(
//                                   startTime: firstFrom!, endTime: firstTo!),
//                           fromText: _chooseOpeningHoursFrom,
//                           toText: _chooseOpeningHoursTo,
//                           activeTimeTextStyle: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 33),
//                           timeTextStyle: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 23),
//                           selectedColor: Theme.of(context).accentColor,
//                           use24HourFormat: true,
//                           interval: Duration(minutes: _timeSteps),
//                           ticks: _ticks,
//                         );
//                         setState(() {
//                           secondFrom = result!.startTime;
//                           secondTo = result.endTime;

//                           addMoreOpeningHoursDayTwo =
//                               "${secondFrom!.format(context)} - ${secondTo!.format(context)}";
//                           dayTwoAddIcon = Platform.isAndroid
//                               ? const Icon(Icons.edit)
//                               : const Icon(CupertinoIcons.pencil);

//                           dayOpeningHours = thirdDayEnum;
//                         });

//                         print("hadi bakalim one from " + firstFrom.toString());
//                         print("hadi bakalim one to " + firstTo.toString());
//                         print("hadi bakalim two from " + secondFrom.toString());
//                         print("hadi bakalim two to " + secondTo.toString());
//                         print(
//                             "hadi bakalim three from " + thirdFrom.toString());
//                         print("hadi bakalim three to " + thirdTo.toString());
//                       },
//                       label: Text(
//                         addMoreOpeningHoursDayTwo,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//           //Opening Hours Monday Three
//           if (dayOpeningHours == thirdDayEnum && secondTo != firstFrom)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Visibility(
//                   visible: false,
//                   child: Text(
//                     "",
//                     overflow: TextOverflow.clip,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     if (dayOpeningHours == thirdDayEnum &&
//                         thirdFrom != null &&
//                         thirdTo != null)
//                       SizedBox(
//                         width: MediaQuery.of(context).size.width * 0.05,
//                         child: RawMaterialButton(
//                           shape: const CircleBorder(),
//                           fillColor: Colors.red[900],
//                           onPressed: () {
//                             setState(() {
//                               thirdFrom = null;
//                               thirdTo = null;

//                               dayThreeAddIcon = Platform.isAndroid
//                                   ? const Icon(Icons.add)
//                                   : const Icon(CupertinoIcons.add);
//                               addMoreOpeningHoursDayThree = "Add";
//                             });
//                           },
//                           child: Icon(
//                             Icons.close,
//                             color: Colors.white,
//                             size: MediaQuery.of(context).size.width * 0.04,
//                           ),
//                         ),
//                       ),
//                     SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.03,
//                     ),
//                     ElevatedButton.icon(
//                       icon: dayThreeAddIcon,
//                       style: ElevatedButton.styleFrom(
//                         primary: _buttonColor,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadiusDirectional.circular(33),
//                         ),
//                       ),
//                       onPressed: () async {
//                         TimeRange? result = await showTimeRangePicker(
//                           context: context,
//                           start: TimeOfDay(
//                             hour: secondTo!.hour,
//                             minute: secondTo!.minute + 15,
//                           ),
//                           end: TimeOfDay(
//                             hour: secondTo!.hour,
//                             minute: secondTo!.minute + 30,
//                           ),
//                           disabledTime: TimeRange(
//                               startTime: firstFrom!, endTime: secondTo!),
//                           fromText: _chooseOpeningHoursFrom,
//                           toText: _chooseOpeningHoursTo,
//                           activeTimeTextStyle: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 33),
//                           timeTextStyle: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 23),
//                           selectedColor: Theme.of(context).accentColor,
//                           use24HourFormat: true,
//                           interval: Duration(minutes: _timeSteps),
//                           ticks: _ticks,
//                         );
//                         setState(() {
//                           thirdFrom = result!.startTime;
//                           thirdTo = result.endTime;
//                           dayThreeAddIcon = Platform.isAndroid
//                               ? const Icon(Icons.edit)
//                               : const Icon(CupertinoIcons.pencil);

//                           addMoreOpeningHoursDayThree =
//                               "${thirdFrom!.format(context)} - ${thirdTo!.format(context)}";
//                         });

//                         print("hadi bakalim one from " + firstFrom.toString());
//                         print("hadi bakalim one to " + firstTo.toString());
//                         print("hadi bakalim two from " + secondFrom.toString());
//                         print("hadi bakalim two to " + secondTo.toString());
//                         print(
//                             "hadi bakalim three from " + thirdFrom.toString());
//                         print("hadi bakalim three to " + thirdTo.toString());
//                       },
//                       label: Text(
//                         addMoreOpeningHoursDayThree,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//         ],
//       );
//     }
  
// }