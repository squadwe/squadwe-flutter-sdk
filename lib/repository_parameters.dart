import 'package:squadwe_client_sdk/squadwe_callbacks.dart';
import 'package:squadwe_client_sdk/squadwe_parameters.dart';
import 'package:squadwe_client_sdk/di/modules.dart';

/// Represent all needed parameters necessary for [squadweRepositoryProvider] to successfully provide an instance
/// of [SquadweRepository].
class RepositoryParameters {
  /// See [SquadweParameters]
  SquadweParameters params;

  /// See [SquadweCallbacks]
  SquadweCallbacks callbacks;

  RepositoryParameters({required this.params, required this.callbacks});
}
