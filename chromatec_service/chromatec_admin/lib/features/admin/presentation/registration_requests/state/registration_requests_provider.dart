import 'package:chromatec_admin/features/admin/domain/usecases/change_registration_request_status.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/create_user.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/get_registration_requests.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:enum_to_string/enum_to_string.dart';

class RegistrationRequestsProvider extends ChangeNotifier {
  final GetRegistrationRequestsUsecase getRegistrationRequestsUsecase;
  final ChangeRegistrationRequestStatusUsecase changeRegistrationRequestStatusUsecase;
  final CreateUserUseCase createUserUseCase;

  String password = "";

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String role = "user";

  RegistrationRequestsProvider({
    @required this.getRegistrationRequestsUsecase, 
    @required this.changeRegistrationRequestStatusUsecase,
    @required this.createUserUseCase
  });

  Future<List<RegistrationRequest>> getRequests() async {
    var requests = await getRegistrationRequestsUsecase();
    requests.sort((a, b) => EnumToString.convertToString(b.status).compareTo(EnumToString.convertToString(a.status)));
    return requests;
  }

  Future<void> onRejectRequest(String id) async {
    isLoading = true;
    await changeRegistrationRequestStatusUsecase(id, RegistrationRequestStatus.Rejected);
    isLoading = false;
  }

  Future<void> onConfirmRequest(RegistrationRequest request, Future<void> Function() onSuccess, Future<void> Function() onError) async {
    isLoading = true;

    var result = await createUserUseCase(request.email, password, request.name, request.surname, role);
    if (result) {
      await changeRegistrationRequestStatusUsecase(request.id, RegistrationRequestStatus.Confirmed);
      onSuccess();
    } else {
      onError();
    }

    isLoading = false;
    
  }
}