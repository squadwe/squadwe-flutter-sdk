import 'package:squadwe_client_sdk/data/local/entity/squadwe_conversation.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class SquadweConversationDao {
  Future<void> saveConversation(SquadweConversation conversation);
  SquadweConversation? getConversation();
  Future<void> deleteConversation();
  Future<void> onDispose();
  Future<void> clearAll();
}

//Only used when persistence is enabled
enum SquadweConversationBoxNames {
  CONVERSATIONS,
  CLIENT_INSTANCE_TO_CONVERSATIONS
}

class PersistedSquadweConversationDao extends SquadweConversationDao {
  //box containing all persisted conversations
  Box<SquadweConversation> _box;

  //box with one to one relation between generated client instance id and conversation id
  final Box<String> _clientInstanceIdToConversationIdentifierBox;

  final String _clientInstanceKey;

  PersistedSquadweConversationDao(
      this._box,
      this._clientInstanceIdToConversationIdentifierBox,
      this._clientInstanceKey);

  @override
  Future<void> deleteConversation() async {
    final conversationIdentifier =
        _clientInstanceIdToConversationIdentifierBox.get(_clientInstanceKey);
    await _clientInstanceIdToConversationIdentifierBox
        .delete(_clientInstanceKey);
    await _box.delete(conversationIdentifier);
  }

  @override
  Future<void> saveConversation(SquadweConversation conversation) async {
    await _clientInstanceIdToConversationIdentifierBox.put(
        _clientInstanceKey, conversation.id.toString());
    await _box.put(conversation.id, conversation);
  }

  @override
  SquadweConversation? getConversation() {
    if (_box.values.length == 0) {
      return null;
    }

    final conversationidentifierString =
        _clientInstanceIdToConversationIdentifierBox.get(_clientInstanceKey);
    final conversationIdentifier =
        int.tryParse(conversationidentifierString ?? "");

    if (conversationIdentifier == null) {
      return null;
    }

    return _box.get(conversationIdentifier);
  }

  @override
  Future<void> onDispose() async {}

  static Future<void> openDB() async {
    await Hive.openBox<SquadweConversation>(
        SquadweConversationBoxNames.CONVERSATIONS.toString());
    await Hive.openBox<String>(SquadweConversationBoxNames
        .CLIENT_INSTANCE_TO_CONVERSATIONS
        .toString());
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
    await _clientInstanceIdToConversationIdentifierBox.clear();
  }
}

class NonPersistedSquadweConversationDao extends SquadweConversationDao {
  SquadweConversation? _conversation;

  @override
  Future<void> deleteConversation() async {
    _conversation = null;
  }

  @override
  SquadweConversation? getConversation() {
    return _conversation;
  }

  @override
  Future<void> onDispose() async {
    _conversation = null;
  }

  @override
  Future<void> saveConversation(SquadweConversation conversation) async {
    _conversation = conversation;
  }

  @override
  Future<void> clearAll() async {
    _conversation = null;
  }
}
