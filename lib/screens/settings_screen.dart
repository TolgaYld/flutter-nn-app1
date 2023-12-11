import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../main.dart';
import '../providers/category.dart';
import '../providers/categorys.dart';
import '../providers/invoice_addresses.dart';
import '../providers/opening_hours.dart';
import '../providers/subcategorys.dart';
import '../providers/subsubcategorys.dart';
import '../screens/profile_overview_screen.dart';
import '../providers/addresses.dart';
import '../screens/edit_profile_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../screens/stores_screen.dart';
import '../providers/advertiser.dart';
import '../screens/auth_screen.dart';
import 'package:provider/provider.dart';
import '../screens/splash.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();

    Provider.of<Advertiser>(context, listen: false).getMe().then((value) {
      // Provider.of<Addresses>(context, listen: false)
      //     .fetchAllMyAddresses()
      //     .then((value) {
      Provider.of<Categorys>(context, listen: false)
          .fetchAllCategorys()
          .then((value) {
        Provider.of<Subcategorys>(context, listen: false)
            .fetchAllSubcategorys()
            .then((value) {
          Provider.of<Subsubcategorys>(context, listen: false)
              .fetchAllSubsubcategorys()
              .then((value) {
            Provider.of<OpeningHours>(context, listen: false)
                .fetchAllMyOpeningHours()
                .then((value) {
              Provider.of<InvoiceAddresses>(context, listen: false)
                  .fetchAllMyAddresses();
            });
          });
        });
      });
    });
    // });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 0.13;
    double width = MediaQuery.of(context).size.width * 0.95;

    return GestureDetector(
      onTap: () {
        streamController.add(false);
      },
      child: Scaffold(
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: null,
            title:
                const Text('Settings', style: TextStyle(color: Colors.white)),
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
          body: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.account_box),
                title: const Text("Profile"),
                subtitle: const Text("Configure your account"),
                onTap: () async {
                  streamController.add(false);
                  await Navigator.of(context, rootNavigator: false).push(
                      MaterialPageRoute(
                          builder: (contex) => const ProfileOverviewScreen()));
                },
              ),
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.store,
                ),
                title: Text("My Stores"),
                subtitle: Text("Configure your stores"),
                onTap: () async {
                  streamController.add(false);
                  await Navigator.of(context, rootNavigator: false).push(
                      MaterialPageRoute(
                          builder: (context) => const StoresScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.assignment),
                title: Text("Invoices"),
                subtitle: Text("See your invoices"),
                onTap: () {
                  streamController.add(false);
                },
              ),
              ListTile(
                leading: Icon(Icons.contact_mail),
                title: Text("Contact"),
                subtitle: Text("Contact the Now Now - Team"),
                onTap: () {
                  streamController.add(false);
                },
              ),
              ListTile(
                leading: const Icon(
                  FontAwesomeIcons.signOutAlt,
                  color: Colors.red,
                ),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onTap: () async {
                  streamController.add(false);
                  await Provider.of<Advertiser>(context, listen: false)
                      .logout();
                  await Navigator.of(context, rootNavigator: true)
                      .pushReplacement(MaterialPageRoute(
                          builder: (context) => const AuthScreen()));
                },
              ),

              // Column(
              //   children: <Widget>[
              //     SizedBox(
              //       height: 15.0,
              //     ),
              //     Container(
              //       width: width,
              //       height: height,
              //       decoration: BoxDecoration(
              //         border: Border.all(
              //           color: Colors.grey,
              //           width: 1,
              //         ),
              //         borderRadius: BorderRadius.all(Radius.circular(15.0)),
              //       ),
              //       child: TextButton(
              //         onPressed: () async {
              //           // await Navigator.of(context, rootNavigator: false).push(
              //           //     MaterialPageRoute(
              //           //         fullscreenDialog: false,
              //           //         builder: (contex) => AddAddressScreen()));
              //         },
              //         child: Row(
              //           children: <Widget>[
              //             Icon(
              //               Icons.account_box,
              //               size: 53,
              //             ),
              //             Text(
              //               'Profile',
              //               style: TextStyle(fontSize: 26),
              //             )
              //           ],
              //         ),
              //       ),
              //     ),
              //     SizedBox(
              //       height: 15.0,
              //     ),
              //     Container(
              //       width: width,
              //       height: height,
              //       decoration: BoxDecoration(
              //         border: Border.all(
              //           color: Colors.grey,
              //           width: 1,
              //         ),
              //         borderRadius: BorderRadius.all(Radius.circular(15.0)),
              //       ),
              //     ),
              //     SizedBox(
              //       height: 15.0,
              //     ),
              //     Container(
              //       width: width,
              //       height: height,
              //       decoration: BoxDecoration(
              //         border: Border.all(
              //           color: Colors.grey,
              //           width: 1,
              //         ),
              //         borderRadius: BorderRadius.all(Radius.circular(15.0)),
              //       ),
              //     ),
              //     SizedBox(
              //       height: 15.0,
              //     ),
              //     Container(
              //       width: width,
              //       height: height,
              //       decoration: BoxDecoration(
              //         border: Border.all(
              //           color: Colors.grey,
              //           width: 1,
              //         ),
              //         borderRadius: BorderRadius.all(Radius.circular(15.0)),
              //       ),
              //     ),
              //     SizedBox(
              //       height: 15.0,
              //     ),
              //     Container(
              //       width: width,
              //       height: height,
              //       decoration: BoxDecoration(
              //         border: Border.all(
              //           color: Colors.grey,
              //           width: 1,
              //         ),
              //         borderRadius: BorderRadius.all(Radius.circular(15.0)),
              //       ),
              //       child: TextButton(
              //         onPressed: () async {
              //           final SecureStorage secureStorage = SecureStorage();
              //           await secureStorage.deleteSecureData("token");
              //           await secureStorage.deleteSecureData("refreshToken");

              //           String token =
              //               await secureStorage.readSecureData("token");
              //           String refreshToken =
              //               await secureStorage.readSecureData("refreshToken");

              //           if (token == null && refreshToken == null) {
              //             await Navigator.of(context, rootNavigator: true)
              //                 .pushReplacement(MaterialPageRoute(
              //                     fullscreenDialog: true,
              //                     builder: (contex) => Splash()));
              //           }
              //         },
              //         child: Row(
              //           children: <Widget>[
              //             Icon(Icons.power_settings_new_outlined),
              //             Text('Logout')
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          )),
    );
  }
}
