import 'package:equatable/equatable.dart';

class ExerciseFilterParams extends Equatable {
  final String? query;

  final int limit;

  final String? cursor;

  const ExerciseFilterParams({
    this.query,
    this.limit = 50,
    this.cursor,
  });

  @override
  List<Object?> get props => [query, limit, cursor];
}
