import 'dart:io';

import 'package:squadwe_client_sdk/squadwe_client_sdk.dart';
import 'package:squadwe_client_sdk/squadwe_parameters.dart';
import 'package:squadwe_client_sdk/data/local/dao/squadwe_contact_dao.dart';
import 'package:squadwe_client_sdk/data/local/dao/squadwe_conversation_dao.dart';
import 'package:squadwe_client_sdk/data/local/dao/squadwe_messages_dao.dart';
import 'package:squadwe_client_sdk/data/local/dao/squadwe_user_dao.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_contact.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_conversation.dart';
import 'package:squadwe_client_sdk/data/remote/responses/squadwe_event.dart';
import 'package:squadwe_client_sdk/di/modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  group("Modules Test", () {
    late ProviderContainer providerContainer;

    final testSquadweParameters = SquadweParameters(
        isPersistenceEnabled: true,
        baseUrl: "https://testbaseUrl.com",
        inboxIdentifier: "testInboxIdentifier",
        clientInstanceKey: "testInstanceKey");

    setUpAll(() async {
      providerContainer = ProviderContainer();
      final hiveTestPath = Directory.current.path + '/test/hive_testing_path';
      Hive
        ..init(hiveTestPath)
        ..registerAdapter(SquadweContactAdapter())
        ..registerAdapter(SquadweConversationAdapter())
        ..registerAdapter(SquadweMessageAdapter())
        ..registerAdapter(SquadweEventMessageUserAdapter())
        ..registerAdapter(SquadweUserAdapter());

      await PersistedSquadweMessagesDao.openDB();
      await PersistedSquadweConversationDao.openDB();
      await PersistedSquadweContactDao.openDB();
      await PersistedSquadweUserDao.openDB();
    });

    test(
        'Given Dio instance is successfully provided when a read unauthenticatedDioProvider is called, then instance should be constructed properly',
        () async {
      //WHEN
      final result = providerContainer
          .read(unauthenticatedDioProvider(testSquadweParameters));

      //THEN
      expect(result.options.baseUrl, equals(testSquadweParameters.baseUrl));
      expect(result.interceptors.isEmpty, equals(true));
    });

    test(
        'Given SquadweClientAuthService instance is successfully provided when a read squadweClientAuthServiceProvider is called, then instance should be constructed properly',
        () async {
      //WHEN
      final result = providerContainer
          .read(squadweClientAuthServiceProvider(testSquadweParameters));

      //THEN
      expect(result.dio.interceptors.length, equals(0));
    });

    test(
        'Given Dio instance is successfully provided when a read authenticatedDioProvider is called, then instance should be constructed properly',
        () async {
      //WHEN
      final result = providerContainer
          .read(authenticatedDioProvider(testSquadweParameters));

      //THEN
      expect(result.options.baseUrl, equals(testSquadweParameters.baseUrl));
      expect(result.interceptors.length, equals(1));
    });

    test(
        'Given SquadweContactDao instance is successfully provided when a read squadweContactDaoProvider is called with persistence enabled, then return instance of PersistedSquadweContactDao',
        () async {
      //GIVEN
      final testSquadweParameters = SquadweParameters(
          isPersistenceEnabled: true,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(squadweContactDaoProvider(testSquadweParameters));

      //THEN
      expect(result is PersistedSquadweContactDao, equals(true));
    });

    test(
        'Given SquadweContactDao instance is successfully provided when a read squadweContactDaoProvider is called with persistence enabled, then return instance of PersistedSquadweContactDao',
        () async {
      //GIVEN
      final testSquadweParameters = SquadweParameters(
          isPersistenceEnabled: false,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(squadweContactDaoProvider(testSquadweParameters));

      //THEN
      expect(result is NonPersistedSquadweContactDao, equals(true));
    });

    test(
        'Given SquadweConversationDao instance is successfully provided when a read squadweConversationDaoProvider is called with persistence enabled, then return instance of PersistedSquadweContactDao',
        () async {
      //GIVEN
      final testSquadweParameters = SquadweParameters(
          isPersistenceEnabled: true,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(squadweConversationDaoProvider(testSquadweParameters));

      //THEN
      expect(result is PersistedSquadweConversationDao, equals(true));
    });

    test(
        'Given SquadweConversationDao instance is successfully provided when a read squadweConversationDaoProvider is called with persistence enabled, then return instance of PersistedSquadweContactDao',
        () async {
      //GIVEN
      final testSquadweParameters = SquadweParameters(
          isPersistenceEnabled: false,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(squadweConversationDaoProvider(testSquadweParameters));

      //THEN
      expect(result is NonPersistedSquadweConversationDao, equals(true));
    });

    test(
        'Given SquadweMessagesDao instance is successfully provided when a read squadweMessagesDaoProvider is called with persistence enabled, then return instance of PersistedSquadweContactDao',
        () async {
      //GIVEN
      final testSquadweParameters = SquadweParameters(
          isPersistenceEnabled: true,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(squadweMessagesDaoProvider(testSquadweParameters));

      //THEN
      expect(result is PersistedSquadweMessagesDao, equals(true));
    });

    test(
        'Given SquadweMessagesDao instance is successfully provided when a read squadweMessagesDaoProvider is called with persistence enabled, then return instance of PersistedSquadweContactDao',
        () async {
      //GIVEN
      final testSquadweParameters = SquadweParameters(
          isPersistenceEnabled: false,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(squadweMessagesDaoProvider(testSquadweParameters));

      //THEN
      expect(result is NonPersistedSquadweMessagesDao, equals(true));
    });

    test(
        'Given SquadweUserDao instance is successfully provided when a read squadweUserDaoProvider is called with persistence enabled, then return instance of PersistedSquadweContactDao',
        () async {
      //GIVEN
      final testSquadweParameters = SquadweParameters(
          isPersistenceEnabled: true,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(squadweUserDaoProvider(testSquadweParameters));

      //THEN
      expect(result is PersistedSquadweUserDao, equals(true));
    });

    test(
        'Given SquadweUserDao instance is successfully provided when a read squadweUserDaoProvider is called with persistence enabled, then return instance of PersistedSquadweContactDao',
        () async {
      //GIVEN
      final testSquadweParameters = SquadweParameters(
          isPersistenceEnabled: false,
          baseUrl: "https://testbaseUrl.com",
          inboxIdentifier: "testInboxIdentifier",
          clientInstanceKey: "testInstanceKey");

      //WHEN
      final result = providerContainer
          .read(squadweUserDaoProvider(testSquadweParameters));

      //THEN
      expect(result is NonPersistedSquadweUserDao, equals(true));
    });

    tearDownAll(() async {
      Hive.close();
    });
  });
}
