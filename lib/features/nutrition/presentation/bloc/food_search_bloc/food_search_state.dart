part of 'food_search_bloc.dart';

abstract class FoodSearchState extends Equatable {
  const FoodSearchState();
  @override
  List<Object?> get props => [];
}

class FoodSearchEmpty extends FoodSearchState {
  final String query;
  const FoodSearchEmpty({this.query = ''});
  @override
  List<Object?> get props => [query];
}

class FoodSearchLoading extends FoodSearchState {
  final String query;
  const FoodSearchLoading({this.query = ''});
  @override
  List<Object?> get props => [query];
}

class FoodSearchLoaded extends FoodSearchState {
  final List<FoodItem> foods;
  final FoodItem? selectedFood;
  final String query;

  /// Size of a page, used to decide whether another page exists.
  final int pageSize;

  /// Whether the server may still have more matching foods.
  final bool hasMore;

  /// True while the next page is being fetched (the list stays visible).
  final bool loadingMore;

  const FoodSearchLoaded({
    required this.foods,
    this.selectedFood,
    this.query = '',
    this.pageSize = 20,
    this.hasMore = false,
    this.loadingMore = false,
  });

  FoodSearchLoaded copyWith({
    List<FoodItem>? foods,
    FoodItem? selectedFood,
    String? query,
    int? pageSize,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return FoodSearchLoaded(
      foods: foods ?? this.foods,
      selectedFood: selectedFood ?? this.selectedFood,
      query: query ?? this.query,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  @override
  List<Object?> get props => [
    foods,
    selectedFood,
    query,
    pageSize,
    hasMore,
    loadingMore,
  ];
}

class FoodSearchError extends FoodSearchState {
  final String message;
  const FoodSearchError({required this.message});
  @override
  List<Object?> get props => [message];
}
