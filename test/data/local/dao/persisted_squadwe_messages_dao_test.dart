import 'dart:io';

import 'package:squadwe_client_sdk/data/local/dao/squadwe_messages_dao.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_message.dart';
import 'package:squadwe_client_sdk/data/remote/responses/squadwe_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../utils/test_resources_util.dart';

void main() {
  group("Persisted Squadwe Message Dao Tests", () {
    late PersistedSquadweMessagesDao dao;
    late Box<String> mockClientInstanceKeyToMessageBox;
    late Box<SquadweMessage> mockMessageBox;
    final testClientInstanceKey = "testKey";

    late final SquadweMessage testMessage;

    setUpAll(() {
      return Future(() async {
        final hiveTestPath = Directory.current.path + '/test/hive_testing_path';
        Hive
          ..init(hiveTestPath)
          ..registerAdapter(SquadweMessageAdapter())
          ..registerAdapter(SquadweEventMessageUserAdapter());

        testMessage = SquadweMessage.fromJson(
            await TestResourceUtil.readJsonResource(fileName: "message"));
      });
    });

    setUp(() {
      return Future(() async {
        mockMessageBox =
            await Hive.openBox(SquadweMessagesBoxNames.MESSAGES.toString());
        mockClientInstanceKeyToMessageBox = await Hive.openBox(
            SquadweMessagesBoxNames.MESSAGES_TO_CLIENT_INSTANCE_KEY
                .toString());

        dao = PersistedSquadweMessagesDao(mockMessageBox,
            mockClientInstanceKeyToMessageBox, testClientInstanceKey);
      });
    });

    test(
        'Given message is successfully deleted when deleteMessage is called, then getMessage should return null',
        () async {
      //GIVEN
      await dao.saveMessage(testMessage);

      //WHEN
      await dao.deleteMessage(testMessage.id);

      //THEN
      expect(dao.getMessage(testMessage.id), null);
    });

    test(
        'Given message is successfully save when saveMessage is called, then getMessage should return saved message',
        () async {
      //WHEN
      await dao.saveMessage(testMessage);

      //THEN
      expect(dao.getMessage(testMessage.id), testMessage);
    });

    test(
        'Given messages are successfully saved when saveMessages is called, then getMessages should return saved messages',
        () async {
      final messages = [testMessage];

      //WHEN
      await dao.saveAllMessages(messages);

      //THEN
      expect(dao.getMessages(), messages);
    });

    test(
        'Given message is successfully retrieved when getMessage is called, then retrieved message should not be null',
        () async {
      //GIVEN
      await dao.saveMessage(testMessage);

      //WHEN
      final retrievedMessage = dao.getMessage(testMessage.id);

      //THEN
      expect(retrievedMessage, testMessage);
    });

    test(
        'Given messages exist in database when getMessages is called, then retrieved messages should not be empty',
        () async {
      //GIVEN
      await dao.saveMessage(testMessage);

      //WHEN
      final retrievedMessages = dao.getMessages();

      //THEN
      expect(retrievedMessages.length, 1);
      expect(retrievedMessages[0], testMessage);
    });

    test(
        'Given messages do not exist in database when getMessages is called, then retrieved messages should be empty',
        () async {
      //GIVEN
      await dao.clear();

      //WHEN
      final retrievedMessages = dao.getMessages();

      //THEN
      expect(retrievedMessages.length, 0);
    });

    test(
        'Given messages are successfully cleared when clear is called, then no message should exist in database',
        () async {
      //GIVEN
      await dao.saveMessage(testMessage);

      //WHEN
      await dao.clear();

      //THEN
      final retrievedMessages = dao.getMessages();
      expect(retrievedMessages.length, 0);
    });

    test(
        'Given messages are successfully cleared when clearAll is called, then retrieving messages should be empty',
        () async {
      //GIVEN
      await dao.saveMessage(testMessage);

      //WHEN
      await dao.clearAll();

      //THEN
      expect(dao.getMessages().isEmpty, true);
    });

    tearDown(() {
      return Future(() async {
        try {
          await mockMessageBox.clear();
          await mockClientInstanceKeyToMessageBox.clear();
        } on HiveError catch (e) {
          print(e);
        }
      });
    });

    tearDownAll(() {
      return Future(() async {
        await mockMessageBox.close();
        await mockClientInstanceKeyToMessageBox.close();
      });
    });
  });
}
