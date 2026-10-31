enum PriceBasis {
  weight,

  serving,

  drink;

  static PriceBasis fromString(String value) {
    return PriceBasis.values.firstWhere(
      (s) => s.name == value,
      orElse: () => PriceBasis.weight,
    );
  }
}
