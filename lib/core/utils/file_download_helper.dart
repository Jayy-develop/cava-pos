import 'dart:convert';
import 'package:flutter/foundation.dart';

// Conditional import for web file download
import 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart' as saver;

class FileDownloadHelper {
  FileDownloadHelper._();

  static void download({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
  }) {
    if (kIsWeb) {
      saver.saveFileWeb(bytes: bytes, fileName: fileName, mimeType: mimeType);
    } else {
      // In mobile/desktop, can save to downloads or use share_plus
      debugPrint('Downloading $fileName (${bytes.length} bytes)');
    }
  }

  static void downloadCsv({
    required String csvContent,
    required String fileName,
  }) {
    // Add UTF-8 BOM for Microsoft Excel auto-detect
    final bytes = [0xEF, 0xBB, 0xBF, ...utf8.encode(csvContent)];
    download(
      bytes: bytes,
      fileName: fileName,
      mimeType: 'text/csv;charset=utf-8',
    );
  }
}
