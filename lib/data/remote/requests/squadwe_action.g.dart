// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'squadwe_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SquadweAction _$SquadweActionFromJson(Map<String, dynamic> json) {
  return SquadweAction(
    identifier: json['identifier'] as String,
    data: json['data'] == null
        ? null
        : SquadweActionData.fromJson(json['data'] as Map<String, dynamic>),
    command: json['command'] as String,
  );
}

Map<String, dynamic> _$SquadweActionToJson(SquadweAction instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'command': instance.command,
      'data': instance.data?.toJson(),
    };
