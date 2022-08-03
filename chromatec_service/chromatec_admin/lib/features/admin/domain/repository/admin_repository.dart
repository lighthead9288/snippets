import 'package:chromatec_admin/features/admin/domain/entities/project.dart';
import 'package:core/core.dart';

abstract class AdminRepository {
  Future<List<User>> getUsers();
  Future<List<User>> getEmployee();
  Future<List<Project>> getProjects();
  Future<List<RegistrationRequest>> getRegistrationRequests();
  Future<void> changeRegistrationRequestStatus(String id, RegistrationRequestStatus status);
  Future<void> updateResponsibilitiesMembersList(String projectId, List<String> members);
  Future<void> changeUserRole(String userId, String role);
  Future<bool> deleteUser(String userId);
  Future<bool> createUser(String email, String password, String name, String surname, String role);
}