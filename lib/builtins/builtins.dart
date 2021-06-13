import 'dart:io';
import 'package:Magnet/builtins/methods.dart';
import 'package:Magnet/evaluator/evaluator.dart';
import 'package:Magnet/object/object.dart';

Object length(List<Object> args) {
  if (args.length > 1 || args.isEmpty) {
    return wronNumberOfArgs(1, args.length);
  }

  switch (args[0].runtimeType) {
    case Str: return Number((args[0] as Str).value.length);

    case Array: return Number((args[0] as Array).values.length);

    case HashMap: return Number((args[0] as HashMap).store.length);

    default:
      return unsoportedArgumentType(args[0].type().toString());
  }
}


Object show(List<Object> args) {
  var buff = StringBuffer();

  for (final arg in args) {
    switch (arg.runtimeType) {
      case Str:
        buff.write(arg.inspect());
        break;

      case Number:
        buff.write(arg.inspect());
        break;

      case Array:
        buff.write(arg.inspect());
        break;

      case Bool:
        buff.write(arg.inspect());
        break;

      case HashMap:
        buff.write(arg.inspect());
        break;
      
      default:
        return unsoportedArgumentType(arg.type().toString());
    }
  }

  print(buff.toString());
  return SingletonNull;
}

Object input(List<Object> args) {
  if (args.length > 1) {
    return wronNumberOfArgs(1, args.length);
  }

  if (args.isEmpty) {
    var str = stdin.readLineSync()!;
    return Str(str);
  }

  if (args[0].runtimeType == Str) {
    stdout.write(args[0].inspect());
    var str = stdin.readLineSync()!;
    return Str(str);
  }

  return unsoportedArgumentType(args[0].type().toString());
}

Object castInt(List<Object> args) {
  if (args.isEmpty || args.length > 1) {
    return wronNumberOfArgs(1, args.length);
  }

  if (args[0].runtimeType == Str) {
    return toInt((args[0] as Str).value);
  }

  return unsoportedArgumentType(args[0].type().toString());
}

Object castString(List<Object> args) {
  if (args.isEmpty || args.length > 1) {
    return wronNumberOfArgs(1, args.length);
  }

  if (args[0].runtimeType == Number) {
    final number = args[0] as Number;
    return Str(number.value.toString());
  }

  return unsoportedArgumentType(args[0].type().toString());
}

Object toInt(String value) {
  var number = int.tryParse(value);
  if (number == null) {
    return Error('Unable to parse int: $value');
  }

  return Number(number);
}

Object range(List<Object> args) {
  if (args.isEmpty || args.length > 2) {
    return wronNumberOfArgs(2, args.length);
  }

  try {
    var array = Array(<Object>[]);
    if (args.length == 1) {
      var val = args[0] as Number;
      for(var i = 0; i < val.value; i++) {
        array.values.add(Number(i));
      }

      return array;
    }
    else {
      var init = args[0] as Number;
      var fin = args[1] as Number;
      if (init.value == fin.value || fin.value < init.value) {
        return Error('Initial value and cannot be grater or equal to the end');
      }

      for(var i = init.value; i < fin.value; i++) {
        array.values.add(Number(i));
      }

      return array;
    }
  } 

  catch(e) {
    return Error('index must be integers');
  }
}

Object objType(List<Object> args) {
  if (args.isEmpty || args.length > 1) {
    return wronNumberOfArgs(1, args.length);
  }

  return Str(args[0].type().toString());
}

Error wronNumberOfArgs(int expected, found) => Error('Expected $expected args but got $found');

Error unsoportedArgumentType(String type) => Error('Unsoported Argument type: $type');

final Builtins = {
  'len': BuiltIn(length),
  'int': BuiltIn(castInt),
  'string': BuiltIn(castString),
  'input': BuiltIn(input),
  'show': BuiltIn(show),
  'append': BuiltIn(append),
  'pop': BuiltIn(pop),
  'removeAt': BuiltIn(removeAt),
  'contains': BuiltIn(contains),
  'range': BuiltIn(range),
};
