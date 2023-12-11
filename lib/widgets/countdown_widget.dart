import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CountdownWidget extends StatefulWidget {
  const CountdownWidget({
    Key? key,
    required this.startTime,
    required this.endTime,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  final Color? backgroundColor;
  final Color? textColor;

  final DateTime startTime;
  final DateTime endTime;

  @override
  _CountdownWidgetState createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Duration duration;
  late Timer timer;

  bool isCountdown = true;

  @override
  void initState() {
    super.initState();

    duration = widget.endTime.difference(widget.startTime);
    startTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => submitTime());
  }

  void submitTime() {
    const submitSeconds = -1;
    if (this.mounted) {
      setState(() {
        final seconds = duration.inSeconds + submitSeconds;

        if (seconds < 0) {
          timer.cancel();
        } else {
          duration = Duration(seconds: seconds);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: buildCountdown(),
    );
  }

  Widget buildCountdown() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = twoDigits(duration.inDays);
    final hours = twoDigits(duration.inHours.remainder(24));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (duration.inDays != 0) buildTimeCard(time: days, header: 'DAYS'),
        if (duration.inDays != 0)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.0102,
          ),
        buildTimeCard(time: hours, header: 'HOURS'),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.0102,
        ),
        buildTimeCard(time: minutes, header: 'MINUTES'),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.0102,
        ),
        buildTimeCard(time: seconds, header: 'SECONDS'),
      ],
    );
  }

  buildTimeCard({
    required String time,
    required String header,
  }) =>
      Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.backgroundColor == null
                ? Platform.isAndroid
                    ? Colors.white
                    : CupertinoColors.white
                : widget.backgroundColor!,
          ),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: widget.textColor == null
                ? Platform.isAndroid
                    ? Colors.white
                    : CupertinoColors.white
                : widget.textColor!,
          ),
        ),
      );
}
