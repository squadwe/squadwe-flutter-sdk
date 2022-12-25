// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'squadwe_new_message_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SquadweNewMessageRequest _$SquadweNewMessageRequestFromJson(
    Map<String, dynamic> json) {
  return SquadweNewMessageRequest(
    content: json['content'] as String,
    echoId: json['echo_id'] as String,
  );
}

Map<String, dynamic> _$SquadweNewMessageRequestToJson(
        SquadweNewMessageRequest instance) =>
    <String, dynamic>{
      'content': instance.content,
      'echo_id': instance.echoId,
    };
