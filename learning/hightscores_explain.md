El archivo [hightscores.dart](/home/m41nh34d/projects/dartinit/learning/hightscores.dart) implementa una clase muy pequeña para gestionar la lista de puntuaciones de un jugador, devolviendo la última, la mejor y el top 3. Es un ejercicio clásico de Exercism que aquí se aprovecha como banco de pruebas para **patterns de Dart 3** (`switch` con patrones de lista, rest pattern, destructuring).

No define un `main()`, así que es código estilo librería: se importa o se prueba desde otro script, no se ejecuta por sí solo.

## Propiedades de la clase

```dart
class HighScores {
  HighScores(this.scores);

  final List<int> scores;
}
```

- `HighScores(this.scores)`: constructor con lista de enteros. `this.scores` es azúcar sintáctica para asignar directamente el parámetro al campo.
- `scores`: campo público y `final`. Como es `final`, la referencia no puede cambiar, pero el contenido de la lista sí:

```dart
final hs = HighScores([10, 20]);
hs.scores.add(30);   // Permitido: muta la lista interna
hs.scores = [1, 2];  // No permitido: reasignar la referencia
```

No hay copia defensiva en el constructor, por lo que el llamador y la clase comparten la misma lista.

## Método `latest`

```dart
int latest() {
  switch (scores) {
    case [..., final last]:
      return last;
    default:
      throw StateError('No scores available');
  }
}
```

Devuelve la última puntuación de la lista. La parte interesante es el `switch` con **patrones de lista**.

### Patrón `[..., final last]`

- `...` es el **rest pattern**: indica "cualquier número de elementos, incluido cero".
- `final last` declara una variable ligada que captura el último elemento de la lista.
- Como el rest absorbe todo antes del último, este patrón encaja con cualquier lista con al menos un elemento.

En una lista vacía el patrón no coincide y se ejecuta el `default`, que lanza `StateError`. En la práctica esto es equivalente a `scores.last`, pero escrito como pattern matching.

## Método `personalBest`

```dart
int personalBest() {
  return scores.reduce((a, b) => a > b ? a : b);
}
```

Devuelve la puntuación máxima.

- `Iterable<int>.reduce` toma el primer elemento como acumulador inicial y aplica la función sobre cada elemento siguiente, devolviendo el acumulado final.
- `(a, b) => a > b ? a : b` es un ternario: devuelve el mayor de los dos.

El comentario del propio archivo dice:

> `reduce` sigue siendo la forma más idiomática para `max`

Es cierto, aunque existen alternativas con patterns. Por ejemplo:

```dart
int personalBest() {
  switch (scores) {
    case [final only]:
      return only;
    case [final first, ...final rest]:
      return rest.fold(first, (a, b) => a > b ? a : b);
    default:
      throw StateError('No scores available');
  }
}
```

El resultado es el mismo, pero deja explícito el caso de un solo elemento y el caso vacío.

## Método `personalTopThree`

```dart
List<int> personalTopThree() {
  final sorted = [...scores]..sort((a, b) => b.compareTo(a));

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
```

Devuelve hasta las tres mejores puntuaciones en orden descendente.

### Copia defensiva y ordenación

```dart
final sorted = [...scores]..sort((a, b) => b.compareTo(a));
```

- `[...scores]` es el operador **spread** aplicado a una lista: crea una lista nueva con los mismos elementos.
- `..sort(...)` es la **notación en cascada**: ejecuta `sort` sobre `sorted` y devuelve el mismo objeto, sin romper la asignación.
- `(a, b) => b.compareTo(a)` invierte la comparación natural de `int`, que por defecto es ascendente, para conseguir orden descendente.

La copia defensiva es importante: si se ordenase directamente `scores`, se mutaría la lista del llamador, algo que normalmente no se espera de un "getter" de las tres mejores.

### Destructuring exhaustivo

El `switch` sobre la lista ordenada cubre los cuatro tamaños posibles sin usar `.length` ni `if/else`:

| Patrón | Cuándo encaja | Devuelve |
|---|---|---|
| `[a, b, c, ...]` | 3 o más elementos | `[a, b, c]` |
| `[a, b]` | exactamente 2 | `[a, b]` |
| `[a]` | exactamente 1 | `[a]` |
| `default` | lista vacía | `[]` |

Cada `case` liga nombres (`a`, `b`, `c`) que sólo son visibles dentro de su bloque `return`. El `...` final del primer caso absorbe los elementos sobrantes sin asignarlos a nada: no hace falta una variable ligada ahí.

## Funciones de orden superior que aparecen

- `List.sort` recibe un comparador `(int, int) → int`.
- `Iterable.reduce` recibe una función combinadora `(int, int) → int`.

Ambas muestran que en Dart es habitual pasar funciones como argumento para parametrizar el comportamiento.

## El problema que tiene el script

El archivo es correcto, pero su API es **incoherente ante la lista vacía**. Cada método reacciona de forma distinta:

| Método | Lista vacía |
|---|---|
| `latest()` | Lanza `StateError('No scores available')` |
| `personalBest()` | Lanza `Bad state: No element` (proveniente de `reduce`) |
| `personalTopThree()` | Devuelve `[]` |

Las dos primeras rompen, pero con mensajes y tipos de excepción diferentes. Una API consistente debería fijar una sola política: o se lanzan errores en los tres métodos (`personalTopThree` lanzaría `StateError`), o se devuelve un valor seguro en los tres (`personalBest` necesitaría tratar el caso por separado con un pattern o con `fold`).

Una versión con la misma política para los tres casos podría ser:

```dart
int personalBest() {
  switch (scores) {
    case [final only]:
      return only;
    case [final first, ...final rest]:
      return rest.fold(first, (a, b) => a > b ? a : b);
    default:
      throw StateError('No scores available');
  }
}
```

Así, una lista vacía produce el mismo `StateError` en los dos métodos que pueden fallar, y `personalTopThree` mantiene su `[]` como caso natural.

Otra ausencia menor: el script no tiene `main()` ni un arnés de pruebas, por lo que para ejecutarlo hay que crear un pequeño conductor en otro archivo. Como ejercicio de patterns está bien, pero un par de `print` o un test de `dart test` lo cerrarían como ejemplo completo.
