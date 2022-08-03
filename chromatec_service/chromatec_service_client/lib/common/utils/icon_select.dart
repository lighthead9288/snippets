import 'package:core/core.dart';
import 'package:flutter/material.dart';

Widget getUploadStatusView(Upload upload) {
    switch (upload.status) {
      case UploadStatus.Loaded:
        return Icon(
          Icons.cloud_done,
          color: Colors.green,
        );
      case UploadStatus.None:
        return Icon(Icons.cloud_done);
      case UploadStatus.Loading:
        return Container(
          padding: EdgeInsets.only(right: 1),          
          height: 16,
          width: 16,
          child: CircularProgressIndicator()
        );
      case UploadStatus.Failed:
        return Icon(
          Icons.error,
          color: Colors.red
        );
      case UploadStatus.Cancelled:
        return Icon(Icons.cancel_outlined);
    }
  }