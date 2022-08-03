import 'package:chromatec_service/common/models/data_status.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:equatable/equatable.dart';

class UserRequestsResponse extends Equatable {
  final DataStatus status;
  List<UserRequest> requests = <UserRequest>[];

  UserRequestsResponse(this.status, {this.requests});

  @override
  List<Object> get props => [ status, requests ];
}