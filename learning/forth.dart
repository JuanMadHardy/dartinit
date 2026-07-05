void main() {
  final String name = "John 8888";
  final regex = RegExp(r'^\b\w+\b');
  final matches = regex.allMatches(name).map((m) => m.group(0)).toList();
  print(matches);
}
