import 'package:Magnet/ast/ast.dart';
import 'package:Magnet/object/object.dart';

final SingletonBool = Bool(true);
final SingletonFalse = Bool(false);
final SingletonNull = None;

Object evaluate(ASTNode node, Enviroment env) {
  switch (node.runtimeType) {

    case Program:
      return evaluateProgram(node as Program, env);

    case ExpressionStatement: {
      var expression = node as ExpressionStatement;
      assert(expression.expression != null);
      return evaluate(expression.expression!, env);
    }

    case ArrayExpression:
      return evaluateArray(node as ArrayExpression, env);

    default:
      return SingletonNull as Object;
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
