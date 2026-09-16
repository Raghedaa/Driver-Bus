import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_color.dart';
import '../../controllers/passenger_controller.dart';

class QrScannerView extends StatefulWidget {
  const QrScannerView({super.key});

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  final MobileScannerController scannerController = MobileScannerController();
  bool isProcessing = false;

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PassengerController>();

    return Scaffold(
      appBar: AppBar(title: Text("scanPassengerTicket".tr)),
      body: Obx(
        () => Stack(
          children: [
            MobileScanner(
              controller: scannerController,
              onDetect: (capture) {
                if (isProcessing) return;

                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? pnrCode = barcodes.first.rawValue;
                  if (pnrCode != null && pnrCode.isNotEmpty) {
                    isProcessing = true;
                    controller.processQrCode(pnrCode);
                  }
                }
              },
            ),
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryGreen,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
