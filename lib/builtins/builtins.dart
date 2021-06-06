import 'package:Magnet/object/object.dart';
// func Longitud(args ...Object) Object {
// 	if len(args) != 1 {
// 		return &Error{Message: wrongNumberofArgs(len(args), 1)}
// 	}

// 	switch arg := args[0].(type) {

// 	case *String:
// 		return &Number{Value: utf8.RuneCountInString(arg.Value)}

// 	case *List:
// 		return &Number{Value: len(arg.Values)}

// 	default:
// 		return &Error{Message: unsoportedArgumentType("longitud", types[args[0].Type()])}

// 	}
// }

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