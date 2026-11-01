import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotter/core/error/failure.dart';
import 'package:spotter/features/nutrition/domain/entities/food_item.dart';
import 'package:spotter/features/nutrition/domain/entities/macro_nutrients.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_entry.dart';
import 'package:spotter/features/nutrition/domain/entities/meal_type.dart';
import 'package:spotter/features/nutrition/domain/entities/portion.dart';
import 'package:spotter/features/nutrition/domain/entities/price_basis.dart';
import 'package:spotter/features/nutrition/domain/params/meal_entry_id_params.dart';
import 'package:spotter/features/nutrition/domain/repository/meal_entry_repo.dart';
import 'package:spotter/features/nutrition/domain/usecases/delete_meal_entry_usecase.dart';
import 'package:spotter/features/nutrition/presentation/widgets/meal_entry_card.dart';

class _MockMealEntryRepo implements MealEntryRepo {
  String? lastDeletedUid;
  String? lastDeletedMealPlanId;
  String? lastDeletedMealEntryId;
  Either<Failure, Unit> deleteResult = const Right(unit);

  @override
  Future<Either<Failure, Unit>> delete({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
  }) async {
    lastDeletedUid = uid;
    lastDeletedMealPlanId = mealPlanId;
    lastDeletedMealEntryId = mealEntryId;
    return deleteResult;
  }

  @override
  Future<Either<Failure, MealEntry?>> get({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
  }) async => const Right(null);

  @override
  Future<Either<Failure, List<MealEntry>>> list({
    required String uid,
    required String mealPlanId,
  }) async => const Right([]);

  @override
  Future<Either<Failure, MealEntry>> save({
    required String uid,
    required String mealPlanId,
    required MealEntry entry,
  }) async => Right(entry);

  @override
  Future<Either<Failure, MealEntry>> update({
    required String uid,
    required String mealPlanId,
    required String mealEntryId,
    required Map<String, dynamic> partial,
  }) async => throw UnimplementedError();
}

MealEntry _sampleEntry({
  String id = 'entry_1',
  MealType type = MealType.breakfast,
}) {
  return MealEntry(
    mealEntryId: id,
    mealPlanId: 'plan_1',
    uid: 'user_1',
    foodId: 'food_1',
    mealType: type,
    order: 0,
    portion: const Portion(label: 'Piece', grams: 100),
    servingsCount: 1,
    schemaVersion: 1,
    createdAt: DateTime(2026),
  );
}

FoodItem _sampleFood() {
  return FoodItem(
    foodId: 'food_1',
    nameAr: 'بيض مسلوق',
    nameEn: 'Boiled Egg',
    category: 'Breakfast',
    per100g: const MacroNutrients(
      energyKcal: 155,
      proteinG: 13,
      fatG: 11,
      carbohydrateG: 1.1,
      fiberG: 0,
      waterG: 0,
      ashG: 0,
      refusePct: 0,
      mineralsMg: <String, double>{},
      vitamins: <String, dynamic>{},
    ),
    portions: const [Portion(label: '1 egg', grams: 50)],
    priceBasis: PriceBasis.serving,
    priceEgp: 6,
    schemaVersion: 1,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    searchText: 'boiled egg بيض مسلوق',
  );
}

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('DeleteMealEntryUseCase', () {
    test('calls repository delete with matching parameters on success', () async {
      final repo = _MockMealEntryRepo();
      final useCase = DeleteMealEntryUseCase(mealEntryRepo: repo);

      const params = MealEntryIdParams(
        uid: 'u123',
        mealPlanId: 'plan456',
        mealEntryId: 'entry789',
      );

      final result = await useCase(params);

      expect(result.isRight(), isTrue);
      expect(repo.lastDeletedUid, equals('u123'));
      expect(repo.lastDeletedMealPlanId, equals('plan456'));
      expect(repo.lastDeletedMealEntryId, equals('entry789'));
    });

    test('returns failure when repository fails', () async {
      final repo = _MockMealEntryRepo()
        ..deleteResult = const Left(ServerFailure(message: 'Network error'));
      final useCase = DeleteMealEntryUseCase(mealEntryRepo: repo);

      const params = MealEntryIdParams(
        uid: 'u123',
        mealPlanId: 'plan456',
        mealEntryId: 'entry789',
      );

      final result = await useCase(params);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, equals('Network error')),
        (_) => fail('Should not succeed'),
      );
    });
  });

  group('MealEntryCard delete button', () {
    testWidgets('shows delete button when unlogged and onDelete is provided', (
      tester,
    ) async {
      var deleted = false;
      await tester.pumpWidget(
        _wrap(
          MealEntryCard(
            entry: _sampleEntry(),
            food: _sampleFood(),
            isLogged: false,
            onLog: () {},
            onDelete: () => deleted = true,
          ),
        ),
      );

      // Verify food name and LOG button are shown
      expect(find.text('Boiled Egg'), findsOneWidget);
      expect(find.text('LOG'), findsOneWidget);

      // Verify delete button is present
      final deleteBtn = find.byTooltip('Delete food');
      expect(deleteBtn, findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);

      // Tap delete button
      await tester.tap(deleteBtn);
      await tester.pump();
      expect(deleted, isTrue);
    });

    testWidgets('does not show delete button when entry is already logged', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          MealEntryCard(
            entry: _sampleEntry(),
            food: _sampleFood(),
            isLogged: true,
            onLog: () {},
            onUndo: () {},
            onDelete: () {},
          ),
        ),
      );

      // Verify LOGGED badge and UNDO button are shown
      expect(find.text('LOGGED'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);

      // Delete button must NOT be rendered when logged
      expect(find.byTooltip('Delete food'), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('shows loading indicator and disables delete when isDeleting is true', (
      tester,
    ) async {
      var deleted = false;
      await tester.pumpWidget(
        _wrap(
          MealEntryCard(
            entry: _sampleEntry(),
            food: _sampleFood(),
            isLogged: false,
            isDeleting: true,
            onLog: () {},
            onDelete: () => deleted = true,
          ),
        ),
      );

      // CircularProgressIndicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsNothing);

      // Tapping should not trigger delete callback
      await tester.tap(find.byTooltip('Delete food'));
      await tester.pump();
      expect(deleted, isFalse);
    });
  });
}
