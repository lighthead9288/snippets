import 'dart:io';
import 'package:core/core.dart';
import 'package:core/src/services/cloud_storage_service.dart';
import 'package:core/src/utils/image_helpers.dart';
import 'package:core/src/widgets/gallery/uploads_gallery/presentation/state/uploads_gallery_provider.dart';
import 'package:core/src/widgets/gallery/view_video/pages/view_video_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';

class UploadsGalleryPage extends StatefulWidget {
  List<Upload> uploads;

  UploadsGalleryPage(List<Upload> _uploads) {
    uploads = _uploads;
  }

  @override
  State<StatefulWidget> createState() => UploadsGalleryPageState();
}

class UploadsGalleryPageState extends State<UploadsGalleryPage> {
  double _deviceHeight;
  double _deviceWidth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    var uploads = this.widget.uploads;
    SnackBarService.instance.buildContext = context;
    return Scaffold(
      appBar: AppBar(
          title: Text(S.of(context).uploads, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white)),
      body: ChangeNotifierProvider(
        create: (_) => UploadsGalleryProvider(cloudStorageService: CloudStorageService.instance),
        child: Consumer<UploadsGalleryProvider>(
          builder: (_, provider, __) {
            return FutureBuilder<Directory>(
              future: provider.getExternalStorageDirectory(),
              builder: (BuildContext _context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Swiper(
                      itemCount: uploads.length,
                      itemBuilder: (BuildContext _context, index) {
                        var upload = uploads[index];
                        return Stack(
                          fit: StackFit.passthrough,
                          children: [
                            Container(
                              child: _getContent(upload),
                            ),
                            Positioned.fill(
                                bottom: _deviceHeight * 0.12,
                                child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                        color: Colors.grey[800],
                                        child: Text(
                                          upload.name,
                                          style: TextStyle(color: Colors.white),
                                        )))),
                            Positioned(
                                top: _deviceHeight * 0.05,
                                right: 0,
                               child: _getUploadAdditionalIcons(upload, provider),
                            ),
                            provider.isDownloading
                                ? StreamBuilder<double>(
                                    initialData: 0,
                                    stream: provider.downloadingStream,
                                    builder: (context, snapshot) {
                                      return Positioned(
                                          bottom: _deviceHeight * 0.08,
                                          child: Container(
                                              alignment: Alignment.center,
                                              height: 3,
                                              width: _deviceWidth,
                                              child: LinearProgressIndicator(
                                                value: provider.downloadingPercent,
                                                backgroundColor: Colors.green,
                                              )));
                                  }
                                )
                                : Container()
                          ],
                        );
                      },
                      // pagination: SwiperPagination(),
                      control: SwiperControl());
                } else {
                  return Center(child: CircularProgressIndicator());
                }
                  
                }
              );
          }
        )
      ),
      
      
      backgroundColor: Colors.black,
    );
  }

  Widget _getContent(Upload upload) {
    if (upload.type == UploadType.Video) {
      return ViewVideoPage(upload);
    } else {
      return ImageHelper.getImageByUploadType(upload, boxFit: BoxFit.fitWidth);
    }
  }

  Widget _getUploadAdditionalIcons(Upload upload, UploadsGalleryProvider provider) {
    var state = provider.getUploadState(upload);
    var downloadingStartedLabel = S.of(context).downloadingwasStarted;
    var downloadingFinishedLabel = S.of(context).fileWasSavedTo;
    switch(state) {
      case UploadExistingInDirectoryState.UrlUploadExists:
        return IconButton(
              icon: Icon(Icons.open_in_new, color: Colors.green),
              onPressed: () {
                provider.onUrlUploadExistsClick(upload, (errorMessage) { 
                  _onFileOpeningError(errorMessage);
                });
              },
            );
      case UploadExistingInDirectoryState.UrlUploadNotExists:
        return IconButton(
              icon: Icon(Icons.download_rounded, color: Colors.white),
              onPressed: () async {
               provider.onUrlUploadNotExistsClick(upload, () {
                 WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    SnackBarService.instance.showSnackBarInfo(downloadingStartedLabel);
                 });
               }, (path) {
                 WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    SnackBarService.instance.showSnackBarInfo("$downloadingFinishedLabel $path");
                 });
               }, (errorMessage) {
                 _onFileOpeningError(errorMessage);
               });
              },
            );
      case UploadExistingInDirectoryState.FileUpload:
        return IconButton(
                icon: Icon(Icons.open_in_new, color: Colors.white),
                onPressed: () {
                  provider.onFileUploadClick(upload, (errorMessage) { 
                    _onFileOpeningError(errorMessage);
                  });
                },
              );
      case UploadExistingInDirectoryState.FileUploadPhotoOrVideo:
        return Container();
      default: return Container();
    }
  }

  void _onFileOpeningError(String message) {
    SnackBarService.instance.showSnackBarInfo(message);
  }
}
