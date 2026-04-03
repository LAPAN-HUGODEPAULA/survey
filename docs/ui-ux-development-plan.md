# LAPAN Survey Platform: UI/UX Development Plan

## 1. Executive Summary
This plan establishes a unified visual and functional identity for the **LAPAN Survey Platform**. By centralizing the header architecture and standardizing professional workflows, we ensure that clinicians and administrators experience a seamless transition between tools while maintaining high accessibility standards (WCAG 2.1).

---

## 2. Technical Core: The Unified `DsAppBar`
All applications will migrate to a single, high-performance `DsAppBar` component located in `packages/design_system_flutter`.

### Features & Configuration:
- **Naming Convention:** Every application will display the title in the format: `LAPAN - [Application Name]`.
- **Zero-Logo Policy:** All `lapan_logo_orange`, `lapan_logo_reduced`, and other variations are strictly removed from the `AppBar` to avoid resolution issues.
- **Shared Professional Menu:** A standardized `DsAccountMenuButton` will be implemented for `survey-frontend`, `clinical-narrative`, and `survey-builder`.
- **Semantic Status Feedback:** The `AppBar` will include a hidden `Semantics` announcement and a visible `Tooltip` on the account icon indicating the current status (e.g., *"Conectado como [Nome]"* or *"Usuário não autenticado"*).
- **Titles for tab navigation:** All applications must have specific titles for each screen with semantic information to ease tab navigation.
- **Consistent language:**: Exceptions and technical messages must be in Brazilian Portuguese. No English messages should "leak" to the user". Messages must follow usability rules for natural language guidelines, such as: be clear, be helpful, reduce cognitive load, avoid abbreviations and acronyms, follow a standard language form or pattern. 
- **Primary actions:** Unify position of primary actions (e. g.: all main buttons to the right)
- **App icon:** change icon for mobile apps. Do not use flutter standard icon.
- **Microcopy:** Define guidelines for microcopy before creating the final shared layout and styleguides.
- **Documentation:** Keep all documentation, specially user guides, up to date with all changes in flow, style or naming. 

---

## 3. Standardized Account Behavior (Professional Apps)
The following behavior will be identical across `survey-frontend`, `clinical-narrative`, and `survey-builder`:

### Unified Actions:
1.  **Entrar (Login):** Visible when the user is not authenticated.
2.  **Trocar conta (Switch Account):** Clears the current session and redirects to the login screen without a full logout (preserving app state where applicable).
3.  **Sair (Logout):** Full session termination and redirect to the entry screen.

### Authentication Feedback:
- **Visual:** The account icon (person) will change color or gain a subtle indicator (e.g., a green dot) when a session is active.
- **Auditory/Screen Reader:** Upon page load or menu focus, the app will announce the user's name and professional role (if available) to ensure the user knows they are operating within their authorized session.

---

## 4. Application-Specific Updates

### A. `survey-frontend` & `clinical-narrative` (The Professional Core)
- **Header:** Replace custom navigation bars with `DsAppBar`.
- **Titles:** 
    - Frontend: `"LAPAN - Gestão de Avaliações"`
    - Narrative: `"LAPAN - Narrativa Clínica"`

- **Consistency:** Both apps will share the exact same logic for session management in the `DsAccountMenuButton`.
- **Splash Screen:** Only `survey-frontend` retains the high-resolution `SplashScreen` for branding purposes.

### B. `survey-builder` (Administrative Tool)
- **Header:** Migrate to `DsAppBar`.
- **Title:** `"LAPAN - Construtor de Questionários"`
- **Account Menu:** **NEW** Implementation of the professional account menu. Administrators will now have the same "Trocar conta" and "Sair" options as clinicians, providing a consistent professional experience.

### C. `survey-patient` (Public Screening)
- **Header:** Migrate to `DsAppBar`.
- **Title:** `"LAPAN - Triagem de Paciente"`
- **Account Menu:** **NONE**. This app remains a linear, anonymous screening tool with no login or account management features.

---

## 5. Accessibility & Design Standards (WCAG 2.1 Level AA)

### Visual Integrity
- **Typography:** Titles will use the `titleLarge` style from the `DsTheme`, ensuring high contrast (at least 4.5:1) against the background.
- **Iconography:** Functional icons (Home, Account) will use standard Material symbols at a minimum size of 24dp for touch-target compliance.

### Interactive Elements
- **Focus Order:** The "LAPAN - [Name]" title will be the first focused element (as a Heading 1), followed by the Account Menu.
- **Semantic Labels:** All header actions will have `semanticsLabel` in Portuguese (e.g., *"Abrir menu da conta"*, *"Voltar ao início"*).

---

## 6. Implementation Roadmap

### Phase 1: Design System (Shared)
- Build `DsAppBar` with `Semantics` and `Tooltip` support.
- Refactor `DsAccountMenuButton` to accept the unified action set (`Entrar`, `Trocar`, `Sair`).

### Phase 2: Professional Migration
- Update `survey-frontend` and `clinical-narrative` simultaneously to ensure parity.
- Implement the `DsAccountMenuButton` in `survey-builder` and link it to the administrative session state.

### Phase 3: Validation & Polish
- Audit all 4 apps for contrast and keyboard navigation.
- Verify that no LAPAN logos remain in any `AppBar` across the platform.
