// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class TabBarMaterialWidget extends StatefulWidget {
//   final int index;
//   final ValueChanged<int> onChangedTab;
//   const TabBarMaterialWidget(
//       {required this.index, required this.onChangedTab, Key? key})
//       : super(key: key);

//   @override
//   _TabBarMaterialWidgetState createState() => _TabBarMaterialWidgetState();
// }

// class _TabBarMaterialWidgetState extends State<TabBarMaterialWidget> {
//   @override
//   Widget build(BuildContext context) {
//     const placeholder = Opacity(
//       opacity: 0,
//       child: IconButton(
//         onPressed: null,
//         icon: Icon(
//           Icons.ac_unit,
//         ),
//       ),
//     );

//     return BottomAppBar(
//       shape: const CircularNotchedRectangle(),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           buildTabItem(
//             index: 0,
//             icon: const Icon(
//               FontAwesomeIcons.home,
//             ),
//           ),
//           buildTabItem(
//             index: 1,
//             icon: const Icon(
//               FontAwesomeIcons.history,
//             ),
//           ),
//           placeholder,
//           buildTabItem(
//             index: 2,
//             icon: const Icon(
//               FontAwesomeIcons.qrcode,
//             ),
//           ),
//           buildTabItem(
//             index: 3,
//             icon: const Icon(
//               FontAwesomeIcons.cog,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildTabItem({
//     required int index,
//     required Icon icon,
//   }) {
//     final isSelected = index == widget.index;
//     return IconTheme(
//       data: IconThemeData(
//         color: isSelected
//             ? Theme.of(context).primaryColor
//             : Platform.isAndroid
//                 ? Colors.grey
//                 : CupertinoColors.systemGrey,
//       ),
//       child: IconButton(
//         onPressed: () => widget.onChangedTab(index),
//         icon: icon,
//       ),
//     );
//   }
// }
