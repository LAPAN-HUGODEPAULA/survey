import 'dart:js_interop';

bool hasProperty(JSObject? _, Object? _) => false;

T? getProperty<T extends JSAny?>(JSObject? _, Object? _) => null;

JSObject? callConstructor(JSFunction? _, List<Object?> _) =>
    throw UnsupportedError('JS interop is not available.');

JSAny? callMethod(JSObject? _, String _, List<Object?> _) =>
    throw UnsupportedError('JS interop is not available.');

void setProperty(JSObject? _, Object? _, Object? _) {
  throw UnsupportedError('JS interop is not available.');
}
