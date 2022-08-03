import 'dart:io';
import 'package:chromatec_service/common/converters/file_converters.dart';
import 'package:chromatec_service/services/media_service.dart';
import 'package:core/core.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path/path.dart' as path;

class PickUploadsManager {

  Future<FileUpload> makePhoto() async {
    var pickedPhoto = await MediaService.instance.makePhoto();
    var file = File(pickedPhoto.path);
    return FileUpload(
        pickedPhoto.hashCode.toString(),
        file,
        path.basename(pickedPhoto.path),
        FileHelper.getFileSizeString(file),
        UploadStatus.None,
        UploadType.Image);
  }

  Future<FileUpload> makeVideo() async {
    var pickedVideo = await MediaService.instance.makeVideo();
    var file = File(pickedVideo.path);
    return FileUpload(
        pickedVideo.hashCode.toString(),
        file,
        path.basename(pickedVideo.path),
        FileHelper.getFileSizeString(file),
        UploadStatus.None,
        UploadType.Video);
  }

  Future<List<FileUpload>> pickFiles() async {
    var filePickerResult = await MediaService.instance.getMultipleFiles();
    var newFiles = FileConverters.fromFilePickerResultToFileList(filePickerResult);
    return newFiles.map((file) => FileUpload(
        file.path.hashCode.toString(),
        file,
        path.basename(file.path),
        FileHelper.getFileSizeString(file),
        UploadStatus.None,
        ImageHelper.getUploadTypeByPath(file.path)
      )
    ).toList();
  }

  Future<List<FileUpload>> pickPhotos() async {
    List<FileUpload> uploads = <FileUpload>[];
    List<Asset> _imageAssets = await MediaService.instance.getMultipleImages(); 
    for (var _imageAsset in _imageAssets) {
      var file = await FileConverters.fromAssetToFile(_imageAsset);
      uploads.add(FileUpload(
          file.path.hashCode.toString(),
          file,
          path.basename(file.path),
          FileHelper.getFileSizeString(file),
          UploadStatus.None,
          UploadType.Image));
    }
    return uploads;
  }

  Future<FileUpload> pickVideo() async {
    var pickedVideo = await MediaService.instance.getVideo();
    var file = File(pickedVideo.path);
    return FileUpload(
        pickedVideo.path.hashCode.toString(),
        file,
        path.basename(pickedVideo.path),
        FileHelper.getFileSizeString(file),
        UploadStatus.None,
        UploadType.Video);
  }
}