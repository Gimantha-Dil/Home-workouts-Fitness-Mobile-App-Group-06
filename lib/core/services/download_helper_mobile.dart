import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> saveAndDownloadFile({
  required List<int> bytes,
  required String fileName,
  required String mimeType,
}) async {
  Directory? dir;
  if (Platform.isAndroid) {
    dir = Directory('/storage/emulated/0/Download');
    if (!await dir.exists()) {
      dir = await getExternalStorageDirectory();
    }
  } else {
    dir = await getApplicationDocumentsDirectory();
  }

  if (dir != null) {
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
  }
}
