import 'package:equatable/equatable.dart';

class LimitParams extends Equatable {
  final String uid;
  final int limit;
  final String? cursor;  

  const LimitParams({
    required this.uid,
    this.limit = 20,
    this.cursor,
  });

  @override
  List<Object?> get props => [uid, limit, cursor];
}
