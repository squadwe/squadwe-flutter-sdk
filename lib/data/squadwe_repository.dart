import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:squadwe_client_sdk/squadwe_callbacks.dart';
import 'package:squadwe_client_sdk/squadwe_client.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_user.dart';
import 'package:squadwe_client_sdk/data/local/local_storage.dart';
import 'package:squadwe_client_sdk/data/remote/squadwe_client_exception.dart';
import 'package:squadwe_client_sdk/data/remote/requests/squadwe_action_data.dart';
import 'package:squadwe_client_sdk/data/remote/requests/squadwe_new_message_request.dart';
import 'package:squadwe_client_sdk/data/remote/responses/squadwe_event.dart';
import 'package:squadwe_client_sdk/data/remote/service/squadwe_client_service.dart';
import 'package:flutter/material.dart';

/// Handles interactions between squadwe client api service[clientService] and
/// [localStorage] if persistence is enabled.
///
/// Results from repository operations are passed through [callbacks] to be handled
/// appropriately
abstract class SquadweRepository {
  @protected
  final SquadweClientService clientService;
  @protected
  final LocalStorage localStorage;
  @protected
  SquadweCallbacks callbacks;
  List<StreamSubscription> _subscriptions = [];

  SquadweRepository(this.clientService, this.localStorage, this.callbacks);

  Future<void> initialize(SquadweUser? user);

  void getPersistedMessages();

  Future<void> getMessages();

  void listenForEvents();

  Future<void> sendMessage(SquadweNewMessageRequest request);

  void sendAction(SquadweActionType action);

  Future<void> clear();

  void dispose();
}

class SquadweRepositoryImpl extends SquadweRepository {
  bool _isListeningForEvents = false;
  Timer? _publishPresenceTimer;
  Timer? _presenceResetTimer;

  SquadweRepositoryImpl(
      {required SquadweClientService clientService,
      required LocalStorage localStorage,
      required SquadweCallbacks streamCallbacks})
      : super(clientService, localStorage, streamCallbacks);

  /// Fetches persisted messages.
  ///
  /// Calls [SquadweCallbacks.onMessagesRetrieved] when [SquadweClientService.getAllMessages] is successful
  /// Calls [SquadweCallbacks.onError] when [SquadweClientService.getAllMessages] fails
  @override
  Future<void> getMessages() async {
    try {
      final messages = await clientService.getAllMessages();
      await localStorage.messagesDao.saveAllMessages(messages);
      callbacks.onMessagesRetrieved?.call(messages);
    } on SquadweClientException catch (e) {
      callbacks.onError?.call(e);
    }
  }

  /// Fetches persisted messages.
  ///
  /// Calls [SquadweCallbacks.onPersistedMessagesRetrieved] if persisted messages are found
  @override
  void getPersistedMessages() {
    final persistedMessages = localStorage.messagesDao.getMessages();
    if (persistedMessages.isNotEmpty) {
      callbacks.onPersistedMessagesRetrieved?.call(persistedMessages);
    }
  }

  /// Initializes squadwe client repository
  Future<void> initialize(SquadweUser? user) async {
    try {
      if (user != null) {
        await localStorage.userDao.saveUser(user);
      }

      //refresh contact
      final contact = await clientService.getContact();
      localStorage.contactDao.saveContact(contact);

      //refresh conversation
      final conversations = await clientService.getConversations();
      final persistedConversation =
          localStorage.conversationDao.getConversation()!;
      final refreshedConversation = conversations.firstWhere(
          (element) => element.id == persistedConversation.id,
          orElse: () =>
              persistedConversation //highly unlikely orElse will be called but still added it just in case
          );
      localStorage.conversationDao.saveConversation(refreshedConversation);
    } on SquadweClientException catch (e) {
      callbacks.onError?.call(e);
    }

    listenForEvents();
  }

  ///Sends message to squadwe inbox
  Future<void> sendMessage(SquadweNewMessageRequest request) async {
    try {
      final createdMessage = await clientService.createMessage(request);
      await localStorage.messagesDao.saveMessage(createdMessage);
      callbacks.onMessageSent?.call(createdMessage, request.echoId);
      if (clientService.connection != null && !_isListeningForEvents) {
        listenForEvents();
      }
    } on SquadweClientException catch (e) {
      callbacks.onError?.call(
          SquadweClientException(e.cause, e.type, data: request.echoId));
    }
  }

  /// Connects to squadwe websocket and starts listening for updates
  ///
  /// Received events/messages are pushed through [SquadweClient.callbacks]
  @override
  void listenForEvents() {
    final token = localStorage.contactDao.getContact()?.pubsubToken;
    if (token == null) {
      return;
    }
    clientService.startWebSocketConnection(
        localStorage.contactDao.getContact()!.pubsubToken ?? "");

    final newSubscription = clientService.connection!.stream.listen((event) {
      SquadweEvent squadweEvent = SquadweEvent.fromJson(jsonDecode(event));
      if (squadweEvent.type == SquadweEventType.welcome) {
        callbacks.onWelcome?.call();
      } else if (squadweEvent.type == SquadweEventType.ping) {
        callbacks.onPing?.call();
      } else if (squadweEvent.type == SquadweEventType.confirm_subscription) {
        if (!_isListeningForEvents) {
          _isListeningForEvents = true;
        }
        _publishPresenceUpdates();
        callbacks.onConfirmedSubscription?.call();
      } else if (squadweEvent.message?.event ==
          SquadweEventMessageType.message_created) {
        print("here comes message: $event");
        final message = squadweEvent.message!.data!.getMessage();
        localStorage.messagesDao.saveMessage(message);
        if (message.isMine) {
          callbacks.onMessageDelivered
              ?.call(message, squadweEvent.message!.data!.echoId!);
        } else {
          callbacks.onMessageReceived?.call(message);
        }
      } else if (squadweEvent.message?.event ==
          SquadweEventMessageType.message_updated) {
        print("here comes the updated message: $event");

        final message = squadweEvent.message!.data!.getMessage();
        localStorage.messagesDao.saveMessage(message);

        callbacks.onMessageUpdated?.call(message);
      } else if (squadweEvent.message?.event ==
          SquadweEventMessageType.conversation_typing_off) {
        callbacks.onConversationStoppedTyping?.call();
      } else if (squadweEvent.message?.event ==
          SquadweEventMessageType.conversation_typing_on) {
        callbacks.onConversationStartedTyping?.call();
      } else if (squadweEvent.message?.event ==
              SquadweEventMessageType.conversation_status_changed &&
          squadweEvent.message?.data?.status == "resolved" &&
          squadweEvent.message?.data?.id ==
              (localStorage.conversationDao.getConversation()?.id ?? 0)) {
        //delete conversation result
        localStorage.conversationDao.deleteConversation();
        localStorage.messagesDao.clear();
        callbacks.onConversationResolved?.call();
      } else if (squadweEvent.message?.event ==
          SquadweEventMessageType.presence_update) {
        final presenceStatuses =
            (squadweEvent.message!.data!.users as Map<dynamic, dynamic>)
                .values;
        final isOnline = presenceStatuses.contains("online");
        if (isOnline) {
          callbacks.onConversationIsOnline?.call();
          _presenceResetTimer?.cancel();
          _startPresenceResetTimer();
        } else {
          callbacks.onConversationIsOffline?.call();
        }
      } else {
        print("squadwe unknown event: $event");
      }
    });
    _subscriptions.add(newSubscription);
  }

  /// Clears all data related to current squadwe client instance
  @override
  Future<void> clear() async {
    await localStorage.clear();
  }

  /// Cancels websocket stream subscriptions and disposes [localStorage]
  @override
  void dispose() {
    localStorage.dispose();
    callbacks = SquadweCallbacks();
    _presenceResetTimer?.cancel();
    _publishPresenceTimer?.cancel();
    _subscriptions.forEach((subs) {
      subs.cancel();
    });
  }

  ///Send actions like user started typing
  @override
  void sendAction(SquadweActionType action) {
    clientService.sendAction(
        localStorage.contactDao.getContact()!.pubsubToken ?? "", action);
  }

  ///Publishes presence update to websocket channel at a 30 second interval
  void _publishPresenceUpdates() {
    sendAction(SquadweActionType.update_presence);
    _publishPresenceTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      sendAction(SquadweActionType.update_presence);
    });
  }

  ///Triggers an offline presence event after 40 seconds without receiving a presence update event
  void _startPresenceResetTimer() {
    _presenceResetTimer = Timer.periodic(Duration(seconds: 40), (timer) {
      callbacks.onConversationIsOffline?.call();
      _presenceResetTimer?.cancel();
    });
  }
}
