import 'download_helper_stub.dart'
if (dart.library.html) 'download_helper_web.dart'
if (dart.library.io) 'download_helper_mobile.dart';

class DownloadHelper {
  static Future<void> downloadFile({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
  }) {
    return saveAndDownloadFile(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
    );
  }
}
