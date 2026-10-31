enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  preWorkout,
  postWorkout;

   static MealType fromString(String value) {
    return MealType.values.firstWhere(
      (s) => s.name == value,
      orElse: () => throw ArgumentError('Unknown MealType: $value'),
    );
  } 
}