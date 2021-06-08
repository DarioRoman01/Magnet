import 'package:Magnet/lexer/token.dart';

abstract class ASTNode {
  String tokenLitertal();
  String str();
}

class Statement extends ASTNode {
  Token token;

  Statement(this.token);

  @override
  String str() => throw UnimplementedError();

  @override
  String tokenLitertal() => token.literal;
}

class Expression extends ASTNode {
  Token token;

  Expression(this.token);

  @override
  String str() => throw UnimplementedError();

  @override
  String tokenLitertal() => token.literal;
}

class Program extends ASTNode {
  List<Statement> statements;

  Program(this.statements);

  @override
  String str() {
    var out = <String>[];
    statements.forEach((e) => out.add(e.str()));
    return out.join('');
  }

  @override
  String tokenLitertal() {
    return statements.isNotEmpty ? statements.first.token.literal : '';
  }
}

class Identifier extends Expression {
  String? value;

  Identifier(this.value, Token token) : super(token);

  @override
  String str() => value!;
}

class LetStatement extends Statement {
  Identifier? name;
  Expression? value;

  LetStatement(this.name, this.value, Token token) : super(token);

  @override
  String str() => '@${name?.str()} = ${value?.str()}';
}

class ReturnStatement extends Statement {
  Expression? returnValue;

  ReturnStatement(this.returnValue, Token token) : super(token);

  @override
  String str() => '$tokenLitertal() ${returnValue?.str()}';
}

class ExpressionStatement extends Statement {
  Expression? expression;

  ExpressionStatement(this.expression, Token token) : super(token);

  @override
  String str() => expression!.str();
}

class Integer extends Expression {
  int value;

  Integer(this.value, Token token) : super(token);

  @override
  String str() => '$value';
}

class Prefix extends Expression {
  String operattor;
  Expression? rigth;

  Prefix(this.operattor, this.rigth, Token token) : super(token);

  @override
  String str() => '($operattor ${rigth!.str()})';
}

class Infix extends Expression {
  Expression? rigth;
  String operattor;
  Expression? left;

  Infix(this.rigth, this.operattor, this.left, Token token) : super(token);

  @override
  String str() => '(${left!.str()} $operattor ${rigth!.str()})';
}

class Boolean extends Expression {
  bool value;

  Boolean(this.value, Token token) : super(token);

  @override
  String str() => tokenLitertal();
}

class Block extends Statement {
  List<Statement> statements;

  Block(this.statements, Token token) : super(token);

  @override
  String str() {
    var out = <String>[];
    statements.forEach((statement) => out.add(statement.str()));
    return out.join(' ');
  }
}

class IfExpression extends Expression {
  Expression? condition;
  Block? consequence;
  Block? alternative;

  IfExpression(this.condition, this.consequence, this.alternative, Token token)
      : super(token);

  @override
  String str() {
    var buff = StringBuffer();
    buff.write('if ${condition!.str()} ${consequence!.str()}');

    if (alternative != null) {
      buff.write('else ${consequence!.str()}');
    }

    return buff.toString();
  }
}

class FunctionExpression extends Expression {
  List<Identifier>? parameters;
  Block? body;

  FunctionExpression(this.parameters, this.body, Token token) : super(token);

  @override
  String str() {
    var params = <String>[];
    parameters!.forEach((param) => params.add(param.str()));
    return '${tokenLitertal()}(${params.join(', ')}) ${body!.str()}';
  }
}

class Call extends Expression {
  Expression function;
  List<Expression> arguments;

  Call(this.function, this.arguments, Token token) : super(token);

  @override
  String str() {
    var args = <String>[];
    arguments.forEach((arg) => args.add(arg.str()));
    return '${function.str()}(${args.join(', ')})';
  }
}

class StringLiteral extends Expression {
  String value;

  StringLiteral(this.value, Token token) : super(token);

  @override
  String str() => value;
}

class ForLoop extends Expression {
  Expression condition;
  Block body;

  ForLoop(this.condition, this.body, Token token) : super(token);

  @override
  String str() {
    return '${tokenLitertal()} (${condition.str()}) ${body.str()}';
  }
}

class WhileLoop extends Expression {
  Expression? condition;
  Block? body;

  WhileLoop(this.condition, this.body, Token token) : super(token);

  @override
  String str() {
    return '${tokenLitertal()} (${condition!.str()}) ${body!.str()}';
  }
}

class ArrayExpression extends Expression {
  List<Expression> values;

  ArrayExpression(this.values, Token token) : super(token);

  @override
  String str() {
    var out = <String>[];
    values.forEach((val) => out.add(val.str()));
    return '[${out.join(', ')}]';
  }
}