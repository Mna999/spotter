import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/features/workouts/domain/entities/exercise.dart';
import 'package:spotter/features/workouts/domain/params/exercise_filter_params.dart';
import 'package:spotter/features/workouts/presentation/blocs/exercise_library_bloc/exercise_library_bloc.dart';
import 'package:spotter/injection_container.dart';

class ExercisePickerScreen extends StatefulWidget {
  const ExercisePickerScreen({super.key});

  @override
  State<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends State<ExercisePickerScreen> {
  static const int _catalogueLimit = 500;
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  final TextEditingController searchController = TextEditingController();
  late final ExerciseLibraryBloc _libraryBloc = sl<ExerciseLibraryBloc>();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Show the whole catalogue before the user types anything.
    _load(null);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _libraryBloc.close();
    searchController.dispose();
    super.dispose();
  }

  void _load(String? query) {
    final trimmed = query?.trim();
    _libraryBloc.add(
      ExercisesRequested(
        exerciseFilterParams: ExerciseFilterParams(
          query: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
          limit: _catalogueLimit,
        ),
      ),
    );
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () => _load(value));
  }

  void _clearQuery() {
    _debounce?.cancel();
    searchController.clear();
    setState(() {});
    _load(null);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return BlocProvider<ExerciseLibraryBloc>.value(
      value: _libraryBloc,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Exercise Library', style: text.headlineMedium),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: _onQueryChanged,
                    onSubmitted: (value) {
                      _debounce?.cancel();
                      _load(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search exercises (e.g. barbell)',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        onPressed: _clearQuery,
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All exercises are listed below. Type the start of a name '
                    'to filter.',
                    style: text.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child:
                        BlocConsumer<ExerciseLibraryBloc, ExerciseLibraryState>(
                          listener: (context, state) {
                            if (state is ExerciseLibraryError) {
                              SnackBarBuilder.showSnackBar(
                                context,
                                state.message,
                                true,
                                cs,
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state is ExerciseLibraryLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (state is ExerciseLibraryLoaded) {
                              if (state.exercises.isEmpty) {
                                return _message(
                                  text,
                                  cs,
                                  'No exercises matched this search.',
                                );
                              }
                              return ListView.separated(
                                itemCount: state.exercises.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) => _ExerciseCard(
                                  exercise: state.exercises[index],
                                  onTap: () => Navigator.pop(
                                    context,
                                    state.exercises[index],
                                  ),
                                ),
                              );
                            }
                            if (state is ExerciseLibraryError) {
                              return _message(
                                text,
                                cs,
                                state.message,
                                isError: true,
                              );
                            }
                            return _message(
                              text,
                              cs,
                              'Loading the exercise library...',
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _message(
    TextTheme text,
    ColorScheme cs,
    String message, {
    bool isError = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.search,
              size: 36,
              color: isError ? cs.error : cs.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodyMedium!.copyWith(
                color: isError ? cs.error : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.onTap});

  final Exercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final hasCoachModel =
        exercise.repThresholds?.isNotEmpty == true &&
        exercise.cues?.isNotEmpty == true;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.fitness_center, color: cs.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.nameEn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleLarge,
                    ),
                    if (exercise.nameAr.trim().isNotEmpty)
                      Text(
                        exercise.nameAr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (hasCoachModel)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.primary),
                  ),
                  child: Text(
                    'COACH',
                    style: text.labelSmall!.copyWith(color: cs.primary),
                  ),
                ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
