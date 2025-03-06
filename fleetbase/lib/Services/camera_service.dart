import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<Uint8List?> takePicture() async {
  try {
    final cameras = await availableCameras(); // From camera plugin
    if (cameras.isEmpty) {
      throw Exception('No cameras found');
    }
    
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    
    return image != null ? await File(image.path).readAsBytes() : null;
  } on CameraException catch (e) {
    print("Camera error: ${e.description}");
    return null;
  }
}
}