import 'package:flutter/material.dart';

class Qroffer with ChangeNotifier {
  final String? id;
  final String? title;
  final double latitude;
  final double longitude;
  final String shortDescription;
  final String longDescription;
  final double price;
  final double? taxPrice;
  final double? gross;
  final String? type;
  final List? media;
  final DateTime? begin;
  final DateTime? end;
  final DateTime? expiryDate;
  final double displayRadius;
  final double pushNotificationRadius;
  bool? isActive;
  final bool? isBanned;
  bool? isDeleted;
  bool? isEditable;
  final bool? isArchive;
  final bool? completelyDeleted;
  final int qrValue;
  final int? liveQrValue;
  final int? redeemedQrValue;
  final bool? inInvoice;
  final DateTime? invoiceDate;
  final String addressId;
  final String? categoryId;
  final String? subcategoryId;
  final List? subsubcategoryIds;
  final String invoiceAddressId;
  final String? invoiceId;
  final String? advertiserId;
  final DateTime? createdAt;

  Qroffer({
    this.id,
    this.title,
    required this.latitude,
    required this.longitude,
    required this.shortDescription,
    required this.longDescription,
    required this.price,
    this.taxPrice,
    this.gross,
    this.type,
    this.media,
    this.begin,
    this.end,
    this.expiryDate,
    required this.displayRadius,
    required this.pushNotificationRadius,
    this.isActive,
    this.isBanned,
    this.isEditable,
    this.isDeleted,
    this.isArchive,
    this.completelyDeleted,
    required this.qrValue,
    this.liveQrValue,
    this.redeemedQrValue,
    this.inInvoice,
    this.invoiceDate,
    required this.addressId,
    this.categoryId,
    this.subcategoryId,
    this.subsubcategoryIds,
    required this.invoiceAddressId,
    this.invoiceId,
    this.advertiserId,
    this.createdAt,
  });
}
