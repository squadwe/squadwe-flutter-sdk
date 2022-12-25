/// {@category FlutterClientSdk}
class SquadweClientException implements Exception {
  String cause;
  dynamic data;
  SquadweClientExceptionType type;

  SquadweClientException(this.cause, this.type, {this.data});
}

/// {@category FlutterClientSdk}
enum SquadweClientExceptionType {
  CREATE_CLIENT_FAILED,
  SEND_MESSAGE_FAILED,
  CREATE_CONTACT_FAILED,
  CREATE_CONVERSATION_FAILED,
  GET_MESSAGES_FAILED,
  GET_CONTACT_FAILED,
  GET_CONVERSATION_FAILED,
  UPDATE_CONTACT_FAILED,
  UPDATE_MESSAGE_FAILED
}
