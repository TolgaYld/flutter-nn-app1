import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/items/tab_items.dart';

class BottomTab extends StatelessWidget {
  const BottomTab({
    Key? key,
    required this.currentTab,
    required this.onSelectTab,
    required this.pageCreator,
    required this.navigatorKeys,
  }) : super(key: key);

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;
  final Map<TabItem, Widget> pageCreator;
  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: Theme.of(context).primaryColor,
        items: [
          _createBottomNavItam(TabItem.Home),
          _createBottomNavItam(TabItem.Past),
          const BottomNavigationBarItem(
              icon: Icon(
                Icons.ac_unit,
              ),
              backgroundColor: Colors.transparent),
          _createBottomNavItam(TabItem.Wallet),
          _createBottomNavItam(TabItem.Settings)
        ],
        onTap: (index) => onSelectTab(TabItem.values[index]),
      ),
      tabBuilder: (context, index) {
        final showItem = TabItem.values[index];
        return CupertinoTabView(
            navigatorKey: navigatorKeys[showItem],
            builder: (context) {
              return pageCreator[showItem]!;
            });
      },
    );
  }

  BottomNavigationBarItem _createBottomNavItam(TabItem tabItem) {
    final createTab = TabItemData.allTabs[tabItem]!;
    return BottomNavigationBarItem(
      icon: Icon(
        createTab.icon.icon,
        size: 27,
      ),
      label: createTab.label,
    );
  }
}
