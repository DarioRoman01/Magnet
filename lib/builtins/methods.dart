import 'package:Magnet/builtins/builtins.dart';
import 'package:Magnet/evaluator/evaluator.dart';
import 'package:Magnet/object/object.dart';

final IndexError = Error('Index must be a number');

enum Methods {
  APPEND,
  POP,
  REMOVE,
  CONTAINS
}

Object append(List<Object> args) {
  if (args.length > 1 || args.isEmpty) {
    return wronNumberOfArgs(1, args.length);
  }

  if (args[0].runtimeType == Number) return Method(args[0], Methods.APPEND);
  return IndexError;
}

Object pop(List<Object> args) {
  if (args.isNotEmpty) {
    return wronNumberOfArgs(0, args.length);
  }

  return Method(SingletonNull, Methods.POP);
}

Object removeAt(List<Object> args) {
  if (args.isEmpty || args.length > 1) {
    return wronNumberOfArgs(1, args.length);
  }

  if (args[0].runtimeType == Number) return Method(args[0], Methods.REMOVE);
  return IndexError;
}

Object contains(List<Object> args) {
  if (args.isEmpty || args.length > 1) {
    return wronNumberOfArgs(1, args.length);
  }

  return Method(args[0], Methods.CONTAINS);
}