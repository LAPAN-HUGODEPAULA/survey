## Why

The `survey-builder` has serious navigation problems for administrative work, including dead-end flows such as the skills screen with no clear path back to the main administration surface. As the builder grows to manage prompts, personas, and access points, these usability gaps will directly slow down configuration work and increase operator error. The current fragmented navigation forces users to return to the survey list as a de facto home, disrupting natural workflows. Administrators need task-based entry points rather than data summaries to accomplish their work efficiently.

## What Changes

### New Navigation Architecture
- **Task-Based Dashboard**: Replace data-focused summaries with primary action buttons for core administrative tasks (Create Survey, Edit Existing, Quick Prompts, Manage Personas, etc.)
- **Persistent Navigation Context**: Implement hybrid sidebar/bottom navigation that remains visible across all sections without forcing returns to dashboard
- **Cross-Workflow Shortcuts**: Direct links between related tasks (survey ↔ prompt ↔ persona flows) to maintain workflow momentum
- **Unified Component Strategy**: Minimize specialized components by extending existing DS widgets with adaptive layouts for different contexts
- **Affective Design Integration**: Incorporate ambient delight and emotional design patterns to enhance user engagement without compromising performance
- **Mobile-First Responsive Design**: Adaptive layout that transitions from sidebar navigation on desktop to bottom navigation on mobile with appropriate touch targets

### Navigation Flow Improvements
- **Natural Workflows**: Users can complete related tasks (survey creation → prompt selection → persona assignment) without losing context or returning to dashboard
- **Progressive Disclosure**: Show primary actions immediately, with secondary options accessible via persistent navigation
- **Mobile Adaptation**: Smooth transition between desktop sidebar and bottom navigation with optimized touch targets
- **Recent Activity Feed**: Compact history of last updates at bottom of dashboard for quick reference (no maximum number of clicks for power users)

### Component Consolidation
- **Single Task Button Component**: Replace multiple specialized buttons with one DsTaskButton that adapts to different contexts (large/dashboard, medium/sidebar, small/mobile)
- **Unified Admin Shell**: Single DsAdminShell wrapper that provides consistent navigation across all admin pages with adaptive layouts
- **Affective Design Integration**: Leverage existing DS emotional design components (ambient delight, progress indicators) to enhance engagement

## Capabilities

### New Capabilities
- `builder-task-dashboard`: Task-focused navigation with primary action buttons and progressive disclosure (no data summaries)
- `persistent-admin-navigation`: Hybrid navigation that maintains context across sections without forcing dashboard returns
- `cross-workflow-shortcuts`: Direct links between related tasks (survey↔prompt↔persona flows)
- `adaptive-component-unification`: Single DsTaskButton component that adapts to different screen sizes and contexts
- `affective-design-admin`: Integration of DS emotional design patterns with performance optimizations

### Modified Capabilities
- `frontend-survey-builder`: Reorganize around task-based navigation with unified shell and adaptive components
- `builder-productivity-ux`: Eliminate navigation friction through persistent context and direct workflows
- `user-navigation-orientation`: Clear visual hierarchy with task-oriented page headers and consistent navigation patterns
- `affective-design-admin`: Enhanced integration of DS emotional design components with performance considerations

## Impact

- Affected apps: `apps/survey-builder`
- Affected design system: Unified components with adaptive layouts
- Component reduction: Eliminate specialized navigation widgets in favor of adaptive DS components
- Performance: Optimized with lazy loading and progressive enhancement
- Mobile experience: New responsive patterns with appropriate touch targets

## Implementation Roadmap

1. **Define Unified Component Architecture**
   - Design DsTaskButton with adaptive layouts
   - Create DsAdminShell wrapper component
   - Establish navigation state management

2. **Implement Task-Based Dashboard**
   - Replace survey list with task-focused home screen
   - Add primary action buttons with clear intent
   - Include compact recent activity feed

3. **Build Persistent Navigation System**
   - Implement adaptive sidebar/bottom navigation
   - Add cross-workflow shortcuts between sections
   - Ensure navigation persists across deep links

4. **Mobile Optimization**
   - Define responsive breakpoints
   - Create mobile-optimized navigation patterns
   - Test touch targets and interaction patterns

5. **Affective Design Integration**
   - Add ambient delight to task completions
   - Implement emotional feedback for workflows
   - Ensure performance isn't compromised

## Design Decisions

1. **Task-Oriented Over Data-Oriented**
   Primary action buttons are the focal point, not data summaries. Users come to accomplish tasks, not just browse data.

2. **Persistent Navigation Without Dashboard Dependency**
   Navigation remains visible so users can move between sections freely without losing context or workflow momentum.

3. **Component Unification Through Adaptation**
   Instead of creating specialized components, extend existing DS widgets with properties that adapt to different contexts.

4. **Affective Design Without Performance Compromise**
   Emotional design patterns enhance engagement while maintaining performance through lazy loading and optional animations.

5. **Mobile-First Responsive Strategy**
   Single adaptive system that transitions smoothly between desktop and mobile layouts without separate implementations.

## Performance Considerations

- Lazy load navigation sections and content
- Stagger animations to avoid overwhelming the user
- Cache frequently accessed data (recent updates, navigation state)
- Ensure affective design elements are optional and non-blocking

## Mobile Strategy

**Desktop (>768px):**
- Left sidebar navigation
- Large task buttons with icons and labels
- Page header with breadcrumbs

**Mobile (<768px):**
- Bottom navigation bar
- Floating action button for primary task
- Swipe gestures for section switching
- Collapsible dashboard sections