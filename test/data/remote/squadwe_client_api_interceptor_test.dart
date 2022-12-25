import 'package:squadwe_client_sdk/data/local/entity/squadwe_contact.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_conversation.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_user.dart';
import 'package:squadwe_client_sdk/data/remote/service/squadwe_client_api_interceptor.dart';
import 'package:squadwe_client_sdk/data/remote/service/squadwe_client_auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils/test_resources_util.dart';
import '../squadwe_repository_test.mocks.dart';
import '../local/local_storage_test.mocks.dart';
import 'squadwe_client_api_interceptor_test.mocks.dart';
import 'squadwe_client_service_test.mocks.dart';

class _HasPath extends Matcher {
  final String _pathValue;
  const _HasPath(this._pathValue);

  @override
  bool matches(item, Map matchState) =>
      (item as RequestOptions).path == _pathValue;

  @override
  Description describe(Description description) =>
      description.addDescriptionOf(_pathValue);
}

@GenerateMocks([
  ResponseInterceptorHandler,
  RequestInterceptorHandler,
  SquadweClientAuthService
])
void main() {
  group("Client Api Interceptor Test", () {
    late final SquadweClientApiInterceptor interceptor;
    final testInboxIdentifier = "testIdentifier";
    final mockAuthService = MockSquadweClientAuthService();
    final mockLocalStorage = MockLocalStorage();
    final mockContactDao = MockSquadweContactDao();
    final mockUserDao = MockSquadweUserDao();
    final mockDio = MockDio();
    final mockConversationDao = MockSquadweConversationDao();
    final mockResponseHandler = MockResponseInterceptorHandler();
    final mockRequestHandler = MockRequestInterceptorHandler();

    late final testContact;

    late final testConversation;

    final testUser = SquadweUser(
        identifier: "identifier",
        identifierHash: "identifierHash",
        name: "name",
        email: "email",
        avatarUrl: "avatarUrl",
        customAttributes: {});

    setUpAll(() async {
      when(mockLocalStorage.contactDao).thenReturn(mockContactDao);
      when(mockLocalStorage.userDao).thenReturn(mockUserDao);
      when(mockAuthService.dio).thenReturn(mockDio);
      when(mockLocalStorage.conversationDao).thenReturn(mockConversationDao);
      testContact = SquadweContact.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "contact"));
      testConversation = SquadweConversation.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "conversation"));
      interceptor = SquadweClientApiInterceptor(
          testInboxIdentifier, mockLocalStorage, mockAuthService);
    });

    tearDown(() {
      reset(mockAuthService);
      reset(mockContactDao);
      reset(mockConversationDao);
      when(mockAuthService.dio).thenReturn(mockDio);
    });

    _createSuccessResponse(body) {
      return Response(
          data: body,
          statusCode: 200,
          requestOptions: RequestOptions(path: "", headers: new Map()));
    }

    _createErrorResponse({required int statusCode, body}) {
      return Response(
          data: body,
          statusCode: statusCode,
          requestOptions: RequestOptions(path: "", headers: new Map()));
    }

    test(
        'Given persisted contact is null when a request is made, then recreate contact and submit request',
        () async {
      //GIVEN
      final testRequest = RequestOptions(path: "/");

      when(mockContactDao.getContact()).thenReturn(null);
      when(mockConversationDao.getConversation()).thenReturn(null);
      when(mockUserDao.getUser()).thenReturn(testUser);
      when(mockAuthService.createNewContact(any, any))
          .thenAnswer((_) => Future.value(testContact));
      when(mockAuthService.createNewConversation(any, any))
          .thenAnswer((_) => Future.value(testConversation));

      //WHEN
      await interceptor.onRequest(testRequest, mockRequestHandler);

      //THEN
      verify(mockAuthService.createNewContact(testInboxIdentifier, testUser));
      verify(mockAuthService.createNewConversation(
          testInboxIdentifier, testContact.contactIdentifier));
      verify(mockContactDao.saveContact(testContact));
      verify(mockConversationDao.saveConversation(testConversation));
      verify(mockRequestHandler.next(any));
    });

    test(
        'Given persisted conversation is null when a request is made, then create a conversation and submit request',
        () async {
      //GIVEN
      final testRequest = RequestOptions(path: "/");

      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockConversationDao.getConversation()).thenReturn(null);
      when(mockAuthService.createNewConversation(any, any))
          .thenAnswer((_) => Future.value(testConversation));

      //WHEN
      await interceptor.onRequest(testRequest, mockRequestHandler);

      //THEN
      verify(mockAuthService.createNewConversation(
          testInboxIdentifier, testContact.contactIdentifier));
      verify(mockConversationDao.saveConversation(testConversation));
      verify(mockRequestHandler.next(any));
    });

    test(
        'Given contact identifier is needed when a request is made, then attach contact identifier and submit request',
        () async {
      //GIVEN
      final testRequest = RequestOptions(
          path:
              "/${SquadweClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}");

      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);

      //WHEN
      await interceptor.onRequest(testRequest, mockRequestHandler);

      //THEN
      verify(mockRequestHandler
          .next(argThat(_HasPath("/${testContact.contactIdentifier}"))));
    });

    test(
        'Given inbox identifier is needed when a request is made, then attach inbox identifier and submit request',
        () async {
      //GIVEN
      final testRequest = RequestOptions(
          path:
              "/${SquadweClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}");

      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);

      //WHEN
      await interceptor.onRequest(testRequest, mockRequestHandler);

      //THEN
      verify(
          mockRequestHandler.next(argThat(_HasPath("/$testInboxIdentifier"))));
    });

    test(
        'Given conversation identifier is needed when a request is made, then attach conversation identifier and submit request',
        () async {
      //GIVEN
      final testRequest = RequestOptions(
          path:
              "/${SquadweClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}");

      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);

      //WHEN
      await interceptor.onRequest(testRequest, mockRequestHandler);

      //THEN
      verify(mockRequestHandler
          .next(argThat(_HasPath("/${testConversation.id}"))));
    });

    test(
        'Given api response is 401 unauthorized when a response is returned, then recreate contact and resubmit request',
        () async {
      //GIVEN
      final testResponse = _createErrorResponse(statusCode: 401);

      when(mockLocalStorage.contactDao).thenReturn(mockContactDao);
      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockDio.fetch(any))
          .thenAnswer((_) => Future.value(_createSuccessResponse({})));
      when(mockUserDao.getUser()).thenReturn(testUser);
      when(mockAuthService.createNewContact(any, any))
          .thenAnswer((_) => Future.value(testContact));
      when(mockAuthService.createNewConversation(any, any))
          .thenAnswer((_) => Future.value(testConversation));

      //WHEN
      await interceptor.onResponse(testResponse, mockResponseHandler);

      //THEN
      verify(mockContactDao.saveContact(testContact));
      verify(mockConversationDao.saveConversation(testConversation));
      verify(mockResponseHandler.next(any));
    });

    test(
        'Given api response is not 401 unauthorized when a response is returned, then forward response through handler',
        () async {
      //GIVEN
      final testResponse = _createErrorResponse(statusCode: 400);

      //WHEN
      await interceptor.onResponse(testResponse, mockResponseHandler);

      //THEN
      verify(mockResponseHandler.next(any));
      verifyNever(mockAuthService.createNewConversation(any, any));
      verifyNever(mockContactDao.saveContact(any));
      verifyNever(mockConversationDao.saveConversation(any));
    });

    test(
        'Given api response is successful when a response is returned, then forward response through handler',
        () async {
      //GIVEN
      final testResponse = _createSuccessResponse({});

      //WHEN
      await interceptor.onResponse(testResponse, mockResponseHandler);

      //THEN
      verify(mockResponseHandler.next(any));
      verifyNever(mockAuthService.createNewContact(any, any));
      verifyNever(mockAuthService.createNewConversation(any, any));
      verifyNever(mockContactDao.saveContact(any));
      verifyNever(mockConversationDao.saveConversation(any));
    });
  });
}
