enum PlanStatus {
  draft,

  committed,

  archived;

  static PlanStatus fromString(String value) {
    return PlanStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => throw ArgumentError('Unknown PlanStatus: $value'),
    );
  }
}
