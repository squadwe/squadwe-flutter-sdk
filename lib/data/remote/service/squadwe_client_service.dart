import 'dart:async';
import 'dart:convert';

import 'package:squadwe_client_sdk/data/local/entity/squadwe_contact.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_conversation.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_message.dart';
import 'package:squadwe_client_sdk/data/remote/squadwe_client_exception.dart';
import 'package:squadwe_client_sdk/data/remote/requests/squadwe_action.dart';
import 'package:squadwe_client_sdk/data/remote/requests/squadwe_action_data.dart';
import 'package:squadwe_client_sdk/data/remote/service/squadwe_client_api_interceptor.dart';
import 'package:squadwe_client_sdk/data/remote/requests/squadwe_new_message_request.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Service for handling squadwe api calls
/// See [SquadweClientServiceImpl]
abstract class SquadweClientService {
  final String _baseUrl;
  WebSocketChannel? connection;
  final Dio _dio;

  SquadweClientService(this._baseUrl, this._dio);

  Future<SquadweContact> updateContact(update);

  Future<SquadweContact> getContact();

  Future<List<SquadweConversation>> getConversations();

  Future<SquadweMessage> createMessage(SquadweNewMessageRequest request);

  Future<SquadweMessage> updateMessage(String messageIdentifier, update);

  Future<List<SquadweMessage>> getAllMessages();

  void startWebSocketConnection(String contactPubsubToken,
      {WebSocketChannel Function(Uri)? onStartConnection});

  void sendAction(String contactPubsubToken, SquadweActionType action);
}

class SquadweClientServiceImpl extends SquadweClientService {
  SquadweClientServiceImpl(String baseUrl, {required Dio dio})
      : super(baseUrl, dio);

  ///Sends message to squadwe inbox
  @override
  Future<SquadweMessage> createMessage(
      SquadweNewMessageRequest request) async {
    try {
      final createResponse = await _dio.post(
          "/public/api/v1/inboxes/${SquadweClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${SquadweClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations/${SquadweClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}/messages",
          data: request.toJson());
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        return SquadweMessage.fromJson(createResponse.data);
      } else {
        throw SquadweClientException(
            createResponse.statusMessage ?? "unknown error",
            SquadweClientExceptionType.SEND_MESSAGE_FAILED);
      }
    } on DioError catch (e) {
      throw SquadweClientException(
          e.message, SquadweClientExceptionType.SEND_MESSAGE_FAILED);
    }
  }

  ///Gets all messages of current squadwe client instance's conversation
  @override
  Future<List<SquadweMessage>> getAllMessages() async {
    try {
      final createResponse = await _dio.get(
          "/public/api/v1/inboxes/${SquadweClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${SquadweClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations/${SquadweClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}/messages");
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        return (createResponse.data as List<dynamic>)
            .map(((json) => SquadweMessage.fromJson(json)))
            .toList();
      } else {
        throw SquadweClientException(
            createResponse.statusMessage ?? "unknown error",
            SquadweClientExceptionType.GET_MESSAGES_FAILED);
      }
    } on DioError catch (e) {
      throw SquadweClientException(
          e.message, SquadweClientExceptionType.GET_MESSAGES_FAILED);
    }
  }

  ///Gets contact of current squadwe client instance
  @override
  Future<SquadweContact> getContact() async {
    try {
      final createResponse = await _dio.get(
          "/public/api/v1/inboxes/${SquadweClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${SquadweClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}");
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        return SquadweContact.fromJson(createResponse.data);
      } else {
        throw SquadweClientException(
            createResponse.statusMessage ?? "unknown error",
            SquadweClientExceptionType.GET_CONTACT_FAILED);
      }
    } on DioError catch (e) {
      throw SquadweClientException(
          e.message, SquadweClientExceptionType.GET_CONTACT_FAILED);
    }
  }

  ///Gets all conversation of current squadwe client instance
  @override
  Future<List<SquadweConversation>> getConversations() async {
    try {
      final createResponse = await _dio.get(
          "/public/api/v1/inboxes/${SquadweClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${SquadweClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations");
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        return (createResponse.data as List<dynamic>)
            .map(((json) => SquadweConversation.fromJson(json)))
            .toList();
      } else {
        throw SquadweClientException(
            createResponse.statusMessage ?? "unknown error",
            SquadweClientExceptionType.GET_CONVERSATION_FAILED);
      }
    } on DioError catch (e) {
      throw SquadweClientException(
          e.message, SquadweClientExceptionType.GET_CONVERSATION_FAILED);
    }
  }

  ///Update current client instance's contact
  @override
  Future<SquadweContact> updateContact(update) async {
    try {
      final updateResponse = await _dio.patch(
          "/public/api/v1/inboxes/${SquadweClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${SquadweClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}",
          data: update);
      if ((updateResponse.statusCode ?? 0).isBetween(199, 300)) {
        return SquadweContact.fromJson(updateResponse.data);
      } else {
        throw SquadweClientException(
            updateResponse.statusMessage ?? "unknown error",
            SquadweClientExceptionType.UPDATE_CONTACT_FAILED);
      }
    } on DioError catch (e) {
      throw SquadweClientException(
          e.message, SquadweClientExceptionType.UPDATE_CONTACT_FAILED);
    }
  }

  ///Update message with id [messageIdentifier] with contents of [update]
  @override
  Future<SquadweMessage> updateMessage(
      String messageIdentifier, update) async {
    try {
      final updateResponse = await _dio.patch(
          "/public/api/v1/inboxes/${SquadweClientApiInterceptor.INTERCEPTOR_INBOX_IDENTIFIER_PLACEHOLDER}/contacts/${SquadweClientApiInterceptor.INTERCEPTOR_CONTACT_IDENTIFIER_PLACEHOLDER}/conversations/${SquadweClientApiInterceptor.INTERCEPTOR_CONVERSATION_IDENTIFIER_PLACEHOLDER}/messages/$messageIdentifier",
          data: update);
      if ((updateResponse.statusCode ?? 0).isBetween(199, 300)) {
        return SquadweMessage.fromJson(updateResponse.data);
      } else {
        throw SquadweClientException(
            updateResponse.statusMessage ?? "unknown error",
            SquadweClientExceptionType.UPDATE_MESSAGE_FAILED);
      }
    } on DioError catch (e) {
      throw SquadweClientException(
          e.message, SquadweClientExceptionType.UPDATE_MESSAGE_FAILED);
    }
  }

  @override
  void startWebSocketConnection(String contactPubsubToken,
      {WebSocketChannel Function(Uri)? onStartConnection}) {
    final socketUrl = Uri.parse(_baseUrl.replaceFirst("http", "ws") + "/cable");
    this.connection = onStartConnection == null
        ? WebSocketChannel.connect(socketUrl)
        : onStartConnection(socketUrl);
    connection!.sink.add(jsonEncode({
      "command": "subscribe",
      "identifier": jsonEncode(
          {"channel": "RoomChannel", "pubsub_token": contactPubsubToken})
    }));
  }

  @override
  void sendAction(String contactPubsubToken, SquadweActionType actionType) {
    final SquadweAction action;
    final identifier = jsonEncode(
        {"channel": "RoomChannel", "pubsub_token": contactPubsubToken});
    switch (actionType) {
      case SquadweActionType.subscribe:
        action = SquadweAction(identifier: identifier, command: "subscribe");
        break;
      default:
        action = SquadweAction(
            identifier: identifier,
            data: SquadweActionData(action: actionType),
            command: "message");
        break;
    }
    connection?.sink.add(jsonEncode(action.toJson()));
  }
}
