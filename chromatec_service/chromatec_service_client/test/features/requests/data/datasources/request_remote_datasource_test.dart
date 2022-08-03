import 'dart:async';
import 'package:chromatec_service/common/models/bookmark_holder.dart';
import 'package:chromatec_service/features/requests/data/datasources/requests_remote_datasource.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:core/flavors/flavors.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFirestoreClient extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockFirestoreQuery extends Mock implements Query {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockStreamQuerySnapshot extends Mock implements Stream<QuerySnapshot> {}

class MockBookmarkHolder extends Mock implements BookmarkHolder {}

void main() {
  RequestsFirebaseDataSource remoteDataSource;
  MockFirestoreClient mockFirestoreClient;
  MockCollectionReference mockCollectionReference;
  MockFirestoreQuery mockFirestoreQuery;
  MockStreamQuerySnapshot mockSnapshotsStream;
  MockBookmarkHolder mockBookmarkHolder;

  const String requestsCollectionName = "Requests";
  const String user1Id = 'userId1';
  const String user2Id = 'userId2';
  const String user3Id = 'userId3';

  final userRequest1 = UserRequest(
      id: 'id1',
      ownerId: user1Id,
      title: 'Title 1',
      description: 'Description 1',
      theme: 'Soft',
      status: 'Opened',
      isPublished: true,
      dateTime: DateTime(2000, 1),
      members: [user1Id, user2Id],
      messages: [],
      uploads: []
    );
  final userRequest2 = UserRequest(
      id: 'id2',
      ownerId: user1Id,
      title: 'Title 2',
      description: 'Description 2',
      theme: 'Soft',
      status: 'Opened',
      isPublished: true,
      dateTime: DateTime(2000, 2),
      members: [user1Id],
      messages: [],
      uploads: []
    );

  final userRequest3 = UserRequest(
      id: 'id3',
      ownerId: user2Id,
      title: 'Title 3',
      description: 'Description 3',
      theme: 'Soft',
      status: 'Opened',
      isPublished: true,
      dateTime: DateTime(2000, 3),
      members: [user2Id, user1Id],
      messages: [],
      uploads: []
    );
  final userRequest4 = UserRequest(
      id: 'id4',
      ownerId: user3Id,
      title: 'Title 4',
      description: 'Description 4',
      theme: 'Soft',
      status: 'Opened',
      isPublished: false,
      dateTime: DateTime(2000, 4),
      members: [user2Id, user3Id],
      messages: [],
      uploads: []
    );
  final userRequest5 = UserRequest(
      id: 'id5',
      ownerId: user3Id,
      title: 'Title 5',
      description: 'Description 5',
      theme: 'Soft',
      status: 'Opened',
      isPublished: true,
      dateTime: DateTime(2000, 4),
      members: [user2Id, user3Id],
      messages: [],
      uploads: []
    );  

  setUp(() {    
    mockFirestoreClient = MockFirestoreClient();    
    mockCollectionReference = MockCollectionReference();
    mockFirestoreQuery = MockFirestoreQuery();
    mockBookmarkHolder = MockBookmarkHolder();
    mockSnapshotsStream = MockStreamQuerySnapshot();
    remoteDataSource = RequestsFirebaseDataSource(db: mockFirestoreClient);

    ChromatecServiceEndpoints.setFlavor(Flavors.Prod);
  }); 

  void prepareAllRequestsStartPortionQuery(int limit, Stream<List<UserRequest>> stream) {
    when(mockFirestoreClient.collection(requestsCollectionName)).thenReturn(mockCollectionReference);
    when(mockCollectionReference.where("members", arrayContains: user1Id)).thenReturn(mockFirestoreQuery);
    when(mockFirestoreQuery.orderBy("date", descending: true)).thenReturn(mockFirestoreQuery);
    when(mockFirestoreQuery.limit(limit)).thenReturn(mockFirestoreQuery);   
    when(mockFirestoreQuery.snapshots()).thenAnswer((_) => mockSnapshotsStream);
    when(mockSnapshotsStream.map(any)).thenAnswer((_) => stream);
  }

  void prepareAllRequestsEndPortionQuery(int limit, DocumentSnapshot bookmark, Stream<List<UserRequest>> stream) {
    when(mockFirestoreClient.collection(requestsCollectionName)).thenReturn(mockCollectionReference);
    when(mockCollectionReference.where("members", arrayContains: user1Id)).thenReturn(mockFirestoreQuery);
    when(mockFirestoreQuery.orderBy("date", descending: true)).thenReturn(mockFirestoreQuery);
    when(mockFirestoreQuery.startAfterDocument(bookmark)).thenReturn(mockFirestoreQuery);
    when(mockFirestoreQuery.limit(limit)).thenReturn(mockFirestoreQuery);   
    when(mockFirestoreQuery.snapshots()).thenAnswer((_) => mockSnapshotsStream);
    when(mockSnapshotsStream.map(any)).thenAnswer((_) => stream);
  }

  void prepareRequestsStartPortionQuery(int limit, bool isPublished, Stream<List<UserRequest>> stream) {
    when(mockFirestoreClient.collection(requestsCollectionName)).thenReturn(mockCollectionReference);
    when(mockCollectionReference.where("members", arrayContains: user1Id)).thenReturn(mockFirestoreQuery);
    when(mockFirestoreQuery.where("isPublished", isEqualTo: isPublished)).thenReturn(mockFirestoreQuery);
    when(mockFirestoreQuery.orderBy("date", descending: true)).thenReturn(mockFirestoreQuery);
    when(mockFirestoreQuery.limit(limit)).thenReturn(mockFirestoreQuery);   
    when(mockFirestoreQuery.snapshots()).thenAnswer((_) => mockSnapshotsStream);
    when(mockSnapshotsStream.map(any)).thenAnswer((_) => stream);
  }

  void prepareRequestsEndPortionQuery(int limit, bool isPublished, DocumentSnapshot bookmark, Stream<List<UserRequest>> stream) {
    when(mockFirestoreClient.collection(requestsCollectionName)).thenReturn(mockCollectionReference);
    when(mockCollectionReference.where("members", arrayContains: user1Id)).thenReturn(mockFirestoreQuery);
    when(mockFirestoreQuery.where("isPublished", isEqualTo: isPublished)).thenReturn(mockFirestoreQuery);
    when(mockFirestoreQuery.orderBy("date", descending: true)).thenReturn(mockFirestoreQuery);
    when(mockFirestoreQuery.startAfterDocument(bookmark)).thenReturn(mockFirestoreQuery);
    when(mockFirestoreQuery.limit(limit)).thenReturn(mockFirestoreQuery);   
    when(mockFirestoreQuery.snapshots()).thenAnswer((_) => mockSnapshotsStream);
    when(mockSnapshotsStream.map(any)).thenAnswer((_) => stream);
  }

  group('Get user requests tests', () {
    test('Get all $user1Id requests start portion', () {
      // arrange
      List<UserRequest> allUser1Requests = [
        userRequest1,
        userRequest2
      ];
      var stream = Stream.value(allUser1Requests);  
      prepareAllRequestsStartPortionQuery(allUser1Requests.length, stream);
      // act
      var result = remoteDataSource.getUserRequests(user1Id, RequestsFilter.All, allUser1Requests.length, mockBookmarkHolder);
      // assert
      expect(result, emits(allUser1Requests));
      // verify(mockCollectionReference.where("members", arrayContains: user1Id));
      // verify(mockFirestoreQuery.orderBy("date", descending: true));
    });

    test('Get all $user1Id requests end portion', () {
      // arrange
      List<UserRequest> allUser1Requests = [
        userRequest3
      ];
      var stream = Stream.value(allUser1Requests);
      mockBookmarkHolder.bookmark = MockDocumentSnapshot();  
      prepareAllRequestsEndPortionQuery(allUser1Requests.length, mockBookmarkHolder.bookmark,  stream);
      // act
      var result = remoteDataSource.getUserRequests(user1Id, RequestsFilter.All, allUser1Requests.length, mockBookmarkHolder);
      // assert
       expect(result, emits(allUser1Requests));
    });

    test('Get published $user2Id requests start portion', () {
      // arrange
      List<UserRequest> user2PublishedRequests = [
        userRequest1,
        userRequest3
      ];
      var stream = Stream.value(user2PublishedRequests);
      prepareRequestsStartPortionQuery(user2PublishedRequests.length, true, stream);
      // act
      var result = remoteDataSource.getUserRequests(user1Id, RequestsFilter.Published, user2PublishedRequests.length, mockBookmarkHolder);
      // assert
      expect(result, emits(user2PublishedRequests));
    });

    test('Get published $user2Id requests end portion', () {
      // arrange
      List<UserRequest> user2PublishedRequests = [
        userRequest5
      ];
      var stream = Stream.value(user2PublishedRequests);
      mockBookmarkHolder.bookmark = MockDocumentSnapshot();
      prepareRequestsEndPortionQuery(user2PublishedRequests.length, true, mockBookmarkHolder.bookmark, stream);
      // act
      var result = remoteDataSource.getUserRequests(user1Id, RequestsFilter.Published, user2PublishedRequests.length, mockBookmarkHolder);
      // assert
      expect(result, emits(user2PublishedRequests));
    });

    test('Get saved $user2Id requests start portion', () {
      // arrange
      List<UserRequest> user2SavedRequests = [
        userRequest4
      ];
      var stream = Stream.value(user2SavedRequests);
      prepareRequestsStartPortionQuery(user2SavedRequests.length, false, stream);
      // act
      var result = remoteDataSource.getUserRequests(user1Id, RequestsFilter.Saved, user2SavedRequests.length, mockBookmarkHolder);
      // assert
      expect(result, emits(user2SavedRequests));
          
    });
  });


  group('Remote datasource converters tests', () {   
    test('From firebase snapshot to user request', () {
      // arrange         
      String userRequestId = 'id';
      DateTime testDate = DateTime(2000);
      String title = 'testTitle';
      UserRequest expectedUserRequest = UserRequest(
        id: userRequestId,
        ownerId: '',
        dateTime: testDate,
        title: title,
        description: '',
        theme: 'Soft',
        status: 'Opened',
        members: [],
        messages: [],
        uploads: [],
        isPublished: true
      );
      Map<String, dynamic> userRequestMap = {
        'id': userRequestId,
        'ownerId': '',
        'title': title,
        'description': '',
        'date': Timestamp.fromDate(testDate),
        'isPublished': true,
        'theme': 'Soft',
        'status': 'Opened',
        'members': [],
        'messages': [],
        'uploads': []
      };
      // act
      var request = remoteDataSource.fromFirebaseSnapshotToRequest(userRequestMap, userRequestMap['id']);
      // assert
      expect(request, expectedUserRequest);  
    });
  });

  

  
}