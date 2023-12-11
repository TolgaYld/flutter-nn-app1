import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './models/enviroment.dart';
import './providers/subsubcategorys_qroffer.dart';
import './providers/subsubcategorys_stad.dart';
import './screens/address_general_screen.dart';
import './screens/address_detail_screen.dart';
import './screens/delete_stores_overview_screen.dart';
import './screens/profile_overview_screen.dart';
import './screens/validating_screen.dart';
import './screens/authentication_onboarding_screen.dart';
import './providers/wallets.dart';
import './screens/edit_stores_ovierview_screen.dart';
import './screens/edit_profile_screen.dart';
import './screens/add_address_screen.dart';
import './screens/add_qroffer_screen.dart';
import './screens/add_stad_screen.dart';
import './screens/barcode_screen.dart';
import './screens/past_advertisements_screen.dart';
import './screens/profile_screen.dart';
import './screens/qr_wallet_screen.dart';
import './screens/settings_screen.dart';
import './screens/stores_screen.dart';
import './screens/terms_and_conditions.dart';
import './home.dart';
import './providers/addresses.dart';
import './providers/categorys.dart';
import './providers/invoice_addresses.dart';
import './providers/opening_hours.dart';
import './providers/qroffers.dart';
import './providers/stads.dart';
import './providers/subcategorys.dart';
import './providers/subsubcategorys.dart';
import './screens/auth_screen.dart';
import './screens/splash.dart';
import '../providers/advertiser.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

Map<int, Color> nowNowGreen = {
  50: Color.fromRGBO(112, 184, 73, .1),
  100: Color.fromRGBO(112, 184, 73, .2),
  200: Color.fromRGBO(112, 184, 73, .3),
  300: Color.fromRGBO(112, 184, 73, .4),
  400: Color.fromRGBO(112, 184, 73, .5),
  500: Color.fromRGBO(112, 184, 73, .6),
  600: Color.fromRGBO(112, 184, 73, .7),
  700: Color.fromRGBO(112, 184, 73, .8),
  800: Color.fromRGBO(112, 184, 73, .9),
  900: Color.fromRGBO(112, 184, 73, 1.0),
};

Map<int, Color> nowNowYellow = {
  50: Color.fromRGBO(245, 231, 62, .1),
  100: Color.fromRGBO(245, 231, 62, .2),
  200: Color.fromRGBO(245, 231, 62, .3),
  300: Color.fromRGBO(245, 231, 62, .4),
  400: Color.fromRGBO(245, 231, 62, .5),
  500: Color.fromRGBO(245, 231, 62, .6),
  600: Color.fromRGBO(245, 231, 62, .7),
  700: Color.fromRGBO(245, 231, 62, .8),
  800: Color.fromRGBO(245, 231, 62, .9),
  900: Color.fromRGBO(245, 231, 62, 1.0),
};

Map<int, Color> nowNowOrange = {
  50: Color.fromRGBO(253, 166, 41, .1),
  100: Color.fromRGBO(253, 166, 41, .2),
  200: Color.fromRGBO(253, 166, 41, .3),
  300: Color.fromRGBO(253, 166, 41, .4),
  400: Color.fromRGBO(253, 166, 41, .5),
  500: Color.fromRGBO(253, 166, 41, .6),
  600: Color.fromRGBO(253, 166, 41, .7),
  700: Color.fromRGBO(253, 166, 41, .8),
  800: Color.fromRGBO(253, 166, 41, .9),
  900: Color.fromRGBO(253, 166, 41, 1.0),
};

MaterialColor nowNowGreenColor = MaterialColor(0xFF70B849, nowNowGreen);
MaterialColor nowNowOrangeColor = MaterialColor(0xFFFDA629, nowNowOrange);
MaterialColor nowNowYellowColor = MaterialColor(0xFFf5e73e, nowNowYellow);

StreamController<bool> streamController = StreamController<bool>.broadcast();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await dotenv.load(fileName: Enviroment.fileName);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    streamController.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Advertiser(),
        ),
        ChangeNotifierProxyProvider<Advertiser, Addresses>(
          create: (ctx) => Addresses(null, []),
          update: (ctx, advertiser, previousAddresses) => Addresses(
            advertiser.token,
            previousAddresses!.addresses,
          ),
        ),
        ChangeNotifierProxyProvider<Advertiser, InvoiceAddresses>(
          create: (ctx) => InvoiceAddresses(null, []),
          update: (ctx, advertiser, previousAddresses) => InvoiceAddresses(
            advertiser.token,
            previousAddresses!.addresses,
          ),
        ),
        ChangeNotifierProxyProvider<Advertiser, Stads>(
          create: (ctx) => Stads(null, []),
          update: (ctx, advertiser, previousStads) => Stads(
            advertiser.token,
            previousStads!.stads,
          ),
        ),
        ChangeNotifierProxyProvider<Advertiser, Qroffers>(
          create: (ctx) => Qroffers(null, []),
          update: (ctx, advertiser, previousQroffers) => Qroffers(
            advertiser.token,
            previousQroffers!.qroffers,
          ),
        ),
        ChangeNotifierProxyProvider<Advertiser, Wallets>(
          create: (ctx) => Wallets(null, []),
          update: (ctx, advertiser, previousWallets) => Wallets(
            advertiser.token,
            previousWallets!.wallets,
          ),
        ),
        ChangeNotifierProxyProvider<Advertiser, OpeningHours>(
          create: (ctx) => OpeningHours(null, []),
          update: (ctx, advertiser, previousOpeningHour) => OpeningHours(
            advertiser.token,
            previousOpeningHour!.openingHours,
          ),
        ),
        ChangeNotifierProxyProvider<Advertiser, SubsubCategorysStad>(
          create: (ctx) => SubsubCategorysStad(null, []),
          update: (ctx, advertiser, previousStads) => SubsubCategorysStad(
            advertiser.token,
            previousStads!.subsubcategorys,
          ),
        ),
        ChangeNotifierProxyProvider<Advertiser, SubsubCategorysQroffer>(
          create: (ctx) => SubsubCategorysQroffer(null, []),
          update: (ctx, advertiser, previousStads) => SubsubCategorysQroffer(
            advertiser.token,
            previousStads!.subsubcategorys,
          ),
        ),
        ChangeNotifierProvider.value(
          value: Categorys(),
        ),
        ChangeNotifierProvider.value(
          value: Subcategorys(),
        ),
        ChangeNotifierProvider.value(
          value: Subsubcategorys(),
        ),
      ],
      child: Consumer<Advertiser>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
            primaryColor: nowNowGreenColor,
            accentColor: nowNowOrangeColor,
            colorScheme: ColorScheme(
              primary: nowNowGreenColor,
              primaryVariant: nowNowGreenColor,
              secondary: nowNowOrangeColor,
              secondaryVariant: nowNowOrangeColor,
              surface: nowNowGreenColor,
              background: Colors.white,
              error: Colors.red,
              onPrimary: Colors.white,
              onSecondary: nowNowOrangeColor,
              onSurface: nowNowGreenColor,
              onBackground: Colors.white,
              onError: Colors.red,
              brightness: Brightness.light,
            ),
          ),
          home: //
              // AuthScreen(),
              //     AuthenticationOnboardingScreen(
              //   initialPage: 6,
              // ),
              auth.isAuth
                  ? const ValidatingScreen()
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder: (ctx, authResultSnapshot) =>
                          authResultSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? Splash()
                              : authResultSnapshot.data == true
                                  ? const ValidatingScreen()
                                  : const AuthScreen(),
                    ),
          initialRoute: '/',
          routes: {
            HomeScreen.routeName: (ctx) => HomeScreen(
                  isOpen: false,
                  stream: streamController.stream,
                ),
            AddAddressScreen.routeName: (ctx) => const AddAddressScreen(),
            AddQrofferScreen.routeName: (ctx) => const AddQrofferScreen(),
            AddStadScreen.routeName: (ctx) => const AddStadScreen(),
            AuthScreen.routeName: (ctx) => const AuthScreen(),
            BarcodeScanner.routeName: (ctx) => const BarcodeScanner(),
            PastAdvertisementsScreen.routeName: (ctx) =>
                const PastAdvertisementsScreen(),
            QrWalletScreen.routeName: (ctx) => const QrWalletScreen(),
            SettingsScreen.routeName: (ctx) => SettingsScreen(),
            Splash.routeName: (ctx) => Splash(),
            StoresScreen.routeName: (ctx) => const StoresScreen(),
            TermsAndConditions.routeName: (ctx) => TermsAndConditions(),
            ProfileScreen.routeName: (ctx) => const ProfileScreen(),
            EditProfileScreen.routeName: (ctx) => const EditProfileScreen(),
            EditStoresOverviewScreen.routeName: (ctx) =>
                const EditStoresOverviewScreen(),
            AuthenticationOnboardingScreen.routeName: (ctx) =>
                const AuthenticationOnboardingScreen(
                  initialPage: 0,
                ),
            ValidatingScreen.routeName: (ctx) => const ValidatingScreen(),
            AddressDetailScreen.routeName: (ctx) => const AddressDetailScreen(),
            DeleteStoresOverviewScreen.routeName: (ctx) =>
                const DeleteStoresOverviewScreen(),
            ProfileOverviewScreen.routeName: (ctx) =>
                const ProfileOverviewScreen(),
            AddressGeneralScreen.routeName: (ctx) => AddressGeneralScreen(),
          },
        ),
      ),
    );
  }
}
