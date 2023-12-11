import 'package:flutter/material.dart';
import '../providers/category.dart';
import '../providers/advertiser.dart';

class Address with ChangeNotifier {
  final String? id;
  final String? companyName;
  final String? name;
  final double latitude;
  final double longitude;
  final String street;
  final String? postcode;
  final String city;
  final String country;
  final String? floor;
  final String? iban;
  final List<dynamic>? timezone;
  final String countryCode;
  final List<dynamic>? media;
  final DateTime? flatrateDateStad;
  final DateTime? flatrateDateQroffer;
  final bool? official;
  final String? vat;
  final String? homepage;
  final String? facebook;
  final String? instagram;
  final String? googleMyBusiness;
  final String? youtube;
  final String? tiktok;
  final String? pinterest;
  final String? phone;
  final String? qrofferShortDescription;
  final bool? isActive;
  final bool? isDeleted;
  final bool? activeStad;
  final bool? activeQroffer;
  final int? activeQrofferValue;
  final String categoryId;
  final String subcategoryId;
  final String? subsubcategoryId;
  final String? advertiserId;
  final String? invoiceAddressId;
  final DateTime? createdAt;

  Address({
    this.id,
    this.companyName,
    this.name,
    required this.latitude,
    required this.longitude,
    required this.street,
    this.postcode,
    required this.city,
    required this.country,
    this.floor,
    this.timezone,
    required this.countryCode,
    this.media,
    this.flatrateDateStad,
    this.flatrateDateQroffer,
    this.official,
    this.homepage,
    this.facebook,
    this.instagram,
    this.googleMyBusiness,
    this.youtube,
    this.tiktok,
    this.pinterest,
    this.phone,
    this.vat,
    this.isActive,
    this.isDeleted,
    this.activeQroffer,
    this.activeQrofferValue,
    this.activeStad,
    this.iban,
    required this.categoryId,
    required this.subcategoryId,
    this.subsubcategoryId,
    this.advertiserId,
    this.qrofferShortDescription,
    this.invoiceAddressId,
    this.createdAt,
  });
}
