import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/language.dart';
import 'package:spotter/features/nutrition/domain/params/food_filter_params.dart';
import 'package:spotter/features/nutrition/domain/params/food_id_params.dart';
import 'package:spotter/features/nutrition/domain/params/search_params.dart';
import 'package:spotter/features/nutrition/domain/usecases/get_food_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/list_food_usecase.dart';
import 'package:spotter/features/nutrition/domain/usecases/search_food_usecase.dart';

part 'food_search_event.dart';
part 'food_search_state.dart';

class FoodSearchBloc extends Bloc<FoodSearchEvent, FoodSearchState> {
  final SearchFoodUsecase searchFood;
  final GetFoodUsecase getFood;
  final ListFoodsUseCase listFoods;
  Language language;
  String? category;

  /// Current browse category / search text, kept so "load more" can repeat the
  /// same query with the next cursor.
  String _query = '';

  /// Page size used for both browsing and searching.
  static const int _pageSize = 20;

  FoodSearchBloc({
    required this.searchFood,
    required this.getFood,
    required this.listFoods,
    this.language = Language.en,
  }) : super(const FoodSearchEmpty()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<FoodSelected>(_onFoodSelected);
    on<FoodListRequested>(_onFoodListRequested);
    on<FoodSearchMoreRequested>(_onMoreRequested);
    on<CategoryFilterChanged>(_onCategoryFilterChanged);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<FoodSearchState> emit,
  ) async {
    final query = event.query.trim();
    _query = query;
    if (query.isEmpty) {
      // An emptied search field means "browse the catalogue again".
      add(const FoodListRequested());
      return;
    }
    emit(FoodSearchLoading(query: query));
    final result = await searchFood(
      SearchParams(query: query, language: language, limit: _pageSize),
    );
    result.fold(
      (failure) => emit(FoodSearchError(message: failure.message)),
      (foods) => emit(
        foods.isEmpty
            ? FoodSearchEmpty(query: query)
            : FoodSearchLoaded(
                foods: foods,
                query: query,
                pageSize: _pageSize,
                hasMore: foods.length >= _pageSize,
              ),
      ),
    );
  }

  Future<void> _onFoodSelected(
    FoodSelected event,
    Emitter<FoodSearchState> emit,
  ) async {
    final previous = state;
    emit(FoodSearchLoading(query: event.foodId));
    final result = await getFood(FoodIdParams(foodId: event.foodId));
    result.fold(
      (failure) => emit(FoodSearchError(message: failure.message)),
      (food) => emit(
        food == null
            ? const FoodSearchError(message: 'Food was not found.')
            : FoodSearchLoaded(
                foods: [food],
                selectedFood: food,
                query: event.foodId,
              ),
      ),
    );
    if (state is FoodSearchError && previous is FoodSearchLoaded) {
      emit(previous);
    }
  }

  Future<void> _onFoodListRequested(
    FoodListRequested event,
    Emitter<FoodSearchState> emit,
  ) async {
    _query = '';
    emit(const FoodSearchLoading());
    final result = await listFoods(
      FoodFilterParams(
        category: category,
        limit: event.limit,
        cursor: event.cursor,
      ),
    );
    result.fold(
      (failure) => emit(FoodSearchError(message: failure.message)),
      (foods) => emit(
        foods.isEmpty
            ? const FoodSearchEmpty()
            : FoodSearchLoaded(
                foods: foods,
                pageSize: event.limit,
                hasMore: foods.length >= event.limit,
              ),
      ),
    );
  }

  /// Appends the next page of the active query. Safe to call repeatedly: it
  /// does nothing while a page is loading or when the catalogue is exhausted.
  Future<void> _onMoreRequested(
    FoodSearchMoreRequested event,
    Emitter<FoodSearchState> emit,
  ) async {
    final current = state;
    if (current is! FoodSearchLoaded) return;
    if (!current.hasMore || current.loadingMore || current.foods.isEmpty) {
      return;
    }

    emit(current.copyWith(loadingMore: true));
    final cursor = current.foods.last.foodId;
    final pageSize = current.pageSize;

    final result = _query.isEmpty
        ? await listFoods(
            FoodFilterParams(
              category: category,
              limit: pageSize,
              cursor: cursor,
            ),
          )
        : await searchFood(
            SearchParams(
              query: _query,
              language: language,
              limit: pageSize,
              cursor: cursor,
            ),
          );

    result.fold(
      // Keep what we already have; stop asking for more on failure.
      (_) => emit(current.copyWith(loadingMore: false, hasMore: false)),
      (foods) {
        final merged = [...current.foods];
        final known = merged.map((food) => food.foodId).toSet();
        var added = 0;
        for (final food in foods) {
          if (known.add(food.foodId)) {
            merged.add(food);
            added++;
          }
        }
        emit(
          current.copyWith(
            foods: merged,
            loadingMore: false,
            hasMore: foods.length >= pageSize && added > 0,
          ),
        );
      },
    );
  }

  Future<void> _onCategoryFilterChanged(
    CategoryFilterChanged event,
    Emitter<FoodSearchState> emit,
  ) async {
    category = event.category;
    _query = '';
    add(const FoodListRequested());
  }
}
