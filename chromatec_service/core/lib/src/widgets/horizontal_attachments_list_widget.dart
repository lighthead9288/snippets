import 'dart:io';

import 'package:core/core.dart';
import 'package:core/src/utils/image_helpers.dart';
import 'package:core/src/utils/uploads_helper.dart';
import 'package:core/src/widgets/gallery/uploads_gallery/presentation/pages/uploads_gallery_page.dart';
import 'package:flutter/material.dart';

class HorizontalAttachmentsListWidget extends StatelessWidget {  
  final List<Upload> uploads;
  final Function(int index) onRemove;

  HorizontalAttachmentsListWidget({@required this.uploads, this.onRemove});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: uploads.length,
        itemBuilder: (BuildContext _context, index) {
          return Stack(
            children: [
              Container(
                  padding: EdgeInsets.only(right: 5, left: 5, top: 5, bottom: 5),
                  child: SizedBox(
                      height: 100,
                      width: 100,
                      child: GestureDetector(
                        child: ImageHelper.getImageByUploadType(uploads[index]),
                        onTap: () {
                          if (Platform.isWindows) {
                            UrlHelper.launchUrl(uploads[index].upload);
                          } else {
                             var uploadsForView = UploadsHelper.getUploadsListForView(uploads, index);
                              NavigationService.instance
                                .navigateToRoute(
                                  MaterialPageRoute(
                                    builder: (context) => UploadsGalleryPage(uploadsForView),
                                  )
                            );
                          }
                         
                        },
                      ))),
              Positioned(
                  bottom: 5,
                  left: 8,
                  child: Container(
                      color: Colors.grey[800],
                      child: Text(
                        TextHelper.cutText(uploads[index].name, 11),
                        style: TextStyle(color: Colors.white),
                      ))),
              (onRemove != null) 
                ? Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      decoration: ShapeDecoration(
                        color: Colors.white, shape: CircleBorder()
                      ),
                      child: GestureDetector(
                        child: Icon(Icons.cancel, color: Colors.grey[800]),
                        onTap: () async {
                          await onRemove(index);
                        },
                      )
                    )
                  )
                : Container()
            ],
          );
        });
  }

}