import 'package:chromatec_service/common/interfaces/pick_uploads_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class PickUploadsWidget extends StatelessWidget {
  final PickUploadsProvider provider;

  PickUploadsWidget({@required this.provider});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      marginBottom: 50,
      animatedIcon: AnimatedIcons.menu_close,
      children: [
        SpeedDialChild(
            child: Icon(Icons.videocam),
            label: S.of(context).makeVideo,
            onTap: () {
              provider.onMakeVideo();
              
            }),
        SpeedDialChild(
            child: Icon(Icons.camera),
            label: S.of(context).makePhoto,
            onTap: () {
              provider.onMakePhoto();
            }),
        SpeedDialChild(
            child: Icon(Icons.file_present),
            label: S.of(context).pickFile,
            onTap: () async {
              provider.onPickFiles();
            }),
        SpeedDialChild(
            child: Icon(Icons.video_collection),
            label: S.of(context).pickVideo,
            onTap: () {
              provider.onPickVideos();
            }),
        SpeedDialChild(
            child: Icon(Icons.photo),
            label: S.of(context).pickPhoto,
            onTap: () async {
              provider.onPickPhotos();
            }),
      ],
    );
  }
}
