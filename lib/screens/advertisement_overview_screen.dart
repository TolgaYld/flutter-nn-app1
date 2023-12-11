import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../main.dart';
import '../providers/opening_hours.dart';
import '../widgets/custom_app_bar.dart';
import '../providers/categorys.dart';
import '../providers/subcategorys.dart';
import '../providers/subsubcategorys.dart';
import '../widgets/addresses_list.dart';
import '../screens/barcode_screen.dart';
import '../providers/addresses.dart';
import '../providers/qroffers.dart';
import '../providers/stads.dart';
import 'package:provider/provider.dart';

class AdvertisementOverviewScreen extends StatefulWidget {
  const AdvertisementOverviewScreen({Key? key}) : super(key: key);

  @override
  State<AdvertisementOverviewScreen> createState() =>
      _AdvertisementOverviewScreenState();
}

class _AdvertisementOverviewScreenState
    extends State<AdvertisementOverviewScreen> {
  var _isInit = true;
  var _isLoading = false;

  Future<void> _refreshScreen(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    try {
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
              Provider.of<Stads>(context, listen: false)
                  .fetchAllMyStads()
                  .then((_) {
                Provider.of<Qroffers>(context, listen: false)
                    .fetchAllMyQroffers()
                    .then((_) {
                  setState(() {
                    _isLoading = false;
                  });
                });
              });
            });
          });
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
      // _secureStorage.deleteAll();
      setState(() {
        _isLoading = true;
      });
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
              Provider.of<OpeningHours>(context, listen: false)
                  .fetchAllMyOpeningHours()
                  .then((value) {
                Provider.of<Stads>(context, listen: false)
                    .fetchAllMyStads()
                    .then((_) {
                  Provider.of<Qroffers>(context, listen: false)
                      .fetchAllMyQroffers()
                      .then((_) {
                    setState(() {
                      _isLoading = false;
                      _isInit = false;
                    });
                  });
                });
              });
            });
          });
        });
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _isInit = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        streamController.add(false);
      },
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
                    systemOverlayStyle: SystemUiOverlayStyle.light,
                    // collapsedHeight: MediaQuery.of(context).size.height * 0.061,
                    toolbarHeight: MediaQuery.of(context).size.height * 0.06,
                    actions: [
                      Padding(
                        padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.026),
                        child: IconButton(
                          onPressed: () async {
                            streamController.add(false);
                            await Navigator.of(context, rootNavigator: true)
                                .pushNamed(BarcodeScanner.routeName);
                          },
                          icon: const Icon(
                            FontAwesomeIcons.qrcode,
                          ),
                        ),
                      )
                    ],
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(0),
                      child: Container(),
                    ),
                    leading: null,
                    title: const Text('My Stores',
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
          body: _isLoading
              ? Center(
                  child: Platform.isAndroid
                      ? CircularProgressIndicator()
                      : CupertinoActivityIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: () => _refreshScreen(context),
                  child: const AddressList()),
        ),
      ),
    );
  }
}
