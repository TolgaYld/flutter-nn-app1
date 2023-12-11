import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum TabItem { Home, Past, Empty1, Wallet, Settings }

class TabItemData {
  final String label;
  final Icon icon;

  TabItemData(this.label, this.icon);

  static Map<TabItem, TabItemData> allTabs = {
    TabItem.Home: TabItemData(
      "Home",
      const Icon(
        FontAwesomeIcons.home,
      ),
    ),
    TabItem.Past: TabItemData(
      "History",
      const Icon(
        FontAwesomeIcons.history,
      ),
    ),
    TabItem.Empty1: TabItemData(
      "",
      const Icon(
        Icons.restore,
        color: Colors.transparent,
      ),
    ),
    TabItem.Wallet: TabItemData(
      "QROFFERS",
      const Icon(
        FontAwesomeIcons.qrcode,
      ),
    ),
    TabItem.Settings: TabItemData(
      "Settings",
      const Icon(
        FontAwesomeIcons.cog,
      ),
    )
  };
}
