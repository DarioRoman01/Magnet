import 'package:Magnet/ast/ast.dart';
import 'package:Magnet/builtins/builtins.dart';
import 'package:Magnet/object/object.dart';

final SingletonTrue = Bool(true);
final SingletonFalse = Bool(false);
final SingletonNull = None();

Object evaluate(ASTNode node, Enviroment env) {
  switch (node.runtimeType) {
    case Program:
      return evaluateProgram(node as Program, env);

    case ExpressionStatement: {
      var expression = node as ExpressionStatement;
      assert(expression.expression != null);
      return evaluate(expression.expression!, env);
    }

    case Integer:
      var number = node as Integer;
      return Number(number.value);

    case Boolean:
      var val = node as Boolean;
      return toBooleanObject(val.value);

    case Prefix: {
      var prefix = node as Prefix;
      assert(prefix.rigth != null);
      var rigth = evaluate(prefix.rigth!, env);
      return evaluatePrefixExpression(prefix.operattor, rigth);
    }

    case Infix: {
      var val = node as Infix;
      assert(val.left != null && val.rigth != null);
      var left = evaluate(val.left!, env);
      var rigth = evaluate(val.rigth!, env);
      return evaluateInfixExpression(val.operattor, left, rigth);
    }

    case Block:
      return evaluateBLockStaments(node as Block, env);

    case WhileLoop:
      return evaluateWhileloop(node as WhileLoop, env);

    case IfExpression:
      return evaluateIfExpression(node as IfExpression, env);

    case ReturnStatement: {
      var statement = node as ReturnStatement;
      assert(statement.returnValue != null);
      var value = evaluate(statement.returnValue!, env);
      return Return(value);
    }

    case LetStatement: {
      var statement = node as LetStatement;
      assert(statement.value != null && statement.name != null);
      var value = evaluate(statement.value!, env);
      env.setItem(statement.name!.value!, value);
      return SingletonNull;
    }

    case Identifier:
      return evaluateIdentifier(node as Identifier, env);

    case FunctionExpression:
      var fn = node as FunctionExpression;
      assert(fn.body != null);
      return Def(fn.parameters!, fn.body!, env);

    case ArrayExpression:
      return evaluateArray(node as ArrayExpression, env);
    
    case Call: {
      var call = node as Call;
      var func = evaluate(call.function, env);
      var args = evaluateExpression(call.arguments, env);
      return applyFunction(func, args);
    }
    
    case StringLiteral:
      return Str((node as StringLiteral).value);

    default:
      return SingletonNull;
  }
}

Object evaluateProgram(Program program, Enviroment env) {
  Object? result;
  for (var statement in program.statements) {
    result = evaluate(statement, env);

    if (result.runtimeType == Return) {
      var returnObj = result as Return;
      return returnObj.value;
    } else if (result.runtimeType == Error) {
      return result as Error;
    }
  }

  return result!;
}

Object applyFunction(Object fn, List<Object> args) {
  if (fn.runtimeType == Def) {
    var func = fn as Def;
    var extendEnv = extendFunctionEnviroment(func, args);
    var evaluated = evaluate(func.body, extendEnv);
    return unwrapReturnValue(evaluated);
  }

  else if(fn.runtimeType == BuiltIn) {
    return (fn as BuiltIn).fn(args);
  }

  return notAFunction(fn.type().toString());
}

Enviroment extendFunctionEnviroment(Def fn, List<Object> args) {
  var env = Enviroment(fn.env);
   fn.parameters.forEach((param) => { 
     env.setItem(param.value!, args[fn.parameters.indexOf(param)])
   });

   return env;
}

Object unwrapReturnValue(Object obj) {
  return obj.runtimeType == Return ? (obj as Return).value : obj; 
}

Object evaluateArray(ArrayExpression arr, Enviroment env) {
  var list = Array(<Object>[]);
  arr.values.forEach((val) => list.values.add(evaluate(val, env)));
  return list;
}

Object evaluateIdentifier(Identifier node, Enviroment env) {
  var value = env.getItem(node.value!);
  if (value == null) {
    var builtin = Builtins[node.value];
    return builtin ?? unkownIdentifier(node.value!);
  }

  return value;
}

Object evaluateBLockStaments(Block block, Enviroment env) {
  Object? result;
  for (var statement in block.statements) {
    result = evaluate(statement, env);
    if (result.type() == ObjectType.RETURNTYPE || result.type() == ObjectType.ERROR) {
      return result;
    }
  }

  return result!;
}

List<Object> evaluateExpression(List<Expression> expressions, Enviroment env) {
  var result = <Object>[];
  for (final expression in expressions) {
    var evaluated = evaluate(expression, env);
    result.add(evaluated);
  }

  return result;
}

Object evaluateWhileloop(WhileLoop whileLoop, Enviroment env) {
  assert(whileLoop.condition != null);
  var condition = evaluate(whileLoop.condition!, env);
  
  if(!isTruthy(condition)) {
    return SingletonNull;
  }

  evaluate(whileLoop.body!, env);
  return evaluate(whileLoop, env);

}

bool isTruthy(Object obj) {
  if (obj == SingletonNull) {
    return false;
  }
  else if(obj == SingletonTrue) {
    return true;
  }
  else if(obj == SingletonFalse) {
    return false;
  }

  return true;
}

Object toBooleanObject(bool val) => val ? SingletonTrue : SingletonFalse;

Object evaluateBangOperatorExpression(Object rigth) {
  if (rigth == SingletonTrue) {
    return SingletonFalse;
  } else if (rigth == SingletonFalse) {
    return SingletonTrue;
  } else if (rigth == SingletonNull) {
    return SingletonTrue;
  }

  return SingletonFalse;
}

Object evaluateMinusOperatorExpression(Object rigth) {
  try {
    var node = rigth as Number;
    node.value = -node.value;
    return node;
  } catch (e) {
    return Error('unkown operator: -${rigth.type().toString()}');
  }
}

Object evaluatePrefixExpression(String operat, Object rigth) {
  switch (operat) {
    case '!':
      return evaluateBangOperatorExpression(rigth);

    case '-':
      return evaluateMinusOperatorExpression(rigth);

    default:
      return Error('unkown operator: $operat ${rigth.type().toString()}');
  }
}

Object evaluateIfExpression(IfExpression ifExp, Enviroment env) {
  assert(ifExp.condition != null);
  var condition = evaluate(ifExp.condition!, env);

  if (isTruthy(condition)) {
    assert(ifExp.consequence != null);
    return evaluate(ifExp.consequence!, env);
  } 
  else if (ifExp.alternative != null) {
    return evaluate(ifExp.alternative!, env);
  }

  return SingletonNull;
}

Object evaluateInfixExpression(String operate, Object left, Object rigth) {
  if(left.type() == ObjectType.INTEGERS && rigth.type() == ObjectType.INTEGERS) {
    return evaluateIntInfix(left, operate, rigth);
  }

  else if(left.type() == ObjectType.STRINGTYPE && rigth.type() == ObjectType.STRINGTYPE) {
    return evaluateStrInfix(left, operate, rigth);
  }

  else if(left.type() == ObjectType.BOOLEAN && rigth.type() == ObjectType.BOOLEAN) {
    return evaluateBoolInfix(left, operate, rigth);
  }

  else if(operate == '==') {
    return toBooleanObject(left == rigth);
  }

  else if(operate == '!=') {
    return toBooleanObject(left !=  rigth);
  }
  
  else if(left.type() != rigth.type()) {
    return typeMismatchError(left.type().toString(), operate, rigth.type().toString());
  } 
  
  else {
    return unkownInfixExpression(left.type().toString(), operate, rigth.type().toString());
  }
}

Object evaluateIntInfix(Object left, String operate, Object rigth) {
  var leftVal = (left as Number).value;
  var rigthVal = (rigth as Number).value;

  switch (operate) {
    case '+':
      return Number(leftVal + rigthVal);
    case '-':
      return Number(leftVal - rigthVal);
    case '*':
      return Number(leftVal * rigthVal);
    case '/':
      return Number(leftVal ~/ rigthVal);
    case '%':
      return Number(leftVal % rigthVal);
    case '>':
      return toBooleanObject(leftVal > rigthVal);
    case '<':
      return toBooleanObject(leftVal < rigthVal);
    case '==':
      return toBooleanObject(leftVal == rigthVal);
    case '!=':
      return toBooleanObject(leftVal != rigthVal);
    case '>=':
      return toBooleanObject(leftVal >= rigthVal);
    case '<=':
      return toBooleanObject(leftVal <= rigthVal);
    default:
      return unkownInfixExpression(left.type().toString(), operate, rigth.type().toString());
  }
}


Object evaluateStrInfix(Object left, String operate, Object rigth) {
  var leftVal = (left as Str).value;
  var rigthVal = (rigth as Str).value;

  switch (operate) {
    case '+':
		  return Str(leftVal + rigthVal);

    case '==':
      return toBooleanObject(leftVal == rigthVal);

    case '!=':
      return toBooleanObject(leftVal != rigthVal);

    default:
      return unkownInfixExpression(left.type().toString(), operate, rigth.type().toString());
  }
}

Object evaluateBoolInfix(Object left, String operate, Object rigth) {
  var leftVal = (left as Bool).value;
  var rigthVal = (rigth as Bool).value;

  switch (operate) {
    case '||':
		  return toBooleanObject(leftVal || rigthVal);

	  case '&&':
		  return toBooleanObject(leftVal && rigthVal);

	  case '==':
		  return toBooleanObject(leftVal == rigthVal);

	  case '!=':
		  return toBooleanObject(leftVal != rigthVal);

    default:
      return unkownInfixExpression(left.type().toString(), operate, rigth.type().toString());
  }

}

Error typeMismatchError(String left, operate, rigth) {
  return Error('type mismatch error: $left $operate $rigth');
}

Error unkownInfixExpression(String left, operate, rigth) {
  return Error('unkown operator: $left $operate $rigth');
}

Error notAFunction(String ident) {
  return Error('Not a function: $ident');
}

Error unkownIdentifier(String ident) {
  return Error('unkown identifier: $ident');
}
