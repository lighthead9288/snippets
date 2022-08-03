import 'package:chromatec_service/common/utils/icon_select.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

typedef AttachmentsListCallback = void Function(int index);

class VerticalAttachmentsList extends StatefulWidget {
  final List<Upload> uploads;
  final AttachmentsListCallback onRemove;

  VerticalAttachmentsList(this.uploads, {this.onRemove});

  @override
  _VerticalAttachmentsListState createState() => _VerticalAttachmentsListState();
}

class _VerticalAttachmentsListState extends State<VerticalAttachmentsList> {
  @override
  Widget build(BuildContext context) {
    var uploads = this.widget.uploads;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext _context, index) {
          if (uploads.length > 0) {
            return Container(
              padding: EdgeInsets.only(top: 2, bottom: 2),
              decoration: BoxDecoration(border: Border(bottom: BorderSide())),
              child: (widget.onRemove != null) 
                ? Dismissible(
                    key: UniqueKey(),
                    onDismissed: (direction) {
                      setState(() {
                        this.widget.onRemove(index);
                      });
                    },
                    background: GestureDetector(
                      child: Container(
                        child: Icon(Icons.delete),
                      ),
                    ),
                    child: _listTile(uploads, index)
                  )
                : _listTile(uploads, index, isReadonly: true)
            );
          } else {
            return Container();
          }
        },
        childCount: uploads.length,    
      )
    );
  }

  Widget _listTile(List<Upload> uploads, int index, {bool isReadonly = false}) {
    var upload = uploads[index];
    return ListTile(
      onTap: () {
        var uploadsForView = UploadsHelper.getUploadsListForView(uploads, index);
        NavigationService.instance.navigateToRoute(MaterialPageRoute(
          builder: (context) => UploadsGalleryPage(uploadsForView),
        ));
      },
      leading: Container(width: 50, height: 50, child: ImageHelper.getImageByUploadType(upload)),
      trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              getUploadStatusView(upload),
              (!isReadonly) 
                ? GestureDetector(
                    child: Icon(Icons.delete),
                    onTap: () {
                      setState(() {
                        this.widget.onRemove(index);
                      });
                    },
                  ) 
                : Container()
            ],
          ),
      title: (upload is FileUpload)
          ? Text(path.basename(upload.upload.path))
          : Text(upload.name),
      subtitle: (upload is FileUpload)
          ? Text(FileHelper.getFileSizeString(upload.upload))
          : Text(upload.size),
    );
  }
}
