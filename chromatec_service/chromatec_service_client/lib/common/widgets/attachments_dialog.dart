import 'package:chromatec_service/common/interfaces/pick_uploads_provider.dart';
import 'package:chromatec_service/features/requests/presentation/dialog/state/dialog_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class AttachmentsDialog extends StatefulWidget {
  final PickUploadsProvider provider;

  AttachmentsDialog({@required this.provider});

  @override
  _AttachmentsDialogState createState() => _AttachmentsDialogState();
}

class _AttachmentsDialogState extends State<AttachmentsDialog> {
  double _deviceHeight;
  double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return _attachmentsDialogUI();
  }

  Widget _attachmentsDialogUI() {
    return Builder(
      builder: (BuildContext _context) {
        var provider = this.widget.provider;
        return Dialog(
          child: Container(
              height: _deviceHeight * 0.45,
              width: _deviceWidth * 0.3,
              padding: EdgeInsets.only(top: 15, left: 25),
              child: Column(children: [
                ListTile(
                  leading: Icon(Icons.photo),
                  title: Text(S.of(context).pickPhoto),
                  onTap: () async {
                    NavigationService.instance.goBack();
                    provider.onPickPhotos();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.video_collection),
                  title: Text(S.of(context).pickVideo),
                  onTap: () async {
                    NavigationService.instance.goBack();
                    provider.onPickVideos();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.file_present),
                  title: Text(S.of(context).pickFile),
                  onTap: () async {
                    NavigationService.instance.goBack();
                    provider.onPickFiles();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera),
                  title: Text(S.of(context).makePhoto),
                  onTap: () async {
                    NavigationService.instance.goBack();
                    provider.onMakePhoto();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.videocam),
                  title: Text(S.of(context).makeVideo),
                  onTap: () async {
                    NavigationService.instance.goBack();
                    provider.onMakeVideo();
                  },
                ),
              ]
            )
          ),
        );
      },
    );
  }
}
