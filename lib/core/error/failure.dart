import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure({this.message = 'Unexpected failure occurred'});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server Failed'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache Failed'});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Invalid Credentials'});
}

class BleFailure extends Failure {
  const BleFailure({super.message = 'BLE Failed'});
}

class LlmFailure extends Failure {
  const LlmFailure({super.message = 'Chatbot Failed'});
}

class PoseFailure extends Failure {
  const PoseFailure({super.message = 'Pose Failure'});
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure({super.message = 'Invalid Input'});
}
