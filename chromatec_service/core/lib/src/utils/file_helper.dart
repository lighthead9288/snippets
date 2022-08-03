import 'dart:io';
import 'dart:math';

import 'package:core/core.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;


import 'package:permission_handler/permission_handler.dart';

class FileHelper {
  static void openFileFromLocal(String path, void onError(String errorMessage)) async {
    try {
      var result = await OpenFile.open(path);
      if (result.type == ResultType.noAppToOpen) {
        onError(result.message);
      }
    } catch(e) {
    }  
  }

  static Future<Directory> getExtStorageDirectory() async {
    if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    }
    Directory dir;
    var permissionStatus = await PermissionService.instance.askExtDataWritePermissions();
    if (permissionStatus == PermissionStatus.granted) {
      dir = await getExternalStorageDirectory();
      var androidString = "/Android";
      var index = dir.path.indexOf(androidString);
      var path = dir.path.replaceRange(index, index + androidString.length, '');
      
      var resultDir = Directory(path);
      if (!resultDir.existsSync()) {
        await resultDir.create(recursive: true);
      }
      return resultDir;    
    }  
    return dir;
  }

  static bool isUploadExistInDirectory(Upload upload, Directory downloadsDir) {
    var path = buildUploadPath(upload, downloadsDir);
    File file = File(path);
    return file.existsSync();
  }

  static String buildUploadPath(Upload upload, Directory downloadsDir) {
    var name = path.basenameWithoutExtension(upload.name);
    var ext = path.extension(upload.name);
    var id = upload.id;
    return '${downloadsDir.path}/${name}_$id$ext';
  }

  static Future<String> getDownloadingPath(Upload upload) async {
  // Directory dir = await getApplicationDocumentsDirectory();
    Directory dir = await getExtStorageDirectory();
    return buildUploadPath(upload, dir);
  }

  static Future<String> getLibraryDocumentDownloadingPath(String documentName, String locale) async {
    Directory dir = await getExtStorageDirectory();
    var libPath = "${dir.path}/library/docs/$locale";
    var libDir = Directory(libPath);
    if (!libDir.existsSync()) {
      libDir.createSync(recursive: true);
    }
    return '${libDir.path}/$documentName.html';
  }

  static String getFileSizeString(File file) {
    var sizeInBytes = file.lengthSync();
    if (sizeInBytes < 1024) {
      return "${sizeInBytes.toStringAsPrecision(4)} Bytes";
    } else if ((sizeInBytes >= pow(2, 10)) && (sizeInBytes < pow(2, 20))) {
      return "${(sizeInBytes / (pow(2, 10))).toStringAsPrecision(4)} KB";
    } else if ((sizeInBytes >= pow(2, 20)) && (sizeInBytes < pow(2, 30))) {
      return "${(sizeInBytes / (pow(2, 20))).toStringAsPrecision(4)} MB";
    } else {
      return "Too big size of file";
    }
  }
}

