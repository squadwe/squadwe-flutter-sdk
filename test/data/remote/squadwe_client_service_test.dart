import 'dart:convert';

import 'package:squadwe_client_sdk/data/local/entity/squadwe_contact.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_conversation.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_message.dart';
import 'package:squadwe_client_sdk/data/remote/squadwe_client_exception.dart';
import 'package:squadwe_client_sdk/data/remote/requests/squadwe_action_data.dart';
import 'package:squadwe_client_sdk/data/remote/requests/squadwe_new_message_request.dart';
import 'package:squadwe_client_sdk/data/remote/service/squadwe_client_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../utils/test_resources_util.dart';
import 'squadwe_client_service_test.mocks.dart';

@GenerateMocks([Dio, WebSocketChannel, WebSocketSink])
void main() {
  group("Client Service Tests", () {
    late final SquadweClientService clientService;
    final testBaseUrl = "https://test.com";
    final mockDio = MockDio();

    setUpAll(() {
      clientService = SquadweClientServiceImpl(testBaseUrl, dio: mockDio);
    });

    _createSuccessResponse(body) {
      return Response(
          data: body,
          statusCode: 200,
          requestOptions: RequestOptions(path: ""));
    }

    _createErrorResponse({required int statusCode, body}) {
      return Response(
          data: body,
          statusCode: statusCode,
          requestOptions: RequestOptions(path: ""));
    }

    test(
        'Given message is successfully sent when createMessage is called, then return sent message',
        () async {
      //GIVEN
      final responseBody =
          await TestResourceUtil.readJsonResource(fileName: "message");
      final request =
          SquadweNewMessageRequest(content: "test message", echoId: "id");
      when(mockDio.post(any, data: request.toJson())).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.createMessage(request);

      //THEN
      expect(result, SquadweMessage.fromJson(responseBody));
    });

    test(
        'Given sending message returns with error response when createMessage is called, then throw error',
        () async {
      //GIVEN
      final request =
          SquadweNewMessageRequest(content: "test message", echoId: "id");
      when(mockDio.post(any, data: request.toJson())).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      SquadweClientException? squadweClientException;
      try {
        await clientService.createMessage(request);
      } on SquadweClientException catch (e) {
        squadweClientException = e;
      }

      //THEN
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type,
          equals(SquadweClientExceptionType.SEND_MESSAGE_FAILED));
    });

    test(
        'Given sending message fails when createMessage is called, then throw error',
        () async {
      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      final request =
          SquadweNewMessageRequest(content: "test message", echoId: "id");
      when(mockDio.post(any, data: request.toJson())).thenThrow(testError);

      //WHEN
      SquadweClientException? squadweClientException;
      try {
        await clientService.createMessage(request);
      } on SquadweClientException catch (e) {
        squadweClientException = e;
      }

      //THEN
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type,
          equals(SquadweClientExceptionType.SEND_MESSAGE_FAILED));
    });

    test(
        'Given messages are successfully fetched when getAllMessages is called, then return fetched messages',
        () async {
      //GIVEN
      final dynamic responseBody =
          await TestResourceUtil.readJsonResource(fileName: "messages");
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.getAllMessages();

      //THEN
      final expected =
          responseBody.map((e) => SquadweMessage.fromJson(e)).toList();
      expect(result, equals(expected));
    });

    test(
        'Given fetch messages returns with error response when getAllMessages is called, then throw error',
        () async {
      //GIVEN
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      SquadweClientException? squadweClientException;
      try {
        await clientService.getAllMessages();
      } on SquadweClientException catch (e) {
        squadweClientException = e;
      }

      //THEN
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type,
          equals(SquadweClientExceptionType.GET_MESSAGES_FAILED));
    });

    test(
        'Given fetch messages fails when getAllMessages is called, then throw error',
        () async {
      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(mockDio.get(any)).thenThrow(testError);

      //WHEN
      SquadweClientException? squadweClientException;
      try {
        await clientService.getAllMessages();
      } on SquadweClientException catch (e) {
        squadweClientException = e;
      }

      //THEN
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type,
          equals(SquadweClientExceptionType.GET_MESSAGES_FAILED));
    });

    test(
        'Given contact is successfully fetched when getContact is called, then return fetched contact',
        () async {
      //GIVEN
      final responseBody =
          await TestResourceUtil.readJsonResource(fileName: "contact");
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.getContact();

      //THEN
      expect(result, equals(SquadweContact.fromJson(responseBody)));
    });

    test(
        'Given fetch contact returns with error response when getContact is called, then throw error',
        () async {
      //GIVEN
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      SquadweClientException? squadweClientException;
      try {
        await clientService.getContact();
      } on SquadweClientException catch (e) {
        squadweClientException = e;
      }

      //THEN
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type,
          equals(SquadweClientExceptionType.GET_CONTACT_FAILED));
    });

    test(
        'Given fetch contact fails when getContact is called, then throw error',
        () async {
      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(mockDio.get(any)).thenThrow(testError);

      //WHEN
      SquadweClientException? squadweClientException;
      try {
        await clientService.getContact();
      } on SquadweClientException catch (e) {
        squadweClientException = e;
      }

      //THEN
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type,
          equals(SquadweClientExceptionType.GET_CONTACT_FAILED));
    });

    test(
        'Given conversations are successfully fetched when getConversations is called, then return fetched conversations',
        () async {
      //GIVEN
      final dynamic responseBody =
          await TestResourceUtil.readJsonResource(fileName: "conversations");
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.getConversations();

      //THEN
      final expected =
          responseBody.map((e) => SquadweConversation.fromJson(e)).toList();
      expect(result, equals(expected));
    });

    test(
        'Given fetch conversations returns with error response when getConversations is called, then throw error',
        () async {
      //GIVEN
      when(mockDio.get(any)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      SquadweClientException? squadweClientException;
      try {
        await clientService.getConversations();
      } on SquadweClientException catch (e) {
        squadweClientException = e;
      }

      //THEN
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type,
          equals(SquadweClientExceptionType.GET_CONVERSATION_FAILED));
    });

    test(
        'Given fetch conversations fails when getConversations is called, then throw error',
        () async {
      //GIVEN
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(mockDio.get(any)).thenThrow(testError);

      //WHEN
      SquadweClientException? squadweClientException;
      try {
        await clientService.getConversations();
      } on SquadweClientException catch (e) {
        squadweClientException = e;
      }

      //THEN
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type,
          equals(SquadweClientExceptionType.GET_CONVERSATION_FAILED));
    });

    test(
        'Given contact is successfully updated when updateContact is called, then return updated contact',
        () async {
      //GIVEN
      final responseBody =
          await TestResourceUtil.readJsonResource(fileName: "contact");
      final update = {"name": "Updated name"};
      when(mockDio.patch(any, data: update)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.updateContact(update);

      //THEN
      expect(result, SquadweContact.fromJson(responseBody));
    });

    test(
        'Given contact update returns with error response when updateContact is called, then throw error',
        () async {
      //GIVEN
      final update = {"name": "Updated name"};
      when(mockDio.patch(any, data: update)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      SquadweClientException? squadweClientException;
      try {
        await clientService.updateContact(update);
      } on SquadweClientException catch (e) {
        squadweClientException = e;
      }

      //THEN
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type,
          equals(SquadweClientExceptionType.UPDATE_CONTACT_FAILED));
    });

    test(
        'Given contact update fails when updateContact is called, then throw error',
        () async {
      //GIVEN
      final update = {"name": "Updated name"};
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(mockDio.patch(any, data: update)).thenThrow(testError);

      //WHEN
      SquadweClientException? squadweClientException;
      try {
        await clientService.updateContact(update);
      } on SquadweClientException catch (e) {
        squadweClientException = e;
      }

      //THEN
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type,
          equals(SquadweClientExceptionType.UPDATE_CONTACT_FAILED));
    });

    test(
        'Given message is successfully updated when updateMessage is called, then return updated message',
        () async {
      //GIVEN
      final responseBody =
          await TestResourceUtil.readJsonResource(fileName: "message");
      final testMessageId = "id";
      final update = {"content": "Updated content"};
      when(mockDio.patch(any, data: update)).thenAnswer(
          (_) => Future.value(_createSuccessResponse(responseBody)));

      //WHEN
      final result = await clientService.updateMessage(testMessageId, update);

      //THEN
      expect(result, SquadweMessage.fromJson(responseBody));
    });

    test(
        'Given message update returns with error response when updateMessage is called, then throw error',
        () async {
      //GIVEN
      final testMessageId = "id";
      final update = {"content": "Updated content"};
      when(mockDio.patch(any, data: update)).thenAnswer(
          (_) => Future.value(_createErrorResponse(statusCode: 401, body: {})));

      //WHEN
      SquadweClientException? squadweClientException;
      try {
        await clientService.updateMessage(testMessageId, update);
      } on SquadweClientException catch (e) {
        squadweClientException = e;
      }

      //THEN
      verify(mockDio.patch(argThat(contains(testMessageId)), data: update));
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type,
          equals(SquadweClientExceptionType.UPDATE_MESSAGE_FAILED));
    });

    test(
        'Given message update fails when updateMessage is called, then throw error',
        () async {
      //GIVEN
      final testMessageId = "id";
      final update = {"content": "Updated content"};
      final testError = DioError(requestOptions: RequestOptions(path: ""));
      when(mockDio.patch(any, data: update)).thenThrow(testError);

      //WHEN
      SquadweClientException? squadweClientException;
      try {
        await clientService.updateMessage(testMessageId, update);
      } on SquadweClientException catch (e) {
        squadweClientException = e;
      }

      //THEN
      verify(mockDio.patch(argThat(contains(testMessageId)), data: update));
      expect(squadweClientException, isNotNull);
      expect(squadweClientException!.type,
          equals(SquadweClientExceptionType.UPDATE_MESSAGE_FAILED));
    });

    test(
        'Given websocket connection is successful when startWebSocketConnection is called, then subscribe for events',
        () async {
      //GIVEN
      final testPubsubtoken = "testPubsubtoken";
      final mockWebSocketChannel = MockWebSocketChannel();
      final mockWebSocketSink = MockWebSocketSink();

      final WebSocketChannel Function(Uri) startConnection = (Uri uri) {
        return mockWebSocketChannel;
      };
      when(mockWebSocketChannel.sink).thenReturn(mockWebSocketSink);
      when(mockWebSocketSink.close()).thenAnswer((_) => Future.value({}));
      when(mockWebSocketSink.add(any)).thenAnswer((_) => Future.value({}));

      //WHEN
      clientService.startWebSocketConnection(testPubsubtoken,
          onStartConnection: startConnection);

      //THEN
      final subscriptionPayload = jsonEncode({
        "command": "subscribe",
        "identifier": jsonEncode(
            {"channel": "RoomChannel", "pubsub_token": testPubsubtoken})
      });
      verify(mockWebSocketSink.add(subscriptionPayload));
      mockWebSocketSink.close();
    });

    test(
        'Given action is sent successfully when sendAction is called, then websocket sink should be triggered',
        () async {
      //GIVEN
      final testPubsubtoken = "testPubsubtoken";
      final mockWebSocketChannel = MockWebSocketChannel();
      final mockWebSocketSink = MockWebSocketSink();

      when(mockWebSocketChannel.sink).thenReturn(mockWebSocketSink);
      when(mockWebSocketSink.close()).thenAnswer((_) => Future.value({}));
      when(mockWebSocketSink.add(any)).thenAnswer((_) => Future.value({}));
      clientService.connection = mockWebSocketChannel;

      //WHEN
      clientService.sendAction(
          testPubsubtoken, SquadweActionType.update_presence);

      //THEN
      verify(mockWebSocketSink.add(any));
    });
  });
}
