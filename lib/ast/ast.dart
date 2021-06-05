import 'package:Magnet/lexer/token.dart';

abstract class ASTNode {
  String tokenLitertal();
  String str();
}

class Statement extends ASTNode {
  Token token;

  Statement(this.token);

  @override
  String str() {
    // TODO: implement str
    throw UnimplementedError();
  }

  @override
  String tokenLitertal() {
    return token.literal;
  }
}

class Expression extends ASTNode {
  Token token;

  Expression(this.token);

  @override
  String str() {
    // TODO: implement str
    throw UnimplementedError();
  }

  @override
  String tokenLitertal() {
    return token.literal;
  }
}

class Program extends ASTNode {
  List<Statement> statements;

  Program(this.statements);

  @override
  String str() {
    var out = <String>[];
    for (var stament in statements) {
      out.add(stament.str());
    }

    return out.join('');
  }

  @override
  String tokenLitertal() {
    if (statements.isNotEmpty) {
      return statements[0].token.literal;
    }

    return '';
  }
}

class Identifier extends Expression {
  String? value;

  Identifier(this.value, Token token) : super(token);

  @override
  String str() {
    return value!;
  }
}

class LetStatement extends Statement {
  Identifier? name;
  Expression? value;

  LetStatement(this.name, this.value, Token token) : super(token);

  @override
  String str() {
    return '@${name?.str()} = ${value?.str()}';
  }
}

class ReturnStatement extends Statement {
  Expression? returnValue;

  ReturnStatement(this.returnValue, Token token) : super(token);

  @override
  String str() {
    return '$tokenLitertal() ${returnValue?.str()}';
  }
}

class ExpressionStatement extends Statement {
  Expression? expression;

  ExpressionStatement(this.expression, Token token) : super(token);

  @override
  String str() {
    return expression!.str();
  }
}

class Integer extends Expression {
  int value;

  Integer(this.value, Token token) : super(token);

  @override
  String str() {
    return '$value';
  }
}

class Prefix extends Expression {
  String operattor;
  Expression? rigth;

  Prefix(this.operattor, this.rigth, Token token) : super(token);

  @override
  String str() {
    return '($operattor ${rigth!.str()})';
  }
}

class Infix extends Expression {
  Expression rigth;
  String operattor;
  Expression left;

  Infix(this.rigth, this.operattor, this.left, Token token) : super(token);

  @override
  String str() {
    return '(${left.str()} $operattor ${rigth.str()})';
  }
}

class Boolean extends Expression {
  bool value;

  Boolean(this.value, Token token) : super(token);

  @override
  String str() {
    return tokenLitertal();
  }
}

class Block extends Statement {
  List<Statement> statements;

  Block(this.statements, Token token) : super(token);

  @override
  String str() {
    var out = <String>[];
    for (var statement in statements) {
      out.add(statement.str());
    }

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
    var paramList = <String>[];
    for (var param in parameters!) {
      paramList.add(param.str());
    }

    var params = paramList.join(' ');
    return '${tokenLitertal()}($params) ${body!.str()}';
  }
}

class Call extends Expression {
  Expression function;
  List<Expression> arguments;

  Call(this.function, this.arguments, Token token) : super(token);

  @override
  String str() {
    var args = <String>[];
    for (var argument in arguments) {
      args.add(argument.str());
    }

    return '${function.str()}(${args.join(', ')})';
  }
}

class StringLiteral extends Expression {
  String value;

  StringLiteral(this.value, Token token) : super(token);

  @override
  String str() {
    return value;
  }
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
  Expression condition;
  Block body;

  WhileLoop(this.condition, this.body, Token token) : super(token);

  @override
  String str() {
    return '${tokenLitertal()} (${condition.str()}) ${body.str()}';
  }
}

class Array extends Expression {
  List<Expression> values;

  Array(this.values, Token token) : super(token);

  @override
  String str() {
    var out = <String>[];
    for(var value in values) {
      out.add(value.str());
    } 

    return '[${out.join(', ')}]';
  }
}