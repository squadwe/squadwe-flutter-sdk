import 'package:hive_flutter/hive_flutter.dart';

import '../entity/squadwe_contact.dart';

///Data access object for retriving squadwe contact from local storage
abstract class SquadweContactDao {
  Future<void> saveContact(SquadweContact contact);
  SquadweContact? getContact();
  Future<void> deleteContact();
  Future<void> onDispose();
  Future<void> clearAll();
}

//Only used when persistence is enabled
enum SquadweContactBoxNames { CONTACTS, CLIENT_INSTANCE_TO_CONTACTS }

class PersistedSquadweContactDao extends SquadweContactDao {
  //box containing all persisted contacts
  Box<SquadweContact> _box;

  //_box with one to one relation between generated client instance id and conversation id
  final Box<String> _clientInstanceIdToContactIdentifierBox;

  final String _clientInstanceKey;

  PersistedSquadweContactDao(this._box,
      this._clientInstanceIdToContactIdentifierBox, this._clientInstanceKey);

  @override
  Future<void> deleteContact() async {
    final contactIdentifier =
        _clientInstanceIdToContactIdentifierBox.get(_clientInstanceKey);
    await _clientInstanceIdToContactIdentifierBox.delete(_clientInstanceKey);
    await _box.delete(contactIdentifier);
  }

  @override
  Future<void> saveContact(SquadweContact contact) async {
    await _clientInstanceIdToContactIdentifierBox.put(
        _clientInstanceKey, contact.contactIdentifier!);
    await _box.put(contact.contactIdentifier, contact);
  }

  @override
  SquadweContact? getContact() {
    if (_box.values.length == 0) {
      return null;
    }

    final contactIdentifier =
        _clientInstanceIdToContactIdentifierBox.get(_clientInstanceKey);

    if (contactIdentifier == null) {
      return null;
    }

    return _box.get(contactIdentifier, defaultValue: null);
  }

  @override
  Future<void> onDispose() async {}

  Future<void> clearAll() async {
    await _box.clear();
    await _clientInstanceIdToContactIdentifierBox.clear();
  }

  static Future<void> openDB() async {
    await Hive.openBox<SquadweContact>(
        SquadweContactBoxNames.CONTACTS.toString());
    await Hive.openBox<String>(
        SquadweContactBoxNames.CLIENT_INSTANCE_TO_CONTACTS.toString());
  }
}

class NonPersistedSquadweContactDao extends SquadweContactDao {
  SquadweContact? _contact;

  @override
  Future<void> deleteContact() async {
    _contact = null;
  }

  @override
  SquadweContact? getContact() {
    return _contact;
  }

  @override
  Future<void> onDispose() async {
    _contact = null;
  }

  @override
  Future<void> saveContact(SquadweContact contact) async {
    _contact = contact;
  }

  Future<void> clearAll() async {
    _contact = null;
  }
}
