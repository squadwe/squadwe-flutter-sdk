//import 'dart:async';

import 'package:squadwe_client_sdk/squadwe_client.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_contact.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_conversation.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_message.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_user.dart';
import 'package:squadwe_client_sdk/di/modules.dart';
import 'package:squadwe_client_sdk/ui/squadwe_chat_dialog.dart';
import 'package:squadwe_client_sdk/ui/squadwe_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';

import '../data/squadwe_repository_test.mocks.dart';
import '../utils/test_resources_util.dart';

void main() {
  final testInboxIdentifier = "testIdentifier";
  final testBaseUrl = "https://testbaseurl.com";
  late ProviderContainer mockProviderContainer;
  final mockService = MockSquadweClientService();

  final testUser = SquadweUser(
      identifier: "identifier",
      identifierHash: "identifierHash",
      name: "name",
      email: "email",
      avatarUrl: "avatarUrl",
      customAttributes: {});
  final testClientInstanceKey = SquadweClient.getClientInstanceKey(
      baseUrl: testBaseUrl,
      inboxIdentifier: testInboxIdentifier,
      userIdentifier: testUser.identifier);
  late final SquadweContact mockContact;
  late final SquadweConversation mockConversation;
  late final List<SquadweMessage> mockMessages;
  final SquadweL10n testL10n = SquadweL10n();
  final mockWebSocketChannel = MockWebSocketChannel();
  final String testModalTitle = "SquadweSupport";

  setUpAll(() async {
    mockContact = SquadweContact.fromJson(
        await TestResourceUtil.readJsonResource(fileName: "contact"));

    mockConversation = SquadweConversation.fromJson(
        await TestResourceUtil.readJsonResource(fileName: "conversation"));

    mockMessages = [
      SquadweMessage.fromJson(
          await TestResourceUtil.readJsonResource(fileName: "message"))
    ];

    when(mockService.getContact())
        .thenAnswer((realInvocation) => Future.value(mockContact));
    when(mockService.getConversations())
        .thenAnswer((realInvocation) => Future.value([mockConversation]));
    when(mockService.getAllMessages())
        .thenAnswer((realInvocation) => Future.value(mockMessages));
    when(mockService.sendAction(any, any))
        .thenAnswer((realInvocation) => Future.microtask(() {}));

    when(mockService.connection).thenReturn(mockWebSocketChannel);

    mockProviderContainer = ProviderContainer();
    mockProviderContainer.updateOverrides([
      squadweClientServiceProvider
          .overrideWithProvider((ref, param) => mockService)
    ]);
    SquadweClient.providerContainerMap.update(
        testClientInstanceKey, (_) => mockProviderContainer,
        ifAbsent: () => mockProviderContainer);
    SquadweClient.providerContainerMap.update(
        "all", (_) => mockProviderContainer,
        ifAbsent: () => mockProviderContainer);
  });

  testWidgets(
      'Given modal successfully instantiates when SquadweChatModal is constructed, then modal should be correctly ',
      (WidgetTester tester) async {
    // WHEN
    await tester.pumpWidget(MaterialApp(
      home: SquadweChatDialog(
        baseUrl: testBaseUrl,
        inboxIdentifier: testInboxIdentifier,
        title: testModalTitle,
        user: testUser,
        l10n: testL10n,
      ),
    ));

    // THEN
    expect(find.text(testModalTitle), findsOneWidget);
    expect(find.text(testL10n.offlineText), findsOneWidget);
  });
}
