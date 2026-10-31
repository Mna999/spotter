enum PlanStatus {
  draft,

  committed,

  archived;

  /// Parses the stored value. Accepts both the plain name (`draft`) and the
  /// legacy `toString()` form (`PlanStatus.draft`).
  static PlanStatus fromString(String value) {
    final normalized = value.split('.').last;
    return PlanStatus.values.firstWhere(
      (s) => s.name == normalized,
      orElse: () => PlanStatus.draft,
    );
  }
}
