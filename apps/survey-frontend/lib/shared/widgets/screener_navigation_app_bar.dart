import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/providers/api_provider.dart';
import 'package:survey_app/core/providers/app_settings.dart';

enum _ScreenerMenuAction {
  login,
  register,
  profile,
  settings,
  switchAccount,
  logout,
}

class ScreenerNavigationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ScreenerNavigationAppBar({
    required this.title,
    super.key,
    this.currentRoute,
  });

  final Widget title;
  final String? currentRoute;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final showHomeButton = currentRoute != '/demographics';

    return AppBar(
      automaticallyImplyLeading: false,
      leading: showHomeButton
          ? IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: 'Voltar ao início',
              onPressed: () => context.go('/demographics'),
            )
          : null,
      title: title,
      actions: [
        DsAccountMenuButton<_ScreenerMenuAction>(
          tooltip: 'Conta',
          icon: const Icon(Icons.person_outline),
          onSelected: (action) => _onMenuSelected(context, action),
          items: _buildMenuItems(context.read<AppSettings>()),
        ),
      ],
    );
  }

  List<DsAccountMenuItem<_ScreenerMenuAction>> _buildMenuItems(
    AppSettings settings,
  ) {
    if (!settings.isLoggedIn) {
      return <DsAccountMenuItem<_ScreenerMenuAction>>[
        if (currentRoute != '/login')
          const DsAccountMenuItem(
            value: _ScreenerMenuAction.login,
            label: 'Entrar',
            icon: Icons.login,
          ),
        if (currentRoute != '/register')
          const DsAccountMenuItem(
            value: _ScreenerMenuAction.register,
            label: 'Criar conta',
            icon: Icons.person_add_alt_1,
          ),
        if (!settings.isLockedAssessmentMode && currentRoute != '/settings')
          const DsAccountMenuItem(
            value: _ScreenerMenuAction.settings,
            label: 'Configurações',
            icon: Icons.settings_outlined,
          ),
      ];
    }

    return <DsAccountMenuItem<_ScreenerMenuAction>>[
      if (currentRoute != '/profile')
        const DsAccountMenuItem(
          value: _ScreenerMenuAction.profile,
          label: 'Perfil',
          icon: Icons.badge_outlined,
        ),
      if (!settings.isLockedAssessmentMode && currentRoute != '/settings')
        const DsAccountMenuItem(
          value: _ScreenerMenuAction.settings,
          label: 'Configurações',
          icon: Icons.settings_outlined,
        ),
      const DsAccountMenuItem(
        value: _ScreenerMenuAction.switchAccount,
        label: 'Trocar conta',
        icon: Icons.swap_horiz,
      ),
      const DsAccountMenuItem(
        value: _ScreenerMenuAction.logout,
        label: 'Sair',
        icon: Icons.logout,
      ),
    ];
  }

  void _onMenuSelected(BuildContext context, _ScreenerMenuAction action) {
    final settings = context.read<AppSettings>();
    switch (action) {
      case _ScreenerMenuAction.login:
        context.go('/login');
        break;
      case _ScreenerMenuAction.register:
        context.go('/register');
        break;
      case _ScreenerMenuAction.profile:
        context.go('/profile');
        break;
      case _ScreenerMenuAction.settings:
        context.go('/settings');
        break;
      case _ScreenerMenuAction.switchAccount:
        settings.clearScreenerSession();
        context.read<ApiProvider>().clearAuthToken();
        context.go('/login');
        break;
      case _ScreenerMenuAction.logout:
        settings.clearScreenerSession();
        context.read<ApiProvider>().clearAuthToken();
        context.go('/login');
        break;
    }
  }
}
