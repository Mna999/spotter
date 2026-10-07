class BodyMetrics {
  double bmi;
  double ree;
  double tdee;
  MacroTargets macroTargets;
  BodyMetrics({
    required this.bmi,
    required this.macroTargets,
    required this.ree,
    required this.tdee,
  });
}

class MacroTargets {
  final int calories;
  final int proteinG;
  final int fatG;
  final int carbsG;

  const MacroTargets({
    required this.calories,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
  });

  // Atwater general factors (kcal/g): https://www.fao.org/4/AA040E/AA040E08.htm
  static const double _kcalPerGProtein = 4;
  static const double _kcalPerGCarb = 4;
  static const double _kcalPerGFat = 9;

  // ISSN: 1.4-2.0 g/kg/day for most exercising individuals (top of range used)
  // https://pubmed.ncbi.nlm.nih.gov/28642676/
  static const double _proteinPerKg = 2.0;

  // IOM AMDR for fat: 20-35% of energy (bottom of range used)
  // https://books.nap.edu/read/10490/chapter/13
  static const double _fatShare = 0.20;

  /// [targetCalories] is TDEE after the goal adjustment.
  factory MacroTargets.calculate({
    required double targetCalories,
    required double weightKg,
  }) {
    final protein = weightKg * _proteinPerKg;
    final fat = targetCalories * _fatShare / _kcalPerGFat;
    final carbsKcal =
        targetCalories - protein * _kcalPerGProtein - fat * _kcalPerGFat;
    final carbs = carbsKcal < 0 ? 0.0 : carbsKcal / _kcalPerGCarb;

    return MacroTargets(
      calories: targetCalories.round(),
      proteinG: protein.round(),
      fatG: fat.round(),
      carbsG: carbs.round(),
    );
  }

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'proteinG': proteinG,
    'fatG': fatG,
    'carbsG': carbsG,
  };

  factory MacroTargets.fromJson(Map<String, dynamic> json) => MacroTargets(
    calories: (json['calories'] as num).toInt(),
    proteinG: (json['proteinG'] as num).toInt(),
    fatG: (json['fatG'] as num).toInt(),
    carbsG: (json['carbsG'] as num).toInt(),
  );
}
