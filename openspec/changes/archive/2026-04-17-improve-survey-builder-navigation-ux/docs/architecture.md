# Survey Builder Administrative Information Architecture

## Overview
The survey-builder uses a task-oriented administrative information architecture centered around a dashboard that provides direct access to core administrative functions.

## Home/Dashboard Screen
- **Primary Function**: Task-based entry point for administrative activities
- **Key Elements**:
  - Large task buttons for core actions (Create Survey, Edit Existing, Quick Prompts, Manage Personas)
  - Secondary actions accessible via persistent navigation
  - Recent activity feed showing last updates
- **Route**: `/` (root after authentication)

## Primary Sections and Route Ownership

### 1. Surveys Section (`/surveys`)
- **Owner**: Survey management team
- **Primary Actions**: Create new survey, edit existing surveys
- **Secondary Actions**: Export surveys, manage survey templates
- **Routes**:
  - `/surveys/` - Survey list/dashboard
  - `/surveys/create` - New survey form
  - `/surveys/:id` - Survey editor
  - `/surveys/:id/edit` - Survey editing mode

### 2. Prompts Section (`/prompts`)
- **Owner**: Content management team
- **Primary Actions**: Create prompts, edit existing prompts
- **Secondary Actions**: Prompt categorization, prompt templates
- **Routes**:
  - `/prompts/` - Prompt catalog
  - `/prompts/create` - New prompt form
  - `/prompts/:id` - Prompt editor

### 3. Personas Section (`/personas`)
- **Owner**: User experience team
- **Primary Actions**: Create personas, manage persona skills
- **Secondary Actions**: Persona sharing, persona templates
- **Routes**:
  - `/personas/` - Persona catalog
  - `/personas/create` - New persona form
  - `/personas/:id` - Persona editor
  - `/personas/:id/skills` - Persona skill management

### 4. Access Points Section (`/access-points`)
- **Owner**: Integration team
- **Primary Actions**: Configure access points, manage API keys
- **Secondary Actions**: Access point monitoring, rate limiting
- **Routes**:
  - `/access-points/` - Access point list
  - `/access-points/create` - New access point
  - `/access-points/:id` - Access point configuration

## Navigation Flow

### Desktop Layout (>768px)
```
┌─────────────────────────────────────────┐
│ Sidebar Navigation                       │
│ ┌─────────────────────────────────────┐ │
│ │ • Dashboard                         │ │
│ │ • Surveys                           │ │
│ │ • Prompts                          │ │
│ │ • Personas                         │ │
│ │ • Access Points                    │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ │                                     │ │
│ │        Page Content                │ │
│ │        + Task Focus               │ │
│ │        + Breadcrumbs             │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### Mobile Layout (<768px)
```
┌─────────────────────────────────┐
│        Page Header              │
│  [Back] [Title] [Actions]       │
│                                 │
│        Content                  │
│         ↓                       │
│                                 │
│     Task Area                   │
│                                 │
─────────────────────────────────
│ Nav | Nav | Nav | Nav | Profile │
└─────────────────────────────────┘
```

## Cross-Workflow Connections

### Survey Creation Workflow
1. Start at dashboard → "Create Survey"
2. Need prompt? → Quick "Add Prompt" button in survey editor
3. Prompt created → Auto-return to survey with prompt selected

### Persona Management Workflow
1. Survey editing → Need persona? → "Manage Personas" shortcut
2. Persona catalog → Create/edit persona → Return to survey

## Route Preservation Strategy
- Legacy routes (e.g., `/survey-prompt-list`) redirect to new structured routes
- Deep links maintain their functionality within the admin shell
- Browser navigation back/forward works correctly within sections