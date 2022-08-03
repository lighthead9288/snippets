import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class FileConverters {
  static Future<File> fromAssetToFile(Asset asset) async {
    final _filePath = await FlutterAbsolutePath.getAbsolutePath(asset.identifier);
    return File(_filePath);
}

static List<File> fromFilePickerResultToFileList(FilePickerResult _result) {
  List<File> _fileList = <File>[];
    if (_result!=null) {
      for(var _path in _result.paths) {
        _fileList.add(File(_path));
      }
    }
  return _fileList;
}
} 

