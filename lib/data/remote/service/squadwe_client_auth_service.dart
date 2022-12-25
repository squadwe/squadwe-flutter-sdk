import 'dart:async';

import 'package:squadwe_client_sdk/data/local/entity/squadwe_contact.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_conversation.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_user.dart';
import 'package:squadwe_client_sdk/data/remote/squadwe_client_exception.dart';
import 'package:squadwe_client_sdk/data/remote/service/squadwe_client_api_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Service for handling squadwe user authentication api calls
/// See [SquadweClientAuthServiceImpl]
abstract class SquadweClientAuthService {
  WebSocketChannel? connection;
  final Dio dio;

  SquadweClientAuthService(this.dio);

  Future<SquadweContact> createNewContact(
      String inboxIdentifier, SquadweUser? user);

  Future<SquadweConversation> createNewConversation(
      String inboxIdentifier, String contactIdentifier);
}

/// Default Implementation for [SquadweClientAuthService]
class SquadweClientAuthServiceImpl extends SquadweClientAuthService {
  SquadweClientAuthServiceImpl({required Dio dio}) : super(dio);

  ///Creates new contact for inbox with [inboxIdentifier] and passes [user] body to be linked to created contact
  @override
  Future<SquadweContact> createNewContact(
      String inboxIdentifier, SquadweUser? user) async {
    try {
      final createResponse = await dio.post(
          "/public/api/v1/inboxes/$inboxIdentifier/contacts",
          data: user?.toJson());
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        //creating contact successful continue with request
        final contact = SquadweContact.fromJson(createResponse.data);
        return contact;
      } else {
        throw SquadweClientException(
            createResponse.statusMessage ?? "unknown error",
            SquadweClientExceptionType.CREATE_CONTACT_FAILED);
      }
    } on DioError catch (e) {
      throw SquadweClientException(
          e.message, SquadweClientExceptionType.CREATE_CONTACT_FAILED);
    }
  }

  ///Creates a new conversation for inbox with [inboxIdentifier] and contact with source id [contactIdentifier]
  @override
  Future<SquadweConversation> createNewConversation(
      String inboxIdentifier, String contactIdentifier) async {
    try {
      final createResponse = await dio.post(
          "/public/api/v1/inboxes/$inboxIdentifier/contacts/$contactIdentifier/conversations");
      if ((createResponse.statusCode ?? 0).isBetween(199, 300)) {
        //creating contact successful continue with request
        final newConversation =
            SquadweConversation.fromJson(createResponse.data);
        return newConversation;
      } else {
        throw SquadweClientException(
            createResponse.statusMessage ?? "unknown error",
            SquadweClientExceptionType.CREATE_CONVERSATION_FAILED);
      }
    } on DioError catch (e) {
      throw SquadweClientException(
          e.message, SquadweClientExceptionType.CREATE_CONVERSATION_FAILED);
    }
  }
}
