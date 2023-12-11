import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Enviroment {
  static String get fileName {
    if (kReleaseMode) {
      return '.env.production';
    }
    return '.env.development';
  }

  static String get baseUrl {
    return dotenv.get("BASE_URL");
  }

  static String get baseUrlWithoutApi {
    return dotenv.get("BASE_URL_WITHOUT_API");
  }

  static String get permissionKey {
    return dotenv.get("PERMISSION_KEY");
  }

  static String get imageApi {
    return dotenv.get("CLOUDINARY_IMAGE_API");
  }

  static String get videoApi {
    return dotenv.get("CLOUDINARY_VIDEO_API");
  }

  static String get cloudinaryApiKey {
    return dotenv.get("CLOUDINARY_API_KEY");
  }

  static String get cloudinaryApiSecret {
    return dotenv.get("CLOUDINARY_API_SECRET");
  }

  static String get cloudinaryCloudName {
    return dotenv.get("CLOUDINARY_CLOUD_NAME");
  }

  static String get cloudinaryUploadPreset {
    return dotenv.get("CLOUDINARY_UPLOAD_PRESET");
  }

  static String get googleApiKey {
    return dotenv.get("PLACES_API_KEY");
  }
}
