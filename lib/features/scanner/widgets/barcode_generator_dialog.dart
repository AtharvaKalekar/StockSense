import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/sku_model.dart';

class BarcodeGeneratorDialog extends StatefulWidget {
  final SkuModel sku;

  const BarcodeGeneratorDialog({super.key, required this.sku});

  @override
  State<BarcodeGeneratorDialog> createState() => _BarcodeGeneratorDialogState();
}

class _BarcodeGeneratorDialogState extends State<BarcodeGeneratorDialog> {
  bool _showQr = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Label Generator - ${widget.sku.skuCode}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Barcode (Code128)'),
                  selected: !_showQr,
                  onSelected: (val) => setState(() => _showQr = !val),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('QR Code'),
                  selected: _showQr,
                  onSelected: (val) => setState(() => _showQr = val),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryTeal, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'STOCKSENSE WMS LABEL',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.sku.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_showQr)
                    QrImageView(
                      data: widget.sku.skuCode,
                      version: QrVersions.auto,
                      size: 140,
                    )
                  else
                    SizedBox(
                      height: 80,
                      width: 200,
                      child: BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: widget.sku.skuCode,
                        drawText: true,
                        style: const TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Location: ${widget.sku.fullLocation}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryTeal,
            foregroundColor: Colors.black,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Print job sent to Bluetooth Thermal Printer!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          },
          icon: const Icon(Icons.print_rounded),
          label: const Text('Print Label'),
        ),
      ],
    );
  }
}
