import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> takePicture() async {
  try {
    final cameras = await availableCameras(); // From camera plugin
    if (cameras.isEmpty) {
      throw Exception('No cameras found');
    }
    
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    
    return image != null ? File(image.path) : null;
  } on CameraException catch (e) {
    print("Camera error: ${e.description}");
    return null;
  }
}
}