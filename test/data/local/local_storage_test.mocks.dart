// Mocks generated by Mockito 5.0.15 from annotations
// in squadwe_client_sdk/test/data/local/local_storage_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:squadwe_client_sdk/data/local/dao/squadwe_contact_dao.dart'
    as _i5;
import 'package:squadwe_client_sdk/data/local/dao/squadwe_conversation_dao.dart'
    as _i2;
import 'package:squadwe_client_sdk/data/local/dao/squadwe_messages_dao.dart'
    as _i7;
import 'package:squadwe_client_sdk/data/local/dao/squadwe_user_dao.dart'
    as _i9;
import 'package:squadwe_client_sdk/data/local/entity/squadwe_contact.dart'
    as _i6;
import 'package:squadwe_client_sdk/data/local/entity/squadwe_conversation.dart'
    as _i4;
import 'package:squadwe_client_sdk/data/local/entity/squadwe_message.dart'
    as _i8;
import 'package:squadwe_client_sdk/data/local/entity/squadwe_user.dart'
    as _i10;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis

/// A class which mocks [SquadweConversationDao].
///
/// See the documentation for Mockito's code generation for more information.
class MockSquadweConversationDao extends _i1.Mock
    implements _i2.SquadweConversationDao {
  MockSquadweConversationDao() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> saveConversation(_i4.SquadweConversation? conversation) =>
      (super.noSuchMethod(Invocation.method(#saveConversation, [conversation]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> deleteConversation() =>
      (super.noSuchMethod(Invocation.method(#deleteConversation, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> onDispose() =>
      (super.noSuchMethod(Invocation.method(#onDispose, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> clearAll() =>
      (super.noSuchMethod(Invocation.method(#clearAll, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  String toString() => super.toString();
}

/// A class which mocks [SquadweContactDao].
///
/// See the documentation for Mockito's code generation for more information.
class MockSquadweContactDao extends _i1.Mock
    implements _i5.SquadweContactDao {
  MockSquadweContactDao() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> saveContact(_i6.SquadweContact? contact) =>
      (super.noSuchMethod(Invocation.method(#saveContact, [contact]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> deleteContact() =>
      (super.noSuchMethod(Invocation.method(#deleteContact, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> onDispose() =>
      (super.noSuchMethod(Invocation.method(#onDispose, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> clearAll() =>
      (super.noSuchMethod(Invocation.method(#clearAll, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  String toString() => super.toString();
}

/// A class which mocks [SquadweMessagesDao].
///
/// See the documentation for Mockito's code generation for more information.
class MockSquadweMessagesDao extends _i1.Mock
    implements _i7.SquadweMessagesDao {
  MockSquadweMessagesDao() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> saveMessage(_i8.SquadweMessage? message) =>
      (super.noSuchMethod(Invocation.method(#saveMessage, [message]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> saveAllMessages(List<_i8.SquadweMessage>? messages) =>
      (super.noSuchMethod(Invocation.method(#saveAllMessages, [messages]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i8.SquadweMessage? getMessage(int? messageId) =>
      (super.noSuchMethod(Invocation.method(#getMessage, [messageId]))
          as _i8.SquadweMessage?);
  @override
  List<_i8.SquadweMessage> getMessages() =>
      (super.noSuchMethod(Invocation.method(#getMessages, []),
          returnValue: <_i8.SquadweMessage>[]) as List<_i8.SquadweMessage>);
  @override
  _i3.Future<void> clear() => (super.noSuchMethod(Invocation.method(#clear, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> deleteMessage(int? messageId) =>
      (super.noSuchMethod(Invocation.method(#deleteMessage, [messageId]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> onDispose() =>
      (super.noSuchMethod(Invocation.method(#onDispose, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> clearAll() =>
      (super.noSuchMethod(Invocation.method(#clearAll, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  String toString() => super.toString();
}

/// A class which mocks [PersistedSquadweConversationDao].
///
/// See the documentation for Mockito's code generation for more information.
class MockPersistedSquadweConversationDao extends _i1.Mock
    implements _i2.PersistedSquadweConversationDao {
  MockPersistedSquadweConversationDao() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> deleteConversation() =>
      (super.noSuchMethod(Invocation.method(#deleteConversation, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> saveConversation(_i4.SquadweConversation? conversation) =>
      (super.noSuchMethod(Invocation.method(#saveConversation, [conversation]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> onDispose() =>
      (super.noSuchMethod(Invocation.method(#onDispose, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> clearAll() =>
      (super.noSuchMethod(Invocation.method(#clearAll, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  String toString() => super.toString();
}

/// A class which mocks [PersistedSquadweContactDao].
///
/// See the documentation for Mockito's code generation for more information.
class MockPersistedSquadweContactDao extends _i1.Mock
    implements _i5.PersistedSquadweContactDao {
  MockPersistedSquadweContactDao() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> deleteContact() =>
      (super.noSuchMethod(Invocation.method(#deleteContact, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> saveContact(_i6.SquadweContact? contact) =>
      (super.noSuchMethod(Invocation.method(#saveContact, [contact]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> onDispose() =>
      (super.noSuchMethod(Invocation.method(#onDispose, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> clearAll() =>
      (super.noSuchMethod(Invocation.method(#clearAll, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  String toString() => super.toString();
}

/// A class which mocks [PersistedSquadweMessagesDao].
///
/// See the documentation for Mockito's code generation for more information.
class MockPersistedSquadweMessagesDao extends _i1.Mock
    implements _i7.PersistedSquadweMessagesDao {
  MockPersistedSquadweMessagesDao() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> clear() => (super.noSuchMethod(Invocation.method(#clear, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> saveMessage(_i8.SquadweMessage? message) =>
      (super.noSuchMethod(Invocation.method(#saveMessage, [message]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> saveAllMessages(List<_i8.SquadweMessage>? messages) =>
      (super.noSuchMethod(Invocation.method(#saveAllMessages, [messages]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  List<_i8.SquadweMessage> getMessages() =>
      (super.noSuchMethod(Invocation.method(#getMessages, []),
          returnValue: <_i8.SquadweMessage>[]) as List<_i8.SquadweMessage>);
  @override
  _i3.Future<void> onDispose() =>
      (super.noSuchMethod(Invocation.method(#onDispose, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> deleteMessage(int? messageId) =>
      (super.noSuchMethod(Invocation.method(#deleteMessage, [messageId]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i8.SquadweMessage? getMessage(int? messageId) =>
      (super.noSuchMethod(Invocation.method(#getMessage, [messageId]))
          as _i8.SquadweMessage?);
  @override
  _i3.Future<void> clearAll() =>
      (super.noSuchMethod(Invocation.method(#clearAll, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  String toString() => super.toString();
}

/// A class which mocks [SquadweUserDao].
///
/// See the documentation for Mockito's code generation for more information.
class MockSquadweUserDao extends _i1.Mock implements _i9.SquadweUserDao {
  MockSquadweUserDao() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> saveUser(_i10.SquadweUser? user) =>
      (super.noSuchMethod(Invocation.method(#saveUser, [user]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> deleteUser() =>
      (super.noSuchMethod(Invocation.method(#deleteUser, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> onDispose() =>
      (super.noSuchMethod(Invocation.method(#onDispose, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> clearAll() =>
      (super.noSuchMethod(Invocation.method(#clearAll, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  String toString() => super.toString();
}

/// A class which mocks [PersistedSquadweUserDao].
///
/// See the documentation for Mockito's code generation for more information.
class MockPersistedSquadweUserDao extends _i1.Mock
    implements _i9.PersistedSquadweUserDao {
  MockPersistedSquadweUserDao() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<void> deleteUser() =>
      (super.noSuchMethod(Invocation.method(#deleteUser, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> saveUser(_i10.SquadweUser? user) =>
      (super.noSuchMethod(Invocation.method(#saveUser, [user]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> onDispose() =>
      (super.noSuchMethod(Invocation.method(#onDispose, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  _i3.Future<void> clearAll() =>
      (super.noSuchMethod(Invocation.method(#clearAll, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i3.Future<void>);
  @override
  String toString() => super.toString();
}
