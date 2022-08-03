import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class ChangeMessageUploadsListUseCase {
  final RequestsRepository repository;

  ChangeMessageUploadsListUseCase({@required this.repository});

  Future<void> call(String requestId, String messageId, String url, FileUpload upload, UploadStatus status) async {
    return await repository.changeMessageUploadsList(requestId, messageId, url, upload.name, upload.id, upload.size, status);
  }
}