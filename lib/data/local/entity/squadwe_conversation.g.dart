// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'squadwe_conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SquadweConversationAdapter extends TypeAdapter<SquadweConversation> {
  @override
  final int typeId = 1;

  @override
  SquadweConversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SquadweConversation(
      id: fields[0] as int,
      inboxId: fields[1] as int,
      messages: (fields[2] as List).cast<SquadweMessage>(),
      contact: fields[3] as SquadweContact,
    );
  }

  @override
  void write(BinaryWriter writer, SquadweConversation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.inboxId)
      ..writeByte(2)
      ..write(obj.messages)
      ..writeByte(3)
      ..write(obj.contact);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SquadweConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SquadweConversation _$SquadweConversationFromJson(Map<String, dynamic> json) {
  return SquadweConversation(
    id: json['id'] as int,
    inboxId: json['inbox_id'] as int,
    messages: (json['messages'] as List<dynamic>)
        .map((e) => SquadweMessage.fromJson(e as Map<String, dynamic>))
        .toList(),
    contact: SquadweContact.fromJson(json['contact'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$SquadweConversationToJson(
        SquadweConversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'inbox_id': instance.inboxId,
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'contact': instance.contact.toJson(),
    };
