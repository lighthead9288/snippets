import 'package:chromatec_service/common/models/bookmark_holder.dart';
import 'package:chromatec_service/common/models/success.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_requests_response.dart';
import 'package:chromatec_service/features/requests/domain/repositories/requests_repository.dart';
import 'package:chromatec_service/features/requests/domain/usecases/get_user_requests.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRequestsRepository extends Mock implements RequestsRepository {}

class MockBookmarkHolder extends Mock implements BookmarkHolder {}

main() {

  GetUserRequestsUseCase getUserRequestsUseCase;
  MockRequestsRepository mockRequestsRepository;
  MockBookmarkHolder mockBookmarkHolder;
  
  setUp(() {
    mockRequestsRepository = MockRequestsRepository();
    mockBookmarkHolder = MockBookmarkHolder();
    getUserRequestsUseCase = GetUserRequestsUseCase(repository: mockRequestsRepository);
  });

  test('Get user requests usecase', () {
    // arrange
    final userId = 'id';
    final filter = RequestsFilter.All;
    final limit = 3;
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

    when(mockRequestsRepository.getUserRequests(userId, filter, limit, mockBookmarkHolder)).thenAnswer((_) => Stream.value(response));
    // act
    var result = getUserRequestsUseCase(userId, filter, limit, mockBookmarkHolder);
    // assert
    expect(result, emits(response));
  });

}