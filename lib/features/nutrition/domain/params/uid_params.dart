import 'package:equatable/equatable.dart';

class UidParams extends Equatable {
  final String uid;

  const UidParams({required this.uid});
  @override
  List<Object?> get props => [uid];
}
