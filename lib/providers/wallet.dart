import 'package:flutter/material.dart';

import '../models/http_exception.dart';

class Wallet with ChangeNotifier {
  String? id;
  String? qrofferId;
  bool redeemed;
  bool notified;
  bool notify;
  DateTime expiryDate;
  bool isExpired;
  bool isDeletedCustomer;
  bool isDeletedAdvertiser;
  String? advertiserId;
  String? addressId;
  bool? isDeleted;

  Wallet({
    this.id,
    this.qrofferId,
    required this.redeemed,
    required this.notified,
    required this.notify,
    required this.expiryDate,
    required this.isExpired,
    required this.isDeletedCustomer,
    required this.isDeletedAdvertiser,
    this.advertiserId,
    this.addressId,
    this.isDeleted,
  });
}
