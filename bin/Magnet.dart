import 'dart:io';

// ignore: library_prefixes
import 'package:Magnet/Magnet.dart' as Magnet;
import 'package:args/args.dart';

const fileCmd = 'file';
const replCmd = 'repl';

void main(List<String> arguments) {
  exitCode = 0;

  final parser = ArgParser()..addFlag(fileCmd, negatable: true, abbr: 'f');
  parser.addFlag(replCmd, negatable: true, abbr: 'r');
  var argResult = parser.parse(arguments);
  if (argResult[replCmd]) {
    Magnet.startRpl();
    return;
  }

  Magnet.read(argResult.rest[0]);
}
