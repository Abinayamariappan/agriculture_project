import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class GenerateReportPage extends StatefulWidget {
  const GenerateReportPage({super.key});

  @override
  _GenerateReportPageState createState() => _GenerateReportPageState();
}

class _GenerateReportPageState extends State<GenerateReportPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedFilter = "All";
  List<SalesData> _salesData = [];

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
  }

  void _fetchSalesData() {
    setState(() {
      _salesData = [
        SalesData("Mon", 200),
        SalesData("Tue", 400),
        SalesData("Wed", 300),
        SalesData("Thu", 500),
        SalesData("Fri", 700),
        SalesData("Sat", 900),
        SalesData("Sun", 600),
      ];
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != DateTimeRange(start: _startDate ?? DateTime.now(), end: _endDate ?? DateTime.now())) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Sales Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Date Range: ${_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'N/A'} - ${_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'N/A'}"),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ["Day", "Sales"],
                data: _salesData.map((e) => [e.day, e.sales.toString()]).toList(),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/Sales_Report.pdf");
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate Report"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _selectDateRange(context),
                  child: const Text("Select Date Range"),
                ),
                const SizedBox(width: 10),
                Text(_startDate != null
                    ? "${DateFormat('yyyy-MM-dd').format(_startDate!)} - ${DateFormat('yyyy-MM-dd').format(_endDate!)}"
                    : "No date selected"),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedFilter,
              items: ["All", "Only Purchases", "Only Requests"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFilter = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                title: ChartTitle(text: "Sales Report"),
                legend: Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <ChartSeries>[
                  ColumnSeries<SalesData, String>(
                    dataSource: _salesData,
                    xValueMapper: (SalesData sales, _) => sales.day,
                    yValueMapper: (SalesData sales, _) => sales.sales,
                    name: "Sales",
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: _generatePDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Generate PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SalesData {
  final String day;
  final double sales;

  SalesData(this.day, this.sales);
}
