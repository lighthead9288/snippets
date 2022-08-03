import 'dart:io';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/usecases/change_request_uploads_list.dart';
import 'package:chromatec_service/features/requests/domain/usecases/create_user_request.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_user_request_by_id.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_users_by_dialog_members_list.dart';
import 'package:chromatec_service/features/requests/domain/usecases/update_user_request.dart';
import 'package:chromatec_service/features/requests/presentation/request_editor/state/request_editor_provider.dart';
import 'package:chromatec_service/features/requests/domain/entities/support_subject.dart';
import 'package:chromatec_service/providers/auth_provider.dart';
import 'package:chromatec_service/providers/uploads_loading_tasks_provider.dart';
import 'package:chromatec_service/services/pick_uploads_manager.dart';
import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart' as user;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

class MockAuthUser extends Mock implements user.User {}

class MockGetUserRequestByIdUseCase extends Mock implements GetUserRequestByIdUseCase {}

class MockGetUsersByDialogMembersListUseCase extends Mock implements GetUsersByDialogMembersListUseCase {}

class MockCreateUserRequestUseCase extends Mock implements CreateUserRequestUseCase {}

class MockUpdateUserRequestUseCase extends Mock implements UpdateUserRequestUseCase {}

class MockChangeRequestUploadsListUseCase extends Mock implements ChangeRequestUploadsListUseCase {}

class MockPickUploadsManager extends Mock implements PickUploadsManager {}

class MockTasksProvider extends Mock implements TasksProvider {}

class MockFile extends Mock implements File {}

void main() {  
  RequestEditorProvider requestEditorProvider;
  MockAuthProvider mockAuthProvider;
  MockAuthUser mockAuthUser;
  MockGetUserRequestByIdUseCase mockGetUserRequestByIdUseCase;
  MockGetUsersByDialogMembersListUseCase mockGetUsersByDialogMembersListUseCase;
  MockCreateUserRequestUseCase mockCreateUserRequestUseCase;
  MockUpdateUserRequestUseCase mockUpdateUserRequestUseCase;
  MockChangeRequestUploadsListUseCase mockChangeRequestUploadsListUseCase;
  MockPickUploadsManager mockPickUploadsManager;
  MockTasksProvider mockTasksProvider;
  MockFile mockFile;

  final String requestId = 'requestId';
  final String userId1 = 'userId1';
  final String userId2 = 'userId2';
  final String label = '';
  List<FileUpload> uploads = [
    FileUpload('id1', mockFile, '', '', UploadStatus.Loading, UploadType.File),
    FileUpload('id2', mockFile, '', '', UploadStatus.Loading, UploadType.File)
  ];
  final userRequest1 = UserRequest(
        id: requestId,
        ownerId: userId1,
        title: '',
        description: '',
        theme: '',
        status: '',
        isPublished: true,
        dateTime: DateTime(2000),
        members: [ '' ],
        messages: [],
        uploads: [ UrlUpload('id', 'url', 'name', 'size', UploadStatus.Loaded, UploadType.File) ]
    );
  final userRequest2 = UserRequest(
          id: requestId,
          ownerId: userId1,
          title: '',
          description: '',
          theme: '',
          status: "Opened",
          members: [ userId1 ],
          messages: [],
          uploads: uploads,
          isPublished: true
  );
  final userRequest3 = UserRequest(
          ownerId: userId1,
          title: '',
          description: '',
          theme: '',
          status: "Opened",
          members: [ userId1 ],
          messages: [],
          uploads: uploads,
          isPublished: true
  );
  final User user1 = User(userId1, '', '', '', '', DateTime(2000), '', []);
  final User user2 = User(userId2, '', '', '', '', DateTime(2000), '', []);
  final List<User> users = [ user1, user2 ];

  
  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockAuthUser = MockAuthUser();
    mockGetUserRequestByIdUseCase = MockGetUserRequestByIdUseCase();
    mockGetUsersByDialogMembersListUseCase = MockGetUsersByDialogMembersListUseCase();
    mockCreateUserRequestUseCase = MockCreateUserRequestUseCase();
    mockUpdateUserRequestUseCase = MockUpdateUserRequestUseCase();
    mockChangeRequestUploadsListUseCase = MockChangeRequestUploadsListUseCase();
    mockPickUploadsManager = MockPickUploadsManager();
    mockTasksProvider = MockTasksProvider();
    mockFile = MockFile();
    requestEditorProvider = RequestEditorProvider(
      auth: mockAuthProvider, 
      getUserRequestByIdUseCase: mockGetUserRequestByIdUseCase, 
      getUsersByDialogMembersListUseCase: mockGetUsersByDialogMembersListUseCase, 
      createUserRequestUseCase: mockCreateUserRequestUseCase, 
      updateUserRequestUseCase: mockUpdateUserRequestUseCase, 
      changeRequestUploadsListUseCase: mockChangeRequestUploadsListUseCase, 
      uploadsManager: mockPickUploadsManager,
      tasksProvider: mockTasksProvider 
    );
  });

  group('Get user request by id', () {
    test('Success', () async {
      // arrange
      when(mockGetUserRequestByIdUseCase.call(requestId)).thenAnswer((_) => Future.value(userRequest1));
      when(mockGetUsersByDialogMembersListUseCase.call(userRequest1.members)).thenAnswer((_) => Future.value(users));
      // act
      var result = await requestEditorProvider.getUserRequestById(requestId, label, () {}, () {});
      // assert
      expect(result, userRequest1);
      expect(requestEditorProvider.support, SupportSubject(label, users));
      expect(requestEditorProvider.uploads.length, userRequest1.uploads.length);
      expect(requestEditorProvider.isInitialLoading, false);    
    });

    test('Error', () async {
      // arrange
      bool isError = false;
      when(mockGetUserRequestByIdUseCase.call(null)).thenAnswer((_) => Future.value(userRequest1));
       // act
      await requestEditorProvider.getUserRequestById(requestId, label, () {}, () {
        isError = true;
      });
      // assert
      expect(isError, true);
    });
  });

  void prepareForChangeRequest() {
    when(mockAuthProvider.user).thenReturn(mockAuthUser);
    when(mockAuthUser.uid).thenReturn(userId1);
    when(mockUpdateUserRequestUseCase(any)).thenAnswer((_) => Future.value());
    when(mockCreateUserRequestUseCase(any)).thenAnswer((_) => Future.value(requestId));
    when(mockTasksProvider.createTaskListByUploads(uploads, userId1, any)).thenAnswer((_) {
      uploads.forEach((upload) async {
        await mockChangeRequestUploadsListUseCase(requestId, '', '', '', '', UploadStatus.Loaded);
      });
    });
    requestEditorProvider.uploads = uploads;      
  }

  group('On save request', () {
    test('Create', () {
      prepareForChangeRequest();
      requestEditorProvider.onSave(null, () { 
        expect(requestEditorProvider.isRequestLoading, false);
      }, () { 
      }, () { 
      });
      expect(requestEditorProvider.isRequestLoading, true);     
      verify(mockCreateUserRequestUseCase(any)).called(1);
    });

    test('Update', ()  {
      prepareForChangeRequest();
      requestEditorProvider.onSave(requestId, () { 
        expect(requestEditorProvider.isRequestLoading, false);
      }, () { 
      }, () { 
      });
      expect(requestEditorProvider.isRequestLoading, true);     
      verify(mockUpdateUserRequestUseCase(any)).called(1); 
    });
  });

  group('On publish request', () {
    test('Create', () {
      prepareForChangeRequest();
      requestEditorProvider.onPublish(null, () { 
        expect(requestEditorProvider.isRequestLoading, false);
      }, () { 
      }, () { 
      });
      expect(requestEditorProvider.isRequestLoading, true);     
      verify(mockCreateUserRequestUseCase(any)).called(1);
    });

    test('Update', () {
      prepareForChangeRequest();
      requestEditorProvider.onPublish(requestId, () { 
        expect(requestEditorProvider.isRequestLoading, false);
      }, () { 
      }, () { 
      });
      expect(requestEditorProvider.isRequestLoading, true);     
      verify(mockUpdateUserRequestUseCase(any)).called(1);
    });
  });

  test('Update user request', () async {
    prepareForChangeRequest();    
    await requestEditorProvider.updateUserRequest(userId1, requestId, '', '', '', [], () { }, () { });
    verify(mockUpdateUserRequestUseCase(userRequest2));
    verify(mockTasksProvider.createTaskListByUploads(uploads, userId1, any));
    verify(mockChangeRequestUploadsListUseCase(requestId, '', '', '', '', UploadStatus.Loaded)).called(uploads.length);
  });

  test('Create user request', () async {
    prepareForChangeRequest();
    await requestEditorProvider.createUserRequest(userId1, '', '', '', [], () { }, () { });
    verify(mockCreateUserRequestUseCase(userRequest3));
    verify(mockTasksProvider.createTaskListByUploads(uploads, userId1, any));
    verify(mockChangeRequestUploadsListUseCase(requestId, '', '', '', '', UploadStatus.Loaded)).called(uploads.length);
  });

  
}