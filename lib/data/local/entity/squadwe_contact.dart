import 'package:equatable/equatable.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:json_annotation/json_annotation.dart';

import '../local_storage.dart';

part 'squadwe_contact.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: SQUADWE_CONTACT_HIVE_TYPE_ID)
class SquadweContact extends Equatable {
  ///unique identifier of contact
  @JsonKey(name: "id")
  @HiveField(0)
  final int id;

  ///Source id of contact obtained on contact create
  @JsonKey(name: "source_id")
  @HiveField(1)
  final String? contactIdentifier;

  ///Token for subscribing to websocket stream events
  @JsonKey(name: "pubsub_token")
  @HiveField(2)
  final String? pubsubToken;

  ///Full name of contact
  @JsonKey()
  @HiveField(3)
  final String name;

  ///Email of contact
  @JsonKey()
  @HiveField(4)
  final String email;

  SquadweContact({
    required this.id,
    required this.contactIdentifier,
    required this.pubsubToken,
    required this.name,
    required this.email,
  });

  factory SquadweContact.fromJson(Map<String, dynamic> json) =>
      _$SquadweContactFromJson(json);

  Map<String, dynamic> toJson() => _$SquadweContactToJson(this);

  @override
  List<Object?> get props => [id, contactIdentifier, pubsubToken, name, email];
}
