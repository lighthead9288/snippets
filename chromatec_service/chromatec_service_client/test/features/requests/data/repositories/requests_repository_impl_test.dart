import 'package:chromatec_service/common/models/bookmark_holder.dart';
import 'package:chromatec_service/common/models/failure.dart';
import 'package:chromatec_service/common/models/success.dart';
import 'package:chromatec_service/features/requests/data/datasources/requests_local_datasource.dart';
import 'package:chromatec_service/features/requests/data/datasources/requests_remote_datasource.dart';
import 'package:chromatec_service/features/requests/data/repositories/requests_repository_impl.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_requests_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRemoteDataSource extends Mock implements RequestsRemoteDataSource {}

class MockLocalDataSource extends Mock implements RequestsLocalDataSource {}

class MockBookmarkHolder extends Mock implements BookmarkHolder {}

void main() {
  RequestsRepositoryImpl repositoryImpl;
  MockRemoteDataSource mockRemoteDataSource;
 // MockLocalDataSource mockLocalDataSource;
  MockBookmarkHolder mockBookmarkHolder;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
   // mockLocalDataSource = MockLocalDataSource();
    mockBookmarkHolder = MockBookmarkHolder();
    repositoryImpl = RequestsRepositoryImpl(remoteDataSource: mockRemoteDataSource, /*localDataSource: mockLocalDataSource*/);
  });

  group('Get user requests', () {
    test('On success', () async {
      // arrange
      final userId = 'id';
      final filter = RequestsFilter.All;
      final limit = 2;
      final userRequest1 = UserRequest(
        id: 'id1',
        ownerId: '',
        title: 'Title 1',
        description: 'Description 1',
        theme: 'Soft',
        status: 'Opened',
        isPublished: true,
        dateTime: DateTime(2000, 1),
        members: [ userId ],
        messages: [],
        uploads: []
      );
      var requests = [ userRequest1 ];
      var expectedResponse = UserRequestsResponse(DataFromServerSuccess(), requests:  requests);
      when(mockRemoteDataSource.getUserRequests(userId, filter, limit, mockBookmarkHolder)).thenAnswer((_) => Stream.value(requests));
      // act
      var result = repositoryImpl.getUserRequests(userId, filter, limit, mockBookmarkHolder);    
      // assert
      var response = await result.first;
      expect(response, expectedResponse);    
    });

    test('On failure', () async {
      // arrange
      var expectedResponse = UserRequestsResponse(ServerFailure());
      when(mockRemoteDataSource.getUserRequests('id', RequestsFilter.All, -1, mockBookmarkHolder)).thenAnswer((_) => null);
      // act
      var result = repositoryImpl.getUserRequests('id', RequestsFilter.All, -1, mockBookmarkHolder);    
      // assert
      var response = await result.first;
      expect(response, expectedResponse);
    }); 
  });

  

}