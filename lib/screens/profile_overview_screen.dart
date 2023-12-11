import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../main.dart';
import '../providers/advertiser.dart';
import '../screens/auth_screen.dart';
import '../screens/edit_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ProfileOverviewScreen extends StatelessWidget {
  static const routeName = "/ProfileOverview";
  const ProfileOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        streamController.add(false);
      },
      child: Scaffold(
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: null,
            title: const Text('Configure Profile',
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
          body: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit),
                title: const Text("Edit Profile"),
                subtitle: const Text("Edit your account"),
                onTap: () async {
                  streamController.add(false);
                  await Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (contex) => const EditProfileScreen()));
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.trash),
                title: Text("Delete Profile"),
                subtitle: Text("Delete your Profile"),
                onTap: () async {
                  streamController.add(false);
                  await Alert(
                    context: context,
                    type: AlertType.warning,
                    title: "Delete Profile",
                    desc:
                        "It's pity that you want to leave us. Are you sure? Your account will be temporarily deactivated for a while. You can log in again until it is finally deleted.",
                    buttons: [
                      DialogButton(
                        color: Colors.red,
                        child: Text(
                          "Delete Profile",
                        ),
                        onPressed: () async {
                          streamController.add(false);
                          try {
                            await Provider.of<Advertiser>(context,
                                    listen: false)
                                .delete();
                            await Provider.of<Advertiser>(context,
                                    listen: false)
                                .logout();
                            await Fluttertoast.showToast(
                                msg: "Profile deleted!",
                                backgroundColor: Theme.of(context).accentColor,
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_LONG);
                            await Navigator.of(context).pushNamedAndRemoveUntil(
                                AuthScreen.routeName,
                                (Route<dynamic> route) => false);
                          } catch (e) {
                            print(e);
                          }
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
            ],
          )),
    );
  }
}
