import 'package:Magnet/ast/ast.dart';
import 'package:Magnet/lexer/token.dart';

typedef prefixParseFn = Expression Function();
typedef infixParseFn = Expression Function(Expression);

Map<TokenType, prefixParseFn> prefixParseFns;
Map<TokenType, infixParseFn> infixParseFns;

enum precedences {
  LOWEST,
  ANDOR,
  EQUEAL,
  LESSGRATER,
  SUM,
  PRODUCT,
  PREFIX,
  CALL,
}