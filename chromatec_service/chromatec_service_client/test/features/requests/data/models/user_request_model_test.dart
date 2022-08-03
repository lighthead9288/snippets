import 'package:chromatec_service/features/requests/data/models/user_request_model.dart';
import 'package:core/core.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/timestamp.dart';

void main() { 
  // arrange
  final uploadTestId = 'uploadId1';
  final uploadTestAddress = 'Upload 1 adress';
  final uploadTestName = 'Upload 1 name';
  final uploadTestSize = 'Upload 1 size';
  final uploadTestStatus = UploadStatus.Loaded;
  final uploadTestType = UploadType.File;

  final messageTestId = 'messageId1';
  final messageTestSenderId = 'messageTestSenderId1';
  final messageTestText = 'Message test text';
  final DateTime messageTestDateTime = DateTime(2000);
  
  final userRequestTestId = 'userRequestTestId';
  final userRequestTestOwnerId = 'testOwnerId';
  final userRequestTestTitle = 'User request test title';
  final userRequestTestDescription = 'User request test description';
  final DateTime requestDateTime = DateTime(2000);
  final userRequestTestIsPublished = true;
  final userRequestTestTheme = 'Soft';
  final userRequestTestStatus = 'Opened';
  final userRequestTestDialogMember = 'Member 1';

  final userRequestTestUpload = DbUpload(
    id: uploadTestId, 
    upload: uploadTestAddress, 
    name: uploadTestName, 
    size: uploadTestSize, 
    status: uploadTestStatus, 
    type: uploadTestType
  );
  final userRequestTestUploads = [ userRequestTestUpload ];

  final Map<String, dynamic> userRequestTestUploadJson = {
    'id': uploadTestId, 
    'upload': uploadTestAddress, 
    'name': uploadTestName, 
    'size': uploadTestSize, 
    'status': EnumToString.convertToString(uploadTestStatus), 
    'type': EnumToString.convertToString(uploadTestType)
  };
  final userRequestTestUploadsJson = [ userRequestTestUploadJson ];

  final userRequestTestMessage = MessageImplDb(
    id: messageTestId, 
    senderId: messageTestSenderId, 
    text: messageTestText, 
    uploads: userRequestTestUploads, 
    dateTime: messageTestDateTime
  );
  final userRequestTestMessages = [ userRequestTestMessage ];

  final userRequestTestMessageJson = {
    'id': messageTestId, 
    'senderId': messageTestSenderId, 
    'text': messageTestText, 
    'uploads': userRequestTestUploadsJson, 
    'dateTime': Timestamp.fromDateTime(messageTestDateTime)
  };
  final userRequestTestMessagesJson = [ userRequestTestMessageJson ];

  final userRequestTestModel = UserRequestModel(
    id: userRequestTestId,
    ownerId: userRequestTestOwnerId,
    title: userRequestTestTitle,
    description: userRequestTestDescription,
    dateTime: requestDateTime,
    isPublished: userRequestTestIsPublished,
    theme: userRequestTestTheme,
    status: userRequestTestStatus,
    members: [ userRequestTestOwnerId, userRequestTestDialogMember ],
    messages: userRequestTestMessages,
    uploads: userRequestTestUploads
  );

  final userRequestTestModelJson = {
    'id': userRequestTestId,
    'ownerId': userRequestTestOwnerId,
    'title': userRequestTestTitle,
    'description': userRequestTestDescription,
    'dateTime': Timestamp.fromDateTime(requestDateTime),
    'isPublished': userRequestTestIsPublished,
    'theme': userRequestTestTheme,
    'status': userRequestTestStatus,
    'members': [ userRequestTestOwnerId, userRequestTestDialogMember ],
    'messages': userRequestTestMessagesJson,
    'uploads': userRequestTestUploadsJson
  };

  group('dbUpload', () {
    test('fromJson', () {
      // act
      var model = DbUpload.fromJson(userRequestTestUploadJson);
      // assert
      expect(model, userRequestTestUpload);
    });

    test('toJson', () {
      // act
      var json = userRequestTestUpload.toJson();
      // assert
      expect(json, userRequestTestUploadJson);
    });
  });
  
  group('messageImpl', () {
    test('fromJson', () {
      // act
      var model = MessageImplDb.fromJson(userRequestTestMessageJson);
      // assert
      expect(model, userRequestTestMessage);
    });

    test('toJson', () {
      // act
      var json = userRequestTestMessage.toJson();
      // assert
      expect(json, userRequestTestMessageJson);
    });
  });

  group('userRequestModel', () {
    test('fromJson', () {
      // act
      var model = UserRequestModel.fromJson(userRequestTestModelJson);
      // assert
      expect(model, userRequestTestModel);
    });

    test('toJson', () {
      // act
      var json = userRequestTestModel.toJson();
      // assert
      expect(json, userRequestTestModelJson);
    });
  });
}