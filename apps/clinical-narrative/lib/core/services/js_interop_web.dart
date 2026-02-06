library;

import 'package:universal_html/js.dart' as js;

js.JsObject? _asJsObject(Object? value) {
  if (value == null) return null;
  if (value is js.JsObject) return value;
  return js.JsObject.fromBrowserObject(value);
}

bool hasProperty(Object? o, Object? name) {
  final obj = _asJsObject(o);
  if (obj == null || name == null) return false;
  return obj.hasProperty(name);
}

Object? getProperty(Object? o, Object? name) {
  final obj = _asJsObject(o);
  if (obj == null || name == null) return null;
  return obj[name];
}

dynamic callConstructor(Object? constr, List<dynamic> arguments) {
  if (constr is js.JsFunction) {
    return js.JsObject(constr, arguments);
  }
  return null;
}

dynamic callMethod(Object? o, String method, List<dynamic> args) {
  final obj = _asJsObject(o);
  if (obj == null) return null;
  return obj.callMethod(method, args);
}

void setProperty(Object? o, Object? name, Object? value) {
  final obj = _asJsObject(o);
  if (obj == null || name == null) return;
  obj[name] = value;
}

T allowInterop<T extends Function>(T f) => f;
