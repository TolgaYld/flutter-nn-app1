import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../main.dart';
import '../providers/addresses.dart';
import '../screens/delete_stores_overview_screen.dart';
import 'package:provider/provider.dart';
import '../screens/edit_stores_ovierview_screen.dart';
// import '../screens/edit_stores_screen.dart';
import '../screens/add_address_screen.dart';

class StoresScreen extends StatelessWidget {
  const StoresScreen({Key? key}) : super(key: key);

  static const routeName = '/stores';

  @override
  Widget build(BuildContext context) {
    final addresses = Provider.of<Addresses>(context).notDeleted;
    return GestureDetector(
      onTap: () {
        streamController.add(false);
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: const BackButton(color: Colors.white),
          title:
              const Text('My Stores', style: TextStyle(color: Colors.white70)),
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
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text("Edit Stores"),
              subtitle: Text("Edit your Stores"),
              onTap: () async {
                streamController.add(false);
                await Navigator.of(context, rootNavigator: false).push(
                    MaterialPageRoute(
                        fullscreenDialog: false,
                        builder: (contex) => const EditStoresOverviewScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text("Add Store"),
              subtitle: Text("Add your new store"),
              onTap: () async {
                streamController.add(false);
                await Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                        builder: (context) => const AddAddressScreen()));
              },
            ),
            ListTile(
              enabled: addresses.length == 1 ? false : true,
              leading: Icon(FontAwesomeIcons.trash),
              title: Text("Delete Store"),
              subtitle: Text("Delete your store"),
              onTap: () async {
                streamController.add(false);
                await Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            const DeleteStoresOverviewScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
