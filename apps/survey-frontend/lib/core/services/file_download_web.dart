import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> saveTextDownload({
  required String fileName,
  required String content,
}) {
  final parts = <web.BlobPart>[content.toJS].toJS;
  final blob = web.Blob(parts, web.BlobPropertyBag(type: 'text/plain'));
  _downloadBlob(blob, fileName);

  return Future.value();
}

Future<void> saveBytesDownload({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
}) {
  final parts = <web.BlobPart>[bytes.toJS].toJS;
  final blob = web.Blob(parts, web.BlobPropertyBag(type: mimeType));
  _downloadBlob(blob, fileName);

  return Future.value();
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
