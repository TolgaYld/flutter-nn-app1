import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../providers/qroffer.dart';
import '../providers/qroffers.dart';
import '../providers/addresses.dart';
import '../providers/address.dart';
import '../providers/wallet.dart';
import '../providers/wallets.dart';
import 'package:provider/provider.dart';

class QrWalletScreen extends StatefulWidget {
  const QrWalletScreen({Key? key}) : super(key: key);

  static const routeName = '/qr_wallet';

  @override
  State<QrWalletScreen> createState() => _QrWalletScreenState();
}

class _QrWalletScreenState extends State<QrWalletScreen> {
  bool _isInit = true;
  bool _isLoading = false;

  late List<Address> addresses;
  late List<Wallet> wallets;
  ExpandableController _addressController = ExpandableController();
  ExpandableController _qrofferController = ExpandableController();
  @override
  void initState() {
    super.initState();

    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      try {
        Provider.of<Addresses>(context, listen: false)
            .fetchAllMyAddresses()
            .then((value) {
          Provider.of<Wallets>(context, listen: false)
              .fetchAllWallets()
              .then((value) {
            addresses =
                Provider.of<Addresses>(context, listen: false).notDeleted;
            wallets = Provider.of<Wallets>(context, listen: false).wallets;
            Provider.of<Qroffers>(context, listen: false)
                .fetchAllMyQroffers()
                .then((_) {
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
    _addressController.dispose();
    _qrofferController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        streamController.add(false);
      },
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
                    systemOverlayStyle: SystemUiOverlayStyle.light,

                    // collapsedHeight: MediaQuery.of(context).size.height * 0.061,
                    toolbarHeight: MediaQuery.of(context).size.height * 0.06,

                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(0),
                      child: Container(),
                    ),

                    title: const Text(
                      'My QROFFERS',
                      style: TextStyle(
                        color: Colors.white,
                      ),
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
          body: !_isLoading
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: addresses.length,
                  itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                    value: addresses[i],
                    child: buildCard(addresses[i]),
                  ),
                )
              : Center(
                  child: Platform.isAndroid
                      ? CircularProgressIndicator()
                      : CupertinoActivityIndicator(),
                ),
        ),
      ),
    );
  }

  Widget buildCard(Address address) {
    List<Qroffer> qroffers = Provider.of<Qroffers>(context, listen: false)
        .findByAddressId(address.id!);

    qroffers = qroffers.where((qrf) => qrf.liveQrValue! > 0).toList();

    List<Qroffer> notExpired = qroffers.where((qrf) {
      return qrf.expiryDate!.isBefore(DateTime.now().toUtc());
    }).toList();

    int expiredQroffersInInt = qroffers.length - notExpired.length;

    return qroffers.isEmpty
        ? Container()
        : Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.012,
            ),
            child: ExpandablePanel(
              controller: _addressController,
              header: Column(children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.09,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(address.name!),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("Total: " + qroffers.length.toString()),
                          Text(
                              "Is Expired: " + expiredQroffersInInt.toString()),
                          Text(
                              "Is Not Expired: " + notExpired.length.toString())
                        ],
                      )
                    ],
                  ),
                  color: Colors.amber,
                ),
              ]),
              collapsed: Container(),
              expanded: Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: qroffers.length,
                  itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                    value: qroffers[i],
                    child: _walletCard(qroffers[i]),
                  ),
                ),
              ),
            ),
          );
    // Column(
    //   children: [
    //     Container(
    //       width: double.infinity,
    //       height: MediaQuery.of(context).size.height * 0.03,
    //       child: Text(address.name!),
    //       color: Colors.amber,
    //     ),
    //     ListView.builder(
    //       shrinkWrap: true,
    //       itemCount: qroffers.length,
    //       itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
    //         value: qroffers[i],
    //         child: Column(
    //           children: [
    //             Text("QROFFER: " + qroffers[i].shortDescription),
    //             Text("Value"),
    //             Text("Expiry Date"),
    //             Text("Customer Wallet"),
    //             Text("Redeemed"),
    //           ],
    //         ),
    //       ),
    //     )
    //   ],
    // );
  }

  Widget _walletCard(Qroffer qroffer) {
    DateFormat formatterDate = DateFormat('dd.MM.yyyy - HH:mm');
    return ExpandablePanel(
      header: Text(
        "Short Description: " + qroffer.shortDescription,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      controller: _qrofferController,
      collapsed: Container(),
      expanded: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              height: 3,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Text(
              "QROFFER:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Text(
              qroffer.shortDescription,
              style: TextStyle(color: Colors.black.withOpacity(0.7)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text(
              "Value:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Text(
              qroffer.qrValue.toStringAsFixed(0),
              style: TextStyle(color: Colors.black.withOpacity(0.7)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text(
              "In how much wallets?:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Text(
              qroffer.liveQrValue!.toStringAsFixed(0),
              style: TextStyle(color: Colors.black.withOpacity(0.7)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text(
              "Redeemed QROFFER:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Text(
              qroffer.redeemedQrValue!.toStringAsFixed(0),
              style: TextStyle(color: Colors.black.withOpacity(0.7)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Text(
              "Expiry Date:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Text(
              formatterDate.format(qroffer.expiryDate!),
              style: TextStyle(color: Colors.black.withOpacity(0.7)),
            ),
            //
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
          ],
        ),
      ),
    );
  }
}
