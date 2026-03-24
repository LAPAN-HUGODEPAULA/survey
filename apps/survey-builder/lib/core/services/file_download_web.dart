import 'dart:js_interop';

import 'package:web/web.dart' as web;

void downloadTextFileImpl(String filename, String content) {
  final parts = <web.BlobPart>[content.toJS as web.BlobPart].toJS;
  final blob = web.Blob(parts, web.BlobPropertyBag(type: 'application/json'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
