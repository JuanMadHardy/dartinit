BigInt square(final int n) {
  if (n <= 0 || n > 64) throw ArgumentError('square must be between 1 and 64');
  int ini = 1;
  int a = 2;
  for (var i = 2; i <= n; i + 1) {
    ini = ini + a;
    a += 2;
  }
  return BigInt.from(ini);
}

BigInt total() {
  if (n <= 0 || n > 64) throw ArgumentError('square must be between 1 and 64');
  int ini = 1;
  int a = 2;
  for (var i = 2; i <= 64; i + 1) {
    ini = ini + a;
    a += 2;
  }
  return BigInt.from(ini);
}
