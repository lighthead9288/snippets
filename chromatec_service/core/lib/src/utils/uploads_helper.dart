import 'package:core/core.dart';

class UploadsHelper {
  static List<Upload> getUploadsListForView(List<Upload> _uploads, int _index) {
    var resList = <Upload>[];
    for(var i=_index; i<_uploads.length; i++) {
      resList.add(_uploads[i]);
    }
    for(var i=0;i<_index;i++) {
      resList.add(_uploads[i]);
    }
    return resList;
  }
}

