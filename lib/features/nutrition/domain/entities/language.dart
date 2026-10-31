enum Language {
  en,
  ar;

  static Language fromString(String value) {
    return Language.values.firstWhere(
      (language) => language.name == value,
      orElse: () => throw ArgumentError('Unkown Language: $value'),
    );
  }
}
