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

  FoodSearchBloc({
    required this.searchFood,
    required this.getFood,
    required this.listFoods,
    this.language = Language.en,
  }) : super(const FoodSearchEmpty()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<FoodSelected>(_onFoodSelected);
    on<FoodListRequested>(_onFoodListRequested);
    on<CategoryFilterChanged>(_onCategoryFilterChanged);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<FoodSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      add(const FoodListRequested());
      return;
    }
    emit(FoodSearchLoading(query: query));
    final result = await searchFood(
      SearchParams(query: query, language: language),
    );
    result.fold(
      (failure) => emit(FoodSearchError(message: failure.message)),
      (foods) => emit(
        foods.isEmpty
            ? FoodSearchEmpty(query: query)
            : FoodSearchLoaded(foods: foods, query: query),
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
    if (state is FoodSearchError && previous is FoodSearchLoaded)
      emit(previous);
  }

  Future<void> _onFoodListRequested(
    FoodListRequested event,
    Emitter<FoodSearchState> emit,
  ) async {
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
            : FoodSearchLoaded(foods: foods),
      ),
    );
  }

  Future<void> _onCategoryFilterChanged(
    CategoryFilterChanged event,
    Emitter<FoodSearchState> emit,
  ) async {
    category = event.category;
    add(const FoodListRequested());
  }
}
