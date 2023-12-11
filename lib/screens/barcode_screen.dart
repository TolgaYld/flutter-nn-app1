import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({Key? key}) : super(key: key);

  static const routeName = "/barcode_scanner";

  @override
  _BarcodeScannerState createState() => _BarcodeScannerState();
}

final String title = "Redeem Failed";
final String titleRedeemed = "Redeemed!";
final String desc = "Qr successfully redeemed!";

class _BarcodeScannerState extends State<BarcodeScanner> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? barcode;

  @override
  void dispose() {
    if (controller != null) {
      controller!.dispose();
    }
    super.dispose();
  }

  @override
  void reassemble() async {
    // TODO: implement reassemble
    super.reassemble();

    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          buildQrView(context),
          Positioned(
            child: buildResult(),
            bottom: MediaQuery.of(context).size.height * 0.26,
          ),
          Positioned(
            child: buildControlButtons(),
            top: MediaQuery.of(context).size.height * 0.026,
          ),
          Positioned(
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Platform.isAndroid
                  ? const Icon(
                      Icons.arrow_back_rounded,
                      size: 42,
                      color: Colors.white,
                    )
                  : const Icon(
                      CupertinoIcons.back,
                      size: 42,
                      color: CupertinoColors.white,
                    ),
            ),
            top: MediaQuery.of(context).size.height * 0.09,
            left: MediaQuery.of(context).size.height * 0.01,
          )
        ],
      ),
    );
  }

  Widget buildQrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
            borderColor: Theme.of(context).primaryColor,
            cutOutSize: MediaQuery.of(context).size.width * 0.8,
            borderRadius: 9,
            borderWidth: 10,
            borderLength: 26),
      );

  void onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);

    controller.scannedDataStream
        .listen((barcode) => setState(() => this.barcode = barcode));
  }

  Widget buildResult() => barcode != null
      // Text(
      //   barcode != null ? "Result: ${barcode!.code}" : "Scan the QR",
      //   maxLines: 3,
      // ),
      ? ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color.fromRGBO(253, 166, 41, 1.0),
            textStyle: const TextStyle(
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: const BorderSide(color: Colors.white, width: 2.0),
            ),
          ),
          onPressed: () async {
            // var result = await runMutation({
            //   "qroffer_id": barcode!.code[0],
            //   "customer_id": barcode!.code[1],
            // }).networkResult;

            // if (result!.hasException) {
            //   await Alert(
            //     context: context,
            //     type: AlertType.error,
            //     title: title,
            //     desc: result.exception!.graphqlErrors[0].message,
            //     buttons: [
            //       DialogButton(
            //         child: Text(
            //           "Ok",
            //           style: TextStyle(color: Colors.white, fontSize: 12),
            //         ),
            //         onPressed: () =>
            //             Navigator.of(context, rootNavigator: true).pop(),
            //         width: MediaQuery.of(context).size.width * 0.12,
            //       )
            //     ],
            //   ).show();
            // } else {
            //   await Alert(
            //     context: context,
            //     type: AlertType.error,
            //     title: titleRedeemed,
            //     desc: desc,
            //     buttons: [
            //       DialogButton(
            //         child: Text(
            //           "Ok",
            //           style: TextStyle(color: Colors.white, fontSize: 12),
            //         ),
            //         onPressed: () {
            //           Navigator.of(context, rootNavigator: true).pop();
            //           Navigator.of(context).pop();
            //         },
            //         width: MediaQuery.of(context).size.width * 0.12,
            //       )
            //     ],
            //   ).show();
            // }
          },
          child: const Text(
            "Redeem QR",
            style: TextStyle(
                fontWeight: FontWeight.w600, color: Colors.white, fontSize: 21),
          ),
        )
      : Container(
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.height * 0.05,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: const BorderRadius.all(
              Radius.circular(9.0),
            ),
          ),
          child: const Center(
            child: Text(
              "Scan QR",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w600),
            ),
          ),
        );

  Widget buildControlButtons() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white24,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                await controller?.toggleFlash();
                setState(() {});
              },
              icon: FutureBuilder<bool?>(
                future: controller?.getFlashStatus(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Icon(
                      snapshot.data! ? Icons.flash_on : Icons.flash_off,
                    );
                  } else {
                    return Icon(Icons.flash_off);
                  }
                },
              ),
            ),
            IconButton(
              onPressed: () async {
                await controller?.flipCamera();
                setState(() {});
              },
              icon: FutureBuilder(
                future: controller?.getCameraInfo(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Platform.isAndroid
                        ? Icon(Icons.switch_camera)
                        : Icon(CupertinoIcons.switch_camera);
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      );
}
