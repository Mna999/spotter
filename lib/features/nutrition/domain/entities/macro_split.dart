import 'package:equatable/equatable.dart';

/// Protein / carbohydrate / fat grams and their share of the Atwater energy.
class MacroSplit extends Equatable {
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double proteinShare;
  final double carbsShare;
  final double fatShare;

  const MacroSplit({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.proteinShare,
    required this.carbsShare,
    required this.fatShare,
  });

  factory MacroSplit.fromGrams({
    required double proteinG,
    required double carbsG,
    required double fatG,
  }) {
    final proteinKcal = proteinG * 4;
    final carbsKcal = carbsG * 4;
    final fatKcal = fatG * 9;
    final total = proteinKcal + carbsKcal + fatKcal;
    return MacroSplit(
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      proteinShare: total <= 0 ? 0 : proteinKcal / total,
      carbsShare: total <= 0 ? 0 : carbsKcal / total,
      fatShare: total <= 0 ? 0 : fatKcal / total,
    );
  }

  @override
  List<Object?> get props => [
    proteinG,
    carbsG,
    fatG,
    proteinShare,
    carbsShare,
    fatShare,
  ];
}
