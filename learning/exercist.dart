

void isArmstrongNumber(String nbr) {
  if (nbr == '0') {
    print('true');
    return;
  }

  List<int> digits = nbr.split('').map(int.parse).toList();

  final valpow = digits.length;

  final result = digits
      .map((d) => BigInt.from(d).pow(valpow))
      .reduce((a, b) => a + b);

  final inputValue = BigInt.parse(nbr);

  print(result.toString());
  print(result == inputValue);
}

void main() {
  isArmstrongNumber('186709961001538790100634132976990');
}
