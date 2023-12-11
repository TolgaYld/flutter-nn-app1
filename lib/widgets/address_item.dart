import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mime/mime.dart';
import 'package:nownow_advertiser/main.dart';
import 'package:nownow_advertiser/screens/address_detail_screen.dart';
import 'package:nownow_advertiser/widgets/network_player.dart';
import 'package:nownow_advertiser/widgets/video_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:video_player/video_player.dart';
import '../widgets/countdown_widget.dart';
import '../providers/categorys.dart';
import '../providers/qroffers.dart';
import '../providers/stads.dart';
import 'package:provider/provider.dart';
import '../providers/address.dart';

class AddressItem extends StatelessWidget {
  AddressItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    EdgeInsets _padding = MediaQuery.of(context).padding;
    EdgeInsets _instets = MediaQuery.of(context).viewInsets;
    double _paddingLeft = _padding.left;
    double _paddingRight = _padding.right;
    double _paddingTop = _padding.top;
    double _paddingBottom = _padding.bottom;

    final address = Provider.of<Address>(context, listen: false);
    final stads = Provider.of<Stads>(context, listen: true).now(address.id!);
    final qroffers =
        Provider.of<Qroffers>(context, listen: true).now(address.id.toString());
    final categoryOfStore = Provider.of<Categorys>(context, listen: false)
        .findById(address.categoryId);
    final String _categoryColor = categoryOfStore.color;

    Color color;

    switch (_categoryColor) {
      case "blue":
        color = Colors.blue;
        break;
      case "red":
        color = Colors.red;
        break;
      case "green":
        color = Colors.green;
        break;
      case "brown":
        color = Colors.brown;
        break;
      case "purple":
        color = Colors.purple;
        break;
      default:
        color = Colors.yellow;
        break;
    }

    // Widget _mediaCheck() {
    //   if (stad != null) {
    //     String? mime = lookupMimeType(stad.media.first);
    //     var fileType = mime!.split('/');
    //     if (fileType.contains("video")) {
    //       return NetworkPlayerWidget(url: stad.media.first);
    //     }
    //   }
    //   return Image.network(
    //     stad == null ? address.media![0] : stad.media[0],
    //     width: double.infinity,
    //     height: MediaQuery.of(context).size.width / 4 * 3,
    //     fit: BoxFit.cover,
    //   );
    // }

    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(
            bottom: _height * 0.030,
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            margin: EdgeInsets.only(
              left: _width * 0.01,
              right: _width * 0.01,
            ),
            child: Container(
              child: InkWell(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                onTap: () async {
                  streamController.add(false);
                  await Navigator.of(context).push(MaterialPageRoute(
                      settings: RouteSettings(
                        arguments: address.id,
                      ),
                      builder: (context) => AddressDetailScreen()));
                }, //selectAdvertisement(context),
                child: Column(
                  children: <Widget>[
                    // Stack(
                    // children: <Widget>[
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Image.network(
                        address.media![0],
                        width: double.infinity,
                        height: MediaQuery.of(context).size.width / 4 * 3,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // if (Platform.isAndroid &&
                    //     qroffers != null &&
                    //     qroffers.isNotEmpty)
                    //   Padding(
                    //     padding: MediaQuery.of(context).viewPadding * 1,
                    //     child: const Icon(
                    //       FontAwesomeIcons.qrcode,
                    //       size: 45,
                    //       color: Colors.white,
                    //     ),
                    //   ),

                    // Padding(
                    //   padding: MediaQuery.of(context).viewPadding * 0.1,
                    //   child: const Icon(
                    //     Icons.qr_code,
                    //     size: 45,
                    //     color: Colors.white,
                    //   ),
                    // ),
                    // ],
                    // ),
                    Container(
                      width: double.infinity,
                      height: _height * 0.04,
                      color: Colors.white,
                      child: Text(
                        address.name!,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 25),
                      ),
                    ),
                    SizedBox(
                      height: _height * 0.003,
                    ),
                    Center(
                      child: Container(
                        width: _width * 0.9,
                        height: _height * 0.002,
                        color: Colors.black12,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: _paddingLeft * 1,
                        right: _paddingRight * 1,
                        top: _paddingTop * 0.2,
                      ),
                      child: Text(
                        // stad != null
                        //     ? stad.shortDescription
                        //     : (qroffers != null && qroffers.isNotEmpty)
                        //         ? qroffers.first.shortDescription
                        //         : "Headline",
                        '${address.street}\n${address.postcode} ${address.city}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w800,
                            fontSize: 21),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: _paddingTop * 0.3,
                          right: _width * 0.03,
                          left: _width * 0.03),
                      child: Container(
                        color: Colors.black12,
                        width: double.infinity,
                        height: _height * 0.002,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: _height * 0.002),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                          color: color,
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: _height * 0.015, top: _height * 0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Row(
                                children: [
                                  const Text(
                                    "STADS: ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: _width * 0.01,
                                  ),
                                  Text(
                                    // stad != null
                                    //     ? stad.displayRadius.toStringAsFixed(0)
                                    //     : (qroffers != null &&
                                    //             qroffers.isNotEmpty)
                                    //         ? qroffers.first.displayRadius
                                    //             .toStringAsFixed(0)
                                    //         : "0",
                                    stads.length.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Text(
                                    "QROFFERS: ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: _width * 0.01,
                                  ),
                                  Text(
                                    // stad != null
                                    //     ? stad.pushNotificationRadius
                                    //         .toStringAsFixed(0)
                                    //     : (qroffers != null &&
                                    //             qroffers.isNotEmpty)
                                    //         ? qroffers
                                    //             .first.pushNotificationRadius
                                    //             .toStringAsFixed(0)
                                    //         : "0",
                                    qroffers.length.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              // Row(
                              //   children: <Widget>[
                              //     const Icon(
                              //       Icons.schedule,
                              //       color: Colors.white,
                              //     ),
                              //     SizedBox(
                              //       width: _width * 0.01,
                              //     ),
                              //     stad != null ||
                              //             (qroffers != null &&
                              //                 qroffers.isNotEmpty)
                              //         ? CountdownWidget(
                              //             startTime: stad != null
                              //                 ? stad.begin!.toUtc().isAfter(
                              //                         DateTime.now().toUtc())
                              //                     ? stad.begin!.toUtc()
                              //                     : DateTime.now().toUtc()
                              //                 : qroffers != null &&
                              //                         qroffers.isNotEmpty
                              //                     ? qroffers.first.begin!
                              //                             .isAfter(
                              //                                 DateTime.now()
                              //                                     .toUtc())
                              //                         ? qroffers.first.begin!
                              //                             .toUtc()
                              //                         : DateTime.now().toUtc()
                              //                     : DateTime.now().toUtc(),
                              //             endTime: stad != null
                              //                 ? stad.end!.toUtc()
                              //                 : qroffers != null &&
                              //                         qroffers.isNotEmpty
                              //                     ? qroffers.first.end!.toUtc()
                              //                     : DateTime.now()
                              //                         .toUtc()
                              //                         .subtract(
                              //                           const Duration(
                              //                               hours: 3),
                              //                         ),
                              //           )
                              //         : const Text(
                              //             "00:00:00",
                              //             style: TextStyle(
                              //               color: Colors.white,
                              //             ),
                              //           ),
                              //     // advertisement.remainingTime,
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //addresses[i]

}
