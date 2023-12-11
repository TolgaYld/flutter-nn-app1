import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../providers/categorys.dart';
import '../providers/qroffer.dart';
import '../providers/qroffers.dart';
import '../providers/address.dart';
import '../providers/addresses.dart';
import '../providers/stad.dart';
import '../providers/stads.dart';
import '../widgets/custom_app_bar.dart';
import '../screens/readvertise_stad_screen.dart';
import '../screens/readvertise_qroffer_screen.dart';
import 'package:provider/provider.dart';

class PastAdvertisementsScreen extends StatefulWidget {
  const PastAdvertisementsScreen({Key? key}) : super(key: key);

  static const routeName = '/past';

  @override
  State<PastAdvertisementsScreen> createState() =>
      _PastAdvertisementsScreenState();
}

enum SortMode { advertiseDate, createdAt, shortDescription, longDescription }

class _PastAdvertisementsScreenState extends State<PastAdvertisementsScreen> {
  SortMode _sortMode = SortMode.createdAt;
  late List<Stad> stads;
  late List<Qroffer> qroffers;
  late List<Address> addresses;
  bool _isInit = true;
  bool _isLoading = false;
  bool _isAscendingAdvertiseDate = false;
  bool _isAscendingCreatedAt = false;
  bool _isAscendingShortDescription = false;
  bool _isAscendingLongDescription = false;
  bool _isAscendingAddress = false;

  int compareDate(bool ascending, DateTime value1, DateTime value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);

  int compareString(bool ascending, String value1, String value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);

  List<String> contextMenu = [
    "Advertise Date",
    "Created At",
    "Short Description",
    "Long Description",
    "Address",
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      try {
        Provider.of<Stads>(context, listen: false)
            .fetchAllMyStads()
            .then((value) {
          Provider.of<Qroffers>(context, listen: false)
              .fetchAllMyQroffers()
              .then((value) {
            stads = Provider.of<Stads>(context, listen: false).stads;
            stads = stads.where((std) => std.isDeleted == true).toList();
            qroffers = Provider.of<Qroffers>(context, listen: false).qroffers;
            qroffers = qroffers.where((qrf) => qrf.isDeleted == true).toList();
            Provider.of<Addresses>(context, listen: false)
                .fetchAllMyAddresses()
                .then((value) {
              addresses =
                  Provider.of<Addresses>(context, listen: false).addresses;
              _isInit = false;
              setState(() {
                _isLoading = false;
              });
            });
          });
        });
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  void dispose() {
    _isInit = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        streamController.add(false);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: NestedScrollView(
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
                      actions: [
                        buildContextMenu(),
                      ],
                      leading: null,
                      title: const Text('History',
                          style: TextStyle(color: Colors.white)),
                      bottom: TabBar(
                          onTap: (index) {
                            streamController.add(false);
                          },
                          labelColor: Colors.white,
                          tabs: const [
                            Tab(
                              text: "STAD",
                              // icon: Icon(
                              //   FontAwesomeIcons.listAlt,
                              //   size: 15,
                              //   color: Colors.white,
                              // ),
                            ),
                            Tab(
                              text: "QROFFER",
                              // icon: Icon(
                              //   FontAwesomeIcons.qrcode,
                              //   size: 15,
                              //   color: Colors.white,
                              // ),
                            )
                          ]),
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
            body: !_isLoading
                ? TabBarView(children: [stadPage(context), qrPage(context)])
                : Center(
                    child: Platform.isAndroid
                        ? const CircularProgressIndicator()
                        : const CupertinoActivityIndicator(),
                  ),
          ),
        ),
      ),
    );
  }

  stadPage(BuildContext context) {
    final addresses = Provider.of<Addresses>(context, listen: false).addresses;

    return GestureDetector(
      onTap: () {
        streamController.add(false);
      },
      child: SafeArea(
        top: false,
        bottom: true,
        child: Builder(
          builder: (context) => CustomScrollView(
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.012,
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  List.generate(
                    addresses.length,
                    (i) => buildAddress(
                      addresses[i],
                      true,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // qroffersInAddress() {
  //   return ListView.builder(
  //     itemCount: qroffers.length,
  //     shrinkWrap: true,
  //     itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
  //       value: qroffers[i],
  //       child: buildCardQroffer(qroffers[i]),
  //     ),
  //   );
  // }

  qrPage(BuildContext context) {
    final addresses = Provider.of<Addresses>(context, listen: false).addresses;

    return GestureDetector(
      onTap: () {
        streamController.add(false);
      },
      child: SafeArea(
        top: false,
        bottom: true,
        child: Builder(
          builder: (context) => CustomScrollView(
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.012,
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  List.generate(
                    addresses.length,
                    (i) => buildAddress(addresses[i], false),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  buildContextMenu() {
    return Padding(
      padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.03),
      child: PopupMenuButton(
          child: (Icon(FontAwesomeIcons.sort)),
          onSelected: _select,
          itemBuilder: (BuildContext context) {
            return contextMenu.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          }),
    );
  }

  Widget buildAddress(Address address, bool isStad) {
    DateFormat formatterDate = DateFormat('dd.MM.yyyy - HH:mm');

    final categoryOfStore = Provider.of<Categorys>(context, listen: true)
        .findById(address.categoryId);
    final String _categoryColor = categoryOfStore.color;
    final stad = Provider.of<Stads>(context, listen: true).deleted(address.id!);
    final qroffer =
        Provider.of<Qroffers>(context, listen: true).deleted(address.id!);

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
    return ExpandablePanel(
      controller: ExpandableController(),
      header: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.051,
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              address.name!,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Text(
              "${address.street}, ${address.postcode}, ${address.city}, ${address.country}",
              style: const TextStyle(fontSize: 12, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      collapsed: Container(),
      expanded: CustomScrollView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.021,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                return isStad
                    ? buildCardStad(stad[i])
                    : buildCardQroffer(qroffer[i]);
              },
              childCount: isStad ? stad.length : qroffer.length,
            ),
          )
        ],
      ),
    );
  }

  buildCardStad(Stad stad) {
    DateFormat formatterDate = DateFormat('dd.MM.yyyy - HH:mm');

    return Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.021,
        ),
        child: Card(
          child: Theme(
            data: Theme.of(context)
                .copyWith(splashFactory: NoSplash.splashFactory),
            child: ExpandablePanel(
              controller: ExpandableController(),
              header: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Created at: " + formatterDate.format(stad.createdAt!),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Price: " + stad.price.toStringAsFixed(2),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              collapsed: Container(),
              expanded: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _history(formatterDate, stad),
              ),
            ),
          ),
        ));
  }

  Widget _history(DateFormat formatterDate, var stad) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          height: 3,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Text(
          "Begin:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Text(
          formatterDate.format(stad.begin!),
          style: TextStyle(color: Colors.black.withOpacity(0.7)),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Text(
          "End:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Text(
          formatterDate.format(stad.end!),
          style: TextStyle(color: Colors.black.withOpacity(0.7)),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Text(
          "Short Description:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Text(
          stad.shortDescription,
          style: TextStyle(color: Colors.black.withOpacity(0.7)),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Text(
          "Long Description:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Text(
          stad.longDescription,
          style: TextStyle(color: Colors.black.withOpacity(0.7)),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
              ),
              onPressed: () async {
                if (stad is Stad) {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ReadvertiseStadScreen(stadId: stad.id!)));
                } else {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ReadvertiseQrofferScreen(qrofferId: stad.id!)));
                }
              },
              icon: Icon(Icons.redo),
              label: Text("Readvertise!")),
        ),
      ],
    );
  }

  buildCardQroffer(Qroffer qroffer) {
    DateFormat formatterDate = DateFormat('dd.MM.yyyy - HH:mm');
    Address address = Provider.of<Addresses>(context, listen: false)
        .findById(qroffer.addressId);
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.021,
      ),
      child: Card(
        child: ExpandablePanel(
          controller: ExpandableController(),
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Created at: " + formatterDate.format(qroffer.createdAt!),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Price: " + qroffer.price.toStringAsFixed(2),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          collapsed: Container(),
          expanded: _history(formatterDate, qroffer),
        ),
      ),
    );
  }

  void _select(String value) {
    if (value == "Advertise Date") {
      setState(() {
        stads.sort((stad1, stad2) =>
            compareDate(_isAscendingAdvertiseDate, stad1.begin!, stad2.begin!));
        qroffers.sort((qrf1, qrf2) =>
            compareDate(_isAscendingAdvertiseDate, qrf1.begin!, qrf2.begin!));
        _isAscendingAdvertiseDate != _isAscendingAddress;
      });
    }
    if (value == "Created At") {
      setState(() {
        stads.sort((stad1, stad2) => compareDate(
            _isAscendingAdvertiseDate, stad1.createdAt!, stad2.createdAt!));
        qroffers.sort((qrf1, qrf2) => compareDate(
            _isAscendingAdvertiseDate, qrf1.createdAt!, qrf2.createdAt!));
        _isAscendingCreatedAt != _isAscendingAddress;
      });
    }
    if (value == "Short Description") {
      setState(() {
        stads.sort((stad1, stad2) => compareString(_isAscendingAdvertiseDate,
            stad1.shortDescription, stad2.shortDescription));
        qroffers.sort((qrf1, qrf2) => compareString(_isAscendingAdvertiseDate,
            qrf1.shortDescription, qrf2.shortDescription));
        _isAscendingShortDescription != _isAscendingShortDescription;
      });
    }
    if (value == "Long Description") {
      setState(() {
        stads.sort((stad1, stad2) => compareString(_isAscendingAdvertiseDate,
            stad1.longDescription, stad2.longDescription));
        qroffers.sort((qrf1, qrf2) => compareString(_isAscendingAdvertiseDate,
            qrf1.longDescription, qrf2.longDescription));
        _isAscendingLongDescription != _isAscendingLongDescription;
      });
    }
  }
}
