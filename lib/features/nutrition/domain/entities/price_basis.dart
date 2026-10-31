enum PriceBasis {
  weight,

  serving,

  drink;

  /// Parses the stored value. Accepts both the plain name (`weight`) and the
  /// legacy `toString()` form (`PriceBasis.weight`).
  static PriceBasis fromString(String value) {
    final normalized = value.split('.').last;
    return PriceBasis.values.firstWhere(
      (s) => s.name == normalized,
      orElse: () => PriceBasis.weight,
    );
  }
}
