
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

JSAny? _toJsAny(Object? value) {
  if (value == null) return null;
  if (value is String) return value.toJS;
  if (value is num) return value.toJS;
  if (value is bool) return value.toJS;
  return value.toString().toJS;
}

bool hasProperty(JSObject? o, Object? name) {
  if (o == null || name == null) return false;
  final key = _toJsAny(name);
  if (key == null) return false;
  return o.hasProperty(key).toDart;
}

T? getProperty<T extends JSAny?>(JSObject? o, Object? name) {
  if (o == null || name == null) return null;
  final key = _toJsAny(name);
  if (key == null) return null;
  return o.getProperty<T>(key);
}

JSObject? callConstructor(JSFunction? constr, List<Object?> arguments) {
  if (constr == null) return null;
  final jsArgs = arguments.map(_toJsAny).toList();
  return constr.callAsConstructorVarArgs<JSObject>(jsArgs);
}

JSAny? callMethod(JSObject? o, String method, List<Object?> args) {
  if (o == null) return null;
  final jsArgs = args.map(_toJsAny).toList();
  return o.callMethodVarArgs<JSAny?>(method.toJS, jsArgs);
}

void setProperty(JSObject? o, Object? name, Object? value) {
  if (o == null || name == null) return;
  final key = _toJsAny(name);
  if (key == null) return;
  o.setProperty(key, _toJsAny(value));
}
