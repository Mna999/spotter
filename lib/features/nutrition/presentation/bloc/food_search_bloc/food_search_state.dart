part of 'food_search_bloc.dart';

abstract class FoodSearchState extends Equatable {
  const FoodSearchState();

  /// Every category seen so far in the catalogue, used to build the filter
  /// chips without the screen having to accumulate them.
  Set<String> get categories => const <String>{};

  @override
  List<Object?> get props => [];
}

class FoodSearchEmpty extends FoodSearchState {
  final String query;

  @override
  final Set<String> categories;

  const FoodSearchEmpty({this.query = '', this.categories = const {}});

  @override
  List<Object?> get props => [query, categories];
}

class FoodSearchLoading extends FoodSearchState {
  final String query;

  @override
  final Set<String> categories;

  const FoodSearchLoading({this.query = '', this.categories = const {}});

  @override
  List<Object?> get props => [query, categories];
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

  @override
  final Set<String> categories;

  const FoodSearchLoaded({
    required this.foods,
    this.selectedFood,
    this.query = '',
    this.pageSize = 20,
    this.hasMore = false,
    this.loadingMore = false,
    this.categories = const {},
  });

  FoodSearchLoaded copyWith({
    List<FoodItem>? foods,
    FoodItem? selectedFood,
    String? query,
    int? pageSize,
    bool? hasMore,
    bool? loadingMore,
    Set<String>? categories,
  }) {
    return FoodSearchLoaded(
      foods: foods ?? this.foods,
      selectedFood: selectedFood ?? this.selectedFood,
      query: query ?? this.query,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      categories: categories ?? this.categories,
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
    categories,
  ];
}

class FoodSearchError extends FoodSearchState {
  final String message;

  @override
  final Set<String> categories;

  const FoodSearchError({required this.message, this.categories = const {}});

  @override
  List<Object?> get props => [message, categories];
}
