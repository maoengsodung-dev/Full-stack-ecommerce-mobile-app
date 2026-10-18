import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    return await _picker.pickImage(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  Future<List<XFile>> pickMultiImage({
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    return await _picker.pickMultiImage(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }
}
