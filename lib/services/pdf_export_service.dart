import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/models.dart';

class PdfExportService {
  static Future<void> workOrder(WorkOrder order) async {
    await Printing.layoutPdf(onLayout: (_) async {
      final doc = pw.Document();
      doc.addPage(pw.MultiPage(build: (_) => [
        pw.Text('Garage Work Order ${order.workOrderNumber}', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 16),
        _line('Vehicle', '${order.vehicleMake} ${order.vehicleModel} • ${order.vehiclePlate}'),
        _line('Created', order.createdAt.toLocal().toString()),
        _line('Status', _label(order.status.name)),
        _line('Department', order.department),
        _line('Technician', order.technician),
        _line('Requested by', order.requestedBy),
        _line('Issue', order.issueSummary),
        pw.SizedBox(height: 12),
        pw.Text('Parts used', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.TableHelper.fromTextArray(headers: ['Serial number', 'Part', 'Quantity'],
          data: order.items.map((p) => [p.serialNumber, p.partName, p.quantity.toString()]).toList()),
      ]));
      return doc.save();
    });
  }

  static Future<void> accident(AccidentReport report) async {
    await Printing.layoutPdf(onLayout: (_) async {
      final doc = pw.Document();
      doc.addPage(pw.MultiPage(build: (_) => [
        pw.Text('Accident Report ${report.reportNumber}', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 16),
        _line('Vehicle plate', report.vehiclePlate),
        _line('Driver', report.driverName),
        _line('Date reported', report.createdAt.toLocal().toString()),
        _line('Severity', report.severity),
        _line('Status', _label(report.status.name)),
        _line('Details', report.description),
        _line('Attached image files', report.imagePaths.isEmpty ? 'None' : report.imagePaths.join('\n')),
      ]));
      return doc.save();
    });
  }

  static pw.Widget _line(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.RichText(text: pw.TextSpan(children: [
      pw.TextSpan(text: '$label: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      pw.TextSpan(text: value.isEmpty ? '—' : value),
    ])),
  );

  static String _label(String text) => text.replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m[0]}').trim();
}
