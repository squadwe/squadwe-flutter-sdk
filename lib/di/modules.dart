import 'package:squadwe_client_sdk/data/squadwe_repository.dart';
import 'package:squadwe_client_sdk/data/local/dao/squadwe_contact_dao.dart';
import 'package:squadwe_client_sdk/data/local/dao/squadwe_conversation_dao.dart';
import 'package:squadwe_client_sdk/data/local/dao/squadwe_messages_dao.dart';
import 'package:squadwe_client_sdk/data/local/dao/squadwe_user_dao.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_contact.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_conversation.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_message.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_user.dart';
import 'package:squadwe_client_sdk/data/local/local_storage.dart';
import 'package:squadwe_client_sdk/data/remote/service/squadwe_client_api_interceptor.dart';
import 'package:squadwe_client_sdk/data/remote/service/squadwe_client_auth_service.dart';
import 'package:squadwe_client_sdk/data/remote/service/squadwe_client_service.dart';
import 'package:squadwe_client_sdk/squadwe_parameters.dart';
import 'package:squadwe_client_sdk/repository_parameters.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

///Provides an instance of [Dio]
final unauthenticatedDioProvider =
    Provider.family.autoDispose<Dio, SquadweParameters>((ref, params) {
  return Dio(BaseOptions(baseUrl: params.baseUrl));
});

///Provides an instance of [SquadweClientApiInterceptor]
final squadweClientApiInterceptorProvider =
    Provider.family<SquadweClientApiInterceptor, SquadweParameters>(
        (ref, params) {
  final localStorage = ref.read(localStorageProvider(params));
  final authService = ref.read(squadweClientAuthServiceProvider(params));
  return SquadweClientApiInterceptor(
      params.inboxIdentifier, localStorage, authService);
});

///Provides an instance of Dio with interceptors set to authenticate all requests called with this dio instance
final authenticatedDioProvider =
    Provider.family.autoDispose<Dio, SquadweParameters>((ref, params) {
  final authenticatedDio = Dio(BaseOptions(baseUrl: params.baseUrl));
  final interceptor = ref.read(squadweClientApiInterceptorProvider(params));
  authenticatedDio.interceptors.add(interceptor);
  return authenticatedDio;
});

///Provides instance of squadwe client auth service [SquadweClientAuthService].
final squadweClientAuthServiceProvider =
    Provider.family<SquadweClientAuthService, SquadweParameters>(
        (ref, params) {
  final unAuthenticatedDio = ref.read(unauthenticatedDioProvider(params));
  return SquadweClientAuthServiceImpl(dio: unAuthenticatedDio);
});

///Provides instance of squadwe client api service [SquadweClientService].
final squadweClientServiceProvider =
    Provider.family<SquadweClientService, SquadweParameters>((ref, params) {
  final authenticatedDio = ref.read(authenticatedDioProvider(params));
  return SquadweClientServiceImpl(params.baseUrl, dio: authenticatedDio);
});

///Provides hive box to store relations between squadwe client instance and contact object,
///which is used when persistence is enabled. Client instances are distinguished using baseurl and inboxIdentifier
final clientInstanceToContactBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      SquadweContactBoxNames.CLIENT_INSTANCE_TO_CONTACTS.toString());
});

///Provides hive box to store relations between squadwe client instance and conversation object,
///which is used when persistence is enabled. Client instances are distinguished using baseurl and inboxIdentifier
final clientInstanceToConversationBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      SquadweConversationBoxNames.CLIENT_INSTANCE_TO_CONVERSATIONS.toString());
});

///Provides hive box to store relations between squadwe client instance and messages,
///which is used when persistence is enabled. Client instances are distinguished using baseurl and inboxIdentifier
final messageToClientInstanceBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      SquadweMessagesBoxNames.MESSAGES_TO_CLIENT_INSTANCE_KEY.toString());
});

///Provides hive box to store relations between squadwe client instance and user object,
///which is used when persistence is enabled. Client instances are distinguished using baseurl and inboxIdentifier
final clientInstanceToUserBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      SquadweUserBoxNames.CLIENT_INSTANCE_TO_USER.toString());
});

///Provides hive box for [SquadweContact] object, which is used when persistence is enabled
final contactBoxProvider = Provider<Box<SquadweContact>>((ref) {
  return Hive.box<SquadweContact>(SquadweContactBoxNames.CONTACTS.toString());
});

///Provides hive box for [SquadweConversation] object, which is used when persistence is enabled
final conversationBoxProvider = Provider<Box<SquadweConversation>>((ref) {
  return Hive.box<SquadweConversation>(
      SquadweConversationBoxNames.CONVERSATIONS.toString());
});

///Provides hive box for [SquadweMessage] object, which is used when persistence is enabled
final messagesBoxProvider = Provider<Box<SquadweMessage>>((ref) {
  return Hive.box<SquadweMessage>(
      SquadweMessagesBoxNames.MESSAGES.toString());
});

///Provides hive box for [SquadweUser] object, which is used when persistence is enabled
final userBoxProvider = Provider<Box<SquadweUser>>((ref) {
  return Hive.box<SquadweUser>(SquadweUserBoxNames.USERS.toString());
});

///Provides an instance of squadwe user dao
///
/// Creates an in memory storage if persistence isn't enabled in params else hive boxes are create to store
/// squadwe client's contact
final squadweContactDaoProvider =
    Provider.family<SquadweContactDao, SquadweParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedSquadweContactDao();
  }

  final contactBox = ref.read(contactBoxProvider);
  final clientInstanceToContactBox =
      ref.read(clientInstanceToContactBoxProvider);
  return PersistedSquadweContactDao(
      contactBox, clientInstanceToContactBox, params.clientInstanceKey);
});

///Provides an instance of squadwe user dao
///
/// Creates an in memory storage if persistence isn't enabled in params else hive boxes are create to store
/// squadwe client's conversation
final squadweConversationDaoProvider =
    Provider.family<SquadweConversationDao, SquadweParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedSquadweConversationDao();
  }
  final conversationBox = ref.read(conversationBoxProvider);
  final clientInstanceToConversationBox =
      ref.read(clientInstanceToConversationBoxProvider);
  return PersistedSquadweConversationDao(conversationBox,
      clientInstanceToConversationBox, params.clientInstanceKey);
});

///Provides an instance of squadwe user dao
///
/// Creates an in memory storage if persistence isn't enabled in params else hive boxes are create to store
/// squadwe client's messages
final squadweMessagesDaoProvider =
    Provider.family<SquadweMessagesDao, SquadweParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedSquadweMessagesDao();
  }
  final messagesBox = ref.read(messagesBoxProvider);
  final messageToClientInstanceBox =
      ref.read(messageToClientInstanceBoxProvider);
  return PersistedSquadweMessagesDao(
      messagesBox, messageToClientInstanceBox, params.clientInstanceKey);
});

///Provides an instance of squadwe user dao
///
/// Creates an in memory storage if persistence isn't enabled in params else hive boxes are create to store
/// user info
final squadweUserDaoProvider =
    Provider.family<SquadweUserDao, SquadweParameters>((ref, params) {
  if (!params.isPersistenceEnabled) {
    return NonPersistedSquadweUserDao();
  }
  final userBox = ref.read(userBoxProvider);
  final clientInstanceToUserBoxBox = ref.read(clientInstanceToUserBoxProvider);
  return PersistedSquadweUserDao(
      userBox, clientInstanceToUserBoxBox, params.clientInstanceKey);
});

///Provides an instance of local storage
final localStorageProvider =
    Provider.family<LocalStorage, SquadweParameters>((ref, params) {
  final contactDao = ref.read(squadweContactDaoProvider(params));
  final conversationDao = ref.read(squadweConversationDaoProvider(params));
  final userDao = ref.read(squadweUserDaoProvider(params));
  final messagesDao = ref.read(squadweMessagesDaoProvider(params));

  return LocalStorage(
      contactDao: contactDao,
      conversationDao: conversationDao,
      userDao: userDao,
      messagesDao: messagesDao);
});

///Provides an instance of squadwe repository
final squadweRepositoryProvider =
    Provider.family<SquadweRepository, RepositoryParameters>(
        (ref, repoParams) {
  final localStorage = ref.read(localStorageProvider(repoParams.params));
  final clientService =
      ref.read(squadweClientServiceProvider(repoParams.params));

  return SquadweRepositoryImpl(
      clientService: clientService,
      localStorage: localStorage,
      streamCallbacks: repoParams.callbacks);
});
