import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/route/routing.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_plan.dart';
import 'package:spotter/features/nutrition/presentation/bloc/food_search_bloc/food_search_bloc.dart';
import 'package:spotter/features/nutrition/presentation/screens/food_detail_screen.dart';
import 'package:spotter/features/nutrition/presentation/utils/nutrition_ui_helpers.dart';
import 'package:spotter/features/nutrition/presentation/widgets/food_result_card.dart';
import 'package:spotter/features/nutrition/presentation/widgets/nutrition_message_view.dart';
import 'package:spotter/injection_container.dart';

/// Searchable food catalogue. The result card opens the detail / portion
/// picker, which either logs the food or adds it to [mealPlan].
class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({
    super.key,
    required this.uid,
    this.mode = FoodActionMode.log,
    this.mealPlan,
    this.logDate,
    this.spentEgp,
  });

  final String uid;
  final FoodActionMode mode;
  final MealPlan? mealPlan;
  final DateTime? logDate;
  final double? spentEgp;

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final FoodSearchBloc _bloc = sl<FoodSearchBloc>();
  final TextEditingController _controller = TextEditingController();
  final Set<String> _categories = {};
  Timer? _debounce;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bloc.add(const FoodListRequested());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _bloc.add(SearchQueryChanged(value));
    });
  }

  void _clearSearch() {
    _controller.clear();
    _debounce?.cancel();
    setState(() => _selectedCategory = null);
    _bloc.add(const CategoryFilterChanged(null));
  }

  void _selectCategory(String? category) {
    setState(() => _selectedCategory = category);
    _bloc.add(CategoryFilterChanged(category));
  }

  Future<void> _openDetail(FoodItem food) async {
    await Routing.routePush(
      FoodDetailScreen(
        uid: widget.uid,
        food: food,
        mode: widget.mode,
        mealPlan: widget.mealPlan,
        logDate: widget.logDate,
        spentEgp: widget.spentEgp,
      ),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return BlocProvider<FoodSearchBloc>.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Food database', style: text.headlineMedium),
        ),
        body: BlocConsumer<FoodSearchBloc, FoodSearchState>(
          listener: (context, state) {
            if (state is FoodSearchLoaded) {
              final found = state.foods
                  .map((food) => food.category.trim())
                  .where((category) => category.isNotEmpty)
                  .toSet();
              if (found.difference(_categories).isNotEmpty) {
                setState(() => _categories.addAll(found));
              }
            }
          },
          builder: (context, state) {
            final query = switch (state) {
              FoodSearchLoaded(:final query) => query,
              FoodSearchLoading(:final query) => query,
              FoodSearchEmpty(:final query) => query,
              _ => '',
            };

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onChanged: _onQueryChanged,
                    decoration: InputDecoration(
                      hintText: 'Search Egyptian foods, brands or meals',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _controller.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: _clearSearch,
                              tooltip: 'Clear',
                              icon: const Icon(Icons.close),
                            ),
                    ),
                  ),
                ),
                if (widget.mode == FoodActionMode.addToPlan)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_note_outlined,
                          size: 15,
                          color: cs.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.mealPlan == null
                                ? 'Adding to a meal plan'
                                : 'Adding to plan for '
                                      '${friendlyDate(widget.mealPlan!.date)}',
                            style: text.bodySmall!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_categories.isNotEmpty)
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _CategoryChip(
                          label: 'ALL',
                          selected: _selectedCategory == null,
                          onTap: () => _selectCategory(null),
                        ),
                        for (final category in _categories)
                          _CategoryChip(
                            label: category.toUpperCase(),
                            selected: _selectedCategory == category,
                            onTap: () => _selectCategory(category),
                          ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _results(context, state, query),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _results(
    BuildContext context,
    FoodSearchState state,
    String query,
  ) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (state is FoodSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is FoodSearchError) {
      return NutritionMessageView(
        title: 'Could not load foods',
        message: state.message,
        icon: Icons.cloud_off_outlined,
        isError: true,
        onAction: () => _bloc.add(const FoodListRequested()),
      );
    }
    if (state is FoodSearchEmpty) {
      return NutritionMessageView(
        title: query.isEmpty ? 'No foods in the catalogue' : 'No matches',
        message: query.isEmpty
            ? 'The food catalogue is empty. Ask an admin to add Egyptian '
                  'foods.'
            : 'Nothing matched "$query". Try a different name or clear the '
                  'category filter.',
        icon: Icons.search_off,
        onAction: query.isEmpty
            ? () => _bloc.add(const FoodListRequested())
            : _clearSearch,
        actionLabel: query.isEmpty ? 'REFRESH' : 'CLEAR SEARCH',
      );
    }

    final foods = state is FoodSearchLoaded ? state.foods : const <FoodItem>[];
    if (foods.isEmpty) {
      return NutritionMessageView(
        title: 'Search the catalogue',
        message: 'Type a food name or pick a category to get started.',
        icon: Icons.restaurant_menu,
        onAction: () => _bloc.add(const FoodListRequested()),
        actionLabel: 'BROWSE ALL',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: foods.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(
                  'MATCHING RECORDS',
                  style: text.labelSmall!.copyWith(
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${foods.length} FOUND',
                  style: text.labelSmall!.copyWith(color: cs.primary),
                ),
                const Spacer(),
                Text(
                  'CAIRO NUTRITION DB',
                  style: text.labelSmall!.copyWith(color: cs.outline),
                ),
              ],
            ),
          );
        }
        final food = foods[index - 1];
        return FoodResultCard(
          food: food,
          onTap: () => _openDetail(food),
          onAdd: () => _openDetail(food),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? cs.primary : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? cs.primary : cs.outlineVariant,
              ),
            ),
            child: Text(
              label,
              style: text.labelSmall!.copyWith(
                color: selected ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
