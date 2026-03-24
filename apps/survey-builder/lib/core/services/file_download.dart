import 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart';

void downloadTextFile(String filename, String content) {
  downloadTextFileImpl(filename, content);
}
