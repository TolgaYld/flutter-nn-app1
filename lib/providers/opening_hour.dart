import 'package:flutter/material.dart';

class OpeningHour with ChangeNotifier {
  final String? id;
  final int day;
  final int dayFrom;
  final TimeOfDay timeFrom;
  final int duration;
  final int dayTo;
  final bool? isDeleted;
  final String? advertiserId;
  final String addressId;

  OpeningHour({
    this.id,
    required this.day,
    required this.dayFrom,
    required this.timeFrom,
    required this.duration,
    required this.dayTo,
    this.isDeleted,
    this.advertiserId,
    required this.addressId,
  });
}
