import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

class ImageHelper {
  static Image getImageByUploadType(Upload _upload, {BoxFit boxFit = BoxFit.contain}) {
    if (_upload is FileUpload) {
      var _uploadType = getUploadTypeByPath(_upload.upload.path);
      switch (_uploadType) {
        case UploadType.Image:
          return Image.file(_upload.upload, fit: boxFit);
        case UploadType.Video:
          return Image.asset('assets/video.png', fit: boxFit);
        case UploadType.File:
          return Image.asset('assets/file.png', fit: boxFit);
      }
    } else if (_upload is UrlUpload) {
        switch (_upload.type) {
          case UploadType.Image:
            return Image.network(
              _upload.upload, 
              fit: boxFit,
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  child: Image.asset('assets/image_placeholder.png')
                );
              },
            );
          case UploadType.Video:
            return Image.asset('assets/video.png', fit: boxFit);
          case UploadType.File:
            return Image.asset('assets/file.png', fit: boxFit);
        }
    }
}

  static UploadType getUploadTypeByPath(String filePath) {
    final mime = lookupMimeType(filePath);
    if (mime != null) {
      if (mime.startsWith('image/')) {
        return UploadType.Image;
      } else if (mime.startsWith('video/')) {
          return UploadType.Video;
      } else {
          return UploadType.File;
        }
    } else {
        return UploadType.File;
      }
  }
}

