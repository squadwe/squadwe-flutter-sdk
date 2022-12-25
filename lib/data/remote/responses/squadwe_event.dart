import 'package:squadwe_client_sdk/squadwe_client_sdk.dart';
import 'package:squadwe_client_sdk/data/local/local_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'squadwe_event.g.dart';

@JsonSerializable(explicitToJson: true)
class SquadweEvent {
  @JsonKey(toJson: eventTypeToJson, fromJson: eventTypeFromJson)
  final SquadweEventType? type;

  @JsonKey()
  final String? identifier;

  @JsonKey(fromJson: eventMessageFromJson)
  final SquadweEventMessage? message;

  SquadweEvent({this.type, this.message, this.identifier});

  factory SquadweEvent.fromJson(Map<String, dynamic> json) =>
      _$SquadweEventFromJson(json);

  Map<String, dynamic> toJson() => _$SquadweEventToJson(this);
}

SquadweEventMessage? eventMessageFromJson(value) {
  if (value == null) {
    return null;
  } else if (value is num) {
    return SquadweEventMessage();
  } else if (value is String) {
    return SquadweEventMessage();
  } else {
    return SquadweEventMessage.fromJson(value as Map<String, dynamic>);
  }
}

@JsonSerializable(explicitToJson: true)
class SquadweEventMessage {
  @JsonKey()
  final SquadweEventMessageData? data;

  @JsonKey(toJson: eventMessageTypeToJson, fromJson: eventMessageTypeFromJson)
  final SquadweEventMessageType? event;

  SquadweEventMessage({this.data, this.event});

  factory SquadweEventMessage.fromJson(Map<String, dynamic> json) =>
      _$SquadweEventMessageFromJson(json);

  Map<String, dynamic> toJson() => _$SquadweEventMessageToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SquadweEventMessageData {
  @JsonKey(name: "account_id")
  final int? accountId;

  @JsonKey()
  final String? content;

  @JsonKey(name: "content_attributes")
  final dynamic contentAttributes;

  @JsonKey(name: "content_type")
  final String? contentType;

  @JsonKey(name: "conversation_id")
  final int? conversationId;

  @JsonKey(name: "created_at")
  final dynamic createdAt;

  @JsonKey(name: "echo_id")
  final String? echoId;

  @JsonKey(name: "external_source_ids")
  final dynamic externalSourceIds;

  @JsonKey()
  final int? id;

  @JsonKey(name: "inbox_id")
  final int? inboxId;

  @JsonKey(name: "message_type")
  final int? messageType;

  @JsonKey(name: "private")
  final bool? private;

  @JsonKey()
  final SquadweEventMessageUser? sender;

  @JsonKey(name: "sender_id")
  final int? senderId;

  @JsonKey(name: "source_id")
  final String? sourceId;

  @JsonKey()
  final String? status;

  @JsonKey(name: "updated_at")
  final dynamic updatedAt;

  @JsonKey()
  final dynamic conversation;

  @JsonKey()
  final SquadweEventMessageUser? user;

  @JsonKey()
  final dynamic users;

  SquadweEventMessageData(
      {this.id,
      this.user,
      this.conversation,
      this.echoId,
      this.sender,
      this.conversationId,
      this.createdAt,
      this.contentAttributes,
      this.contentType,
      this.messageType,
      this.content,
      this.inboxId,
      this.sourceId,
      this.updatedAt,
      this.status,
      this.accountId,
      this.externalSourceIds,
      this.private,
      this.senderId,
      this.users});

  factory SquadweEventMessageData.fromJson(Map<String, dynamic> json) =>
      _$SquadweEventMessageDataFromJson(json);

  Map<String, dynamic> toJson() => _$SquadweEventMessageDataToJson(this);

  getMessage() {
    return SquadweMessage.fromJson(toJson());
  }
}

/// {@category FlutterClientSdk}
@HiveType(typeId: SQUADWE_EVENT_USER_HIVE_TYPE_ID)
@JsonSerializable(explicitToJson: true)
class SquadweEventMessageUser extends Equatable {
  @JsonKey(name: "avatar_url")
  @HiveField(0)
  final String? avatarUrl;

  @JsonKey()
  @HiveField(1)
  final int? id;

  @JsonKey()
  @HiveField(2)
  final String? name;

  @JsonKey()
  @HiveField(3)
  final String? thumbnail;

  SquadweEventMessageUser(
      {this.id, this.avatarUrl, this.name, this.thumbnail});

  factory SquadweEventMessageUser.fromJson(Map<String, dynamic> json) =>
      _$SquadweEventMessageUserFromJson(json);

  Map<String, dynamic> toJson() => _$SquadweEventMessageUserToJson(this);

  @override
  List<Object?> get props => [id, avatarUrl, name, thumbnail];
}

enum SquadweEventType { welcome, ping, confirm_subscription }

String? eventTypeToJson(SquadweEventType? actionType) {
  return actionType.toString();
}

SquadweEventType? eventTypeFromJson(String? value) {
  switch (value) {
    case "welcome":
      return SquadweEventType.welcome;
    case "ping":
      return SquadweEventType.ping;
    case "confirm_subscription":
      return SquadweEventType.confirm_subscription;
    default:
      return null;
  }
}

enum SquadweEventMessageType {
  presence_update,
  message_created,
  message_updated,
  conversation_typing_off,
  conversation_typing_on,
  conversation_status_changed
}

String? eventMessageTypeToJson(SquadweEventMessageType? actionType) {
  switch (actionType) {
    case null:
      return null;
    case SquadweEventMessageType.conversation_typing_on:
      return "conversation.typing_on";
    case SquadweEventMessageType.conversation_typing_off:
      return "conversation.typing_off";
    case SquadweEventMessageType.presence_update:
      return "presence.update";
    case SquadweEventMessageType.message_created:
      return "message.created";
    case SquadweEventMessageType.message_updated:
      return "message.updated";
    case SquadweEventMessageType.conversation_status_changed:
      return "conversation.status_changed";
    default:
      return actionType.toString();
  }
}

SquadweEventMessageType? eventMessageTypeFromJson(String? value) {
  switch (value) {
    case "presence.update":
      return SquadweEventMessageType.presence_update;
    case "message.created":
      return SquadweEventMessageType.message_created;
    case "message.updated":
      return SquadweEventMessageType.message_updated;
    case "conversation.typing_on":
      return SquadweEventMessageType.conversation_typing_on;
    case "conversation.typing_off":
      return SquadweEventMessageType.conversation_typing_off;
    case "conversation.status_changed":
      return SquadweEventMessageType.conversation_status_changed;
    default:
      return null;
  }
}
