
import 'dart:js_interop';

bool hasProperty(JSObject? o, Object? name) => false;

T? getProperty<T extends JSAny?>(JSObject? o, Object? name) => null;

JSObject? callConstructor(JSFunction? constr, List<Object?> arguments) =>
    throw UnsupportedError('JS interop is not available.');

JSAny? callMethod(JSObject? o, String method, List<Object?> args) =>
    throw UnsupportedError('JS interop is not available.');

void setProperty(JSObject? o, Object? name, Object? value) {}
