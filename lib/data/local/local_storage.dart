import 'package:squadwe_client_sdk/data/local/dao/squadwe_contact_dao.dart';
import 'package:squadwe_client_sdk/data/local/dao/squadwe_conversation_dao.dart';
import 'package:squadwe_client_sdk/data/local/dao/squadwe_messages_dao.dart';
import 'package:squadwe_client_sdk/data/local/dao/squadwe_user_dao.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_conversation.dart';
import 'package:squadwe_client_sdk/data/remote/responses/squadwe_event.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'entity/squadwe_contact.dart';
import 'entity/squadwe_conversation.dart';
import 'entity/squadwe_message.dart';
import 'entity/squadwe_user.dart';

const SQUADWE_CONTACT_HIVE_TYPE_ID = 0;
const SQUADWE_CONVERSATION_HIVE_TYPE_ID = 1;
const SQUADWE_MESSAGE_HIVE_TYPE_ID = 2;
const SQUADWE_USER_HIVE_TYPE_ID = 3;
const SQUADWE_EVENT_USER_HIVE_TYPE_ID = 4;

class LocalStorage {
  SquadweUserDao userDao;
  SquadweConversationDao conversationDao;
  SquadweContactDao contactDao;
  SquadweMessagesDao messagesDao;

  LocalStorage({
    required this.userDao,
    required this.conversationDao,
    required this.contactDao,
    required this.messagesDao,
  });

  static Future<void> openDB({void Function()? onInitializeHive}) async {
    if (onInitializeHive == null) {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(SQUADWE_CONTACT_HIVE_TYPE_ID)) {
        Hive..registerAdapter(SquadweContactAdapter());
      }
      if (!Hive.isAdapterRegistered(SQUADWE_CONVERSATION_HIVE_TYPE_ID)) {
        Hive..registerAdapter(SquadweConversationAdapter());
      }
      if (!Hive.isAdapterRegistered(SQUADWE_MESSAGE_HIVE_TYPE_ID)) {
        Hive..registerAdapter(SquadweMessageAdapter());
      }
      if (!Hive.isAdapterRegistered(SQUADWE_EVENT_USER_HIVE_TYPE_ID)) {
        Hive..registerAdapter(SquadweEventMessageUserAdapter());
      }
      if (!Hive.isAdapterRegistered(SQUADWE_USER_HIVE_TYPE_ID)) {
        Hive..registerAdapter(SquadweUserAdapter());
      }
    } else {
      onInitializeHive();
    }

    await PersistedSquadweContactDao.openDB();
    await PersistedSquadweConversationDao.openDB();
    await PersistedSquadweMessagesDao.openDB();
    await PersistedSquadweUserDao.openDB();
  }

  Future<void> clear({bool clearSquadweUserStorage = true}) async {
    await conversationDao.deleteConversation();
    await messagesDao.clear();
    if (clearSquadweUserStorage) {
      await userDao.deleteUser();
      await contactDao.deleteContact();
    }
  }

  Future<void> clearAll() async {
    await conversationDao.clearAll();
    await contactDao.clearAll();
    await messagesDao.clearAll();
    await userDao.clearAll();
  }

  dispose() {
    userDao.onDispose();
    conversationDao.onDispose();
    contactDao.onDispose();
    messagesDao.onDispose();
  }
}
