import 'package:chromatec_admin/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:chromatec_admin/features/admin/domain/entities/project.dart';
import 'package:chromatec_admin/features/admin/domain/repository/admin_repository.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class AdminRepositoryImpl extends AdminRepository {
  final AdminRemoteDatasource remoteDatasource;

  AdminRepositoryImpl({@required this.remoteDatasource});

  @override
  Future<List<User>> getUsers() {
    return remoteDatasource.getUsers();
  }

  @override
  Future<List<User>> getEmployee() {
    return remoteDatasource.getEmployee();
  }

  @override
  Future<void> changeUserRole(String userId, String role) {
    return remoteDatasource.changeUserRole(userId, role);
  }

  @override
  Future<bool> deleteUser(String userId) {
    return remoteDatasource.deleteUser(userId);
  }

  @override
  Future<bool> createUser(String email, String password, String name, String surname, String role) {
    return remoteDatasource.createUser(email, password, name, surname, role);
  }

  @override
  Future<List<Project>> getProjects() {
    return remoteDatasource.getProjects();
  }

  @override
  Future<void> updateResponsibilitiesMembersList(String projectId, List<String> members) {
    return remoteDatasource.updateResponsibilitiesMembersList(projectId, members);
  }

  @override
  Future<List<RegistrationRequest>> getRegistrationRequests() {
    return remoteDatasource.getRegistrationRequests();
  }

  @override
  Future<void> changeRegistrationRequestStatus(String id, RegistrationRequestStatus status) {
    return remoteDatasource.changeRegistrationRequestStatus(id, status);
  } 
}