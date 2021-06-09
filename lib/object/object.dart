import 'package:Magnet/ast/ast.dart';

enum ObjectType {
  BOOLEAN,
  BUILTIN,
  DEF,
  ERROR,
  INTEGERS,
  ITER,
  NULL,
  RETURNTYPE,
  STRINGTYPE,
  LIST,
}

abstract class Object {
  ObjectType type();
  String inspect();
}

class Number extends Object {
  int value;

  Number(this.value);

  @override
  ObjectType type() => ObjectType.INTEGERS;

  @override
  String inspect() => '$value';
}

class Bool extends Object {
  bool value;

  Bool(this.value);

  @override
  String inspect() => '$value';

  @override
  ObjectType type() => ObjectType.BOOLEAN;
}

class None extends Object {
  @override
  String inspect() => 'none';

  @override
  ObjectType type() => ObjectType.NULL;
}

class Return extends Object {
  Object value;

  Return(this.value);

  @override
  String inspect() => value.inspect();

  @override
  ObjectType type() => ObjectType.RETURNTYPE;
}

class Error extends Object {
  String message;

  Error(this.message);

  @override
  String inspect() => 'Error: $message';

  @override
  ObjectType type() => ObjectType.ERROR;
}

class Def extends Object {
  List<Identifier> parameters;
  Block body;
  Enviroment env;

  Def(this.parameters, this.body, this.env);

  @override
  String inspect() {
    var args = <String>[];
    parameters.forEach((param) => args.add(param.str()));
    return 'def|${args.join(", ")}| {\n ${body.str()} \n}';
  }

  @override
  ObjectType type() => ObjectType.DEF;
}

class Str extends Object {
  String value;

  Str(this.value);

  @override
  String inspect() => value;

  @override
  ObjectType type() => ObjectType.STRINGTYPE;
}

typedef BuiltinFn = Object Function(List<Object> args);

class BuiltIn extends Object {
  BuiltinFn fn;

  BuiltIn(this.fn);

  @override
  String inspect() => 'builtin function';

  @override
  ObjectType type() => ObjectType.BUILTIN;
}

class Enviroment {
  late Map<String, Object> store;
  Enviroment? outer;

  Enviroment(this.outer) {
    store = <String, Object>{};
  }

  Object? getItem(String key) {
    var val = store[key];
    if (val == null) {
      return outer != null ? outer!.getItem(key) : null;
    }
    return val;
  }

  void setItem(String key, Object val) => store[key] = val;

  void delItem(String key) => store.remove(key);
}

class Array extends Object {
  List<Object> values;

  Array(this.values);

  @override
  String inspect() {
    var buff = <String>[];
    values.forEach((val) => buff.add(val.inspect()));
    return '[${buff.join(", ")}]';
  }

  @override
  ObjectType type() => ObjectType.LIST;
}
