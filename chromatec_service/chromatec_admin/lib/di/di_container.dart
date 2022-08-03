import 'dart:io';

import 'package:chromatec_admin/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:chromatec_admin/features/admin/data/repository/admin_repository_impl.dart';
import 'package:chromatec_admin/features/admin/domain/repository/admin_repository.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/change_registration_request_status.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/change_user_role.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/create_user.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/delete_user.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/get_employee.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/get_projects.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/get_registration_requests.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/get_users.dart';
import 'package:chromatec_admin/features/admin/domain/usecases/update_responsibility_members_list.dart';
import 'package:chromatec_admin/features/admin/presentation/add_employee_to_responsibilities_list/state/add_employee_to_responsibilities_list_provider.dart';
import 'package:chromatec_admin/features/admin/presentation/create_user/state/create_user_page_provider.dart';
import 'package:chromatec_admin/features/admin/presentation/edit_user_info/state/edit_user_provider.dart';
import 'package:chromatec_admin/features/admin/presentation/projects/state/projects_provider.dart';
import 'package:chromatec_admin/features/admin/presentation/registration_requests/state/registration_requests_provider.dart';
import 'package:chromatec_admin/features/admin/presentation/users_list/state/users_list_provider.dart';
import 'package:chromatec_admin/widgets/android/android_controls.dart';
import 'package:chromatec_admin/widgets/widgets_factory.dart';
import 'package:chromatec_admin/widgets/windows/windows_controls.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:core/core.dart';
import 'package:firedart/firestore/firestore.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // UI factory
  if (Platform.isWindows) {
    sl.registerFactory<IWidgetsFactory>(() => WindowsControlsFactory());
  } else {
    sl.registerFactory<IWidgetsFactory>(() => AndroidControlsFactory());
  }

  // Presentation
  sl.registerFactory(() => UsersListProvider(getUsersUseCase: sl()));
  sl.registerFactory(() => CreateUserPageProvider(createUserUseCase: sl()));
  sl.registerFactory(() => EditUserProvider(changeUserRoleUseCase: sl(), deleteUserUseCase: sl()));
  sl.registerFactory(() => ProjectsProvider(getProjectsUsecase: sl()));
  sl.registerFactory(() => AddEmployeeToResponsibilitiesListProvider(getEmployeeUsecase: sl(), updateResponsibilityMembersListUsecase: sl()));
  sl.registerFactory(() => RegistrationRequestsProvider(
    getRegistrationRequestsUsecase: sl(), 
    changeRegistrationRequestStatusUsecase: sl(),
    createUserUseCase: sl()
  ));

  // Domain
  sl.registerLazySingleton(() => GetUsersUseCase(repository: sl()));
  sl.registerLazySingleton(() => ChangeUserRoleUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteUserUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateUserUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetProjectsUsecase(repository: sl()));
  sl.registerLazySingleton(() => GetEmployeeUsecase(repository: sl()));
  sl.registerLazySingleton(() => UpdateResponsibilityMembersListUsecase(repository: sl()));
  sl.registerLazySingleton(() => GetRegistrationRequestsUsecase(repository: sl()));
  sl.registerLazySingleton(() => ChangeRegistrationRequestStatusUsecase(repository: sl()));

  // Data  
  // Repository
  sl.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(remoteDatasource: sl()));

  if (Platform.isWindows) {
    // Datasource
    sl.registerLazySingleton<AdminRemoteDatasource>(() => AdminRemoteDesktopDatasource(db: sl()));
    // Services
    final firestoreInstance = Firestore.instance;
    sl.registerLazySingleton(() => firestoreInstance);
  } else {
    // Datasource
    sl.registerLazySingleton<AdminRemoteDatasource>(() => AdminFirebaseDatasource(db: sl(), instance: sl()));
    // Services
    final firestoreInstance = FirebaseFirestore.instance;
    final firebaseFunctionsInstance = FirebaseFunctions.instance;
    sl.registerLazySingleton(() => firestoreInstance);
    sl.registerLazySingleton(() => firebaseFunctionsInstance);
  }

  
}