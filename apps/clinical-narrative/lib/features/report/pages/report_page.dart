/// Pagina de exibicao do prontuario gerado pela IA.
library;

import 'dart:io';
import 'dart:js_interop';

import 'package:clinical_narrative_app/core/providers/app_settings.dart';
import 'package:design_system_flutter/report/report_models.dart';
import 'package:design_system_flutter/report/report_view.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, required this.report});

  final ReportDocument report;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String _generateReportFileName(AppSettings settings) {
    final base = settings.patient.medicalRecordId.isNotEmpty
        ? settings.patient.medicalRecordId
        : settings.patient.name;
    final cleanBase = base
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w\s]'), '');
    return 'prontuario_${cleanBase.isEmpty ? 'paciente' : cleanBase}.txt';
  }

  String _buildReportText(ReportDocument report) {
    return report.toPlainText(
      footer:
          'Gerado por LAPAN - Laboratório de Pesquisa Aplicada à Neurociência da Visão',
    );
  }

  void _printReport() {
    if (kIsWeb) {
      web.window.print();
    }
  }

  Future<void> _exportReport(AppSettings settings, ReportDocument report) async {
    final fileName = _generateReportFileName(settings);
    final reportText = _buildReportText(report);
    final result = await _writeReportFile(fileName, reportText);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );
  }

  Future<String> _writeReportFile(String fileName, String content) async {
    try {
      if (kIsWeb) {
        return await _saveReportToWebBrowser(fileName, content);
      }
      return await _saveReportToNativeDirectory(fileName, content);
    } catch (e) {
      return 'Falha ao exportar prontuário: $e';
    }
  }

  Future<String> _saveReportToWebBrowser(String fileName, String content) async {
    final parts = <web.BlobPart>[content.toJS as web.BlobPart].toJS;
    final blob = web.Blob(parts, web.BlobPropertyBag(type: 'text/plain'));
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName
      ..style.display = 'none';

    web.document.body?.appendChild(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);

    return 'Download iniciado: $fileName';
  }

  Future<String> _saveReportToNativeDirectory(
    String fileName,
    String content,
  ) async {
    final tempDir = Directory.systemTemp;
    final reportsDir = Directory(path.join(tempDir.path, 'clinical_reports'));

    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final file = File(path.join(reportsDir.path, fileName));
    await file.writeAsString(content);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);

    return DsScaffold(
      appBar: AppBar(
        title: const Text('Prontuário gerado'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ReportView(
              report: widget.report,
              footer:
                  'Gerado por LAPAN - Laboratório de Pesquisa Aplicada à Neurociência da Visão',
              onPrint: kIsWeb ? _printReport : null,
              onExport: () => _exportReport(settings, widget.report),
            ),
          ),
        ),
      ),
    );
  }
}
