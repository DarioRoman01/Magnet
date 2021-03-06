import 'dart:convert';

import 'package:Magnet/ast/ast.dart';
import 'package:Magnet/builtins/methods.dart';

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
  METHOD,
  MAP,
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
    var args = parameters.map((p) => p.str());
    return '(${args.join(", ")}) => {${body.str()}}';
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
  String inspect() => '[${values.map((v) => v.inspect()).join(", ")}]';

  @override
  ObjectType type() => ObjectType.LIST;
}

class Method extends Object {
  Object value;
  Methods method;

  Method(this.value, this.method);

  @override
  String inspect() => '${method.toString()}(${value.inspect()})';

  @override
  ObjectType type() => ObjectType.METHOD;
}

class Iterator extends Object {
  Object current;
  List<Object> values;

  Iterator(this.current, this.values);

  Object? next() {
    if (values.isEmpty) return null;
    var val = current;
    values.removeAt(0);
    if (values.isNotEmpty) current = values[0];
    return val;
  }

  @override
  String inspect() => '[${values.map((e) => e.inspect()).join(', ')}]';

  @override
  ObjectType type() => ObjectType.ITER;
}

class HashMap extends Object {
  Map<Object, Object> store;

  HashMap(this.store);

  @override
  String inspect() {
    final str = store.map((k, v) => MapEntry(k.inspect(), v.inspect()));
    final out = JsonEncoder.withIndent(' ').convert(str);
    return out;
  }

  @override
  ObjectType type() => ObjectType.MAP;    
}