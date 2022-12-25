import 'dart:io';

import 'package:squadwe_client_sdk/data/local/dao/squadwe_contact_dao.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_contact.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../utils/test_resources_util.dart';

void main() {
  group("Persisted Squadwe Contact Dao Tests", () {
    late PersistedSquadweContactDao dao;
    late Box<String> mockClientInstanceKeyToContactBox;
    late Box<SquadweContact> mockContactBox;
    final testClientInstanceKey = "testKey";

    late final SquadweContact testContact;

    setUpAll(() {
      return Future(() async {
        testContact = SquadweContact.fromJson(
            await TestResourceUtil.readJsonResource(fileName: "contact"));
        final hiveTestPath = Directory.current.path + '/test/hive_testing_path';
        Hive
          ..init(hiveTestPath)
          ..registerAdapter(SquadweContactAdapter());
      });
    });

    setUp(() {
      return Future(() async {
        mockContactBox =
            await Hive.openBox(SquadweContactBoxNames.CONTACTS.toString());
        mockClientInstanceKeyToContactBox = await Hive.openBox(
            SquadweContactBoxNames.CLIENT_INSTANCE_TO_CONTACTS.toString());

        dao = PersistedSquadweContactDao(mockContactBox,
            mockClientInstanceKeyToContactBox, testClientInstanceKey);
      });
    });

    test(
        'Given contact is successfully deleted when deleteContact is called, then getContact should return null',
        () async {
      //GIVEN
      await dao.saveContact(testContact);

      //WHEN
      await dao.deleteContact();

      //THEN
      expect(dao.getContact(), null);
    });

    test(
        'Given contact is successfully save when saveContact is called, then getContact should return saved contact',
        () async {
      //WHEN
      await dao.saveContact(testContact);

      //THEN
      expect(dao.getContact(), testContact);
    });

    test(
        'Given contact is successfully retrieved when getContact is called, then retrieved contact should not be null',
        () async {
      //GIVEN
      await dao.saveContact(testContact);

      //WHEN
      final retrievedContact = dao.getContact();

      //THEN
      expect(retrievedContact, testContact);
    });

    test(
        'Given contacts are successfully cleared when clearAll is called, then retrieved contact should be null',
        () async {
      //GIVEN
      await dao.saveContact(testContact);

      //WHEN
      await dao.clearAll();

      //THEN
      expect(dao.getContact(), null);
    });

    tearDown(() {
      return Future(() async {
        try {
          await mockContactBox.clear();
          await mockClientInstanceKeyToContactBox.clear();
        } on HiveError catch (e) {
          print(e);
        }
      });
    });

    tearDownAll(() {
      return Future(() async {
        await mockContactBox.close();
        await mockClientInstanceKeyToContactBox.close();
      });
    });
  });
}
