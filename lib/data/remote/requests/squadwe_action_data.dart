import 'package:json_annotation/json_annotation.dart';

part 'squadwe_action_data.g.dart';

@JsonSerializable(explicitToJson: true)
class SquadweActionData {
  @JsonKey(toJson: actionTypeToJson, fromJson: actionTypeFromJson)
  final SquadweActionType action;

  SquadweActionData({required this.action});

  factory SquadweActionData.fromJson(Map<String, dynamic> json) =>
      _$SquadweActionDataFromJson(json);

  Map<String, dynamic> toJson() => _$SquadweActionDataToJson(this);
}

enum SquadweActionType { subscribe, update_presence }

String actionTypeToJson(SquadweActionType actionType) {
  switch (actionType) {
    case SquadweActionType.update_presence:
      return "update_presence";
    case SquadweActionType.subscribe:
      return "subscribe";
  }
}

SquadweActionType actionTypeFromJson(String? value) {
  switch (value) {
    case "update_presence":
      return SquadweActionType.update_presence;
    case "subscribe":
      return SquadweActionType.subscribe;
    default:
      return SquadweActionType.update_presence;
  }
}
