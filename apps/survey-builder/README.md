# Survey Builder

Flutter web application for creating, editing, and deleting surveys in the LAPAN platform.

## Development

```bash
flutter pub get
flutter run -d chrome --dart-define=FLAVOR="dockerVps" --dart-define=API_BASE_URL="http://localhost:8000/api/v1"
```

## Build (Web)

```bash
flutter build web --dart-define=FLAVOR="dockerVps" --dart-define=API_BASE_URL="/api/v1"
```
