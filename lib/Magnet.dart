import 'dart:io';
import 'package:Magnet/evaluator/evaluator.dart';
import 'package:Magnet/lexer/lexer.dart';
import 'package:Magnet/object/object.dart';
import 'package:Magnet/parser/parser.dart';
import 'package:Magnet/repl/repl.dart';

void start() {
  startRpl();
}

void read(String path) {
  final file = File(path);
  final source = file.readAsStringSync();

  var lexer = Lexer(source, '', 0, 0);
  var parser = Parser(lexer);
  var program = parser.parseProgram();
  var env = Enviroment(null);

  if (parser.errors.isNotEmpty) {
    parser.errors.forEach((err) => print(err));
    return;
  }

  var evaluated = evaluate(program, env);
  if (evaluated != SingletonNull) {
    print(evaluated.inspect());
  }
}