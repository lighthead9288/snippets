import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:media_picker/media_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class MediaService {
  static MediaService instance = MediaService();

  Future<PickedFile> getImage() {
    return ImagePicker().getImage(source: ImageSource.gallery);
  }

  Future<PickedFile> getVideo() {
    return ImagePicker().getVideo(source: ImageSource.gallery);
  }

  Future<PickedFile> makePhoto() {
    return ImagePicker().getImage(source: ImageSource.camera);
  }

  Future<PickedFile> makeVideo() {
    return ImagePicker().getVideo(source: ImageSource.camera);
  }

  Future<List<Asset>> getMultipleImages() async {
    return await MultiImagePicker.pickImages(
      maxImages: 100,
      enableCamera: true
    );
  }

  Future<List<String>> getMultipleVideos() async {
    return await MediaPicker.pickVideos(quantity: 7);
    
  }

  Future<FilePickerResult> getMultipleFiles() async {
    return await FilePicker.platform.pickFiles(allowMultiple: true);    
  }
}