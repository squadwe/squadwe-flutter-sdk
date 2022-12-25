import 'dart:io';

import 'package:squadwe_client_sdk/data/local/dao/squadwe_contact_dao.dart';
import 'package:squadwe_client_sdk/data/local/dao/squadwe_conversation_dao.dart';
import 'package:squadwe_client_sdk/data/local/dao/squadwe_messages_dao.dart';
import 'package:squadwe_client_sdk/data/local/dao/squadwe_user_dao.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_contact.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_conversation.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_message.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_user.dart';
import 'package:squadwe_client_sdk/data/local/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'local_storage_test.mocks.dart';

@GenerateMocks([
  SquadweConversationDao,
  SquadweContactDao,
  SquadweMessagesDao,
  PersistedSquadweConversationDao,
  PersistedSquadweContactDao,
  PersistedSquadweMessagesDao,
  SquadweUserDao,
  PersistedSquadweUserDao
])
void main() {
  group("Local Storage Tests", () {
    final mockContactDao = MockSquadweContactDao();
    final mockConversationDao = MockSquadweConversationDao();
    final mockUserDao = MockSquadweUserDao();
    final mockMessagesDao = MockSquadweMessagesDao();

    late final LocalStorage localStorage;

    setUpAll(() {
      final hiveTestPath = Directory.current.path + '/test/hive_testing_path';

      Hive
        ..init(hiveTestPath)
        ..registerAdapter(SquadweContactAdapter())
        ..registerAdapter(SquadweConversationAdapter())
        ..registerAdapter(SquadweMessageAdapter())
        ..registerAdapter(SquadweUserAdapter());

      localStorage = LocalStorage(
          userDao: mockUserDao,
          conversationDao: mockConversationDao,
          contactDao: mockContactDao,
          messagesDao: mockMessagesDao);
    });

    test(
        'Given persisted db is successfully opened when openDB is called, then all hive boxes should be open',
        () async {
      //WHEN
      await LocalStorage.openDB(onInitializeHive: () {});

      //THEN
      expect(true, Hive.isBoxOpen(SquadweContactBoxNames.CONTACTS.toString()));
      expect(
          true,
          Hive.isBoxOpen(
              SquadweContactBoxNames.CLIENT_INSTANCE_TO_CONTACTS.toString()));
      expect(
          true,
          Hive.isBoxOpen(
              SquadweConversationBoxNames.CONVERSATIONS.toString()));
      expect(
          true,
          Hive.isBoxOpen(SquadweConversationBoxNames
              .CLIENT_INSTANCE_TO_CONVERSATIONS
              .toString()));
      expect(
          true, Hive.isBoxOpen(SquadweMessagesBoxNames.MESSAGES.toString()));
      expect(
          true,
          Hive.isBoxOpen(SquadweMessagesBoxNames
              .MESSAGES_TO_CLIENT_INSTANCE_KEY
              .toString()));
      expect(true, Hive.isBoxOpen(SquadweUserBoxNames.USERS.toString()));
      expect(true, Hive.isBoxOpen(SquadweUserBoxNames.USERS.toString()));
    });

    test(
        'Given localStorage is successfully cleared when clear is called, then daos should be cleared',
        () async {
      //WHEN
      await localStorage.clear(clearSquadweUserStorage: true);

      //THEN
      verify(mockContactDao.deleteContact());
      verify(mockConversationDao.deleteConversation());
      verify(mockMessagesDao.clear());
      verify(mockUserDao.deleteUser());
    });

    test(
        'Given localStorage is successfully cleared except user db when clear is called, then daos should be cleared except user db',
        () async {
      //WHEN
      await localStorage.clear(clearSquadweUserStorage: false);

      //THEN
      verifyNever(mockContactDao.deleteContact());
      verify(mockConversationDao.deleteConversation());
      verify(mockMessagesDao.clear());
      verifyNever(mockUserDao.deleteUser());
    });

    test(
        'Given all data is successfully cleared when clearAll is called, then all data daos should be cleared',
        () async {
      //WHEN
      await localStorage.clearAll();

      //THEN
      verify(mockContactDao.clearAll());
      verify(mockConversationDao.clearAll());
      verify(mockMessagesDao.clearAll());
      verify(mockUserDao.clearAll());
    });

    test(
        'Given localStorage is successfully disposed when dispose is called, then all daos should be disposed',
        () {
      //WHEN
      localStorage.dispose();

      //THEN
      verify(mockContactDao.onDispose());
      verify(mockConversationDao.onDispose());
      verify(mockMessagesDao.onDispose());
      verify(mockUserDao.onDispose());
    });

    tearDownAll(() async {
      await Hive.close();
    });
  });
}
