import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

class ChangeRequestUploadsListUseCase {
  final RequestsRepository repository;

  ChangeRequestUploadsListUseCase({@required this.repository});

  Future<void> call(String requestId, String url, String uploadId, String uploadName, String uploadSize, UploadStatus uploadStatus) async {
    return await repository.changeRequestUploadsList(requestId, url, uploadId, uploadName, uploadSize, uploadStatus);
  }

}