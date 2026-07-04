class House {
  static const List<String> _subjects = [
    'the house that Jack built.',
    'the malt',
    'the rat',
    'the cat',
    'the dog',
    'the cow with the crumpled horn',
    'the maiden all forlorn',
    'the man all tattered and torn',
    'the priest all shaven and shorn',
    'the rooster that crowed in the morn',
    'the farmer sowing his corn',
    'the horse and the hound and the horn',
  ];

  static const List<String> _actions = [
    '',
    'that lay in the house that Jack built.',
    'that ate the malt',
    'that killed the rat',
    'that worried the cat',
    'that tossed the dog',
    'that milked the cow with the crumpled horn',
    'that kissed the maiden all forlorn',
    'that married the man all tattered and torn',
    'that woke the priest all shaven and shorn',
    'that kept the rooster that crowed in the morn',
    'that belonged to the farmer sowing his corn',
  ];

  String recite(int startVerse, int endVerse) {
    final verses = <String>[];

    for (var verse = startVerse; verse <= endVerse; verse++) {
      verses.add(_buildVerse(verse));
    }

    return verses.join('\n');
  }

  String _buildVerse(int verse) {
    final index = verse - 1;

    // Primer fragmento: "This is ..."
    final lines = <String>['This is ${_subjects[index]}'];

    // Añadir acumulación hacia atrás
    for (var i = index; i > 0; i--) {
      lines.add(_actions[i]);
    }

    return lines.join(' ');
  }
}
