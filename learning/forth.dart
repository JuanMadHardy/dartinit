class Forth {
  final List<int> _stack = [];
  final Map<String, List<String>> _definitions = {};

  List<int> get stack => List.unmodifiable(_stack);

  void evaluate(String input) {
    final tokens = _tokenize(input);
    int i = 0;
    final tok = tokens.iterator;

    while (tok.moveNext()) {
      final token = tok.current.toUpperCase();

      if (token == ':') {
        i = _defineWord(tokens, i);
      } else if (_definitions.containsKey(token)) {
        _executeDefinition(token);
      } else if (_isNumber(token)) {
        _stack.add(int.parse(token));
      } else {
        _executeBuiltin(token);
      }
      i++;
    }
  }

  List<String> _tokenize(String input) {
    return input.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  }

  bool _isNumber(String token) {
    return RegExp(r'^-?\d+$').hasMatch(token);
  }

  int _defineWord(List<String> tokens, int start) {
    final name = tokens[start + 1].toUpperCase();
    final body = <String>[];
    int i = start + 2;

    while (i < tokens.length && tokens[i] != ';') {
      body.add(tokens[i]);
      i++;
    }

    _definitions[name] = body;
    return i;
  }

  void _executeDefinition(String name) {
    final body = _definitions[name]!;
    for (final token in body) {
      final upper = token.toUpperCase();
      if (_definitions.containsKey(upper)) {
        _executeDefinition(upper);
      } else if (_isNumber(upper)) {
        _stack.add(int.parse(upper));
      } else {
        _executeBuiltin(upper);
      }
    }
  }

  void _executeBuiltin(String word) {
    switch (word) {
      case '+':
        _binaryOp((a, b) => b + a);
        break;
      case '-':
        _binaryOp((a, b) => b - a);
        break;
      case '*':
        _binaryOp((a, b) => b * a);
        break;
      case '/':
        _binaryOp((a, b) => b ~/ a);
        break;
      case 'DUP':
        _stack.add(_stack.last);
        break;
      case 'DROP':
        _stack.removeLast();
        break;
      case 'SWAP':
        final a = _stack.removeLast();
        final b = _stack.removeLast();
        _stack.add(a);
        _stack.add(b);
        break;
      case 'OVER':
        _stack.add(_stack[_stack.length - 2]);
        break;
      default:
        throw ArgumentError('Unknown word: $word');
    }
  }

  void _binaryOp(int Function(int, int) op) {
    final a = _stack.removeLast();
    final b = _stack.removeLast();
    _stack.add(op(a, b));
  }
}

void main() {
  void test(String label, String code) {
    final forth = Forth();
    forth.evaluate(code);
    print('$label => ${forth.stack}');
  }

  test('1 2 +', '1 2 +');
  test('5 3 -', '5 3 -');
  test('2 4 *', '2 4 *');
  test('8 2 /', '8 2 /');
  test('3 DUP', '3 DUP');
  test('5 DROP', '5 DROP');
  test('1 2 SWAP', '1 2 SWAP');
  test('1 2 OVER', '1 2 OVER');
  test('define double', ': double 2 * ; 5 double');
  test('negative -3', '-3');
  test('case insensitive', '1 2 + DUP');
}
