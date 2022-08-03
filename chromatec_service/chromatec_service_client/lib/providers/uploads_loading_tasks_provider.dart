import 'package:core/core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class TasksProvider extends ChangeNotifier {
  static TasksProvider instance = TasksProvider();
  List<UploadTask> tasks = <UploadTask>[];

  void createTaskListByUploads(List<Upload> uploads, String userId, void onTaskFinish(String url, Upload upload)) {
    for (var upload in uploads) {
      final mime = lookupMimeType(upload.upload.path);
      UploadTask task;
      if (mime.startsWith('image/')) {
        task = CloudStorageService.instance.uploadUserImage(userId, upload.upload);        
      } else if (mime.startsWith('video/')) {
        task = CloudStorageService.instance.uploadUserVideo(userId, upload.upload);        
      } else {
        task = CloudStorageService.instance.uploadUserFile(userId, upload.upload);       
      }
      task
        ..snapshotEvents.listen((event) {
            print('Upload: ${path.basename(upload.upload.path)}');
            print('Uploading state: ${event.state}');
            print('Progress: ${(event.bytesTransferred / event.totalBytes) * 100} %');
          })
        ..then((snapshot) async {
            var url = await snapshot.ref.getDownloadURL();
            onTaskFinish(url, upload);
            tasks.remove(task);
            Future.delayed(const Duration(seconds: 5), () => notifyListeners());
            print('Tasks length: ${tasks.length}');
          })
        ..catchError((e) {
            print('Upload: ${path.basename(upload.upload.path)} uploading error');
          });
      tasks.add(task);
      notifyListeners();
    }
    notifyListeners();
  }
}