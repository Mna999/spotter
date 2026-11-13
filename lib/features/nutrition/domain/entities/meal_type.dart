enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  preWorkout,
  postWorkout;

  /// Parses the stored value. Accepts both the plain name (`breakfast`) and
  /// the legacy `toString()` form (`MealType.breakfast`) written by older
  /// builds. Unknown values fall back to [snack] instead of throwing so a
  /// single bad document cannot break the whole day.
  static MealType fromString(String value) {
    final normalized = value.split('.').last;
    return MealType.values.firstWhere(
      (s) => s.name == normalized,
      orElse: () => MealType.snack,
    );
  }

  /// The meal that best matches a 24-hour clock [hour].
  static MealType forHour(int hour) {
    if (hour < 11) return MealType.breakfast;
    if (hour < 16) return MealType.lunch;
    if (hour < 21) return MealType.dinner;
    return MealType.snack;
  }
}
