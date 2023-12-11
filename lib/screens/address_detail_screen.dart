import 'dart:async';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mime/mime.dart';
import '../main.dart';
import '../providers/categorys.dart';
import '../screens/address_general_screen.dart';
import '../screens/edit_qroffer_screen.dart';
import '../screens/edit_stad_screen.dart';
import '../widgets/countdown_widget.dart';
import '../widgets/network_player.dart';
import '../providers/qroffer.dart';
import '../providers/qroffers.dart';
import '../providers/stad.dart';
import '../providers/stads.dart';
import '../providers/addresses.dart';
import 'package:provider/provider.dart';
import '../providers/address.dart';

class AddressDetailScreen extends StatefulWidget {
  static const routeName = "/addressDetail";
  const AddressDetailScreen({Key? key}) : super(key: key);

  @override
  _AddressDetailScreenState createState() => _AddressDetailScreenState();
}

class _AddressDetailScreenState extends State<AddressDetailScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final String addressId =
        ModalRoute.of(context)!.settings.arguments as String;
    final Address address =
        Provider.of<Addresses>(context, listen: true).findById(addressId);
    final List<Stad> stads =
        Provider.of<Stads>(context, listen: true).addressId(addressId);
    final List<Qroffer> qroffers =
        Provider.of<Qroffers>(context, listen: true).addressId(addressId);

    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        streamController.add(false);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address.name!,
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "${address.street}, ",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.45),
                                        fontSize: 8.1,
                                      ),
                                    ),
                                    Text(
                                      "${address.postcode!}, ",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.45),
                                        fontSize: 8.1,
                                      ),
                                    ),
                                    Text(
                                      "${address.city}, ",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.45),
                                        fontSize: 8.1,
                                      ),
                                    ),
                                    Text(
                                      address.country,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.45),
                                        fontSize: 8.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        IconButton(
                          onPressed: () async {
                            streamController.add(false);

                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddressGeneralScreen(
                                  id: addressId,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            FontAwesomeIcons.store,
                            size: 21,
                          ),
                        )
                      ],
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
                      bottom: TabBar(
                          onTap: (index) {
                            streamController.add(false);
                          },
                          labelColor: Colors.white,
                          tabs: [
                            Tab(
                              text: "STAD",
                              icon: Icon(
                                FontAwesomeIcons.listAlt,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                            Tab(
                              text: "QROFFER",
                              icon: Icon(
                                FontAwesomeIcons.qrcode,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ]),
                    ),
                  ),
                )
              ];
            },
            body: GestureDetector(
              child: TabBarView(children: [
                bodyWidgetSTAD(address),
                bodyWidgetQROFFER(address),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  bodyWidgetQROFFER(Address address) {
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;
    final liveQroffers = Provider.of<Qroffers>(context, listen: true)
        .activeQroffers(address.id!);
    final futureQroffers =
        Provider.of<Qroffers>(context, listen: true).future(address.id!);

    final categoryOfStore = Provider.of<Categorys>(context, listen: true)
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

    return SafeArea(
      top: false,
      bottom: true,
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
                  left: _width * 0.021,
                  right: _width * 0.021,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Live: "),
                        SizedBox(
                          width: _height * 0.012,
                        ),
                        Center(
                          child: liveQroffers!.isEmpty
                              ? Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: liveQroffers.isNotEmpty
                                        ? _height * 0.333
                                        : _height * 0.12,
                                    child: Center(
                                        child:
                                            Text("U don't have Live QROFFERS")),
                                  ),
                                )
                              : expandedListQroffer(
                                  liveQroffers, address, color),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Future: "),
                        SizedBox(
                          width: _height * 0.012,
                        ),
                        Center(
                          child: futureQroffers.isEmpty
                              ? Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: futureQroffers.isNotEmpty
                                        ? _height * 0.333
                                        : _height * 0.12,
                                    child: Center(
                                        child: Text(
                                            "U don't have QROFFERS in Future")),
                                  ),
                                )
                              : expandedListQroffer(
                                  futureQroffers, address, color),
                        ),
                        SizedBox(
                          height: _height * 0.018,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bodyWidgetSTAD(Address address) {
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;
    final liveStad =
        Provider.of<Stads>(context, listen: true).activeStad(address.id!);
    final futureStads =
        Provider.of<Stads>(context, listen: true).future(address.id!);
    final liveQroffers = Provider.of<Qroffers>(context, listen: true)
        .activeQroffers(address.id!);
    final categoryOfStore = Provider.of<Categorys>(context, listen: true)
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

    Widget _mediaCheck() {
      if (liveStad != null) {
        String? mime = lookupMimeType(liveStad.media.first);
        var fileType = mime!.split('/');
        if (fileType.contains("video")) {
          return NetworkPlayerWidget(
            url: liveStad.media.first,
          );
        }
      }
      return Image.network(
        liveStad!.media.first,
        width: double.infinity,
        height: MediaQuery.of(context).size.width / 4 * 3,
        fit: BoxFit.cover,
      );
    }

    return SafeArea(
      top: false,
      bottom: true,
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
                  left: _width * 0.021,
                  right: _width * 0.021,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Live: "),
                        SizedBox(
                          width: _height * 0.012,
                        ),
                        Center(
                          child: liveStad == null
                              ? Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: liveStad != null
                                        ? _height * 0.333
                                        : _height * 0.12,
                                    child: Center(
                                        child:
                                            Text("U don't have a Live STAD")),
                                  ),
                                )
                              : stadItem(
                                  address, liveStad, liveQroffers!, color),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Future: "),
                        SizedBox(
                          width: _height * 0.012,
                        ),
                        Center(
                          child: futureStads.isEmpty
                              ? Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: futureStads.isNotEmpty
                                        ? _height * 0.333
                                        : _height * 0.12,
                                    child: Center(
                                        child: Text(
                                            "U don't have a STAD in Future")),
                                  ),
                                )
                              : expandedListStad(futureStads, address, color),
                        ),
                        SizedBox(
                          height: _height * 0.018,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  expandedListStad(List<Stad> futureStads, Address address, Color color) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            SizedBox(
              height: _height * 0.012,
            ),
            Column(
              children: List.generate(
                futureStads.length,
                (index) => ExpandablePanel(
                  header: Row(
                    children: [
                      Flexible(
                        child: Container(
                          child: Text(
                            "Short Description: " +
                                futureStads[index].shortDescription,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      )
                    ],
                  ),
                  collapsed: Container(),
                  expanded: stadItem(address, futureStads[index], [], color),
                ),
              ),
            ),
          ],
        ));
  }

  expandedListQroffer(List<Qroffer> qroffers, Address address, Color color) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    final liveStad =
        Provider.of<Stads>(context, listen: true).activeStad(address.id!);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          SizedBox(
            height: _height * 0.012,
          ),
          Column(
            children: List.generate(
              qroffers.length,
              (index) => ExpandablePanel(
                header: Row(
                  children: [
                    Flexible(
                      child: Container(
                        child: Text(
                          "Short Description: " +
                              qroffers[index].shortDescription,
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    )
                  ],
                ),
                collapsed: Container(),
                expanded:
                    qrofferItem(address, qroffers[index], liveStad, color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  stadItem(
    Address address,
    Stad stad,
    List<Qroffer> qroffer,
    Color color,
  ) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    EdgeInsets _padding = MediaQuery.of(context).padding;
    EdgeInsets _instets = MediaQuery.of(context).viewInsets;
    double _paddingLeft = _padding.left;
    double _paddingRight = _padding.right;
    double _paddingTop = _padding.top;
    double _paddingBottom = _padding.bottom;

    Widget _mediaCheck() {
      if (stad != null) {
        String? mime = lookupMimeType(stad.media.first);
        var fileType = mime!.split('/');
        if (fileType.contains("video")) {
          return NetworkPlayerWidget(
            url: stad.media.first,
          );
        }
      }
      return Image.network(
        stad.media.first,
        width: double.infinity,
        height: MediaQuery.of(context).size.width / 4 * 3,
        fit: BoxFit.cover,
      );
    }

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
                  // await Navigator.of(context).push(MaterialPageRoute(
                  //     settings: RouteSettings(
                  //       arguments: address.id,
                  //     ),
                  //     builder: (context) => AddressDetailScreen()));
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
                          child: _mediaCheck(),
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
                        if (qroffer.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                              left: _width * 0.012,
                              top: _height * 0.012,
                            ),
                            child: const Icon(
                              FontAwesomeIcons.qrcode,
                              size: 45,
                              color: Colors.white,
                            ),
                          ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: MediaQuery.of(context).viewPadding * 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (stad.isEditable!)
                                  IconButton(
                                    icon: const Icon(
                                      FontAwesomeIcons.pen,
                                      color: Colors.white,
                                      size: 21,
                                    ),
                                    color: Colors.black,
                                    onPressed: () async {
                                      await Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  EditStadScreen(
                                                      stadId: stad.id!)));
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    FontAwesomeIcons.trash,
                                    color: Colors.red,
                                    size: 21,
                                  ),
                                  color: Colors.black,
                                  onPressed: () async {
                                    double price = 0.00;
                                    String desc =
                                        'U Must pay: ${price.toStringAsFixed(2)} €';
                                    Timer.periodic(const Duration(seconds: 9),
                                        (timer) {
                                      setState(() {
                                        price = 0.01;
                                        desc =
                                            'U Must pay: ${price.toStringAsFixed(2)} €';
                                      });
                                    });
                                    await AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.QUESTION,
                                      title: 'U want to delete ur STAD?',
                                      desc: desc,
                                      btnOkText: 'Delete STAD',
                                      btnCancelText: 'Cancel',
                                      btnOkOnPress: () {
                                        try {
                                          Provider.of<Stads>(context,
                                                  listen: false)
                                              .deleteStad(stad.id!, price);
                                        } catch (e) {
                                          print(e);
                                        }
                                      },
                                      btnCancelOnPress: () {},
                                    ).show();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
                        stad.shortDescription,
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
                                  const Icon(
                                    FontAwesomeIcons.solidEye,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: _width * 0.015,
                                  ),
                                  Text(
                                    stad.displayRadius.toStringAsFixed(0),

                                    // stads.length.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.bell,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: _width * 0.01,
                                  ),
                                  Text(
                                    stad.pushNotificationRadius
                                        .toStringAsFixed(0),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              if (stad.isActive!)
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.schedule,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: _width * 0.01,
                                    ),

                                    CountdownWidget(
                                      startTime: DateTime.now().toUtc(),
                                      endTime: stad.end!.toUtc(),
                                    )

                                    // advertisement.remainingTime,
                                  ],
                                ),
                              if (!stad.isActive!)
                                Row(
                                  children: <Widget>[
                                    const Text(
                                      "Starts: ",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      // Icons.schedule,
                                      // color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: _width * 0.01,
                                    ),

                                    CountdownWidget(
                                      startTime: DateTime.now().toUtc(),
                                      endTime: stad.begin!.toUtc(),
                                    )

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
          ),
        ),
      ],
    );
  }

  qrofferItem(Address address, Qroffer qroffer, Stad? stad, Color color) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    EdgeInsets _padding = MediaQuery.of(context).padding;
    EdgeInsets _instets = MediaQuery.of(context).viewInsets;
    double _paddingLeft = _padding.left;
    double _paddingRight = _padding.right;
    double _paddingTop = _padding.top;
    double _paddingBottom = _padding.bottom;

    Widget _mediaCheck() {
      if (stad != null) {
        String? mime = lookupMimeType(stad.media.first);
        var fileType = mime!.split('/');
        if (fileType.contains("video")) {
          return NetworkPlayerWidget(
            url: stad.media.first,
          );
        }
      }
      return Image.network(
        stad != null ? stad.media.first : address.media!.first,
        width: double.infinity,
        height: MediaQuery.of(context).size.width / 4 * 3,
        fit: BoxFit.cover,
      );
    }

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
                  // await Navigator.of(context).push(MaterialPageRoute(
                  //     settings: RouteSettings(
                  //       arguments: address.id,
                  //     ),
                  //     builder: (context) => AddressDetailScreen()));
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
                          child: _mediaCheck(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: _width * 0.012,
                            top: _height * 0.012,
                          ),
                          child: const Icon(
                            FontAwesomeIcons.qrcode,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: MediaQuery.of(context).viewPadding * 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (qroffer.isEditable!)
                                  IconButton(
                                    icon: const Icon(
                                      FontAwesomeIcons.pen,
                                      color: Colors.white,
                                      size: 21,
                                    ),
                                    color: Colors.black,
                                    onPressed: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditQrofferScreen(
                                            qrofferId: qroffer.id!,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    FontAwesomeIcons.trash,
                                    color: Colors.red,
                                    size: 21,
                                  ),
                                  color: Colors.black,
                                  onPressed: () async {
                                    double price = 0.00;
                                    String desc =
                                        'U Must pay: ${price.toStringAsFixed(2)} €';
                                    Timer.periodic(const Duration(seconds: 9),
                                        (timer) {
                                      setState(() {
                                        price = 0.01;
                                        desc =
                                            'U Must pay: ${price.toStringAsFixed(2)} €';
                                      });
                                    });
                                    await AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.QUESTION,
                                      title: 'U want to delete ur QROFFER?',
                                      desc: desc,
                                      btnOkText: 'Delete QROFFER',
                                      btnCancelText: 'Cancel',
                                      btnOkOnPress: () {
                                        try {
                                          Provider.of<Qroffers>(context,
                                                  listen: false)
                                              .deleteQroffer(
                                                  qroffer.id!, price);
                                        } catch (e) {
                                          print(e);
                                        }
                                      },
                                      btnCancelOnPress: () {},
                                    ).show();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
                        stad != null
                            ? stad.shortDescription
                            : qroffer.shortDescription,
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
                                  const Icon(
                                    FontAwesomeIcons.solidEye,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: _width * 0.015,
                                  ),
                                  Text(
                                    stad != null
                                        ? stad.displayRadius.toStringAsFixed(0)
                                        : qroffer.displayRadius
                                            .toStringAsFixed(0),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.bell,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: _width * 0.01,
                                  ),
                                  Text(
                                    stad != null
                                        ? stad.pushNotificationRadius
                                            .toStringAsFixed(0)
                                        : qroffer.pushNotificationRadius
                                            .toStringAsFixed(0),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                              if (stad != null)
                                if (stad.isActive!)
                                  Row(
                                    children: <Widget>[
                                      const Icon(
                                        Icons.schedule,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: _width * 0.01,
                                      ),

                                      CountdownWidget(
                                        startTime: DateTime.now().toUtc(),
                                        endTime: stad.end!.toUtc(),
                                      )

                                      // advertisement.remainingTime,
                                    ],
                                  ),
                              if (stad != null)
                                if (!stad.isActive!)
                                  Row(
                                    children: <Widget>[
                                      const Text(
                                        "Starts: ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        // Icons.schedule,
                                        // color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: _width * 0.01,
                                      ),

                                      CountdownWidget(
                                        startTime: DateTime.now().toUtc(),
                                        endTime: stad.begin!.toUtc(),
                                      )

                                      // advertisement.remainingTime,
                                    ],
                                  ),
                              if (stad == null)
                                if (qroffer.isActive!)
                                  Row(
                                    children: <Widget>[
                                      const Icon(
                                        Icons.schedule,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: _width * 0.01,
                                      ),

                                      CountdownWidget(
                                        startTime: DateTime.now().toUtc(),
                                        endTime: qroffer.end!.toUtc(),
                                      )

                                      // advertisement.remainingTime,
                                    ],
                                  ),
                              if (stad == null)
                                if (!qroffer.isActive!)
                                  Row(
                                    children: <Widget>[
                                      const Text(
                                        "Starts: ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        // Icons.schedule,
                                        // color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: _width * 0.01,
                                      ),

                                      CountdownWidget(
                                        startTime: DateTime.now().toUtc(),
                                        endTime: qroffer.begin!.toUtc(),
                                      )

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
          ),
        ),
      ],
    );
  }
}
