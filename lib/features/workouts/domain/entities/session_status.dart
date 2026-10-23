enum SessionStatus {
  planned,

  inProgress,

  paused,

  finished,

  cancelled;

  static SessionStatus fromString(String value) {
    return SessionStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => throw ArgumentError('Unknown SessionStatus: $value'),
    );
  }
}
