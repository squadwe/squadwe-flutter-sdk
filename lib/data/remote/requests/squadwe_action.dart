import 'package:json_annotation/json_annotation.dart';

import 'squadwe_action_data.dart';

part 'squadwe_action.g.dart';

@JsonSerializable(explicitToJson: true)
class SquadweAction {
  @JsonKey()
  final String identifier;

  @JsonKey()
  final String command;

  @JsonKey()
  final SquadweActionData? data;

  SquadweAction({required this.identifier, this.data, required this.command});

  factory SquadweAction.fromJson(Map<String, dynamic> json) =>
      _$SquadweActionFromJson(json);

  Map<String, dynamic> toJson() => _$SquadweActionToJson(this);
}
