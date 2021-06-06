import 'dart:convert';
import 'dart:io';
import 'package:Magnet/evaluator/evaluator.dart';
import 'package:Magnet/lexer/lexer.dart';
import 'package:Magnet/lexer/token.dart';
import 'package:Magnet/object/object.dart';
import 'package:Magnet/parser/parser.dart';


final EOF_TOKEN = Token(TokenType.EOF, '');

void printParserErrors(List<String> errors) {
  errors.forEach((err) => print(err));
}

void startRpl() {
  print('Welocme to Magnet!\n');
  var scanned = <String>[];

  while(true) {
    print('>>');
    var source = stdin.readLineSync(encoding: Encoding.getByName('utf-8')!);
    if (source! == 'exit()') {
      break;
    }

    scanned.add(source);
    var lexer = Lexer(scanned.join(' '), '', 0, 0);
    var parser = Parser(lexer);
    var env = Enviroment(null);
    var program = parser.parseProgram();

    if (parser.errors.isNotEmpty) {
      printParserErrors(parser.errors);
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