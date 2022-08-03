import 'package:chromatec_service/features/requests/presentation/dialog/state/dialog_provider.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class HorizontalAttachmentsListWidget extends StatelessWidget {  
  final DialogProvider provider;

  HorizontalAttachmentsListWidget({@required this.provider});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.uploads.length,
        itemBuilder: (BuildContext _context, index) {
          return Stack(
            children: [
              Container(
                  padding: EdgeInsets.only(right: 5, left: 5, top: 5, bottom: 5),
                  child: SizedBox(
                      height: 100,
                      width: 100,
                      child: GestureDetector(
                        child: ImageHelper.getImageByUploadType(provider.uploads[index]),
                        onTap: () {
                          var uploadsForView = UploadsHelper.getUploadsListForView(provider.uploads, index);
                          NavigationService.instance
                            .navigateToRoute(
                              MaterialPageRoute(
                                builder: (context) => UploadsGalleryPage(uploadsForView),
                              )
                            );
                        },
                      ))),
              Positioned(
                  bottom: 5,
                  left: 8,
                  child: Container(
                      color: Colors.grey[800],
                      child: Text(
                        TextHelper.cutText(provider.uploads[index].name, 11),
                        style: TextStyle(color: Colors.white),
                      ))),
              Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                      decoration: ShapeDecoration(
                          color: Colors.white, shape: CircleBorder()),
                      child: GestureDetector(
                        child: Icon(Icons.cancel, color: Colors.grey[800]),
                        onTap: () async {
                          await provider.onRemoveUpload(index);
                        },
                      )))
            ],
          );
        });
  }

}