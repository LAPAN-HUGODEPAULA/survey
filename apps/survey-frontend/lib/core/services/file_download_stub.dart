library;

import 'dart:typed_data';

Future<void> saveTextDownload({
  required String fileName,
  required String content,
}) async {}

Future<void> saveBytesDownload({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
}) async {}
