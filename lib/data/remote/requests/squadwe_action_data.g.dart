// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'squadwe_action_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SquadweActionData _$SquadweActionDataFromJson(Map<String, dynamic> json) {
  return SquadweActionData(
    action: actionTypeFromJson(json['action'] as String?),
  );
}

Map<String, dynamic> _$SquadweActionDataToJson(SquadweActionData instance) =>
    <String, dynamic>{
      'action': actionTypeToJson(instance.action),
    };
