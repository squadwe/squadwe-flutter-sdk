import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'squadwe_new_message_request.g.dart';

@JsonSerializable(explicitToJson: true)
class SquadweNewMessageRequest extends Equatable {
  @JsonKey()
  final String content;
  @JsonKey(name: "echo_id")
  final String echoId;

  SquadweNewMessageRequest({required this.content, required this.echoId});

  @override
  List<Object> get props => [content, echoId];

  factory SquadweNewMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SquadweNewMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SquadweNewMessageRequestToJson(this);
}
