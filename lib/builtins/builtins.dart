import 'package:Magnet/object/object.dart';

Object length(List<Object> args) {
  if (args.length > 1 || args.isEmpty) {
    return wronNumberOfArgs(1, args.length);
  }

  switch (args[0].runtimeType) {
    case Str:
      return Number((args[0] as Str).value.length);

    case Array:
      return Number((args[0] as Array).values.length);

    default:
      return unsoportedArgumentType(args[0].type().toString());
  }
}


Error wronNumberOfArgs(int expected, found) {
  return Error('Expected $expected args but got $found');
}

Error unsoportedArgumentType(String type) {
  return Error('Unsoported Argument type: $type');
}

final Builtins = {
  'len': BuiltIn(length),
};
