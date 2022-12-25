import 'package:squadwe_client_sdk/squadwe_callbacks.dart';
import 'package:squadwe_client_sdk/squadwe_client.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_message.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_user.dart';
import 'package:squadwe_client_sdk/data/remote/squadwe_client_exception.dart';
import 'package:squadwe_client_sdk/ui/squadwe_chat_theme.dart';
import 'package:squadwe_client_sdk/ui/squadwe_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

///Squadwe chat widget
/// {@category FlutterClientSdk}
class SquadweChat extends StatefulWidget {
  /// Specifies a custom app bar for squadwe page widget
  final PreferredSizeWidget? appBar;

  ///Installation url for squadwe
  final String baseUrl;

  ///Identifier for target squadwe inbox.
  ///
  /// For more details see https://www.squadwe.com/docs/product/channels/api/client-apis
  final String inboxIdentifier;

  /// Enables persistence of squadwe client instance's contact, conversation and messages to disk
  /// for convenience.
  ///
  /// Setting [enablePersistence] to false holds squadwe client instance's data in memory and is cleared as
  /// soon as squadwe client instance is disposed
  final bool enablePersistence;

  /// Custom user details to be attached to squadwe contact
  final SquadweUser? user;

  /// See [ChatList.onEndReached]
  final Future<void> Function()? onEndReached;

  /// See [ChatList.onEndReachedThreshold]
  final double? onEndReachedThreshold;

  /// See [Message.onMessageLongPress]
  final void Function(types.Message)? onMessageLongPress;

  /// See [Message.onMessageTap]
  final void Function(types.Message)? onMessageTap;

  /// See [Input.onSendPressed]
  final void Function(types.PartialText)? onSendPressed;

  /// See [Input.onTextChanged]
  final void Function(String)? onTextChanged;

  /// Show avatars for received messages.
  final bool showUserAvatars;

  /// Show user names for received messages.
  final bool showUserNames;

  final SquadweChatTheme theme;

  /// See [SquadweL10n]
  final SquadweL10n l10n;

  /// See [Chat.timeFormat]
  final DateFormat? timeFormat;

  /// See [Chat.dateFormat]
  final DateFormat? dateFormat;

  ///See [SquadweCallbacks.onWelcome]
  final void Function()? onWelcome;

  ///See [SquadweCallbacks.onPing]
  final void Function()? onPing;

  ///See [SquadweCallbacks.onConfirmedSubscription]
  final void Function()? onConfirmedSubscription;

  ///See [SquadweCallbacks.onConversationStartedTyping]
  final void Function()? onConversationStartedTyping;

  ///See [SquadweCallbacks.onConversationIsOnline]
  final void Function()? onConversationIsOnline;

  ///See [SquadweCallbacks.onConversationIsOffline]
  final void Function()? onConversationIsOffline;

  ///See [SquadweCallbacks.onConversationStoppedTyping]
  final void Function()? onConversationStoppedTyping;

  ///See [SquadweCallbacks.onMessageReceived]
  final void Function(SquadweMessage)? onMessageReceived;

  ///See [SquadweCallbacks.onMessageSent]
  final void Function(SquadweMessage)? onMessageSent;

  ///See [SquadweCallbacks.onMessageDelivered]
  final void Function(SquadweMessage)? onMessageDelivered;

  ///See [SquadweCallbacks.onMessageUpdated]
  final void Function(SquadweMessage)? onMessageUpdated;

  ///See [SquadweCallbacks.onPersistedMessagesRetrieved]
  final void Function(List<SquadweMessage>)? onPersistedMessagesRetrieved;

  ///See [SquadweCallbacks.onMessagesRetrieved]
  final void Function(List<SquadweMessage>)? onMessagesRetrieved;

  ///See [SquadweCallbacks.onError]
  final void Function(SquadweClientException)? onError;

  ///Horizontal padding is reduced if set to true
  final bool isPresentedInDialog;

  const SquadweChat(
      {Key? key,
      required this.baseUrl,
      required this.inboxIdentifier,
      this.enablePersistence = true,
      this.user,
      this.appBar,
      this.onEndReached,
      this.onEndReachedThreshold,
      this.onMessageLongPress,
      this.onMessageTap,
      this.onSendPressed,
      this.onTextChanged,
      this.showUserAvatars = true,
      this.showUserNames = true,
      this.theme = const SquadweChatTheme(),
      this.l10n = const SquadweL10n(),
      this.timeFormat,
      this.dateFormat,
      this.onWelcome,
      this.onPing,
      this.onConfirmedSubscription,
      this.onMessageReceived,
      this.onMessageSent,
      this.onMessageDelivered,
      this.onMessageUpdated,
      this.onPersistedMessagesRetrieved,
      this.onMessagesRetrieved,
      this.onConversationStartedTyping,
      this.onConversationStoppedTyping,
      this.onConversationIsOnline,
      this.onConversationIsOffline,
      this.onError,
      this.isPresentedInDialog = false})
      : super(key: key);

  @override
  _SquadweChatState createState() => _SquadweChatState();
}

class _SquadweChatState extends State<SquadweChat> {
  ///
  List<types.Message> _messages = [];

  late String status;

  final idGen = Uuid();
  late final _user;
  SquadweClient? squadweClient;

  late final squadweCallbacks;

  @override
  void initState() {
    super.initState();

    if (widget.user == null) {
      _user = types.User(id: idGen.v4());
    } else {
      _user = types.User(
        id: widget.user?.identifier ?? idGen.v4(),
        firstName: widget.user?.name,
        imageUrl: widget.user?.avatarUrl,
      );
    }

    squadweCallbacks = SquadweCallbacks(
      onWelcome: () {
        widget.onWelcome?.call();
      },
      onPing: () {
        widget.onPing?.call();
      },
      onConfirmedSubscription: () {
        widget.onConfirmedSubscription?.call();
      },
      onConversationStartedTyping: () {
        widget.onConversationStoppedTyping?.call();
      },
      onConversationStoppedTyping: () {
        widget.onConversationStartedTyping?.call();
      },
      onPersistedMessagesRetrieved: (persistedMessages) {
        if (widget.enablePersistence) {
          setState(() {
            _messages = persistedMessages
                .map((message) => _squadweMessageToTextMessage(message))
                .toList();
          });
        }
        widget.onPersistedMessagesRetrieved?.call(persistedMessages);
      },
      onMessagesRetrieved: (messages) {
        if (messages.isEmpty) {
          return;
        }
        setState(() {
          final chatMessages = messages
              .map((message) => _squadweMessageToTextMessage(message))
              .toList();
          final mergedMessages =
              <types.Message>[..._messages, ...chatMessages].toSet().toList();
          final now = DateTime.now().millisecondsSinceEpoch;
          mergedMessages.sort((a, b) {
            return (b.createdAt ?? now).compareTo(a.createdAt ?? now);
          });
          _messages = mergedMessages;
        });
        widget.onMessagesRetrieved?.call(messages);
      },
      onMessageReceived: (squadweMessage) {
        _addMessage(_squadweMessageToTextMessage(squadweMessage));
        widget.onMessageReceived?.call(squadweMessage);
      },
      onMessageDelivered: (squadweMessage, echoId) {
        _handleMessageSent(
            _squadweMessageToTextMessage(squadweMessage, echoId: echoId));
        widget.onMessageDelivered?.call(squadweMessage);
      },
      onMessageUpdated: (squadweMessage) {
        _handleMessageUpdated(_squadweMessageToTextMessage(squadweMessage,
            echoId: squadweMessage.id.toString()));
        widget.onMessageUpdated?.call(squadweMessage);
      },
      onMessageSent: (squadweMessage, echoId) {
        final textMessage = types.TextMessage(
            id: echoId,
            author: _user,
            text: squadweMessage.content ?? "",
            status: types.Status.delivered);
        _handleMessageSent(textMessage);
        widget.onMessageSent?.call(squadweMessage);
      },
      onConversationResolved: () {
        final resolvedMessage = types.TextMessage(
            id: idGen.v4(),
            text: widget.l10n.conversationResolvedMessage,
            author: types.User(
                id: idGen.v4(),
                firstName: "Bot",
                imageUrl:
                    "https://d2cbg94ubxgsnp.cloudfront.net/Pictures/480x270//9/9/3/512993_shutterstock_715962319converted_920340.png"),
            status: types.Status.delivered);
        _addMessage(resolvedMessage);
      },
      onError: (error) {
        if (error.type == SquadweClientExceptionType.SEND_MESSAGE_FAILED) {
          _handleSendMessageFailed(error.data);
        }
        print("Ooops! Something went wrong. Error Cause: ${error.cause}");
        widget.onError?.call(error);
      },
    );

    SquadweClient.create(
            baseUrl: widget.baseUrl,
            inboxIdentifier: widget.inboxIdentifier,
            user: widget.user,
            enablePersistence: widget.enablePersistence,
            callbacks: squadweCallbacks)
        .then((client) {
      setState(() {
        squadweClient = client;
        squadweClient!.loadMessages();
      });
    }).onError((error, stackTrace) {
      widget.onError?.call(SquadweClientException(
          error.toString(), SquadweClientExceptionType.CREATE_CLIENT_FAILED));
      print("squadwe client failed with error $error: $stackTrace");
    });
  }

  types.TextMessage _squadweMessageToTextMessage(SquadweMessage message,
      {String? echoId}) {
    String? avatarUrl = message.sender?.avatarUrl ?? message.sender?.thumbnail;

    //Sets avatar url to null if its a gravatar not found url
    //This enables placeholder for avatar to show
    if (avatarUrl?.contains("?d=404") ?? false) {
      avatarUrl = null;
    }
    return types.TextMessage(
        id: echoId ?? message.id.toString(),
        author: message.isMine
            ? _user
            : types.User(
                id: message.sender?.id.toString() ?? idGen.v4(),
                firstName: message.sender?.name,
                imageUrl: avatarUrl,
              ),
        text: message.content ?? "",
        status: types.Status.seen,
        createdAt: DateTime.parse(message.createdAt).millisecondsSinceEpoch);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendMessageFailed(String echoId) async {
    final index = _messages.indexWhere((element) => element.id == echoId);
    setState(() {
      _messages[index] = _messages[index].copyWith(status: types.Status.error);
    });
  }

  void _handleResendMessage(types.TextMessage message) async {
    squadweClient!.sendMessage(content: message.text, echoId: message.id);
    final index = _messages.indexWhere((element) => element.id == message.id);
    setState(() {
      _messages[index] = message.copyWith(status: types.Status.sending);
    });
  }

  void _handleMessageTap(types.Message message) async {
    if (message.status == types.Status.error && message is types.TextMessage) {
      _handleResendMessage(message);
    }
    widget.onMessageTap?.call(message);
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = _messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  void _handleMessageSent(
    types.Message message,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);

    if (_messages[index].status == types.Status.seen) {
      return;
    }

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = message;
      });
    });
  }

  void _handleMessageUpdated(
    types.Message message,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = message;
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: message.text,
        status: types.Status.sending);

    _addMessage(textMessage);

    squadweClient!
        .sendMessage(content: textMessage.text, echoId: textMessage.id);
    widget.onSendPressed?.call(message);
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.isPresentedInDialog ? 8.0 : 16.0;
    return Scaffold(
      appBar: widget.appBar,
      backgroundColor: widget.theme.backgroundColor,
      body: Column(
        children: [
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                  left: horizontalPadding, right: horizontalPadding),
              child: Chat(
                messages: _messages,
                onMessageTap: _handleMessageTap,
                onPreviewDataFetched: _handlePreviewDataFetched,
                onSendPressed: _handleSendPressed,
                user: _user,
                onEndReached: widget.onEndReached,
                onEndReachedThreshold: widget.onEndReachedThreshold,
                onMessageLongPress: widget.onMessageLongPress,
                onTextChanged: widget.onTextChanged,
                showUserAvatars: widget.showUserAvatars,
                showUserNames: widget.showUserNames,
                timeFormat: widget.timeFormat ?? DateFormat.Hm(),
                dateFormat: widget.timeFormat ?? DateFormat("EEEE MMMM d"),
                theme: widget.theme,
                l10n: widget.l10n,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/logo.png",
                  package: 'squadwe_client_sdk',
                  width: 15,
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Powered by Squadwe",
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    squadweClient?.dispose();
  }
}
