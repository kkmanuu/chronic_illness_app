// export_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html show AnchorElement, Blob, Url; // Web only
import 'dart:io' as io show File; // Mobile/Desktop only

import 'package:chronic_illness_app/core/models/reading_model.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  Future<String> exportReadingsToCSV({
    List<ReadingModel>? readings,
    ReadingModel? singleReading,
    bool shareOnMobile = false, // enable sharing option
  }) async {
    if ((readings == null || readings.isEmpty) && singleReading == null) {
      throw Exception('No readings provided to export');
    }

    try {
      // Prepare CSV data with headers
      List<List<dynamic>> csvData = [
        ['ID', 'Blood Sugar (mg/dL)', 'Systolic BP (mmHg)', 'Diastolic BP (mmHg)', 'Timestamp'],
      ];

      // Add single reading or list of readings
      if (singleReading != null) {
        csvData.add([
          singleReading.id,
          singleReading.bloodSugar,
          singleReading.systolicBP,
          singleReading.diastolicBP,
          DateFormat('yyyy-MM-dd HH:mm:ss').format(singleReading.timestamp),
        ]);
      } else if (readings != null) {
        csvData.addAll(readings.map((reading) => [
              reading.id,
              reading.bloodSugar,
              reading.systolicBP,
              reading.diastolicBP,
              DateFormat('yyyy-MM-dd HH:mm:ss').format(reading.timestamp),
            ]));
      }

      // Convert to CSV string
      String csvString = const ListToCsvConverter().convert(csvData);
      String fileName = 'health_reading_${DateTime.now().millisecondsSinceEpoch}.csv';

      if (kIsWeb) {
        // ---- WEB DOWNLOAD ----
        final bytes = utf8.encode(csvString);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();

        html.Url.revokeObjectUrl(url);

        return "Downloaded: $fileName";
      } else {
        // ---- MOBILE/DESKTOP ----
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';

        final file = io.File(filePath);
        await file.writeAsString(csvString);

        // If share option enabled, trigger share dialog
        if (shareOnMobile) {
          await Share.shareXFiles([XFile(file.path)], text: 'My health readings export');
        }

        return filePath;
      }
    } catch (e) {
      throw Exception('Export failed: $e');
    }
  }
}
