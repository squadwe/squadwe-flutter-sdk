import 'dart:async';
import 'dart:convert';

import 'package:squadwe_client_sdk/squadwe_callbacks.dart';
import 'package:squadwe_client_sdk/data/squadwe_repository.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_contact.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_conversation.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_message.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_user.dart';
import 'package:squadwe_client_sdk/data/local/local_storage.dart';
import 'package:squadwe_client_sdk/data/remote/squadwe_client_exception.dart';
import 'package:squadwe_client_sdk/data/remote/requests/squadwe_action_data.dart';
import 'package:squadwe_client_sdk/data/remote/requests/squadwe_new_message_request.dart';
import 'package:squadwe_client_sdk/data/remote/service/squadwe_client_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../utils/test_resources_util.dart';
import 'squadwe_repository_test.mocks.dart';
import 'local/local_storage_test.mocks.dart';

@GenerateMocks(
    [LocalStorage, SquadweClientService, SquadweCallbacks, WebSocketChannel])
void main() {
  group("Squadwe Repository Tests", () {
    late final SquadweContact testContact;

    late final SquadweConversation testConversation;
    final testUser = SquadweUser(
        identifier: "identifier",
        identifierHash: "identifierHash",
        name: "name",
        email: "email",
        avatarUrl: "avatarUrl",
        customAttributes: {});
    late final SquadweMessage testMessage;

    final mockLocalStorage = MockLocalStorage();
    final mockSquadweClientService = MockSquadweClientService();
    final mockSquadweCallbacks = MockSquadweCallbacks();
    final mockMessagesDao = MockSquadweMessagesDao();
    final mockContactDao = MockSquadweContactDao();
    final mockConversationDao = MockSquadweConversationDao();
    final mockUserDao = MockSquadweUserDao();
    StreamController mockWebSocketStream = StreamController.broadcast();
    final mockWebSocketChannel = MockWebSocketChannel();

    late final SquadweRepository repo;

    setUpAll(() async {
      testContact = SquadweContact.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "contact"));
      testConversation = SquadweConversation.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "conversation"));
      testMessage = SquadweMessage.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "message"));

      when(mockLocalStorage.messagesDao).thenReturn(mockMessagesDao);
      when(mockLocalStorage.contactDao).thenReturn(mockContactDao);
      when(mockLocalStorage.userDao).thenReturn(mockUserDao);
      when(mockLocalStorage.conversationDao).thenReturn(mockConversationDao);
      when(mockSquadweClientService.connection)
          .thenReturn(mockWebSocketChannel);
      when(mockWebSocketChannel.stream)
          .thenAnswer((_) => mockWebSocketStream.stream);
      when(mockSquadweClientService.startWebSocketConnection(any))
          .thenAnswer((_) => () {});

      repo = SquadweRepositoryImpl(
          clientService: mockSquadweClientService,
          localStorage: mockLocalStorage,
          streamCallbacks: mockSquadweCallbacks);
    });

    setUp(() {
      reset(mockSquadweCallbacks);
      reset(mockContactDao);
      reset(mockConversationDao);
      reset(mockUserDao);
      reset(mockMessagesDao);
      when(mockContactDao.getContact()).thenReturn(testContact);
      mockWebSocketStream = StreamController.broadcast();
      when(mockWebSocketChannel.stream)
          .thenAnswer((_) => mockWebSocketStream.stream);
    });

    test(
        'Given messages are successfully fetched when getMessages is called, then callback should be called with fetched messages',
        () async {
      //GIVEN
      final testMessages = [testMessage];
      when(mockSquadweClientService.getAllMessages())
          .thenAnswer((_) => Future.value(testMessages));
      when(mockSquadweCallbacks.onMessagesRetrieved).thenAnswer((_) => (_) {});
      when(mockMessagesDao.saveAllMessages(any))
          .thenAnswer((_) => Future.microtask(() {}));

      //WHEN
      await repo.getMessages();

      //THEN
      verify(mockSquadweClientService.getAllMessages());
      verify(mockSquadweCallbacks.onMessagesRetrieved?.call(testMessages));
      verify(mockMessagesDao.saveAllMessages(testMessages));
    });

    test(
        'Given messages are fails to fetch when getMessages is called, then callback should be called with an error',
        () async {
      //GIVEN
      final testError = SquadweClientException(
          "error", SquadweClientExceptionType.GET_MESSAGES_FAILED);
      when(mockSquadweClientService.getAllMessages()).thenThrow(testError);
      when(mockSquadweCallbacks.onError).thenAnswer((_) => (_) {});
      when(mockSquadweCallbacks.onMessagesRetrieved).thenAnswer((_) => (_) {});

      //WHEN
      await repo.getMessages();

      //THEN
      verify(mockSquadweClientService.getAllMessages());
      verifyNever(mockSquadweCallbacks.onMessagesRetrieved);
      verify(mockSquadweCallbacks.onError?.call(testError));
      verifyNever(mockMessagesDao.saveAllMessages(any));
    });

    test(
        'Given persisted messages are successfully fetched when getPersitedMessages is called, then callback should be called with fetched messages',
        () async {
      //GIVEN
      final testMessages = [testMessage];
      when(mockMessagesDao.getMessages()).thenReturn(testMessages);
      when(mockSquadweCallbacks.onPersistedMessagesRetrieved)
          .thenAnswer((_) => (_) {});

      //WHEN
      repo.getPersistedMessages();

      //THEN
      verifyNever(mockSquadweClientService.getAllMessages());
      verify(mockSquadweCallbacks.onPersistedMessagesRetrieved
          ?.call(testMessages));
    });

    test(
        'Given message is successfully sent when sendMessage is called, then callback should be called with sent message',
        () async {
      //GIVEN
      final messageRequest =
          SquadweNewMessageRequest(content: "new message", echoId: "echoId");
      when(mockSquadweClientService.createMessage(any))
          .thenAnswer((_) => Future.value(testMessage));
      when(mockSquadweCallbacks.onMessageSent).thenAnswer((_) => (_, __) {});
      when(mockMessagesDao.saveMessage(any))
          .thenAnswer((_) => Future.microtask(() {}));

      //WHEN
      await repo.sendMessage(messageRequest);

      //THEN
      verify(mockSquadweClientService.createMessage(messageRequest));
      verify(mockSquadweCallbacks.onMessageSent
          ?.call(testMessage, messageRequest.echoId));
      verify(mockMessagesDao.saveMessage(testMessage));
    });

    test(
        'Given message fails to send when sendMessage is called, then callback should be called with an error',
        () async {
      //GIVEN
      final testError = SquadweClientException(
          "error", SquadweClientExceptionType.SEND_MESSAGE_FAILED);
      final messageRequest =
          SquadweNewMessageRequest(content: "new message", echoId: "echoId");
      when(mockSquadweClientService.createMessage(any)).thenThrow(testError);
      when(mockSquadweCallbacks.onError).thenAnswer((_) => (_) {});

      //WHEN
      await repo.sendMessage(messageRequest);

      //THEN
      verify(mockSquadweClientService.createMessage(messageRequest));
      verify(mockSquadweCallbacks.onError?.call(testError));
      verifyNever(mockMessagesDao.saveMessage(any));
    });

    test(
        'Given repo is initialized with user successfully when initialize is called, then client should be properly initialized',
        () async {
      //GIVEN
      when(mockSquadweClientService.getContact())
          .thenAnswer((_) => Future.value(testContact));
      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);
      when(mockSquadweClientService.getConversations())
          .thenAnswer((_) => Future.value([testConversation]));
      when(mockUserDao.saveUser(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockContactDao.saveContact(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockConversationDao.saveConversation(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockSquadweClientService.startWebSocketConnection(any))
          .thenAnswer((_) => () {});

      //WHEN
      await repo.initialize(testUser);

      //THEN
      verify(mockSquadweClientService.getContact());
      verify(mockUserDao.saveUser(testUser));
      verify(mockContactDao.saveContact(testContact));
      verify(mockConversationDao.saveConversation(testConversation));
    });

    test(
        'Given repo is initialized with null user successfully when initialize is called, then client should be properly initialized',
        () async {
      //GIVEN
      when(mockSquadweClientService.getContact())
          .thenAnswer((_) => Future.value(testContact));
      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);
      when(mockSquadweClientService.getConversations())
          .thenAnswer((_) => Future.value([testConversation]));
      when(mockUserDao.saveUser(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockContactDao.saveContact(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockConversationDao.saveConversation(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockSquadweClientService.startWebSocketConnection(any))
          .thenAnswer((_) => () {});

      //WHEN
      await repo.initialize(null);

      //THEN
      verifyNever(mockUserDao.saveUser(testUser));
      verify(mockContactDao.saveContact(testContact));
      verify(mockConversationDao.saveConversation(testConversation));
    });

    test(
        'Given welcome event is received when listening for events, then callback welcome event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSquadweCallbacks.onWelcome).thenAnswer((_) => () {});
      final dynamic welcomeEvent = {"type": "welcome"};
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(welcomeEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockSquadweCallbacks.onWelcome?.call());
    });

    test(
        'Given ping event is received when listening for events, then callback onPing event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSquadweCallbacks.onPing).thenAnswer((_) => () {});
      final dynamic pingEvent = {"type": "ping", "message": 12243849943};
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(pingEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockSquadweCallbacks.onPing?.call());
    });

    test(
        'Given confirm subscription event is received when listening for events, then callback onConfirmSubscription event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSquadweClientService.sendAction(any, any))
          .thenAnswer((_) => (_) {});
      when(mockSquadweCallbacks.onConfirmedSubscription)
          .thenAnswer((_) => () {});
      final dynamic confirmSubscriptionEvent = {"type": "confirm_subscription"};
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(confirmSubscriptionEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockSquadweCallbacks.onConfirmedSubscription?.call());
      verify(mockSquadweClientService.sendAction(
          testContact.pubsubToken, SquadweActionType.update_presence));
    });

    test(
        'Given typing on event is received when listening for events, then callback onConversationStartedTyping event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSquadweCallbacks.onConversationStartedTyping)
          .thenAnswer((_) => () {});
      final dynamic typingOnEvent = await TestResourceUtil.readJsonResource(
          fileName: "websocket_conversation_typing_on");
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(typingOnEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockSquadweCallbacks.onConversationStartedTyping?.call());
    });

    test(
        'Given online presence update event is received when listening for events, then callback onConversationIsOnline event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSquadweCallbacks.onConversationIsOnline)
          .thenAnswer((_) => () {});
      final dynamic presenceUpdateOnlineEvent =
          await TestResourceUtil.readJsonResource(
              fileName: "websocket_presence_update");
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(presenceUpdateOnlineEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockSquadweCallbacks.onConversationIsOnline?.call());
    });

    test(
        'Given conversation is offline when listening for events, then callback onConversationIsOffline event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSquadweCallbacks.onConversationIsOffline)
          .thenAnswer((_) => () {});
      when(mockSquadweCallbacks.onConversationIsOnline)
          .thenAnswer((_) => () {});
      final dynamic presenceUpdateOnlineEvent =
          await TestResourceUtil.readJsonResource(
              fileName: "websocket_presence_update");
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(presenceUpdateOnlineEvent));
      await Future.delayed(Duration(seconds: 41));

      //THEN
      verify(mockSquadweCallbacks.onConversationIsOnline?.call());
      verify(mockSquadweCallbacks.onConversationIsOffline?.call());
    }, timeout: Timeout(Duration(seconds: 45)));

    test(
        'Given typing off event is received when listening for events, then callback onConversationStoppedTyping event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSquadweCallbacks.onConversationStoppedTyping)
          .thenAnswer((_) => () {});
      final dynamic typingOffEvent = await TestResourceUtil.readJsonResource(
          fileName: "websocket_conversation_typing_off");
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(typingOffEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockSquadweCallbacks.onConversationStoppedTyping?.call());
    });

    test(
        'Given conversation status changed event is received when listening for events, then callback onConversationResolved event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.conversationDao).thenReturn(mockConversationDao);
      when(mockConversationDao.getConversation()).thenReturn(testConversation);
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSquadweCallbacks.onConversationResolved)
          .thenAnswer((_) => () {});
      final dynamic resolvedEvent = await TestResourceUtil.readJsonResource(
          fileName: "websocket_conversation_status_changed");
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(resolvedEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verify(mockSquadweCallbacks.onConversationResolved?.call());
    });

    test(
        'Given an updated message event is received when listening for events, then callback onMessageUpdated event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockMessagesDao.saveMessage(any))
          .thenAnswer((_) => Future.microtask(() {}));
      when(mockSquadweCallbacks.onMessageUpdated).thenAnswer((_) => (_) {});
      final dynamic messageUpdatedEvent =
          await TestResourceUtil.readJsonResource(
              fileName: "websocket_message_updated");

      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(messageUpdatedEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      final message =
          SquadweMessage.fromJson(messageUpdatedEvent["message"]["data"]);
      verify(mockSquadweCallbacks.onMessageUpdated?.call(message));
    });

    test(
        'Given new message event is sent when listening for events, then callback onMessageSent event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      when(mockSquadweCallbacks.onMessageDelivered)
          .thenAnswer((_) => (_, __) {});
      when(mockMessagesDao.saveMessage(any))
          .thenAnswer((_) => Future.microtask(() {}));
      final dynamic messageSentEvent = {
        "type": "message",
        "message": {
          "event": "message.created",
          "data": {
            "id": 0,
            "content": "content",
            "echo_id": "echo_id",
            "message_type": 0,
            "content_type": "contentType",
            "content_attributes": "contentAttributes",
            "created_at": DateTime.now().toString(),
            "conversation_id": 0,
            "attachments": [],
          }
        }
      };

      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(messageSentEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      final message =
          SquadweMessage.fromJson(messageSentEvent["message"]["data"]);
      verify(mockSquadweCallbacks.onMessageDelivered
          ?.call(message, messageSentEvent["message"]["echo_id"]));
    });

    test(
        'Given unknown event is received when listening for events, then no callback event should be triggered',
        () async {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});
      final dynamic unknownEvent = {"type": "unknown"};
      repo.listenForEvents();

      //WHEN
      mockWebSocketStream.add(jsonEncode(unknownEvent));
      await Future.delayed(Duration(seconds: 1));

      //THEN
      verifyZeroInteractions(mockSquadweCallbacks);
      repo.dispose();
    });

    test(
        'Given action is successfully sent when sendAction is called, then client service sendAction should be triggered',
        () {
      //GIVEN
      when(mockContactDao.getContact()).thenReturn(testContact);
      when(mockSquadweClientService.sendAction(any, any))
          .thenAnswer((realInvocation) => Future.microtask(() {}));

      //WHEN
      repo.sendAction(SquadweActionType.update_presence);

      //THEN
      verify(mockSquadweClientService.sendAction(
          testContact.pubsubToken, SquadweActionType.update_presence));
    });

    test(
        'Given repository is successfully disposed when dispose is called, then localStorage should be disposed',
        () {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});

      //WHEN
      repo.dispose();

      //THEN
      verify(mockLocalStorage.dispose());
    });

    test(
        'Given repository is successfully cleared when clear is called, then localStorage should be cleared',
        () {
      //GIVEN
      when(mockLocalStorage.dispose()).thenAnswer((_) => (_) {});

      //WHEN
      repo.clear();

      //THEN
      verify(mockLocalStorage.clear());
    });

    tearDown(() async {
      await mockWebSocketStream.close();
    });

    tearDownAll(() {
      repo.dispose();
    });
  });
}
