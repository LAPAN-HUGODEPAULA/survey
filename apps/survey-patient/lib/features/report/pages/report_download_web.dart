import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<String> saveBrowserFile({
  required String fileName,
  required String content,
  required String mimeType,
}) {
  final parts = <web.BlobPart>[content.toJS].toJS;
  final blob = web.Blob(parts, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';

  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);

  return Future.value('Download iniciado: $fileName');
}

Future<void> saveBrowserLocalStorage({
  required String key,
  required String value,
}) {
  web.window.localStorage.setItem(key, value);

  return Future.value();
}

Future<void> printBrowserPage() {
  web.window.print();

  return Future.value();
}
