class ServerException implements Exception {
  String code;
  ServerException({required this.code});
}

class CacheException implements Exception {
  String code;
  CacheException({required this.code});
}

class AuthException implements Exception {
  String code;
  AuthException({required this.code});
}

class BleException implements Exception {
  String code;
  BleException({required this.code});
}

class LlmException implements Exception {
  String code;
  LlmException({required this.code});
}

class PoseException implements Exception {
  String code;
  PoseException({required this.code});
}

class InvalidInputException implements Exception {
  String code;
  InvalidInputException({required this.code});
}
