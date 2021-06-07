import 'dart:io';
import 'package:Magnet/evaluator/evaluator.dart';
import 'package:Magnet/lexer/lexer.dart';
import 'package:Magnet/lexer/token.dart';
import 'package:Magnet/object/object.dart';
import 'package:Magnet/parser/parser.dart';

final EOF_TOKEN = Token(TokenType.EOF, '');

void startRpl() {
  print('Welocme to Magnet!\n');
  var scanned = <String>[];

  while(true) {
    stdout.write('>>> ');
    var source = stdin.readLineSync();
    if (source! == 'exit()') {
      break;
    }

    scanned.add(source);
    var lexer = Lexer(scanned.join(' '), '', 0, 0);
    var parser = Parser(lexer);
    var env = Enviroment(null);
    var program = parser.parseProgram();

    if (parser.errors.isNotEmpty) {
      parser.errors.forEach((err) => print(err));
      scanned.removeLast();
      continue;
    }

    var evaluated = evaluate(program, env);
    if (scanned.last.contains('escribir')) {
      scanned.removeLast();
    }

    if (evaluated != SingletonNull) {
      print(evaluated.inspect());

      if (evaluated.runtimeType == Error) {
        scanned.removeLast();
      }
    }
  }
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