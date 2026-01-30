/// MSH Map - Print Service
///
/// Ermöglicht das Drucken von POI-Details als PDF
library;

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Service zum Erstellen und Drucken von PDF-Dokumenten
class PrintService {
  PrintService._();

  /// Druckt allgemeine POI-Informationen
  static Future<void> printPoiDetails({
    required String title,
    required String category,
    String? address,
    String? phone,
    String? website,
    String? openingHours,
    String? description,
    List<String>? additionalInfo,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header mit Logo-Bereich
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 20),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300, width: 2),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'MSH Map',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Mansfeld-Südharz entdecken',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      'msh-map.de',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Titel
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              // Kategorie-Badge
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  category,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ),

              pw.SizedBox(height: 24),

              // Kontaktdaten
              if (address != null || phone != null || website != null || openingHours != null)
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Kontakt',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      if (address != null)
                        _buildInfoRow('Adresse:', address),
                      if (phone != null)
                        _buildInfoRow('Telefon:', phone),
                      if (website != null)
                        _buildInfoRow('Website:', website),
                      if (openingHours != null)
                        _buildInfoRow('Öffnungszeiten:', openingHours),
                    ],
                  ),
                ),

              if (description != null) ...[
                pw.SizedBox(height: 20),
                pw.Text(
                  'Beschreibung',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  description,
                  style: const pw.TextStyle(
                    fontSize: 12,
                    lineSpacing: 4,
                  ),
                ),
              ],

              if (additionalInfo != null && additionalInfo.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text(
                  'Weitere Informationen',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                ...additionalInfo.map(
                  (info) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('• ', style: const pw.TextStyle(fontSize: 12)),
                        pw.Expanded(
                          child: pw.Text(
                            info,
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              pw.Spacer(),

              // Footer
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 20),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.grey300),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Erstellt mit MSH Map - msh-map.de',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey500,
                      ),
                    ),
                    pw.Text(
                      'Stand: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: '$title - MSH Map',
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  /// Zeigt einen Druck-Button mit Tooltip
  static Widget buildPrintButton({
    required VoidCallback onPressed,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(
        Icons.print,
        color: color ?? Colors.grey[600],
      ),
      tooltip: 'Drucken',
      onPressed: onPressed,
    );
  }
}
