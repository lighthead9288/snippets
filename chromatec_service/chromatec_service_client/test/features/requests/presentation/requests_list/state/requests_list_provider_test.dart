import 'package:chromatec_service/common/models/success.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_requests_response.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_user_requests.dart';
import 'package:chromatec_service/features/requests/presentation/requests_list/state/requests_list_provider.dart';
import 'package:chromatec_service/providers/auth_provider.dart';
import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

class MockGetUserRequestsUseCase extends Mock implements GetUserRequestsUseCase {}

class MockGetUserByIdUseCase extends Mock implements GetUserByIdUseCase {}

class MockAuthUser extends Mock implements firebase.User {}

void main() {

  RequestsListProvider requestsListProvider;
  MockAuthProvider mockAuthProvider;
  MockAuthUser mockAuthUser;
  MockGetUserRequestsUseCase mockGetUserRequestsUseCase;
  MockGetUserByIdUseCase mockGetUserByIdUseCase;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockAuthUser = MockAuthUser();
    mockGetUserRequestsUseCase = MockGetUserRequestsUseCase();
    requestsListProvider = RequestsListProvider(
      auth: mockAuthProvider, 
      getUserRequestsUseCase: mockGetUserRequestsUseCase,
      getUserByIdUseCase: mockGetUserByIdUseCase
    );
  });

  test('Get user requests', () async {
    // arrange
    final userId = 'id';
    final filter = RequestsFilter.All;
    final limit = 10;
    final userRequest1 = UserRequest(
        id: 'id1',
        ownerId: '',
        title: 'Title 1',
        description: 'Description 1',
        theme: 'Soft',
        status: 'Opened',
        isPublished: true,
        dateTime: DateTime(2000, 1),
        members: [userId],
        messages: [],
        uploads: []
      );
    var requests = [ userRequest1 ];
    var response = UserRequestsResponse(DataFromServerSuccess(), requests: requests);
    when(mockAuthProvider.user).thenReturn(mockAuthUser);
    when(mockAuthUser.uid).thenReturn(userId);
    when(mockGetUserRequestsUseCase(userId, filter, limit, requestsListProvider)).thenAnswer((_) => Stream.value(response));
    // act
    var result = await requestsListProvider.getRequests().first;
    // assert
    expect(result, response);
    expect(requestsListProvider.requests, requests);
  });

  test('On update requests filter', () {
    // arrange
    var testFilter = RequestsFilter.Published;
    requestsListProvider.requests = [ UserRequest() ];
    // act
    requestsListProvider.onUpdateRequestFilter(testFilter);
    // assert
    expect(requestsListProvider.requestsFilter, testFilter);
    expect(requestsListProvider.requests.isEmpty, true);
  });

  test('On exit', () {
    // arrange
    requestsListProvider.requests = [ UserRequest() ];
    // act
    requestsListProvider.onExit();
    // assert
    expect(requestsListProvider.requests.isEmpty, true);
  });  

  group('On request select', () {  
    bool isPublished;
    bool isSaved;
    bool isShowRequestSavingResultRising;
    test('Is request published', () {
      // arrange
      var userRequest = UserRequest(isPublished: true);
      // act
      requestsListProvider.onRequestSelect(userRequest, (request) {
        isPublished = true;
        return;
      }, (request) { return; }, (result) {});
      // assert
      expect(isPublished, true);
      expect(requestsListProvider.requests.isEmpty, true);
    });   

    test('Is request exited', () {
      // arrange
      var userRequest = UserRequest(isPublished: false);
      // act
      requestsListProvider.onRequestSelect(userRequest, (request) { return; }, 
      (request) { 
        isSaved = true;
        return; 
      }, 
      (result) {});
      // assert
      expect(isSaved, true);
      expect(requestsListProvider.requests.isEmpty, true);
    });

    test('Is request saved', () async {
      // arrange
      var userRequest = UserRequest(isPublished: false);
      // act
      await requestsListProvider.onRequestSelect(userRequest, (request) { return; }, 
      (request) async { 
        isSaved = true;
        return await Future.value(RequestSavingResult.Saved); 
      }, 
      (result) {
        isShowRequestSavingResultRising = result is RequestSavingResult;
      });
      // assert
      expect(isSaved && isShowRequestSavingResultRising, true);
      expect(requestsListProvider.requests.isEmpty, true);
    });
  });

  test('On add request', () async {
    bool isSaved;
    bool isShowRequestSavingResultRising;
    // act
    await requestsListProvider.onAddRequest(() async {
      isSaved = true;
      return await Future.value(RequestSavingResult.Saved); 
    }, (result) { 
      isShowRequestSavingResultRising = result is RequestSavingResult;
    });
    // assert
    expect(isSaved && isShowRequestSavingResultRising, true);
    expect(requestsListProvider.requests.isEmpty, true);
  });

}