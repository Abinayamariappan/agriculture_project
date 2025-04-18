import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

// ... (imports remain unchanged)

class GenerateReportPage extends StatefulWidget {
  @override
  _GenerateReportPageState createState() => _GenerateReportPageState();
}

class _GenerateReportPageState extends State<GenerateReportPage> {
  DateTime selectedDate = DateTime.now();
  double totalRevenue = 0.0;
  int totalProductsSold = 0;
  int totalOrders = 0;
  List<Map<String, dynamic>> orderSummary = [];

  @override
  void initState() {
    super.initState();
    fetchReport();
  }

  Future<Database> get database async {
    return openDatabase(join(await getDatabasesPath(), 'agricult.db'));
  }

  Future<void> fetchReport() async {
    final db = await database;
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    final orders = await db.rawQuery('''
      SELECT payment_method, order_status, SUM(total_amount) as revenue, COUNT(*) as count
      FROM orders
      WHERE DATE(datetime(created_at / 1000, 'unixepoch')) = ?
      GROUP BY payment_method, order_status
    ''', [formattedDate]);

    final productData = await db.rawQuery('''
      SELECT SUM(quantity) as total_products
      FROM order_items
      WHERE order_id IN (
        SELECT id FROM orders
        WHERE DATE(datetime(created_at / 1000, 'unixepoch')) = ?
      )
    ''', [formattedDate]);

    totalRevenue = 0;
    totalOrders = 0;
    totalProductsSold = (productData.first['total_products'] as int? ?? 0);
    orderSummary = [];

    for (var order in orders) {
      final paymentMethod = order['payment_method'];
      final orderStatus = order['order_status'];
      final revenue = (order['revenue'] as num?)?.toDouble() ?? 0.0;
      final count = (order['count'] as int?) ?? 0;

      totalRevenue += revenue;
      totalOrders += count;

      final productDetails = await db.rawQuery('''
        SELECT oi.product_name, SUM(oi.quantity) as total_quantity
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.id
        WHERE DATE(datetime(o.created_at / 1000, 'unixepoch')) = ?
        AND o.payment_method = ? AND o.order_status = ?
        GROUP BY oi.product_name
      ''', [formattedDate, paymentMethod, orderStatus]);

      orderSummary.add({
        ...order,
        'products': productDetails,
      });
    }

    setState(() {});
  }

  Future<void> generatePDF() async {
    final pdf = pw.Document();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text("📄 AgriConnect Daily Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text("Date: $formattedDate", style: pw.TextStyle(fontSize: 16)),
          pw.Divider(),

          pw.Text("🧾 Summary", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text("🛒 Total Orders: $totalOrders", style: pw.TextStyle(fontSize: 14)),
          pw.Text("📦 Total Products Sold: $totalProductsSold", style: pw.TextStyle(fontSize: 14)),
          pw.Text("💰 Total Revenue: ₹${totalRevenue.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 20),

          pw.Text("📌 Order Breakdown", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),

          if (orderSummary.isEmpty)
            pw.Text("No order summary available", style: pw.TextStyle(fontSize: 14))
          else
            ...orderSummary.map((item) => pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 8),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey600),
                borderRadius: pw.BorderRadius.circular(10),
                color: PdfColors.grey200,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Payment Method: ${item['payment_method']}", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Order Status: ${item['order_status']}", style: pw.TextStyle(fontSize: 14)),
                  pw.Text("Orders Count: ${item['count']}", style: pw.TextStyle(fontSize: 14)),
                  pw.Text("Revenue: ₹${(item['revenue'] as double).toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 6),
                  pw.Text("Products:", style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 3),
                  ...((item['products'] ?? []) as List<dynamic>).map<pw.Widget>((prod) {
                    return pw.Bullet(
                      text: "${prod['product_name']} x ${prod['total_quantity']}",
                      style: pw.TextStyle(fontSize: 12),
                    );
                  }).toList(),
                ],
              ),
            )),
        ],
      ),
    );

    final output = await getExternalStorageDirectory();
    final file = File("${output!.path}/AgriConnect_Report_$formattedDate.pdf");
    await file.writeAsBytes(await pdf.save());

    // Show PDF
    await OpenFile.open(file.path);

  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      fetchReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📊 Generate Report"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("📅 Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => selectDate(context),
                  icon: Icon(Icons.calendar_today),
                  label: Text("Pick Date"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                )
              ],
            ),
            SizedBox(height: 20),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🛒 Total Orders: $totalOrders",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    Text("💰 Revenue: ₹${totalRevenue.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    Text("📦 Products Sold: $totalProductsSold",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
            Text("🧾 Order Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            Expanded(
              child: orderSummary.isEmpty
                  ? Center(child: Text("No records available", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                itemCount: orderSummary.length,
                itemBuilder: (context, index) {
                  final item = orderSummary[index];
                  return ListTile(
                    leading: Icon(Icons.receipt, color: Colors.green),
                    title: Text("${item['payment_method']} - ${item['order_status']}"),
                    subtitle: Text("Orders: ${item['count']}, Revenue: ₹${item['revenue'].toStringAsFixed(2)}"),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: generatePDF,
        label: Text("Download PDF"),
        icon: Icon(Icons.picture_as_pdf),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}
