import 'package:chromatec_service/common/models/bookmark_holder.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_requests_response.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:flutter/widgets.dart';

class GetUserRequestsUseCase {
  final RequestsRepository repository;

  GetUserRequestsUseCase({@required this.repository});

  Stream<UserRequestsResponse> call(String userId, RequestsFilter filter, int limit, BookmarkHolder holder) => repository.getUserRequests(userId, filter, limit, holder);
}