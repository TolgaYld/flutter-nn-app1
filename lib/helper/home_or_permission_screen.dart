import 'package:permission_handler/permission_handler.dart';

Future<bool> checkPermission() async {
  bool _locationIsPermanentlyDenied =
      await Permission.location.isPermanentlyDenied;
  bool _locationIsRestricted = await Permission.location.isRestricted;
  bool _locationIsDenied = await Permission.location.isDenied;

  // bool _cameraIsPermanentlyDenied = await Permission.camera.isPermanentlyDenied;
  // bool _cameraIsRestricted = await Permission.camera.isRestricted;
  // bool _cameraIsDenied = await Permission.camera.isDenied;

  // bool _photoIsPermanentlyDenied = await Permission.photos.isDenied;
  // bool _photoIsRestricted = await Permission.photos.isRestricted;
  // bool _photoIsDenied = await Permission.photos.isDenied;

  if (_locationIsDenied ||
      _locationIsPermanentlyDenied ||
      _locationIsRestricted) {
    return false;
  }
  return true;
}
