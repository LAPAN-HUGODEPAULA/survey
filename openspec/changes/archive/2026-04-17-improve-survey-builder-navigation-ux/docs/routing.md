# Survey Builder Route Migration

## Route Mapping Strategy

The survey builder implements a route mapping strategy to preserve existing functionality while transitioning to the new administrative shell architecture.

## Legacy Route to New Route Mapping

| Legacy Route | New Route | Action |
|--------------|-----------|--------|
| `/survey-prompt-list` | `/prompts/` | Redirect with shell preservation |
| `/persona-skill-list` | `/personas/` | Redirect with shell preservation |
| `/survey-list` | `/surveys/` | Direct integration |
| `/survey-form` | `/surveys/create` | Direct integration |
| `/survey/:id/edit` | `/surveys/:id` | Direct integration |

## Route Adaptation Implementation

### 1. Legacy Route Detection
Routes are detected at the application entry point and wrapped with the admin shell:

```dart
// Main entry point adaptation
void main() {
  runApp(
    MaterialApp(
      onGenerateRoute: (settings) {
        // Check for legacy routes
        final legacyRoute = _mapLegacyRoute(settings.name);
        if (legacyRoute != null) {
          return MaterialPageRoute(
            builder: (context) => DsAdminShell(
              navigation: _getNavigationItems(),
              currentSection: _extractSectionFromRoute(legacyRoute),
              child: _buildLegacyRouteContent(legacyRoute),
            ),
            settings: RouteSettings(
              name: legacyRoute,
              arguments: settings.arguments,
            ),
          );
        }
        
        // Handle new routes
        return _handleNewRoute(settings);
      },
    ),
  );
}
```

### 2. Deep Link Preservation
Deep links maintain their functionality while being wrapped in the admin shell:

```dart
// Example: Survey editor deep link
Route _buildSurveyEditorRoute(RouteSettings settings) {
  final surveyId = settings.arguments as String;
  return MaterialPageRoute(
    builder: (context) => DsAdminShell(
      navigation: _getNavigationItems(),
      currentSection: 'surveys',
      child: SurveyFormPage(
        surveyId: surveyId,
        isInAdminShell: true,
      ),
    ),
  );
}
```

### 3. Route Guards
Navigation guards ensure consistent shell usage:

```dart
// Shell navigation wrapper
void _navigateToSection(BuildContext context, String section) {
  // Prevent shell nesting
  if (_isAlreadyInAdminShell(context)) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  
  Navigator.of(context).pushNamed('/$section');
}
```

## Browser Navigation Compatibility

### Back/Forward Navigation
- Routes are managed in a way that preserves browser history
- Shell navigation doesn't break back/forward functionality
- State is maintained across navigation changes

### Bookmarking and Sharing
- Legacy URLs continue to work
- New URLs provide direct access to specific sections
- Deep links to survey editors remain functional

## Error Handling for Unknown Routes

```dart
// Fallback for unknown routes
Route _handleUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute(
    builder: (context) => DsAdminShell(
      navigation: _getNavigationItems(),
      currentSection: 'dashboard',
      child: ErrorPage(
        message: 'Página não encontrada: ${settings.name}',
      ),
    ),
  );
}
```

## Testing Strategy

### Test Cases
1. **Legacy Route Access**: Verify legacy URLs redirect to new routes with shell
2. **Deep Link Functionality**: Ensure direct access to editors works
3. **Navigation History**: Test back/forward navigation within shell
4. **State Preservation**: Verify form state is maintained during navigation

### Automation Tests
```dart
// Test example for legacy route adaptation
testWidgets('Legacy route wraps in admin shell', (tester) async {
  await tester.pumpAndSettle();
  
  // Navigate to legacy route
  await tester.binding.defaultBinaryMessenger
      .handlePlatformMessage('route', 'survey-prompt-list', null);
  
  // Verify shell is present
  expect(find.byType(DsAdminShell), findsOneWidget);
  
  // Verify content is correct
  expect(find.text('Prompts'), findsOneWidget);
});
```

## Migration Considerations

### Performance Impact
- Route mapping adds minimal overhead
- Shell wrapping is lazy-loaded
- Deep links maintain their original performance characteristics

### User Experience
- Legacy URLs continue to work transparently
- No disruption to existing workflows
- Gradual migration path for power users