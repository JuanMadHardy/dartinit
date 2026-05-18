// ignore_for_file: unused_import

import 'dart:io';

import 'package:command_runner/command_runner.dart';
import 'package:http/http.dart' as http;

const version = '0.0.1';

void main(List<String> arguments) async {
  var runner = CommandRunner();
  await runner.run(arguments);
}
