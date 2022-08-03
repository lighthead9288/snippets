import 'package:chromatec_service/features/account/domain/usecases/send_registration_request.dart';
import 'package:chromatec_service/features/account/presentation/register_request/state/register_request_provider.dart';
import 'package:chromatec_service/features/dealer_reports/domain/usecases/delete_dealer_report.dart';
import 'package:chromatec_service/features/requests/domain/usecases/delete_user_request.dart';
import 'package:chromatec_service/features/account/data/datasources/account_datasource.dart';
import 'package:chromatec_service/features/account/data/repository/account_repository_impl.dart';
import 'package:chromatec_service/features/account/domain/repository/account_repository.dart';
import 'package:chromatec_service/features/account/domain/usecases/login.dart';
import 'package:chromatec_service/features/account/domain/usecases/logout.dart';
import 'package:chromatec_service/features/account/domain/usecases/register.dart';
import 'package:chromatec_service/features/account/domain/usecases/update_last_seen_date.dart';
import 'package:chromatec_service/features/account/presentation/login/state/login_page_provider.dart';
import 'package:chromatec_service/features/account/presentation/register/state/register_page_provider.dart';
import 'package:chromatec_service/features/account/presentation/reset_password/state/reset_password_provider.dart';
import 'package:chromatec_service/features/catalog/data/datasources/catalog_remote_datasource.dart';
import 'package:chromatec_service/features/catalog/data/repository/catalog_repository_impl.dart';
import 'package:chromatec_service/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:chromatec_service/features/catalog/domain/usecases/load_product_categories.dart';
import 'package:chromatec_service/features/catalog/presentation/state/catalog_provider.dart';
import 'package:chromatec_service/features/contacts/presentation/state/contacts_page_provider.dart';
import 'package:chromatec_service/features/dealer_reports/data/datasources/dealer_reports_remote_datasource.dart';
import 'package:chromatec_service/features/dealer_reports/data/repositories/dealer_reports_repository_impl.dart';
import 'package:chromatec_service/features/dealer_reports/domain/repositories/dealer_reports_repository.dart';
import 'package:chromatec_service/features/dealer_reports/domain/usecases/change_dealer_report_uploads_list.dart';
import 'package:chromatec_service/features/dealer_reports/domain/usecases/create_dealer_report.dart';
import 'package:chromatec_service/features/dealer_reports/domain/usecases/get_all_dealer_reports.dart';
import 'package:chromatec_service/features/dealer_reports/domain/usecases/get_dealer_report_by_id.dart';
import 'package:chromatec_service/features/dealer_reports/domain/usecases/get_dealer_reports.dart';
import 'package:chromatec_service/features/dealer_reports/domain/usecases/update_dealer_report.dart';
import 'package:chromatec_service/features/dealer_reports/presentation/dealer_report_editor/state/dealer_report_editor_provider.dart';
import 'package:chromatec_service/features/dealer_reports/presentation/dealer_report_viewer/state/dealer_report_viewer_provider.dart';
import 'package:chromatec_service/features/dealer_reports/presentation/dealer_reports_list/state/dealer_reports_list_provider.dart';
import 'package:chromatec_service/features/home/presentation/state/home_page_provider.dart';
import 'package:chromatec_service/features/language/presentation/state/language_settings_provider.dart';
import 'package:chromatec_service/features/lessons/data/datasources/remote_lessons_datasource.dart';
import 'package:chromatec_service/features/lessons/data/repository/lessons_repository_impl.dart';
import 'package:chromatec_service/features/lessons/domain/repository/lessons_repository.dart';
import 'package:chromatec_service/features/lessons/domain/usecases/load_lessons.dart';
import 'package:chromatec_service/features/lessons/presentation/state/lessons_provider.dart';
import 'package:chromatec_service/features/library/data/datasources/local_navigator_based_library_datasource.dart';
import 'package:chromatec_service/features/library/data/datasources/remote_library_datasource.dart';
import 'package:chromatec_service/features/library/data/datasources/remote_navigator_based_library_datasource.dart';
import 'package:chromatec_service/features/library/data/repository/library_repository_impl.dart';
import 'package:chromatec_service/features/library/data/repository/navigator_based_library_repository_impl.dart';
import 'package:chromatec_service/features/library/domain/repository/library_repository.dart';
import 'package:chromatec_service/features/library/domain/repository/navigator_based_library_repository.dart';
import 'package:chromatec_service/features/library/domain/usecases/load_library_document.dart';
import 'package:chromatec_service/features/library/domain/usecases/load_library_items.dart';
import 'package:chromatec_service/features/library/domain/usecases/load_navigator_based_library_items.dart';
import 'package:chromatec_service/features/library/domain/usecases/search_library_documents.dart';
import 'package:chromatec_service/features/library/presentation/library_document/state/library_document_provider.dart';
import 'package:chromatec_service/features/library/presentation/library_menu/state/library_provider.dart';
import 'package:chromatec_service/features/library/presentation/library_search/state/library_search_provider.dart';
import 'package:chromatec_service/features/news/data/datasources/news_remote_datasource.dart';
import 'package:chromatec_service/features/news/data/repository/news_repository_impl.dart';
import 'package:chromatec_service/features/news/domain/repository/news_repository.dart';
import 'package:chromatec_service/features/news/domain/usecases/load_news.dart';
import 'package:chromatec_service/features/news/presentation/state/news_provider.dart';
import 'package:chromatec_service/features/profile/data/datasources/profile_datasource.dart';
import 'package:chromatec_service/features/profile/data/repository/profile_repository_impl.dart';
import 'package:chromatec_service/features/profile/domain/repository/profile_repository.dart';
import 'package:chromatec_service/features/profile/domain/usecases/update_user_email.dart';
import 'package:chromatec_service/features/profile/domain/usecases/update_user_info.dart';
import 'package:chromatec_service/features/profile/presentation/change_user_email/state/change_user_email_provider.dart';
import 'package:chromatec_service/features/profile/presentation/change_user_password/state/change_user_password_provider.dart';
import 'package:chromatec_service/features/profile/presentation/credentials_editor/state/credentials_edit_provider.dart';
import 'package:chromatec_service/features/profile/presentation/profile_editor/state/profile_provider.dart';
import 'package:chromatec_service/features/requests/data/datasources/requests_remote_datasource.dart';
import 'package:chromatec_service/features/requests/data/repositories/requests_repository_impl.dart';
import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:chromatec_service/features/requests/domain/usecases/add_dialog_members.dart';
import 'package:chromatec_service/features/requests/domain/usecases/add_message.dart';
import 'package:chromatec_service/features/requests/domain/usecases/change_message_uploads_list.dart';
import 'package:chromatec_service/features/requests/domain/usecases/change_request_uploads_list.dart';
import 'package:chromatec_service/features/requests/domain/usecases/create_user_request.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_dealers_list.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_dialog_data.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_dialog_members.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_responsible_users.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_user_request_by_id.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_user_requests.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_users_by_dialog_members_list.dart';
import 'package:chromatec_service/features/requests/domain/usecases/remove_dialog_member.dart';
import 'package:chromatec_service/features/requests/domain/usecases/update_user_request.dart';
import 'package:chromatec_service/features/requests/presentation/add_users_to_dialog/state/add_users_to_dialog_provider.dart';
import 'package:chromatec_service/features/requests/presentation/dialog/state/dialog_provider.dart';
import 'package:chromatec_service/features/requests/presentation/dialog_members/state/dialog_members_provider.dart';
import 'package:chromatec_service/features/requests/presentation/request_editor/state/request_editor_provider.dart';
import 'package:chromatec_service/features/requests/presentation/requests_list/state/requests_list_provider.dart';
import 'package:chromatec_service/features/requests/presentation/select_support/state/select_support_provider.dart';
import 'package:chromatec_service/features/software_activation/data/datasources/software_activation_datasource.dart';
import 'package:chromatec_service/features/software_activation/data/repositories/software_activation_repository_impl.dart';
import 'package:chromatec_service/features/software_activation/domain/repositories/software_activation_repository.dart';
import 'package:chromatec_service/features/software_activation/domain/usecases/activate_software_license.dart';
import 'package:chromatec_service/features/software_activation/presentation/state/software_activation_provider.dart';
import 'package:chromatec_service/providers/auth_provider.dart';
import 'package:chromatec_service/providers/uploads_loading_tasks_provider.dart';
import 'package:chromatec_service/services/media_service.dart';
import 'package:chromatec_service/services/messaging_service.dart';
import 'package:chromatec_service/services/network_connection_service.dart';
import 'package:chromatec_service/services/pick_uploads_manager.dart';
import 'package:core/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:get_it/get_it.dart';


final sl = GetIt.instance;

Future<void> init() async{
  //Presentation
  sl.registerFactory(() => RequestsListProvider(
    getUserRequestsUseCase: sl(), 
    auth: sl(), 
    getUserByIdUseCase: sl(),
    deleteUserRequestUsecase: sl()
  ));
  sl.registerFactory(() => RequestEditorProvider(
    getUserRequestByIdUseCase: sl(), 
    getUsersByDialogMembersListUseCase: sl(),
    createUserRequestUseCase: sl(), 
    updateUserRequestUseCase: sl(),
    changeRequestUploadsListUseCase: sl(),
    auth: sl(), 
    uploadsManager: sl(),
    tasksProvider: sl() 
  ));
  sl.registerFactory(() => DialogButtonProvider());
  sl.registerFactory(() => DialogProvider(
    auth: sl(), 
    tasksProvider: sl(), 
    uploadsManager: sl(), 
    getDialogDataUseCase: sl(), 
    addMessageUseCase: sl(),
    changeMessageUploadsListUseCase: sl(),
    getUserByIdUseCase: sl()
  ));
  sl.registerFactory(() => SelectSupportProvider(auth: sl(), getUserByIdUseCase: sl(), getDealersListUseCase: sl(), getResponsibleUsersUseCase: sl()));
  sl.registerFactory(() => DialogMembersProvider(auth: sl(), getUserByIdUseCase: sl(), getDialogMembersUseCase: sl(), removeDialogMemberUseCase: sl()));
  sl.registerFactory(() => AddUsersToDialogProvider(auth: sl(), getResponsibleUsersUseCase: sl(), addDialogMembersUseCase: sl()));
  sl.registerFactory(() => UploadsGalleryProvider(cloudStorageService: sl()));
  sl.registerFactory(() => DealerReportsListProvider(auth: sl(), getDealerReportsUseCase: sl(), getAllDealerReportsUsecase: sl(), deleteDealerReportUsecase: sl()));
  sl.registerFactory(() => DealerReportEditorProvider(auth: sl(), uploadsManager: sl(), tasksProvider: sl(), getUserByIdUseCase: sl(), 
    getDealerReportByIdUseCase: sl(), createDealerReportUseCase: sl(), updateDealerReportUseCase: sl(), changeDealerReportUploadsListUseCase: sl()));
  sl.registerFactory(() => DealerReportViewerProvider(getDealerReportByIdUseCase: sl()));
  sl.registerFactory(() => ContactsPageProvider(permissionService: sl()));
  sl.registerFactory(() => HomePageProvider(getUserByIdUseCase: sl(), logoutUseCase: sl(), updateLastSeenDateUseCase: sl(), auth: sl()));
  sl.registerFactory(() => SoftwareActivationProvider(activateSoftwareLicenseUseCase: sl()));
  sl.registerFactory(() => ProfileProvider(auth: sl(), getUserByIdUseCase: sl(), logoutUseCase: sl()));
  sl.registerFactory(() => CredentialsEditorProvider(auth: sl(), mediaService: sl(), cloudStorageService: sl(), getUserByIdUseCase: sl(), updateUserUseCase: sl()));
  sl.registerFactory(() => ChangeUserEmailProvider(auth: sl(), updateUserEmailUseCase: sl()));
  sl.registerFactory(() => ChangeUserPasswordProvider(auth: sl()));
  sl.registerFactory(() => ResetPasswordProvider(auth: sl()));
  sl.registerFactory(() => LanguageSettingsProvider());
  sl.registerFactory(() => LoginPageProvider(loginUseCase: sl()));
  sl.registerFactory(() => RegisterRequestProvider(sendRegistrationRequestUsecase: sl(), mediaService: sl(), uploadsManager: sl(), cloudStorageService: sl()));
  sl.registerFactory(() => CatalogProvider(loadProductCategoriesUseCase: sl()));
  sl.registerFactory(() => NewsProvider(loadNewsUseCase: sl()));
  sl.registerFactory(() => LessonsProvider(loadLessonsUsecase: sl()));
  sl.registerFactory(() => LibraryProvider(loadLibraryItemsUseCase: sl(), loadNavigatorBasedLibraryMenu: sl(), 
    cloudStorageService: sl(), networkConnectionService: sl(), searchLibraryDocumentsUsecase: sl()));
  sl.registerFactory(() => LibraryDocumentProvider(loadLibraryDocumentUseCase: sl(), networkConnectionService: sl()));
  sl.registerFactory(() => LibrarySearchProvider());

  //Domain
  sl.registerLazySingleton(() => GetUserRequestsUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetUserRequestByIdUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetUsersByDialogMembersListUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateUserRequestUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteUserRequestUsecase(repository: sl()));
  sl.registerLazySingleton(() => UpdateUserRequestUseCase(repository: sl()));
  sl.registerLazySingleton(() => ChangeRequestUploadsListUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetDialogDataUseCase(repository: sl()));
  sl.registerLazySingleton(() => AddMessageUseCase(repository: sl()));
  sl.registerLazySingleton(() => ChangeMessageUploadsListUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetDealersListUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetResponsibleUsersUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetDialogMembersUseCase(repository: sl()));
  sl.registerLazySingleton(() => RemoveDialogMemberUseCase(repository: sl()));
  sl.registerLazySingleton(() => AddDialogMembersUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetDealerReportsUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetAllDealerReportsUsecase(repository: sl()));
  sl.registerLazySingleton(() => GetDealerReportByIdUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateDealerReportUseCase(repository: sl()));
  sl.registerLazySingleton(() => DeleteDealerReportUsecase(repository: sl()));
  sl.registerLazySingleton(() => UpdateDealerReportUseCase(repository: sl()));
  sl.registerLazySingleton(() => ChangeDealerReportUploadsListUseCase(repository: sl()));
  sl.registerLazySingleton(() => ActivateSoftwareLicenseUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateUserEmailUseCase(repository: sl())); 
  sl.registerLazySingleton(() => LoadProductCategoriesUseCase(repository: sl())); 
  sl.registerLazySingleton(() => LoadNewsUseCase(repository: sl()));
  sl.registerLazySingleton(() => LoadLessonsUsecase(repository: sl()));
  sl.registerLazySingleton(() => LoadLibraryItemsUseCase(repository: sl()));
  sl.registerLazySingleton(() => LoginUseCase(repository: sl(), auth: sl(), messagingService: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(auth: sl(), repository: sl(), messagingService: sl(), cloudStorageService: sl()));
  sl.registerLazySingleton(() => SendRegistrationRequestUsecase(repository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(auth: sl(), repository: sl(), messagingService: sl()));
  sl.registerLazySingleton(() => UpdateLastSeenDateUseCase(repository: sl()));
  sl.registerLazySingleton(() => LoadNavigatorBasedLibraryMenuUseCase(repository: sl()));
  sl.registerLazySingleton(() => LoadLibraryDocumentUseCase(repository: sl()));
  sl.registerLazySingleton(() => SearchLibraryDocumentsUsecase(repository: sl()));

  //Data
  //Repository
  sl.registerLazySingleton<CommonRepository>(() => CommonRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<RequestsRepository>(() => RequestsRepositoryImpl(remoteDataSource: sl(),/* localDataSource: sl()*/));
  sl.registerLazySingleton<DealerReportsRepository>(() => DealerReportsRepositoryImpl(remoteDatasource: sl()));
  sl.registerLazySingleton<SoftwareActivationRepository>(() => SoftwareActivationRepositoryImpl(dataSource: sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(datasource: sl()));
  sl.registerLazySingleton<AccountRepository>(() => AccountRepositoryImpl(accountDatasource: sl()));
  sl.registerLazySingleton<CatalogRepository>(() => CatalogRepositoryImpl(remoteDatasource: sl()));
  sl.registerLazySingleton<NewsRepository>(() => NewsRepositoryImpl(remoteDatasource: sl()));
  sl.registerLazySingleton<LessonsRepository>(() => LessonsRepositoryImpl(remoteDatasource: sl()));
  sl.registerLazySingleton<LibraryRepository>(() => LibraryRepositoryImpl(remoteDatasource: sl()));
  sl.registerLazySingleton<NavigatorBasedLibraryRepository>(() => NavigatorBasedLibraryRepositoryImpl(remoteDatasource: sl(), localDatasource: sl(), 
    networkConnectionService: sl()));

  //DataSource
  sl.registerLazySingleton<CommonRemoteDataSource>(() => CommonFirebaseRemoteDataSource(db: sl()));
  sl.registerLazySingleton<RequestsRemoteDataSource>(() => RequestsFirebaseDataSource(db: sl()));
  sl.registerLazySingleton<DealerReportsRemoteDatasource>(() => DealerReportsFirebaseRemoteDatasource(db: sl()));
  sl.registerLazySingleton<SoftwareActivationDataSource>(() => SoftwareActivationDataSourceImpl(instance: sl()));
  sl.registerLazySingleton<ProfileDatasource>(() => ProfileFirebaseDatasource(db: sl()));
  sl.registerLazySingleton<AccountDatasource>(() => AccountFirebaseDatasource(db: sl(), messagingService: sl()));
  sl.registerLazySingleton<CatalogRemoteDatasource>(() => CatalogRemoteDatasourceImpl());
  sl.registerLazySingleton<NewsRemoteDatasource>(() => NewsRemoteDatasourceImpl());
  sl.registerLazySingleton<LessonsRemoteDatasource>(() => LessonsRemoteDatasourceImpl());
  sl.registerLazySingleton<LibraryRemoteDatasource>(() => LibraryRemoteDatasourceImpl());
  sl.registerLazySingleton<RemoteNavigatorBasedLibraryDatasource>(() => RemoteNavigatorBasedLibraryDatasourceImpl(db: sl()));
  sl.registerLazySingleton<LocalNavigatorBasedLibraryDatasource>(() => LocalNavigatorBasedLibraryDatasourceImpl(cloudStorageService: sl()));

  //Services
  final firestoreInstance = FirebaseFirestore.instance;
  final firebaseFunctionsInstance = FirebaseFunctions.instance;
  sl.registerLazySingleton(() => firestoreInstance);
  sl.registerLazySingleton(() => firebaseFunctionsInstance);
  sl.registerLazySingleton(() => AuthProvider.instance);
  sl.registerFactory(() => PickUploadsManager());
  sl.registerLazySingleton(() => TasksProvider.instance);
  sl.registerLazySingleton(() => MediaService.instance);
  sl.registerLazySingleton(() => CloudStorageService.instance);
  sl.registerLazySingleton(() => MessagingService.instance);
  sl.registerLazySingleton(() => PermissionService.instance);
  sl.registerLazySingleton(() => NetworkConnectionService.instance);
}