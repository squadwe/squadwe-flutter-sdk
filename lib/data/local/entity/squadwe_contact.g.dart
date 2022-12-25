// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'squadwe_contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SquadweContactAdapter extends TypeAdapter<SquadweContact> {
  @override
  final int typeId = 0;

  @override
  SquadweContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SquadweContact(
      id: fields[0] as int,
      contactIdentifier: fields[1] as String?,
      pubsubToken: fields[2] as String?,
      name: fields[3] as String,
      email: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SquadweContact obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.contactIdentifier)
      ..writeByte(2)
      ..write(obj.pubsubToken)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SquadweContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SquadweContact _$SquadweContactFromJson(Map<String, dynamic> json) {
  return SquadweContact(
    id: json['id'] as int,
    contactIdentifier: json['source_id'] as String?,
    pubsubToken: json['pubsub_token'] as String?,
    name: json['name'] as String,
    email: json['email'] as String,
  );
}

Map<String, dynamic> _$SquadweContactToJson(SquadweContact instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source_id': instance.contactIdentifier,
      'pubsub_token': instance.pubsubToken,
      'name': instance.name,
      'email': instance.email,
    };
