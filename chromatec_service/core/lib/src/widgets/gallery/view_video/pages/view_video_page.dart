import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ViewVideoPage extends StatefulWidget {
  final Upload upload;

  ViewVideoPage(this.upload);

  @override
  State<StatefulWidget> createState() => ViewVideoPageState();
}

class ViewVideoPageState extends State<ViewVideoPage> {
  VideoPlayerController _videoPlayerController;
  Future<void> _initializeVideoPlayerFuture;
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    var upload = this.widget.upload;
    if (upload is UrlUpload) {
      _videoPlayerController = VideoPlayerController.network(upload.upload);
    } else {
      _videoPlayerController = VideoPlayerController.file(upload.upload);
    }
    _initializeVideoPlayerFuture = _videoPlayerController.initialize().then((value) {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        looping: true
      );
      setState(() {   
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if ((snapshot.connectionState == ConnectionState.done)
              && (_chewieController != null) 
              && (_chewieController.videoPlayerController.value.isInitialized)) {
                return Chewie(
                  controller: _chewieController,
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }              
          }
        )      
      ),
      backgroundColor: Colors.black,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
  }
}