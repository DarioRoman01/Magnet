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
  TokenType.ASSING: Precedence.ANDOR,
  TokenType.MOD: Precedence.PRODUCT,
  TokenType.LPAREN: Precedence.CALL,
  TokenType.LBRACKET: Precedence.CALL,
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

  Parser(this.lexer) {
    _errors = <String>[];
    prefixFns = registerPrefixFns();
    infixFns = registerInfixFns();
    currentToken = null;
    peekToken = null;
    advanceTokens();
    advanceTokens();
  }

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
    if (peekToken?.tokenType == TokenType.LPAREN) {
      advanceTokens();
      return args;
    }

    advanceTokens();
    var expression = parseExpression(Precedence.LOWEST);
    if (expression != null) {
      args.add(expression);
    }

    while (peekToken?.tokenType == TokenType.COMMA) {
      advanceTokens();
      advanceTokens();
      expression = parseExpression(Precedence.LOWEST);
      if (expression != null) {
        args.add(expression);
      }
    }
    
    if (!expectedToken(TokenType.RPAREN)) {
      return null;
    }

    return args;
  }

  List<String> get errors =>  _errors;

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

  Expression? parseInfixExpression(Expression left) {
    assert(currentToken != null);
    var infix = Infix(null, currentToken!.literal, left, currentToken!);
    var precedence = currentPrecedence();
    advanceTokens();
    infix.rigth = parseExpression(precedence);
    return infix;
  }

  Expression? parseMethodExpression(Expression left) {
    assert(currentToken != null);
    var method = MethodExpression(currentToken!, left, null);
    advanceTokens();
    method.method = parseExpression(Precedence.LOWEST);
    return method;
  }

  Expression? parseFunction() {
    assert(currentToken != null);
    var func = FunctionExpression(null, null, currentToken!);
    if (!expectedToken(TokenType.LPAREN)) {
      return null;
    }

    func.parameters = parseFunctionParameters();
    if (!expectedToken(TokenType.ARROW)) {
      return null;
    }

    if (!expectedToken(TokenType.LBRACE)) {
      return null;
    }

    func.body = parseBlock();
    return func;
  }

  List<Identifier> parseFunctionParameters() {
    assert(peekToken != null);
    var params = <Identifier>[];
    if (peekToken?.tokenType == TokenType.RPAREN) {
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

    if (!expectedToken(TokenType.RPAREN)) {
      return <Identifier>[];
    }

    return params;
  }

  Expression? parseCallList(Expression listIdent) {
    assert(currentToken != null);
    var callList = CallList(listIdent, null, currentToken!);
    advanceTokens();
    callList.index = parseExpression(Precedence.LOWEST);
    if (!expectedToken(TokenType.RBRACKET)) {
      return null;
    }

    return callList;
  }

  Expression? parseReassigment(Expression identifier) {
    assert(currentToken != null);
    var reassigment = Reassigment(currentToken!, identifier, null);
    advanceTokens();
    reassigment.newVal = parseExpression(Precedence.LOWEST);
    return reassigment;
  }

  Statement? parseLetStatement() {
    assert(currentToken != null);
    var statement = LetStatement(null, null, currentToken!);
    if (!expectedToken(TokenType.IDENT)) {
      print(currentToken?.printToken());
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
      !(currentToken?.tokenType == TokenType.RBRACE) && 
      !(currentToken?.tokenType == TokenType.EOF)) {
        var statement = parseStatement();
        if (statement != null) {
          block.statements.add(statement);
        }

        advanceTokens();
    }

    return block;
  }
  
  Expression? parseArray() {
    assert(currentToken != null);
    var arr = ArrayExpression(<Expression>[], currentToken!);
    arr.values = parseArrayValues()!;
    return arr;
  }

  List<Expression>? parseArrayValues() {
    assert(currentToken != null);
    var values = <Expression>[];
    if (peekToken?.tokenType == TokenType.RBRACKET) {
      advanceTokens();
      return values;
    }

    advanceTokens();
    var expression = parseExpression(Precedence.LOWEST);
    if (expression != null) {
      values.add(expression);
    }

    while(peekToken?.tokenType == TokenType.COMMA) {
      advanceTokens();
      advanceTokens();

      expression = parseExpression(Precedence.LOWEST);
      if (expression != null) {
        values.add(expression);
      }
    }

    if (!expectedToken(TokenType.RBRACKET)) {
      return null;
    }

    return values;
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

  Expression? parseWhile() {
    assert(currentToken != null);
    var whileExp = WhileLoop(null, null, currentToken!);
    if (!expectedToken(TokenType.LPAREN)) {
      return null;
    }

    advanceTokens();
    whileExp.condition = parseExpression(Precedence.LOWEST);
    if (!expectedToken(TokenType.RPAREN)) {
      return null;
    }

    if (!expectedToken(TokenType.LBRACE)) {
      return null;
    }

    whileExp.body = parseBlock();
    return whileExp;
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
    while (!(peekToken?.tokenType == TokenType.SEMICOLON) && precedence.index < peekPrecedence().index) {
      var infixFn = infixFns[peekToken?.tokenType];
      if (infixFn == null) {
        return leftExpression;
      }

      advanceTokens();
      assert(leftExpression != null);
      leftExpression = infixFn(leftExpression!);
    }

    return leftExpression;
  }

  Precedence peekPrecedence() {
    assert(currentToken != null);
    var precedence = Precedences[peekToken?.tokenType];
    if (precedence == null) {
      return Precedence.LOWEST;
    }

    return precedence;
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

  InfixParseFns registerInfixFns() {
    var infixFns = {
      TokenType.PLUS: parseInfixExpression,
      TokenType.MINUS: parseInfixExpression,
      TokenType.DIVISION: parseInfixExpression,
      TokenType.TIMES: parseInfixExpression,
      TokenType.EQ: parseInfixExpression,
      TokenType.NOT_EQ: parseInfixExpression,
      TokenType.GTOREQ: parseInfixExpression,
      TokenType.LTOREQ: parseInfixExpression,
      TokenType.LT: parseInfixExpression,
      TokenType.GT: parseInfixExpression,
      TokenType.LPAREN: parseCall,
      TokenType.BAR: parseCall,
      TokenType.DCOLON: parseMethodExpression,
      TokenType.ASSING: parseReassigment,
      TokenType.LBRACKET: parseCallList,
      TokenType.MOD: parseInfixExpression,
      TokenType.AND: parseInfixExpression,
      TokenType.OR: parseInfixExpression,
    };

    return infixFns;
  }

  PrefixParseFns registerPrefixFns() {
    var prefixFns = {
      TokenType.FALSE: parseBoolean,
      TokenType.FUNCTION: parseFunction,
      TokenType.WHILE: parseWhile,
      TokenType.IDENT: parseIdentifier,
      TokenType.IF: parseIf,
      TokenType.INT: parseInteger,
      TokenType.LPAREN: parseGroupExpression,
      TokenType.MINUS: parsePrefixExpression,
      TokenType.NOT: parsePrefixExpression,
      TokenType.TRUE: parseBoolean,
      TokenType.STRING: parseStringLiteral,
      TokenType.LBRACKET: parseArray,
    };

    return prefixFns;
  }
}
