import 'dart:io';

import 'package:squadwe_client_sdk/data/local/dao/squadwe_conversation_dao.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_contact.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_conversation.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../utils/test_resources_util.dart';

void main() {
  group("Persisted Squadwe Conversation Dao Tests", () {
    late PersistedSquadweConversationDao dao;
    late Box<String> mockClientInstanceKeyToConversationBox;
    late Box<SquadweConversation> mockConversationBox;
    final testClientInstanceKey = "testKey";

    late final SquadweConversation testConversation;

    setUpAll(() {
      return Future(() async {
        testConversation = SquadweConversation.fromJson(
            await TestResourceUtil.readJsonResource(fileName: "conversation"));

        final hiveTestPath = Directory.current.path + '/test/hive_testing_path';
        Hive
          ..init(hiveTestPath)
          ..registerAdapter(SquadweConversationAdapter())
          ..registerAdapter(SquadweContactAdapter())
          ..registerAdapter(SquadweMessageAdapter());
      });
    });

    setUp(() {
      return Future(() async {
        mockConversationBox = await Hive.openBox(
            SquadweConversationBoxNames.CONVERSATIONS.toString());
        mockClientInstanceKeyToConversationBox = await Hive.openBox(
            SquadweConversationBoxNames.CLIENT_INSTANCE_TO_CONVERSATIONS
                .toString());

        dao = PersistedSquadweConversationDao(mockConversationBox,
            mockClientInstanceKeyToConversationBox, testClientInstanceKey);
      });
    });

    test(
        'Given conversation is successfully deleted when deleteConversation is called, then getConversation should return null',
        () async {
      //GIVEN
      await dao.saveConversation(testConversation);

      //WHEN
      await dao.deleteConversation();

      //THEN
      expect(dao.getConversation(), null);
    });

    test(
        'Given conversation is successfully save when saveConversation is called, then getConversation should return saved conversation',
        () async {
      //WHEN
      await dao.saveConversation(testConversation);

      //THEN
      expect(dao.getConversation(), testConversation);
    });

    test(
        'Given conversation is successfully retrieved when getConversation is called, then retrieved conversation should not be null',
        () async {
      //GIVEN
      await dao.saveConversation(testConversation);

      //WHEN
      final retrievedConversation = dao.getConversation();

      //THEN
      expect(retrievedConversation, testConversation);
    });

    test(
        'Given conversations are successfully cleared when clearAll is called, then retrieving a conversation should be null',
        () async {
      //GIVEN
      await dao.saveConversation(testConversation);

      //WHEN
      await dao.clearAll();

      //THEN
      expect(dao.getConversation(), null);
    });

    tearDown(() {
      return Future(() async {
        try {
          await mockConversationBox.clear();
          await mockClientInstanceKeyToConversationBox.clear();
        } on HiveError catch (e) {
          print(e);
        }
      });
    });

    tearDownAll(() {
      return Future(() async {
        await mockConversationBox.close();
        await mockClientInstanceKeyToConversationBox.close();
      });
    });
  });
}
