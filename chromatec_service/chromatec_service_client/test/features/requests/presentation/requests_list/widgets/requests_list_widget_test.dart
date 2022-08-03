import 'package:chromatec_service/common/models/failure.dart';
import 'package:chromatec_service/common/models/success.dart';
import 'package:chromatec_service/common/widgets/failure_widget.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_request.dart';
import 'package:chromatec_service/features/requests/domain/entities/user_requests_response.dart';
import 'package:chromatec_service/features/requests/presentation/requests_list/state/requests_list_provider.dart';
import 'package:chromatec_service/features/requests/presentation/requests_list/widgets/request_card_widget.dart';
import 'package:chromatec_service/features/requests/presentation/requests_list/widgets/requests_list_widget.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRequestsListProvider extends Mock implements RequestsListProvider {}

void main() {
  MockRequestsListProvider mockRequestsListProvider;
  final ownerId = "ownerId1";
  final userRequest1 = UserRequest(
        id: 'id1',
        ownerId: ownerId,
        title: 'Title 1',
        description: 'Description 1',
        theme: 'Soft',
        status: 'Opened',
        isPublished: true,
        dateTime: DateTime(2000, 1),
        members: [''],
        messages: [],
        uploads: []
      );
    final userRequest2 = UserRequest(
        id: 'id2',
        ownerId: ownerId,
        title: 'Title 2',
        description: 'Description 2',
        theme: 'Soft',
        status: 'Opened',
        isPublished: true,
        dateTime: DateTime(2000, 1),
        members: [''],
        messages: [],
        uploads: []
      );

  setUp(() {
    mockRequestsListProvider = MockRequestsListProvider();
  });

  void prepareRequestsForLoading(UserRequestsResponse response, List<UserRequest> alreadyExistedRequests) {
    var stream = Stream.value(response);
    when(mockRequestsListProvider.requestsFilter).thenReturn(RequestsFilter.All);
    when(mockRequestsListProvider.loadingMode).thenReturn(LoadingMode.Online);
    when(mockRequestsListProvider.requests).thenReturn(alreadyExistedRequests);
    when(mockRequestsListProvider.getRequests()).thenAnswer((_) => stream);
    when(mockRequestsListProvider.isMe(userRequest1, ownerId)).thenReturn(true);
    when(mockRequestsListProvider.isMe(userRequest2, ownerId)).thenReturn(true);
  }

  void pumpWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RequestsListWidget(provider: mockRequestsListProvider),
        locale: S.delegate.supportedLocales.first,
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales        
      )
    );
    await tester.pumpAndSettle();
  }

  void pumpWithDelay(WidgetTester tester) async {
    await tester.pumpWidget(
          MaterialApp(
            home: RequestsListWidget(provider: mockRequestsListProvider),
            locale: S.delegate.supportedLocales.first,
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales        
          )
        );
    await tester.pump(Duration.zero);
  }

  void checkNecessary() {
    expect(find.byType(RequestsListWidget), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  }

  testWidgets('Test requests list widget success rethrieving', (tester) async {
    // arrange
    var requests = [ userRequest1, userRequest2 ];
    prepareRequestsForLoading(UserRequestsResponse(DataFromServerSuccess(), requests: requests), []);
    // act
    await pumpWidget(tester);
    // assert
    checkNecessary();
    expect(find.byType(RequestCard), findsNWidgets(requests.length));
  });

  testWidgets('Test requests empty list widget', (tester) async {
    // arrange
    var requests = <UserRequest>[];
    prepareRequestsForLoading(UserRequestsResponse(DataFromServerSuccess(), requests: requests), []);
    // act
    await pumpWidget(tester);
    // assert
    checkNecessary();
    expect(find.byType(EmptyDataWidget), findsOneWidget);
  });

  testWidgets('Test requests list widget failure', (tester) async {
    // arrange
    prepareRequestsForLoading(UserRequestsResponse(ServerFailure(), requests: []), []);
    // act
    await pumpWidget(tester);
    // assert
    checkNecessary();
    expect(find.byType(FailureWidget), findsOneWidget);
  }); 

  testWidgets('Test requests list widget first loading', (tester) async {
    // arrange
    var requests = [ userRequest1, userRequest2 ];
    prepareRequestsForLoading(UserRequestsResponse(DataFromServerSuccess(), requests: requests), []);
    // act
    await pumpWithDelay(tester);
    // assert
    checkNecessary();
    expect(find.byType(LoadingWidget), findsOneWidget);
    expect(find.byType(RequestCard), findsNothing);
  });

  testWidgets('Test requests list widget loading with existed requests', (tester) async {
    // arrange
    var requests = [ userRequest1, userRequest2 ];
    prepareRequestsForLoading(UserRequestsResponse(DataFromServerSuccess(), requests: requests), requests);
    // act
    await pumpWithDelay(tester);
    // assert
    checkNecessary();
    expect(find.byType(RequestCard), findsWidgets);
    expect(find.byType(LoadingWidget), findsOneWidget);
  });
}