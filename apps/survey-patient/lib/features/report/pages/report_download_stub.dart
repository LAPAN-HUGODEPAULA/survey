Future<String> saveBrowserFile({
  required String fileName,
  required String content,
  required String mimeType,
}) async {
  throw UnsupportedError(
    'Browser downloads are available only on Flutter Web.',
  );
}

Future<void> saveBrowserLocalStorage({
  required String key,
  required String value,
}) async {
  throw UnsupportedError(
    'Browser local storage is available only on Flutter Web.',
  );
}

Future<void> printBrowserPage() async {
  throw UnsupportedError('Browser printing is available only on Flutter Web.');
}
