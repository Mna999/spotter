import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/language.dart';

class SearchParams extends Equatable {
  final String query;
  final Language language;
  final int limit;
  final String? cursor;

  const SearchParams({
    required this.query,
    required this.language,
    this.limit = 20,
    this.cursor,
  });

  @override
  List<Object?> get props => [query, language, limit, cursor];
}
