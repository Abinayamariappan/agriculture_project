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
  List<Map<String, dynamic>> salesData = [];
  List<Map<String, dynamic>> jobData = [];

  @override
  void initState() {
    super.initState();
    fetchReport();
  }

  Future<void> fetchReport() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    salesData = await fetchSalesReport(formattedDate);
    jobData = await fetchJobReport(formattedDate);
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> fetchSalesReport(String date) async {
    final database = openDatabase(join(await getDatabasesPath(), 'agrifarm.db'));
    final db = await database;
    return await db.rawQuery(
        "SELECT product_name, SUM(quantity) AS total_qty, SUM(price) AS total_price FROM sales WHERE date = ? GROUP BY product_name", [date]
    );
  }

  Future<List<Map<String, dynamic>>> fetchJobReport(String date) async {
    final database = openDatabase(join(await getDatabasesPath(), 'agrifarm.db'));
    final db = await database;
    return await db.rawQuery(
        "SELECT job_type, COUNT(*) AS total_jobs FROM farming_jobs WHERE date = ? GROUP BY job_type", [date]
    );
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

              // Sales Report
              pw.Text("📈 Sales Report", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              salesData.isEmpty
                  ? pw.Text("No sales records available", style: pw.TextStyle(color: PdfColors.grey))
                  : pw.TableHelper.fromTextArray(
                headers: ["Product", "Qty", "Total Price"],
                data: salesData.map((sale) => [sale['product_name'], sale['total_qty'], "₹${sale['total_price']}"]).toList(),
              ),

              pw.SizedBox(height: 15),

              // Farming Job Report
              pw.Text("🚜 Farming Job Report", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              jobData.isEmpty
                  ? pw.Text("No job records available", style: pw.TextStyle(color: PdfColors.grey))
                  : pw.TableHelper.fromTextArray(
                headers: ["Job Type", "Total Jobs"],
                data: jobData.map((job) => [job['job_type'], job['total_jobs']]).toList(),
              ),
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
            // Date Picker Row
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

            // Sales Report Card
            buildReportCard("📈 Sales Report", salesData, Icons.shopping_cart, "product_name", "Qty: {total_qty}, ₹{total_price}"),

            SizedBox(height: 15),

            // Farming Job Report Card
            buildReportCard("🚜 Farming Job Report", jobData, Icons.agriculture, "job_type", "Total Jobs: {total_jobs}"),
          ],
        ),
      ),

      // Floating Action Button for PDF Export
      floatingActionButton: FloatingActionButton.extended(
        onPressed: generatePDF,
        label: Text("Download PDF"),
        icon: Icon(Icons.picture_as_pdf),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  Widget buildReportCard(String title, List<Map<String, dynamic>> data, IconData icon, String mainKey, String subTextTemplate) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
            Divider(),
            data.isEmpty
                ? Center(child: Text("No records available", style: TextStyle(color: Colors.grey)))
                : Column(
              children: data.map((item) {
                String subtitle = subTextTemplate;
                item.forEach((key, value) {
                  subtitle = subtitle.replaceAll("{$key}", value.toString());
                });

                return ListTile(
                  leading: Icon(icon, color: Colors.green),
                  title: Text(item[mainKey]),
                  subtitle: Text(subtitle),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
