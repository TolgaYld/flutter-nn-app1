import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../main.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../providers/addresses.dart';
import 'package:provider/provider.dart';

class DeleteStoresOverviewScreen extends StatelessWidget {
  static const routeName = "/deleteStoresOverview";
  const DeleteStoresOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final addresses = Provider.of<Addresses>(context, listen: true).notDeleted;
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
                title: Text(addresses[i].name!),
                subtitle: addresses[i].isActive!
                    ? Text("Store is: Activated")
                    : Text("Store is: Not Activated"),
                onTap: () async {
                  streamController.add(false);
                  await Alert(
                    context: context,
                    type: AlertType.warning,
                    title: "Delete Store",
                    desc: "You want to delete " + addresses[i].name! + "?",
                    buttons: [
                      DialogButton(
                        color: Colors.red,
                        child: Text(
                          "Delete",
                        ),
                        onPressed: () async {
                          streamController.add(false);
                          try {
                            await Provider.of<Addresses>(context, listen: false)
                                .deleteAddressFromDb(addresses[i].id!);
                          } catch (e) {
                            print(e);
                          }

                          Navigator.of(context, rootNavigator: true).pop();
                          await Fluttertoast.showToast(
                              msg: "Store deleted!",
                              backgroundColor: Theme.of(context).accentColor,
                              gravity: ToastGravity.BOTTOM,
                              toastLength: Toast.LENGTH_LONG);
                        },
                        width: MediaQuery.of(context).size.width * 0.15,
                      ),
                      DialogButton(
                        color: Theme.of(context).accentColor,
                        child: Text(
                          "Close",
                        ),
                        onPressed: () {
                          streamController.add(false);
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        width: MediaQuery.of(context).size.width * 0.15,
                      )
                    ],
                  ).show();
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
