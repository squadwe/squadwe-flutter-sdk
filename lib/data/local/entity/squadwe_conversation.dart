import 'package:squadwe_client_sdk/squadwe_client_sdk.dart';
import 'package:squadwe_client_sdk/data/local/entity/squadwe_contact.dart';
import 'package:squadwe_client_sdk/data/local/local_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
part 'squadwe_conversation.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: SQUADWE_CONVERSATION_HIVE_TYPE_ID)
class SquadweConversation extends Equatable {
  ///The numeric ID of the conversation
  @JsonKey()
  @HiveField(0)
  final int id;

  ///The numeric ID of the inbox
  @JsonKey(name: "inbox_id")
  @HiveField(1)
  final int inboxId;

  ///List of all messages from the conversation
  @JsonKey()
  @HiveField(2)
  final List<SquadweMessage> messages;

  ///Contact of the conversation
  @JsonKey()
  @HiveField(3)
  final SquadweContact contact;

  SquadweConversation(
      {required this.id,
      required this.inboxId,
      required this.messages,
      required this.contact});

  factory SquadweConversation.fromJson(Map<String, dynamic> json) =>
      _$SquadweConversationFromJson(json);

  Map<String, dynamic> toJson() => _$SquadweConversationToJson(this);

  @override
  List<Object?> get props => [id, inboxId, messages, contact];
}
