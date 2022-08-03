import 'dart:async';
import 'dart:io';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class UploadsGalleryProvider extends ChangeNotifier {
  final CloudStorageService cloudStorageService;

  Directory extStorageDirectory;
  bool isDownloading = false;
  double downloadingPercent = 0;

  StreamController<double> _downloadingStreamController;
  Stream<double> downloadingStream;

  UploadsGalleryProvider({@required this.cloudStorageService}) {
    _downloadingStreamController = StreamController<double>();
    downloadingStream = _downloadingStreamController.stream;
  }

  Future<Directory> getExternalStorageDirectory() async {
    extStorageDirectory = await FileHelper.getExtStorageDirectory();
    return extStorageDirectory;
  }

  UploadExistingInDirectoryState getUploadState(Upload upload) {
    return (upload is UrlUpload)
        // launch after downloading from server         
        ? FileHelper.isUploadExistInDirectory(upload, extStorageDirectory)
          ? UploadExistingInDirectoryState.UrlUploadExists
          : UploadExistingInDirectoryState.UrlUploadNotExists
        // launch from local by path
        : (upload.type == UploadType.File)
            ? UploadExistingInDirectoryState.FileUpload
            : UploadExistingInDirectoryState.FileUploadPhotoOrVideo;
  }

  void onUrlUploadExistsClick(Upload upload, void onError(String errorMessage)) {
    var path = FileHelper.buildUploadPath(upload, extStorageDirectory);
    FileHelper.openFileFromLocal(path, (errorMessage) {
      onError(errorMessage);
    });
  }

  void onUrlUploadNotExistsClick(Upload upload, void onDownloadingStart(), void onDownloadingFinished(String path), onFileOpeningError(String errorMessage)) async {
    var uploadLocalPath = await FileHelper.getDownloadingPath(upload);
    onDownloadingStart();
    isDownloading = true;
    notifyListeners();
    await cloudStorageService.downloadFile(upload, uploadLocalPath,
        (count, total) {
      downloadingPercent = count / total;
      _downloadingStreamController.add(downloadingPercent);
    });
    onDownloadingFinished(uploadLocalPath);
    isDownloading = false;
    notifyListeners();
    if (upload.type == UploadType.File) {
      FileHelper.openFileFromLocal(uploadLocalPath, (errorMessage) {
        onFileOpeningError(errorMessage);
      });
    }
  }

  void onFileUploadClick(Upload upload, void onError(String errorMessage)) {
    FileHelper.openFileFromLocal(upload.upload.path, (_errorMessage) {
      onError(_errorMessage);
    });
  }
}

enum UploadExistingInDirectoryState {
  UrlUploadExists, 
  UrlUploadNotExists, 
  FileUpload, 
  FileUploadPhotoOrVideo
}