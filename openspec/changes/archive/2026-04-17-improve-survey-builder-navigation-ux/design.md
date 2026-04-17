## Context

The current `survey-builder` grows by adding more list and editor screens, but it still behaves like a collection of isolated routes. Administrators can enter prompt and persona catalogs from ad hoc actions, and some screens become dead ends without a stable path back to the home context. This is already causing usability problems and will become worse as access-point management and audit review are added.

The builder needs a coherent information architecture centered on tasks rather than data. Users come to accomplish specific work (create surveys, manage prompts, configure personas), not just browse collections. The new navigation must support natural workflows while maintaining context across deep interactions.

## Goals / Non-Goals

**Goals:**
- Create a task-based dashboard that prioritizes primary administrative actions over data summaries
- Implement persistent navigation that remains visible across all sections without forcing returns to dashboard
- Enable cross-workflow shortcuts between related tasks (survey creation ↔ prompt selection ↔ persona assignment)
- Use unified, adaptive components that minimize specialized widgets while maximizing reusability
- Integrate affective design patterns (ambient delight, emotional feedback) to enhance engagement without compromising performance
- Ensure mobile responsiveness with appropriate touch targets and interaction patterns

**Non-Goals:**
- Rebranding the builder visual language from scratch
- Creating separate navigation systems for desktop vs mobile (single adaptive system)
- Prioritizing data summaries over task-based actions
- Compromising performance for affective design elements
- Changing authentication or core survey functionality

## Component Architecture

### 1. Unified DsTaskButton
```dart
class DsTaskButton extends StatelessWidget {
  const DsTaskButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = DsTaskButtonSize.medium,
    this.emotion = DsEmotion.neutral,
    this.isLoading = false,
    this.progress = 0.0,
    this.showChevron = false,
  });

  // Size variants:
  // - large: Icon + Label + Description (dashboard)
  // - medium: Icon + Label (sidebar)
  // - small: Label only (mobile bottom nav)

  // Automatically handles:
  // - Appropriate padding and spacing
  // - Loading states with progress indicators
  // - Delight animations on interaction
  // - Disabled states with opacity
  // - Grouping semantics
}
```

### 2. DsAdminShell
```dart
class DsAdminShell extends StatelessWidget {
  const DsAdminShell({
    super.key,
    required this.navigation,
    required this.child,
    this.currentSection,
    this.userProfile,
    this.recentUpdates,
  });

  // Desktop layout:
  // ┌─────────────────────────────────────────┐
  // │ Sidebar │                                │
  // │         │                                │
  // │         │     Page Content               │
  // │         │     + Task Focus               │
  // │         │     + Breadcrumbs             │
  // │         │                                │
  // └─────────┴───────────────────────────────┘
  //
  // Mobile layout:
  // ┌─────────────────────────────────┐
  // │        Page Header              │
  // │  [Back] [Title] [Actions]       │
  // │                                 │
  // │        Content                  │
  // │         ↓                       │
  // │                                 │
  // │     Task Area                   │
  // │                                 │
  // ──────────────────────────────────
  // │ Nav | Nav | Nav | Nav | Profile │
  // └─────────────────────────────────┘

  // Features:
  // - Adaptive navigation (sidebar/desktop, bottom/mobile)
  // - Consistent page headers with breadcrumbs
  // - User profile integration
  // - Ambient delight for completed tasks
  // - Performance optimization with lazy loading
}
```

### 3. Task-Based Dashboard
```dart
class DsTaskDashboard extends StatelessWidget {
  const DsTaskDashboard({
    super.key,
    required this.user,
    required this.recentUpdates,
    this.onTaskSelected,
  });

  // Primary Actions (Large, Visual):
  // 🎯 Create New Survey
  // 📝 Edit Existing Survey  
  // 💡 Quick Prompts
  // 👥 Manage Personas
  // 🔗 Access Points

  // Secondary Actions (Compact):
  // Templates, Import/Export, Settings

  // Recent Activity (Footer):
  // • Survey "Diabetes Screening" updated 2h ago
  // • Prompt "Clinical Summary" created yesterday
  // • Persona "Cardiology Expert" shared
}
```

## Navigation Flow Patterns

### 1. Primary Workflow
```
Dashboard → Task Selection → Specific Action → Completion
    ↓            ↓              ↓            ↓
Always     Persistent      Context      Ambient
visible    navigation     preserved    celebration
```

### 2. Cross-Section Workflow
```
Create Survey → Need Prompt → 
Quick "Add Prompt" button → 
Prompt Creation → Auto-return to survey → 
Continue with selected prompt
```

### 3. Mobile Adaptation
```
Desktop: Sidebar + Large buttons + Full headers
Mobile: Bottom nav + FAB + Compact headers
Transition: Smooth reflow between breakpoints
```

## Affective Design Integration

### 1. Task Completion Feedback
```dart
DsTaskButton(
  icon: Icons.add_rounded,
  label: 'Create Survey',
  onTap: _createSurvey,
  emotion: DsEmotion.delight,
  // Gentle celebration animation on successful creation
)
```

### 2. Ambient Delight for Updates
```dart
DsAmbientDelight(
  duration: const Duration(milliseconds: 800),
  child: DsRecentUpdateCard(
    title: 'Survey updated successfully',
    time: 'Just now',
  ),
)
```

### 3. Progress Indication
```dart
DsTaskButton(
  isLoading: _saving,
  progress: _saveProgress,
  label: 'Publishing Survey...',
  // Shows animated progress without blocking
)
```

## Responsive Design Strategy

### Breakpoints
- **Desktop**: > 768px (sidebar navigation)
- **Tablet**: 768px - 1024px (adaptive sidebar)
- **Mobile**: < 768px (bottom navigation)

### Component Adaptation
```dart
// DsTaskButton automatically adapts:
if (MediaQuery.sizeOf(context).width > 768) {
  // Large: Icon + Label + Description
} else if (MediaQuery.sizeOf(context).width > 480) {
  // Medium: Icon + Label  
} else {
  // Small: Label only
}
```

## Performance Optimizations

### 1. Lazy Loading
```dart
class DsNavigationSidebar extends StatefulWidget {
  @override
  State<DsNavigationSidebar> createState() => _DsNavigationSidebarState();
  
  // Load navigation items on demand
  // Cache frequently accessed sections
}
```

### 2. Staggered Animations
```dart
// Animate elements sequentially, not all at once
class DsTaskDashboard extends StatefulWidget {
  @override
  State<DsTaskDashboard> createState() => _DsTaskDashboardState();
  
  // Animate primary tasks first, then secondary, then recent updates
}
```

### 3. Smart Caching
```dart
// Cache recent updates and user preferences
class NavigationService {
  final _recentUpdates = <RecentUpdate>[];
  final _userPreferences = <String, dynamic>{};
  
  // Update cache on interaction
  // Preload likely next navigation items
}
```

## Implementation Plan

### Phase 1: Component Foundation
1. Define DsTaskButton with all size variants
2. Create DsAdminShell wrapper
3. Implement basic adaptive layouts

### Phase 2: Task Dashboard
1. Replace survey list with task-focused dashboard
2. Add primary action buttons with clear intent
3. Implement recent activity feed

### Phase 3: Navigation System
1. Build persistent sidebar/bottom navigation
2. Add cross-workflow shortcuts
3. Ensure deep links work within shell

### Phase 4: Mobile & Polish
1. Optimize for mobile breakpoints
2. Add affective design elements
3. Performance tuning and testing

## Risk Mitigation

- **Performance Risk**: Use lazy loading and optional affective elements
- **Complexity Risk**: Keep component adaptation simple and well-documented
- **Mobile Risk**: Test extensively on actual devices with different screen sizes
- **User Adoption Risk**: Maintain familiar patterns while introducing improvements