library;

import 'dart:typed_data';

import 'package:survey_app/core/services/file_download_stub.dart'
    if (dart.library.js_interop) 'package:survey_app/core/services/file_download_web.dart'
    as file_download;

Future<void> saveTextDownload({
  required String fileName,
  required String content,
}) {
  return file_download.saveTextDownload(
    fileName: fileName,
    content: content,
  );
}

Future<void> saveBytesDownload({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
}) {
  return file_download.saveBytesDownload(
    fileName: fileName,
    bytes: bytes,
    mimeType: mimeType,
  );
}
