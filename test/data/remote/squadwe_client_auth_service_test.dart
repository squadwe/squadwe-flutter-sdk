
import 'package:squadwe_client_sdk/data/local/entity/squadwe_contact.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_conversation.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_user.dart';
import 'package:squadwe_client_sdk/data/remote/squadwe_client_exception.dart';
import 'package:squadwe_client_sdk/data/remote/service/squadwe_client_auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils/test_resources_util.dart';
import 'squadwe_client_service_test.mocks.dart';

@GenerateMocks([
  Dio
])
void main() {
  group("Client Auth Service Tests", (){
    late final SquadweClientAuthService clientService ;
    final mockDio = MockDio();
    final testInboxIdentifier = "inboxIdentifier";
    final testContactIdentifier = "contactIdentifier";
    final testUser = SquadweUser(
        identifier: "identifier",
        identifierHash: "identifierHash",
        name: "name",
        email: "email",
        avatarUrl: "avatarUrl",
        customAttributes: {}
    );

    setUpAll((){
      clientService = SquadweClientAuthServiceImpl(dio: mockDio);
    });

    _createSuccessResponse(body){
      return Response(
          data: body,
          statusCode: 200,
          requestOptions: RequestOptions(path: "")
      );
    }

    _createErrorResponse({required int statusCode, body}){
      return Response(
        data: body,
        statusCode: statusCode,
        requestOptions: RequestOptions(path: "")
      );
    }

    test('Given contact is successfully created when createNewContact is called, then return created contact', () async{

      //GIVEN
      final responseBody = await TestResourceUtil.readJsonResource(fileName: "contact");
      when(mockDio.post(any, data: testUser.toJson())).thenAnswer((_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.createNewContact(testInboxIdentifier,testUser);

      //THEN
      expect(result, SquadweContact.fromJson(responseBody));

    });

    test('Given contact creation returns with error response when createNewContact is called, then throw error', () async{

      //GIVEN
      when(
          mockDio.post(any, data: testUser.toJson())
      ).thenAnswer((_) => Future.value(_createErrorResponse(statusCode:401, body: {})));

      //WHEN
      SquadweClientException? squadweClientException;
      try{
        await clientService.createNewContact(testInboxIdentifier,testUser);
      }on SquadweClientException catch (e){
        squadweClientException = e;
      }

      //THEN
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type, equals(SquadweClientExceptionType.CREATE_CONTACT_FAILED));

    });

    test('Given contact creation fails when createNewContact is called, then throw error', () async{

      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(
          mockDio.post(any, data: testUser.toJson())
      ).thenThrow(testError);

      //WHEN
      SquadweClientException? squadweClientException;
      try{
        await clientService.createNewContact(testInboxIdentifier,testUser);
      }on SquadweClientException catch (e){
        squadweClientException = e;
      }

      //THEN
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type, equals(SquadweClientExceptionType.CREATE_CONTACT_FAILED));

    });

    test('Given conversation is successfully created when createNewConversation is called, then return created conversation', () async{

      //GIVEN
      final responseBody = await TestResourceUtil.readJsonResource(fileName: "conversation");
      when(mockDio.post(any)).thenAnswer((_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.createNewConversation(testInboxIdentifier,testContactIdentifier);

      //THEN
      expect(result, SquadweConversation.fromJson(responseBody));

    });

    test('Given conversation creation returns with error response when createNewConversation is called, then throw error', () async{

      //GIVEN
      when(
          mockDio.post(any)
      ).thenAnswer((_) => Future.value(_createErrorResponse(statusCode:401, body: {})));

      //WHEN
      SquadweClientException? squadweClientException;
      try{
        await clientService.createNewConversation(testInboxIdentifier, testContactIdentifier);
      }on SquadweClientException catch (e){
        squadweClientException = e;
      }

      //THEN
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type, equals(SquadweClientExceptionType.CREATE_CONVERSATION_FAILED));

    });

    test('Given conversation creation fails when createNewConversation is called, then throw error', () async{

      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(
          mockDio.post(any)
      ).thenThrow(testError);

      //WHEN
      SquadweClientException? squadweClientException;
      try{
        await clientService.createNewConversation(testInboxIdentifier,testContactIdentifier);
      }on SquadweClientException catch (e){
        squadweClientException = e;
      }

      //THEN
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type, equals(SquadweClientExceptionType.CREATE_CONVERSATION_FAILED));

    });

  });

}