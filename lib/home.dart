import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './widgets/bottom_tab.dart';
import './widgets/items/tab_items.dart';
import './screens/add_qroffer_screen.dart';
import './screens/add_stad_screen.dart';
import './screens/advertisement_overview_screen.dart';
import './screens/past_advertisements_screen.dart';
import './screens/qr_wallet_screen.dart';
import './screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  bool isOpen;
  final Stream<bool> stream;
  static const routeName = "/home";

  HomeScreen({Key? key, required this.isOpen, required this.stream})
      : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TabItem _currentTab = TabItem.Home;

  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.Home: GlobalKey<NavigatorState>(),
    TabItem.Past: GlobalKey<NavigatorState>(),
    TabItem.Wallet: GlobalKey<NavigatorState>(),
    TabItem.Settings: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, Widget> allScreens() {
    return {
      TabItem.Home: AdvertisementOverviewScreen(),
      TabItem.Past: PastAdvertisementsScreen(),
      TabItem.Empty1: AdvertisementOverviewScreen(),
      TabItem.Wallet: QrWalletScreen(),
      TabItem.Settings: SettingsScreen()
    };
  }

  bool _isOpened = false;
  Icon _fabIcon = Icon(
    Icons.add,
    color: Colors.white,
  );

  Icon _qrIcon = Icon(
    FontAwesomeIcons.qrcode,
    size: 51,
    color: Colors.white,
  );

  Icon _stadIcon = Icon(
    FontAwesomeIcons.listAlt,
    size: 51,
    color: Colors.white,
  );

  String _qrDescription =
      "Advertise an exclusive QR code that you can use to attract customers, with a term from 3 days to 6 months.";
  String _qrName = "QROFFER";
  String _stadName = "STAD";
  String _stadDescription =
      "Advertise a STAD - Short Time Advertisement to make your customers aware of your exclusive offers. Set the push notification radius, set your visibility radius and the duration of your advertisement.";

  @override
  void initState() {
    super.initState();
    widget.stream.listen((event) {
      mySetState(event);
    });
  }

  void mySetState(bool isOpen) {
    setState(() {
      _isOpened = isOpen;
      if (isOpen) {
        _fabIcon = Icon(
          Icons.close,
          color: Colors.white,
        );
      } else {
        _fabIcon = Icon(
          Icons.add,
          color: Colors.white,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[_currentTab]!.currentState!.maybePop(),
      child: GestureDetector(
        onTap: () {
          if (_isOpened == true) {
            setState(() {
              _isOpened = false;
              _fabIcon = Icon(
                Icons.add,
                color: Colors.white,
              );
            });
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_isOpened == true)
                InkWell(
                  onTap: () {
                    setState(() {
                      _isOpened = false;
                      _fabIcon = Icon(
                        Icons.add,
                        color: Colors.white,
                      );
                    });

                    Navigator.of(context, rootNavigator: false).push(
                        MaterialPageRoute(
                            fullscreenDialog: false,
                            builder: (context) => const AddStadScreen()));
                  },
                  child: _fabInkwellLayout(
                      _stadIcon,
                      _stadName,
                      _stadDescription,
                      Colors.grey,
                      Theme.of(context).accentColor),
                ),
              if (_isOpened == true)
                SizedBox(
                  height: _height * 0.03,
                ),
              if (_isOpened == true)
                InkWell(
                  onTap: () {
                    setState(() {
                      _isOpened = false;
                      _fabIcon = Icon(
                        Icons.add,
                        color: Colors.white,
                      );
                    });

                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                            builder: (context) => const AddQrofferScreen()));
                  },
                  child: _fabInkwellLayout(_qrIcon, _qrName, _qrDescription,
                      Colors.grey, Color.fromRGBO(245, 231, 62, 1.0)),
                ),
              if (_isOpened == true)
                SizedBox(
                  height: _height * 0.03,
                ),
              _floatingActionButton(),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          body: BottomTab(
            navigatorKeys: navigatorKeys,
            pageCreator: allScreens(),
            currentTab: _currentTab,
            onSelectTab: (onSelectTab) {
              if (onSelectTab == _currentTab) {
                navigatorKeys[onSelectTab]!
                    .currentState!
                    .popUntil((route) => route.isFirst);
              } else {
                if (onSelectTab == TabItem.Empty1) {
                  setState(() {
                    _onPressedFAB();
                    _currentTab = TabItem.Past;
                  });
                }
                setState(() {
                  _currentTab = onSelectTab;
                  _isOpened = false;
                  _fabIcon = Icon(
                    Icons.add,
                    color: Colors.white,
                  );
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _floatingActionButton() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _onPressedFAB();
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.width * 0.2,
        child: Center(
          child: Stack(
            children: [
              Center(
                child: FloatingActionButton(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: _fabIcon,
                  onPressed: _onPressedFAB,
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: MediaQuery.of(context).size.width * 0.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fabInkwellLayout(
    Icon icon,
    String stadOrQrName,
    String description,
    Color inkwellColor,
    Color borderColor,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.18,
      decoration: BoxDecoration(
        color: inkwellColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          icon,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stadOrQrName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  description,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _onPressedFAB() {
    if (_isOpened == false) {
      setState(() {
        _isOpened = true;
        _fabIcon = Icon(
          Icons.close,
          color: Colors.white,
        );
      });
    } else {
      setState(() {
        _isOpened = false;
        _fabIcon = Icon(
          Icons.add,
          color: Colors.white,
        );
      });
    }
  }
}
