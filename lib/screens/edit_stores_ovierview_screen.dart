import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../providers/invoice_address.dart';
import '../providers/invoice_addresses.dart';
import '../screens/edit_store_screen.dart';
import '../providers/addresses.dart';
import 'package:provider/provider.dart';
// import '../screens/edit_stores_screen.dart';
import '../screens/add_address_screen.dart';

class EditStoresOverviewScreen extends StatelessWidget {
  const EditStoresOverviewScreen({Key? key}) : super(key: key);

  static const routeName = '/editstoreoverview';

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
            title: const Text('Edit Stores',
                style: TextStyle(color: Colors.white70)),
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
          body: ListView.builder(
            itemCount: addresses.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: addresses[i],
              child: ListTile(
                leading: Container(
                  // width: MediaQuery.of(context).size.width / 2,
                  // height: MediaQuery.of(context).size.width / 2 / 4 * 3,
                  child: AspectRatio(
                    aspectRatio: 2 / 1.5,
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(100),
                          ),
                          border: Border.all(
                              color: Theme.of(context).primaryColor, width: 1),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(addresses[i].media!.first)),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(100),
                            ),
                          ),
                        )),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(addresses[i].name!),
                    Text(
                      "${addresses[i].street}, ${addresses[i].postcode} ${addresses[i].city}",
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                subtitle: addresses[i].isActive!
                    ? Text(
                        "Store is: Activated",
                        style: TextStyle(
                          fontSize: 10.2,
                        ),
                      )
                    : Text(
                        "Store is: Not Activated",
                        style: TextStyle(
                          fontSize: 10.2,
                        ),
                      ),
                onTap: () async {
                  streamController.add(false);
                  await Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(
                          builder: (context) => EditStoreScreen(
                                addressId: addresses[i].id!,
                              )));
                },
              ),
            ),
          )
          // ListView(
          //   children: [
          //     ListTile(
          //       leading: Icon(Icons.edit),
          //       title: Text("Edit Stores"),
          //       subtitle: Text("Edit your Stores"),
          //       onTap: () async {
          //         // await Navigator.of(context, rootNavigator: false).push(
          //         //     MaterialPageRoute(
          //         //         fullscreenDialog: false,
          //         //         builder: (contex) => EditEditStoresOverviewScreen()));
          //       },
          //     ),
          //     ListTile(
          //       leading: Icon(Icons.add),
          //       title: Text("Add Store"),
          //       subtitle: Text("Add your new store"),
          //       onTap: () async {
          //         await Navigator.of(context).push(
          //             MaterialPageRoute(builder: (context) => const AddAddress()));
          //       },
          //     ),
          //   ],
          // ),
          ),
    );
  }
}
