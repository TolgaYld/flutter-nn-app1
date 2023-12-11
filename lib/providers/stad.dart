import 'package:flutter/material.dart';

class Stad with ChangeNotifier {
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
  final List media;
  final DateTime? begin;
  final DateTime? end;
  final double displayRadius;
  final double pushNotificationRadius;
  bool? isActive;
  final bool? isBanned;
  bool? isDeleted;
  bool? isEditable;
  final bool? isArchive;
  final bool? completelyDeleted;
  final bool? inInvoice;
  final DateTime? invoiceDate;
  final String addressId;
  final String? categoryId;
  final String? subcategoryId;
  final List? subsubcategoryIds;
  final String? invoiceAddressId;
  final String? invoiceId;
  final String? advertiserId;
  final DateTime? createdAt;

  Stad({
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
    required this.media,
    this.begin,
    this.end,
    required this.displayRadius,
    required this.pushNotificationRadius,
    this.isActive,
    this.isBanned,
    this.isDeleted,
    this.isArchive,
    this.isEditable,
    this.completelyDeleted,
    this.inInvoice,
    this.invoiceDate,
    required this.addressId,
    this.categoryId,
    this.subcategoryId,
    this.subsubcategoryIds,
    this.invoiceAddressId,
    this.invoiceId,
    this.advertiserId,
    this.createdAt,
  });
}
