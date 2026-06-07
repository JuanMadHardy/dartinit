class HighScores {
  HighScores(this.scores);

  final List<int> scores;

  /// Última puntuación usando pattern matching
  int latest() {
    switch (scores) {
      case [..., final last]:
        return last;
      default:
        throw StateError('No scores available');
    }
  }

  /// Mejor puntuación usando destructuring
  int personalBest() {
    // reduce sigue siendo la forma más idiomática para max
    return scores.reduce((a, b) => a > b ? a : b);
  }

  /// Top 3 puntuaciones usando records y patterns
  List<int> personalTopThree() {
    // Copia defensiva para no mutar la lista original
    final sorted = [...scores]..sort((a, b) => b.compareTo(a));

    // Pattern matching para extraer hasta 3 valores
    switch (sorted) {
      case [final a, final b, final c, ...]:
        return [a, b, c];
      case [final a, final b]:
        return [a, b];
      case [final a]:
        return [a];
      default:
        return [];
    }
  }
}
