import 'package:squadwe_client_sdk/data/local/entity/squadwe_user.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class SquadweUserDao {
  Future<void> saveUser(SquadweUser user);
  SquadweUser? getUser();
  Future<void> deleteUser();
  Future<void> onDispose();
  Future<void> clearAll();
}

//Only used when persistence is enabled
enum SquadweUserBoxNames { USERS, CLIENT_INSTANCE_TO_USER }

class PersistedSquadweUserDao extends SquadweUserDao {
  //box containing chat users
  Box<SquadweUser> _box;
  //box with one to one relation between generated client instance id and user identifier
  final Box<String> _clientInstanceIdToUserIdentifierBox;

  final String _clientInstanceKey;

  PersistedSquadweUserDao(this._box, this._clientInstanceIdToUserIdentifierBox,
      this._clientInstanceKey);

  @override
  Future<void> deleteUser() async {
    final userIdentifier =
        _clientInstanceIdToUserIdentifierBox.get(_clientInstanceKey);
    await _clientInstanceIdToUserIdentifierBox.delete(_clientInstanceKey);
    await _box.delete(userIdentifier);
  }

  @override
  Future<void> saveUser(SquadweUser user) async {
    await _clientInstanceIdToUserIdentifierBox.put(
        _clientInstanceKey, user.identifier.toString());
    await _box.put(user.identifier, user);
  }

  @override
  SquadweUser? getUser() {
    if (_box.values.length == 0) {
      return null;
    }
    final userIdentifier =
        _clientInstanceIdToUserIdentifierBox.get(_clientInstanceKey);

    return _box.get(userIdentifier);
  }

  @override
  Future<void> onDispose() async {}

  @override
  Future<void> clearAll() async {
    await _box.clear();
    await _clientInstanceIdToUserIdentifierBox.clear();
  }

  static Future<void> openDB() async {
    await Hive.openBox<SquadweUser>(SquadweUserBoxNames.USERS.toString());
    await Hive.openBox<String>(
        SquadweUserBoxNames.CLIENT_INSTANCE_TO_USER.toString());
  }
}

class NonPersistedSquadweUserDao extends SquadweUserDao {
  SquadweUser? _user;

  @override
  Future<void> deleteUser() async {
    _user = null;
  }

  @override
  SquadweUser? getUser() {
    return _user;
  }

  @override
  Future<void> onDispose() async {
    _user = null;
  }

  @override
  Future<void> saveUser(SquadweUser user) async {
    _user = user;
  }

  @override
  Future<void> clearAll() async {
    _user = null;
  }
}
