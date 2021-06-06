import 'package:Magnet/ast/ast.dart';
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

    case ArrayExpression:
      return evaluateArray(node as ArrayExpression, env);

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

Object evaluateArray(ArrayExpression arr, Enviroment env) {
  var list = Array(<Object>[]);
  for (var val in arr.values) {
    list.values.add(evaluate(val, env));
  }

  return list;
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

