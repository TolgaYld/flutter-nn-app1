import 'package:flutter/material.dart';
import '../providers/category.dart';
import '../providers/advertiser.dart';

class InvoiceAddress with ChangeNotifier {
  final String? id;
  final String? companyName;
  final String? name;
  final String gender;
  final String firstname;
  final String lastname;
  final String email;
  final double latitude;
  final double longitude;
  final String street;
  final String? postcode;
  final String city;
  final String country;
  final String? floor;
  final List<dynamic>? timezone;
  final String countryCode;
  final DateTime? flatrateDateStad;
  final DateTime? flatrateDateQroffer;
  final String? phone;
  final bool? isDeleted;
  final bool? wantLetter;
  final bool? wantEmail;
  final String? advertiserId;
  final String? addressId;

  InvoiceAddress({
    this.id,
    this.companyName,
    this.name,
    required this.email,
    required this.gender,
    required this.firstname,
    required this.lastname,
    required this.latitude,
    required this.longitude,
    required this.street,
    this.postcode,
    required this.city,
    required this.country,
    this.floor,
    this.timezone,
    required this.countryCode,
    this.flatrateDateStad,
    this.flatrateDateQroffer,
    this.phone,
    this.isDeleted,
    this.addressId,
    this.advertiserId,
    this.wantEmail,
    this.wantLetter,
  });
}
