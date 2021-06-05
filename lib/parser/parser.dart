import 'package:Magnet/ast/ast.dart';
import 'package:Magnet/lexer/lexer.dart';
import 'package:Magnet/lexer/token.dart';

typedef prefixParseFn = Expression? Function();
typedef infixParseFn = Expression? Function(Expression);

typedef PrefixParseFns = Map<TokenType, prefixParseFn>;
typedef InfixParseFns = Map<TokenType, infixParseFn>;

enum Precedence {
  LOWEST,
  ANDOR,
  EQUEAL,
  LESSGRATER,
  SUM,
  PRODUCT,
  PREFIX,
  CALL,
}

const Precedences = {
  TokenType.AND: Precedence.ANDOR,
  TokenType.EQ: Precedence.EQUEAL,
  TokenType.NOT_EQ: Precedence.EQUEAL,
  TokenType.LT: Precedence.LESSGRATER,
  TokenType.LTOREQ: Precedence.LESSGRATER,
  TokenType.GT: Precedence.LESSGRATER,
  TokenType.GTOREQ: Precedence.LESSGRATER,
  TokenType.PLUS: Precedence.SUM,
  TokenType.MINUS: Precedence.SUM,
  TokenType.DIVISION: Precedence.PRODUCT,
  TokenType.TIMES: Precedence.PRODUCT,
  TokenType.MOD: Precedence.PRODUCT,
  TokenType.LPAREN: Precedence.CALL,
  TokenType.BAR: Precedence.CALL,
  TokenType.OR: Precedence.ANDOR,
};

class Parser {
  Lexer lexer;
  late Token? currentToken;
  late Token? peekToken;
  late List<String> _errors;
  late PrefixParseFns prefixFns;
  late InfixParseFns infixFns;

  Parser(this.lexer);

  void advanceTokens() {
    currentToken = peekToken;
    peekToken = lexer.nextToken();
  }

  Precedence currentPrecedence() {
    assert(currentToken != null);
    var precedence = Precedences[currentToken?.tokenType];
    if (precedence == null) {
      return Precedence.LOWEST;
    }

    return precedence;
  }

  Program parseProgram() {
    var program = Program(<Statement>[]);
    while (currentToken?.tokenType != TokenType.EOF) {
      var statement = parseStatement();
      if (statement != null) {
        program.statements.add(statement);
      }
      
      advanceTokens();
    }

    return program;
  }

  Expression parseBoolean() {
    assert(currentToken != null);
    if (currentToken?.tokenType == TokenType.TRUE) {
      return Boolean(true, currentToken!);
    }

    return Boolean(false, currentToken!);
  }

  Expression parseCall(Expression func) {
    assert(currentToken != null);
    var call = Call(func, <Expression>[], currentToken!);
    call.arguments = parseCallArguemts()!;
    return call;
  }

  List<Expression>? parseCallArguemts() {
    assert(currentToken != null);
    var args = <Expression>[];
    if (peekToken?.tokenType == TokenType.BAR) {
      advanceTokens();
      return args;
    }

    advanceTokens();
    var expression = parseExpression(Precedence.LOWEST);
    if (expression != null) {
      args.add(expression);
    }

    while (peekToken?.tokenType == TokenType.COMMA) {
      expression = parseExpression(Precedence.LOWEST);
      if (expression != null) {
        args.add(expression);
      }
    }

    if (!expectedToken(TokenType.BAR)) {
      return null;
    }

    return args;
  }

  List<String> errors() {
    return _errors;
  }

  Statement? parseStatement() {
    if (currentToken?.tokenType == TokenType.LET) {
      return parseLetStatement();

    } else if (currentToken?.tokenType == TokenType.RETURN) {
      return parseReturnStatement();
    }

    return parseExpressionStatement();
  }

  Statement parseReturnStatement() {
    assert(currentToken != null);
    var statemt = ReturnStatement(null, currentToken!);
    advanceTokens();

    statemt.returnValue = parseExpression(Precedence.LOWEST);
    assert(peekToken != null);

    if (peekToken?.tokenType == TokenType.SEMICOLON) {
      advanceTokens();
    }

    return statemt;
  }

  ExpressionStatement parseExpressionStatement() {
    assert(currentToken != null);
    var statement = ExpressionStatement(null, currentToken!);
    statement.expression = parseExpression(Precedence.LOWEST);

    assert(peekToken != null);
    if (peekToken?.tokenType == TokenType.SEMICOLON) {
      advanceTokens();
    }

    return statement;
  }

  Expression? parseGroupExpression() {
    advanceTokens();
    var expression = parseExpression(Precedence.LOWEST);
    if (!expectedToken(TokenType.RPAREN)) {
      return null;
    }

    return expression;
  }


  Expression parseStringLiteral() {
    assert(currentToken != null);
    return StringLiteral(currentToken!.literal, currentToken!);
  }

  Expression parsePrefixExpression() {
    assert(currentToken != null);
    var prefix = Prefix(currentToken!.literal, null, currentToken!);
    advanceTokens();
    prefix.rigth = parseExpression(Precedence.PREFIX);
    return prefix;
  }

  Expression? parseFunction() {
    assert(currentToken != null);
    var func = FunctionExpression(null, null, currentToken!);
    if (!expectedToken(TokenType.BAR)) {
      return null;
    }

    func.parameters = parseFunctionParameters();
    if (!expectedToken(TokenType.LBRACE)) {
      return null;
    }

    func.body = parseBlock();
    return func;
  }

  List<Identifier> parseFunctionParameters() {
    assert(peekToken != null);
    var params = <Identifier>[];
    if (peekToken?.tokenType == TokenType.BAR) {
      advanceTokens();
      return params;
    }

    advanceTokens();
    var identifier = Identifier(currentToken?.literal, currentToken!);
    params.add(identifier);

    while (peekToken?.tokenType == TokenType.COMMA) {
      advanceTokens();
      advanceTokens();
      identifier = Identifier(currentToken?.literal, currentToken!);
      params.add(identifier);
    }

    if (!expectedToken(TokenType.BAR)) {
      return <Identifier>[];
    }

    return params;
  }

  Statement? parseLetStatement() {
    assert(currentToken != null);
    var statement = LetStatement(null, null, currentToken!);
    if (!expectedToken(TokenType.IDENT)) {
      return null;
    }

    statement.name = parseIdentifier();
    if (!expectedToken(TokenType.ASSING)) {
      return null;
    }

    advanceTokens();
    statement.value = parseExpression(Precedence.LOWEST);
    assert(peekToken != null);
    if (peekToken?.tokenType == TokenType.SEMICOLON) {
      advanceTokens();
    }

    return statement;
  }

  Block parseBlock() {
    assert(currentToken != null);
    var block = Block(<Statement>[], currentToken!);
    advanceTokens();

    while (
      !(currentToken?.tokenType == TokenType.LBRACE) && 
      !(currentToken?.tokenType == TokenType.EOF)) {
        var statement = parseStatement();
        if (statement != null) {
          block.statements.add(statement);
        }

        advanceTokens();
    }

    return block;
  }

  Expression? parseIf() {
    var ifExpression = IfExpression(null, null, null, currentToken!);
    if (!expectedToken(TokenType.LPAREN)) {
      return null;
    }

    advanceTokens();
    ifExpression.condition = parseExpression(Precedence.LOWEST);
    if (!expectedToken(TokenType.RPAREN)) {
      return null;
    }

    if (!expectedToken(TokenType.LBRACE)) {
      return null;
    }

    ifExpression.consequence = parseBlock();
    assert(peekToken != null);
    if (peekToken?.tokenType == TokenType.ELSE) {
      advanceTokens();
      if (!expectedToken(TokenType.LBRACE)) {
        return null;
      }

      ifExpression.alternative = parseBlock();
    }

    return ifExpression;
  }

  Expression? parseInteger() {
    assert(currentToken != null);
    var integer = Integer(0, currentToken!);

    var val = int.tryParse(currentToken!.literal);
    if (val == null) {
      var message = 'Is not a int ${currentToken?.literal}';
      _errors.add(message);
      return null;
    }

    integer.value = val;
    return integer;  
  }

  Expression? parseExpression(Precedence precedence) {
    assert(currentToken != null);
    var prefixFn = prefixFns[currentToken?.tokenType];
    if (prefixFn == null) {
      var message = 'no function to parse ${currentToken?.literal}';
      _errors.add(message);
      return null;
    }

    var leftExpression = prefixFn();
    assert(currentToken != null);
    while (!(peekToken?.tokenType == TokenType.SEMICOLON)) {

      var infixFn = infixFns[currentToken?.tokenType];
      if (infixFn == null) {
        return leftExpression;
      }

      advanceTokens();
      assert(leftExpression != null);
      leftExpression = infixFn(leftExpression!);
    }

    return leftExpression;
  }

  Identifier parseIdentifier() {
    return Identifier(currentToken?.literal, currentToken!);
  }

  bool expectedToken(TokenType type) {
    if (peekToken?.tokenType == type) {
      advanceTokens();
      return true;
    }

    expectedTokenError(type);
    return false;
  }

  void expectedTokenError(TokenType type) {
    assert(currentToken != null);
    var err = 'Syntax error expected ${type.toString()} but got ${currentToken?.tokenType.toString()}';
    _errors.add(err);
  }

  PrefixParseFns registerPrefixFns() {
    var prefixFns = {
      TokenType.FALSE: parseBoolean,
      TokenType.FUNCTION: parseFunction,
      TokenType.IDENT: parseIdentifier,
    };

    return prefixFns;
  }
}
