import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> orderSummaryData = [];

  int totalOrders = 0;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    fetchReport();
  }

  Future<List<Map<String, dynamic>>> fetchOrderSummary(String date) async {
    final database = openDatabase(join(await getDatabasesPath(), 'agricult.db'));
    final db = await database;

    return await db.rawQuery('''
      SELECT 
        payment_method,
        order_status,
        COUNT(*) AS total_orders,
        SUM(total_amount) AS total_amount
      FROM orders
      WHERE DATE(datetime(created_at / 1000, 'unixepoch')) = ?
      GROUP BY payment_method, order_status
    ''', [date]);
  }

  Future<void> fetchReport() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    orderSummaryData = await fetchOrderSummary(formattedDate);

    // Calculate totals
    totalOrders = orderSummaryData.fold(0, (sum, item) => sum + (item['total_orders'] as int));
    totalAmount = orderSummaryData.fold(0.0, (sum, item) => sum + (item['total_amount'] as num).toDouble());

    setState(() {});
  }

  Future<void> generatePDF() async {
    final pdf = pw.Document();
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("🌾 AgriConnect Daily Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text("Date: $formattedDate", style: pw.TextStyle(fontSize: 16, color: PdfColors.grey600)),
              pw.Divider(),

              pw.Text("🧾 Order Summary", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              orderSummaryData.isEmpty
                  ? pw.Text("No order records available", style: pw.TextStyle(color: PdfColors.grey))
                  : pw.TableHelper.fromTextArray(
                headers: ["Payment", "Status", "Orders", "Amount"],
                data: orderSummaryData.map((item) => [
                  item['payment_method'],
                  item['order_status'],
                  item['total_orders'].toString(),
                  "₹${item['total_amount']}"
                ]).toList(),
              ),
              pw.SizedBox(height: 10),
              pw.Text("📦 Total Orders: $totalOrders | 💰 Revenue: ₹${totalAmount.toStringAsFixed(2)}",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    final output = await getExternalStorageDirectory();
    final file = File("${output!.path}/Daily_Report_${formattedDate}.pdf");
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📊 Daily Report"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "📅 Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => selectDate(context),
                  icon: Icon(Icons.calendar_today, color: Colors.white),
                  label: Text("Pick Date"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                ),
              ],
            ),
            SizedBox(height: 15),

            // Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🧾 Order Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    Divider(),
                    orderSummaryData.isEmpty
                        ? Center(child: Text("No records available", style: TextStyle(color: Colors.grey)))
                        : Column(
                      children: orderSummaryData.map((item) {
                        return ListTile(
                          leading: Icon(Icons.receipt_long, color: Colors.green),
                          title: Text("${item['payment_method']} - ${item['order_status']}"),
                          subtitle: Text("Orders: ${item['total_orders']}, Amount: ₹${item['total_amount']}"),
                        );
                      }).toList(),
                    ),
                    if (orderSummaryData.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "📦 Total Orders: $totalOrders | 💰 Revenue: ₹${totalAmount.toStringAsFixed(2)}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
