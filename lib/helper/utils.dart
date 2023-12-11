import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Utils {
  static Future<File?> pickMedia({
    required bool isGallery,
    Future<File?> Function(File file)? cropImage,
  }) async {
    try {
      final ImageSource source =
          isGallery ? ImageSource.gallery : ImageSource.camera;
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: source,
      );

      if (pickedFile == null) return null;

      if (cropImage == null) {
        return File(pickedFile.path);
      } else {
        final File file = File(pickedFile.path);

        return cropImage(file);
      }
    } catch (e) {
      print("error: " + e.toString());
    }
  }
}
