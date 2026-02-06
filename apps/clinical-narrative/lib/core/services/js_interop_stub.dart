library;

bool hasProperty(Object? o, Object? name) => false;

dynamic getProperty(Object? o, Object? name) => null;

dynamic callConstructor(Function constr, List<dynamic> arguments) =>
    throw UnsupportedError('JS interop is not available.');

dynamic callMethod(Object? o, String method, List<dynamic> args) =>
    throw UnsupportedError('JS interop is not available.');

void setProperty(Object? o, Object? name, Object? value) {}

T allowInterop<T extends Function>(T f) => f;
