import 'dart:io';

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar(
      {Key? key,
      List<Widget>? this.actions,
      required String this.appBarText,
      required bool this.backButtonIsActive})
      : super(key: key);

  final List<Widget>? actions;
  final String appBarText;
  final bool backButtonIsActive;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading:
          backButtonIsActive ? const BackButton(color: Colors.white) : null,
      toolbarHeight: MediaQuery.of(context).size.height * 0.1011,
      flexibleSpace: Container(
        height: MediaQuery.of(context).size.height * 0.1011,
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
      actions: actions,
      title: Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.06),
        child: Text(
          appBarText,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
