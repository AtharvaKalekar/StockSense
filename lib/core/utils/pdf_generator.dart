import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfReportGenerator {
  static Future<Uint8List> generateDispatchNote(
    String orderNumber,
    String customerName,
    List<Map<String, dynamic>> items,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('STOCKSENSE WMS - DISPATCH MANIFEST', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Order Number: $orderNumber'),
              pw.Text('Customer: $customerName'),
              pw.Text('Date: ${DateTime.now().toIso8601String()}'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['SKU Name', 'Qty', 'Unit Price'],
                data: items.map((item) => [item['name'].toString(), item['qty'].toString(), item['price'].toString()]).toList(),
              ),
              pw.SizedBox(height: 30),
              pw.Text('Authorized Signature: _______________________'),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateInventoryReport(List<Map<String, dynamic>> inventoryItems) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('STOCKSENSE EXECUTIVE INVENTORY AUDIT REPORT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Generated: ${DateTime.now().toIso8601String()}'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['SKU Name', 'SKU Code', 'Qty', 'Price (INR)'],
                data: inventoryItems.map((item) => [item['name'].toString(), item['sku'].toString(), item['qty'].toString(), item['price'].toString()]).toList(),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
