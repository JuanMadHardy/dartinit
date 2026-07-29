El archivo [forth.dart](/home/m41nh34d/projects/dartinit/learning/forth.dart) implementa un intérprete muy pequeño del lenguaje **Forth**. En Forth se trabaja con una pila y los operadores se escriben después de los números:

```text
1 2 +
```

Significa: mete `1`, mete `2`, saca ambos, súmalos y guarda `3`.

## Propiedades de la clase

```dart
final List<int> _stack = [];
```

`_stack` es la pila donde se guardan los números.

- `List<int>`: lista que solamente acepta enteros.
- `_stack`: el guion bajo indica que es privada para la librería.
- `final`: la variable siempre apunta a la misma lista.
- `final` no impide modificar el contenido:

```dart
_stack.add(10); // Permitido
_stack = [];    // No permitido
```

La segunda propiedad:

```dart
final Map<String, List<String>> _definitions = {};
```

Guarda palabras creadas por el usuario. Es un mapa donde:

- La clave es el nombre de la palabra.
- El valor es la secuencia de instrucciones.

Por ejemplo:

```forth
: DOUBLE 2 * ;
```

Se almacenaría aproximadamente así:

```dart
{
  'DOUBLE': ['2', '*']
}
```

## Getter `stack`

```dart
List<int> get stack => List.unmodifiable(_stack);
```

Es una propiedad de solo lectura que permite consultar la pila:

```dart
print(forth.stack);
```

`List.unmodifiable` evita que alguien desde fuera modifique accidentalmente el estado interno:

```dart
forth.stack.add(5); // Lanza un error
```

Es una práctica de encapsulación: la clase controla cómo cambia su información.

## Método `evaluate`

```dart
void evaluate(String input)
```

Es el punto de entrada del intérprete. Recibe código Forth, lo divide en tokens y procesa cada token.

Para:

```text
1 2 +
```

los tokens son:

```dart
['1', '2', '+']
```

Luego decide qué es cada token:

```dart
if (token == ':') {
  // Empieza una definición
} else if (_definitions.containsKey(token)) {
  // Es una palabra definida por el usuario
} else if (_isNumber(token)) {
  // Es un número
} else {
  // Debe ser una operación incorporada
}
```

Esta cadena refleja una idea habitual en intérpretes: **clasificar primero la instrucción y ejecutarla después**.

```dart
final token = tok.current.toUpperCase();
```

Convierte todo a mayúsculas para que el lenguaje no distinga entre:

```text
dup
DUP
Dup
```

## Método `_tokenize`

```dart
List<String> _tokenize(String input) {
  return input
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();
}
```

Hace tres operaciones:

1. `split(...)` separa el texto por espacios, tabulaciones o saltos de línea.
2. `where(...)` elimina tokens vacíos.
3. `toList()` convierte el resultado en una lista.

La expresión regular:

```dart
RegExp(r'\s+')
```

significa “uno o más caracteres de espacio en blanco”.

## Método `_isNumber`

```dart
bool _isNumber(String token) {
  return RegExp(r'^-?\d+$').hasMatch(token);
}
```

Comprueba si un token representa un entero.

La expresión significa:

- `^`: principio del texto.
- `-?`: signo negativo opcional.
- `\d+`: uno o más dígitos.
- `$`: final del texto.

Acepta:

```text
10
0
-25
```

No acepta:

```text
2.5
12x
+
```

## Método `_defineWord`

```dart
int _defineWord(List<String> tokens, int start)
```

Lee una definición situada entre `:` y `;`.

Para:

```text
: DOUBLE 2 * ;
```

obtiene:

```dart
name = 'DOUBLE';
body = ['2', '*'];
```

Finalmente la guarda:

```dart
_definitions[name] = body;
```

El método devuelve la posición del `;`, supuestamente para que `evaluate` continúe después de la definición.

## Método `_executeDefinition`

```dart
void _executeDefinition(String name)
```

Ejecuta una palabra definida por el usuario.

Primero obtiene su cuerpo:

```dart
final body = _definitions[name]!;
```

El operador `!` le dice a Dart:

> Confío en que el valor existe y no es `null`.

Esto es razonable porque antes se comprobó:

```dart
_definitions.containsKey(token)
```

Después procesa cada instrucción del cuerpo. También permite que una definición invoque otra definición, mediante recursividad:

```dart
_executeDefinition(upper);
```

## Método `_executeBuiltin`

Este método ejecuta las operaciones incorporadas.

### Operaciones aritméticas

```dart
case '+':
  _binaryOp((a, b) => b + a);
```

La expresión:

```dart
(a, b) => b + a
```

es una función anónima corta. Equivale a:

```dart
int sumar(int a, int b) {
  return b + a;
}
```

La resta y la división usan `b - a` y `b ~/ a` porque el último elemento introducido es el primero que se extrae.

Ejemplo:

```text
5 3 -
```

Se extraen en este orden:

```dart
a = 3;
b = 5;
resultado = b - a; // 5 - 3
```

`~/` es la división entera de Dart:

```dart
8 ~/ 3 == 2
```

### `DUP`

```dart
_stack.add(_stack.last);
```

Duplica el último elemento:

```text
[3] → [3, 3]
```

### `DROP`

```dart
_stack.removeLast();
```

Elimina el último elemento:

```text
[1, 5] → [1]
```

### `SWAP`

Intercambia los dos últimos:

```text
[1, 2] → [2, 1]
```

### `OVER`

```dart
_stack.add(_stack[_stack.length - 2]);
```

Copia el penúltimo elemento:

```text
[1, 2] → [1, 2, 1]
```

### Operación desconocida

```dart
throw ArgumentError('Unknown word: $word');
```

Si una palabra no existe, se lanza una excepción. `$word` es interpolación de strings.

## Método `_binaryOp`

```dart
void _binaryOp(int Function(int, int) op)
```

Recibe otra función como parámetro. Esto evita repetir el mismo proceso para sumar, restar, multiplicar y dividir:

```dart
final a = _stack.removeLast();
final b = _stack.removeLast();
_stack.add(op(a, b));
```

`int Function(int, int)` significa:

> Una función que recibe dos enteros y devuelve un entero.

Esta técnica se conoce como función de orden superior.

## Función `main`

```dart
void main()
```

Es el punto de entrada del programa.

Dentro se declara una función local:

```dart
void test(String label, String code)
```

Cada prueba crea un intérprete nuevo:

```dart
final forth = Forth();
```

Lo ejecuta:

```dart
forth.evaluate(code);
```

Y muestra el resultado:

```dart
print('$label => ${forth.stack}');
```

## El problema que tiene el script

Al ejecutarlo, las operaciones básicas funcionan, pero falla aquí:

```dart
test('define double', ': double 2 * ; 5 double');
```

El problema está en `evaluate`: se recorren los tokens mediante un `Iterator`, pero `_defineWord` actualiza la variable `i`.

```dart
final tok = tokens.iterator;
```

El iterador y `i` son recorridos independientes. Cambiar `i` no hace que el iterador salte hasta después de `;`. Por eso el cuerpo de `DOUBLE` termina ejecutándose cuando todavía no debería.

Una estructura coherente sería recorrer únicamente por índice:

```dart
void evaluate(String input) {
  final tokens = _tokenize(input);
  var i = 0;

  while (i < tokens.length) {
    final token = tokens[i].toUpperCase();

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
```

Así, cuando `_defineWord` devuelve la posición de `;`, el recorrido continúa correctamente después de la definición.

También faltan validaciones para operaciones con una pila vacía, división entre cero y definiciones sin `;`. Como ejercicio educativo está bien, pero esas comprobaciones serían el siguiente paso para hacerlo robusto.
