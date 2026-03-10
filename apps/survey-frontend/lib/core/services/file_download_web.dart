library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> saveTextDownload({
  required String fileName,
  required String content,
}) async {
  final parts = <web.BlobPart>[content.toJS as web.BlobPart].toJS;
  final blob = web.Blob(parts, web.BlobPropertyBag(type: 'text/plain'));
  _downloadBlob(blob, fileName);
}

Future<void> saveBytesDownload({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
}) async {
  final parts = <web.BlobPart>[bytes.toJS as web.BlobPart].toJS;
  final blob = web.Blob(parts, web.BlobPropertyBag(type: mimeType));
  _downloadBlob(blob, fileName);
}

void _downloadBlob(web.Blob blob, String fileName) {
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
