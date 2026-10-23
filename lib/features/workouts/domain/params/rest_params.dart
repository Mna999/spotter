import 'package:equatable/equatable.dart';

class RestParams extends Equatable {
  final int durationSec;

  const RestParams({required this.durationSec});

  @override
  List<Object?> get props => [durationSec];
}
