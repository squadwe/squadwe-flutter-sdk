import 'package:squadwe_client_sdk/squadwe_client_sdk.dart';
import 'package:squadwe_client_sdk/data/squadwe_repository.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_contact.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_conversation.dart';
import 'package:squadwe_client_sdk/data/remote/requests/squadwe_action_data.dart';
import 'package:squadwe_client_sdk/data/remote/requests/squadwe_new_message_request.dart';
import 'package:squadwe_client_sdk/di/modules.dart';
import 'package:squadwe_client_sdk/squadwe_parameters.dart';
import 'package:squadwe_client_sdk/repository_parameters.dart';
import 'package:riverpod/riverpod.dart';

import 'data/local/local_storage.dart';

/// Represents a squadwe client instance. All squadwe operations (Example: sendMessages) are
/// passed through squadwe client. For more info visit
/// https://www.squadwe.com/docs/product/channels/api/client-apis
///
/// {@category FlutterClientSdk}
class SquadweClient {
  late final SquadweRepository _repository;
  final SquadweParameters _parameters;
  final SquadweCallbacks? callbacks;
  final SquadweUser? user;

  String get baseUrl => _parameters.baseUrl;

  String get inboxIdentifier => _parameters.inboxIdentifier;

  SquadweClient._(this._parameters, {this.user, this.callbacks}) {
    providerContainerMap.putIfAbsent(
        _parameters.clientInstanceKey, () => ProviderContainer());
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    _repository = container.read(squadweRepositoryProvider(
        RepositoryParameters(
            params: _parameters, callbacks: callbacks ?? SquadweCallbacks())));
  }

  void _init() {
    try {
      _repository.initialize(user);
    } on SquadweClientException catch (e) {
      callbacks?.onError?.call(e);
    }
  }

  ///Retrieves squadwe client's messages. If persistence is enabled [SquadweCallbacks.onPersistedMessagesRetrieved]
  ///will be triggered with persisted messages. On successfully fetch from remote server
  ///[SquadweCallbacks.onMessagesRetrieved] will be triggered
  void loadMessages() async {
    _repository.getPersistedMessages();
    await _repository.getMessages();
  }

  /// Sends squadwe message. The echoId is your temporary message id. When message sends successfully
  /// [SquadweMessage] will be returned with the [echoId] on [SquadweCallbacks.onMessageSent]. If
  /// message fails to send [SquadweCallbacks.onError] will be triggered [echoId] as data.
  Future<void> sendMessage(
      {required String content, required String echoId}) async {
    final request = SquadweNewMessageRequest(content: content, echoId: echoId);
    await _repository.sendMessage(request);
  }

  ///Send squadwe action performed by user.
  ///
  /// Example: User started typing
  Future<void> sendAction(SquadweActionType action) async {
    _repository.sendAction(action);
  }

  ///Disposes squadwe client and cancels all stream subscriptions
  dispose() {
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    _repository.dispose();
    container.dispose();
    providerContainerMap.remove(_parameters.clientInstanceKey);
  }

  /// Clears all squadwe client data
  clearClientData() {
    final container = providerContainerMap[_parameters.clientInstanceKey]!;
    final localStorage = container.read(localStorageProvider(_parameters));
    localStorage.clear(clearSquadweUserStorage: false);
  }

  /// Creates an instance of [SquadweClient] with the [baseUrl] of your squadwe installation,
  /// [inboxIdentifier] for the targeted inbox. Specify custom user details using [user] and [callbacks] for
  /// handling squadwe events. By default persistence is enabled, to disable persistence set [enablePersistence] as false
  static Future<SquadweClient> create(
      {required String baseUrl,
      required String inboxIdentifier,
      SquadweUser? user,
      bool enablePersistence = true,
      SquadweCallbacks? callbacks}) async {
    if (enablePersistence) {
      await LocalStorage.openDB();
    }

    final squadweParams = SquadweParameters(
        clientInstanceKey: getClientInstanceKey(
            baseUrl: baseUrl,
            inboxIdentifier: inboxIdentifier,
            userIdentifier: user?.identifier),
        isPersistenceEnabled: enablePersistence,
        baseUrl: baseUrl,
        inboxIdentifier: inboxIdentifier,
        userIdentifier: user?.identifier);

    final client =
        SquadweClient._(squadweParams, callbacks: callbacks, user: user);

    client._init();

    return client;
  }

  static final _keySeparator = "|||";

  ///Create a squadwe client instance key using the squadwe client instance baseurl, inboxIdentifier
  ///and userIdentifier. Client instance keys are used to differentiate between client instances and their data
  ///(contact ([SquadweContact]),conversation ([SquadweConversation]) and messages ([SquadweMessage]))
  ///
  /// Create separate [SquadweClient] instances with same baseUrl, inboxIdentifier, userIdentifier and persistence
  /// enabled will be regarded as same therefore use same contact and conversation.
  static String getClientInstanceKey(
      {required String baseUrl,
      required String inboxIdentifier,
      String? userIdentifier}) {
    return "$baseUrl$_keySeparator$userIdentifier$_keySeparator$inboxIdentifier";
  }

  static Map<String, ProviderContainer> providerContainerMap = Map();

  ///Clears all persisted squadwe data on device for a particular squadwe client instance.
  ///See [getClientInstanceKey] on how squadwe client instance are differentiated
  static Future<void> clearData(
      {required String baseUrl,
      required String inboxIdentifier,
      String? userIdentifier}) async {
    final clientInstanceKey = getClientInstanceKey(
        baseUrl: baseUrl,
        inboxIdentifier: inboxIdentifier,
        userIdentifier: userIdentifier);
    providerContainerMap.putIfAbsent(
        clientInstanceKey, () => ProviderContainer());
    final container = providerContainerMap[clientInstanceKey]!;
    final params = SquadweParameters(
        isPersistenceEnabled: true,
        baseUrl: "",
        inboxIdentifier: "",
        clientInstanceKey: "");

    final localStorage = container.read(localStorageProvider(params));
    await localStorage.clear();

    localStorage.dispose();
    container.dispose();
    providerContainerMap.remove(clientInstanceKey);
  }

  /// Clears all persisted squadwe data on device.
  static Future<void> clearAllData() async {
    providerContainerMap.putIfAbsent("all", () => ProviderContainer());
    final container = providerContainerMap["all"]!;
    final params = SquadweParameters(
        isPersistenceEnabled: true,
        baseUrl: "",
        inboxIdentifier: "",
        clientInstanceKey: "");

    final localStorage = container.read(localStorageProvider(params));
    await localStorage.clearAll();

    localStorage.dispose();
    container.dispose();
  }
}
