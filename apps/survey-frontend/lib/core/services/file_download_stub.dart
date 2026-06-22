import 'dart:typed_data';

Future<void> saveTextDownload({
  required String fileName,
  required String content,
}) {
  final _ = (fileName, content);

  return Future.value();
}

Future<void> saveBytesDownload({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
}) {
  final _ = (fileName, bytes, mimeType);

  return Future.value();
}
