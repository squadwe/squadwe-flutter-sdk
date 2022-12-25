
import 'package:squadwe_client_sdk/squadwe_client.dart';
import 'package:squadwe_client_sdk/data/squadwe_repository.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_user.dart';
import 'package:squadwe_client_sdk/data/remote/requests/squadwe_action_data.dart';
import 'package:squadwe_client_sdk/di/modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';

import 'squadwe_client_test.mocks.dart';
import 'data/squadwe_repository_test.mocks.dart';


@GenerateMocks([
  SquadweRepository
])
void main() {
  group("Squadwe Client Test", (){
    late SquadweClient client ;
    final testInboxIdentifier = "testIdentifier";
    final testBaseUrl = "https://testbaseurl.com";
    late ProviderContainer mockProviderContainer;
    final mockLocalStorage = MockLocalStorage();
    final mockRepository = MockSquadweRepository();

    final testUser = SquadweUser(
        identifier: "identifier",
        identifierHash: "identifierHash",
        name: "name",
        email: "email",
        avatarUrl: "avatarUrl",
        customAttributes: {}
    );
    final testClientInstanceKey = SquadweClient.getClientInstanceKey(
        baseUrl: testBaseUrl,
        inboxIdentifier: testInboxIdentifier,
        userIdentifier: testUser.identifier
    );

    setUp(() async{
      when(mockRepository.initialize(testUser)).thenAnswer((realInvocation) => Future.microtask((){}));
      mockProviderContainer = ProviderContainer();
      mockProviderContainer.updateOverrides([
        localStorageProvider.overrideWithProvider((ref, param) => mockLocalStorage),
        squadweRepositoryProvider.overrideWithProvider((ref, param) => mockRepository)
      ]);
      SquadweClient.providerContainerMap.update(testClientInstanceKey, (_) => mockProviderContainer, ifAbsent: () => mockProviderContainer);
      SquadweClient.providerContainerMap.update("all", (_) => mockProviderContainer, ifAbsent: () => mockProviderContainer);


      client = await SquadweClient.create(
          baseUrl: testBaseUrl,
        inboxIdentifier: testInboxIdentifier,
        user: testUser,
        enablePersistence: false
      );
    });

    test('Given all persisted data is successfully cleared when a clearAllData is called, then all local storage data should be cleared', () async{

      //GIVEN
      when(mockLocalStorage.clearAll()).thenAnswer((_)=>Future.microtask((){}));
      when(mockLocalStorage.dispose()).thenAnswer((_)=>Future.microtask((){}));

      //WHEN
      await SquadweClient.clearAllData();

      //THEN
      verify(mockLocalStorage.clearAll());
    });

    test('Given client persisted data is successfully cleared when a clearData is called, then clients local storage data should be cleared', () async{

      //GIVEN
      when(mockLocalStorage.clear()).thenAnswer((_)=>Future.microtask((){}));
      when(mockLocalStorage.dispose()).thenAnswer((_)=>Future.microtask((){}));

      //WHEN
      await SquadweClient.clearData(
          baseUrl: testBaseUrl,
          inboxIdentifier: testInboxIdentifier,
          userIdentifier: testUser.identifier
      );

      //THEN
      verify(mockLocalStorage.clear());
      verify(mockLocalStorage.dispose());
    });

    test('Given client instance persisted data is successfully cleared when a clearClientData is called, then clients local storage data should be cleared', () async{

      //GIVEN
      when(mockLocalStorage.clear()).thenAnswer((_)=>Future.microtask((){}));
      when(mockLocalStorage.dispose()).thenAnswer((_)=>Future.microtask((){}));

      //WHEN
      await client.clearClientData();

      //THEN
      verify(mockLocalStorage.clear(clearSquadweUserStorage: false));
      verifyNever(mockLocalStorage.dispose());
    });

    test('Given client instance is successfully disposed when a dispose is called, then repository should be disposed', () async{

      //GIVEN
      when(mockLocalStorage.clear()).thenAnswer((_)=>Future.microtask((){}));
      when(mockLocalStorage.dispose()).thenAnswer((_)=>Future.microtask((){}));

      //WHEN
      await client.dispose();

      //THEN
      verify(mockRepository.dispose());
      expect(SquadweClient.providerContainerMap[testClientInstanceKey], equals(null));

    });

    test('Given message sends successfully disposed when a sendMessage is called, then repository should be called', () async{

      //GIVEN
      when(mockRepository.sendMessage(any)).thenAnswer((_)=>Future.microtask((){}));

      //WHEN
      await client.sendMessage(content: "test message", echoId: "id");

      //THEN
      verify(mockRepository.sendMessage(any));

    });

    test('Given message sends successfully disposed when a sendMessage is called, then repository should be called', () async{

      //GIVEN
      when(mockRepository.sendMessage(any)).thenAnswer((_)=>Future.microtask((){}));

      //WHEN
      await client.sendMessage(content: "test message", echoId: "id");

      //THEN
      verify(mockRepository.sendMessage(any));

    });

    test('Given messages load successfully when a loadMessages is called, then repository should be called', () async{

      //GIVEN
      when(mockRepository.getMessages()).thenAnswer((_)=>Future.microtask((){}));
      when(mockRepository.getPersistedMessages()).thenAnswer((_)=>Future.microtask((){}));

      //WHEN
      client.loadMessages();

      //THEN
      verify(mockRepository.getPersistedMessages());
      verify(mockRepository.getMessages());

    });

    test('Given action is sent successfully when a sendAction is called, then repository should be called', () async{

      //GIVEN
      when(mockRepository.sendAction(any)).thenAnswer((_)=>Future.microtask((){}));

      //WHEN
      client.sendAction(SquadweActionType.update_presence);

      //THEN
      verify(mockRepository.sendAction(SquadweActionType.update_presence));

    });

    test('Given client is successfully initialized when a create is called without persistence enabled, then repository should be initialized', () async{

      //GIVEN

      //WHEN
      final result = await SquadweClient.create(
          baseUrl: testBaseUrl,
          inboxIdentifier: testInboxIdentifier,
          user: testUser,
          enablePersistence: false
      );

      //THEN
      verify(mockRepository.initialize(testUser));
      expect(result.baseUrl, equals(testBaseUrl));
      expect(result.inboxIdentifier, equals(testInboxIdentifier));

    });

    test('Given client is successfully initialized when a create is called with persistence enabled, then repository should be initialized', () async{

      //GIVEN

      //WHEN
      final result = await SquadweClient.create(
          baseUrl: testBaseUrl,
          inboxIdentifier: testInboxIdentifier,
          user: testUser,
          enablePersistence: true
      );

      //THEN
      verify(mockRepository.initialize(testUser));
      expect(result.baseUrl, equals(testBaseUrl));
      expect(result.inboxIdentifier, equals(testInboxIdentifier));

    });

  });

}