import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/enviroment.dart';
import '../providers/wallet.dart';

import '../models/http_exception.dart';

class Wallets with ChangeNotifier {
  List<Wallet> _wallets = [];

  final String? authToken;

  Wallets(this.authToken, this._wallets);

  List<Wallet> get wallets {
    return [..._wallets];
  }

  Wallet findById(String id) {
    return _wallets.firstWhere((wlt) => wlt.id == id);
  }

  List<Wallet> findAdvertiserId(String advertiserId) {
    return _wallets.where((wlt) => wlt.advertiserId == advertiserId).toList();
  }

  Future<void> fetchAllWallets() async {
    final String _walletUrl = Enviroment.baseUrl + '/wallet/myWalletAdvertiser';

    Dio _dio = Dio();
    try {
      Response _responseWallet = await _dio.get(_walletUrl,
          options: Options(headers: {
            "Authorization": "Bearer $authToken",
            "Permission": Enviroment.permissionKey,
          }));
      print(_responseWallet.data);

      if (_responseWallet.statusCode == 200) {
        // if (_responseWallet.data[0] != null) {
        //   print(_responseWallet.statusMessage);
        //   if (_responseWallet.data[0]["statusCode"] != null) {
        //     throw HttpException(
        //         message: "${_responseWallet.data[0]["message"]}");
        //   }
        // }

        final List<Wallet> _loadedWallets = [];

        for (var wallet in await _responseWallet.data) {
          _loadedWallets.add(Wallet(
            id: wallet["id"],
            expiryDate: DateTime.parse(wallet["expiry_date"]),
            isDeletedAdvertiser: wallet["is_deleted_advertiser"],
            isDeletedCustomer: wallet["is_deleted_customer"],
            isExpired: wallet["is_expired"],
            notified: wallet["notified"],
            notify: wallet["notify"],
            redeemed: wallet["redeemed"],
            addressId: wallet["address_id"],
            advertiserId: wallet["advertiser_id"],
            isDeleted: wallet["is_deleted"],
            qrofferId: wallet["qroffer_id"],
          ));
        }

        _wallets = _loadedWallets;
        notifyListeners();
      } else {
        throw HttpException(message: _responseWallet.statusMessage!);
      }
    } catch (e) {
      throw HttpException(message: "Can not fetch Subcategorys.");
    }
  }
}
