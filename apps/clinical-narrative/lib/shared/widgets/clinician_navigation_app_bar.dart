import 'package:clinical_narrative_app/core/navigation/app_navigator.dart';
import 'package:clinical_narrative_app/core/providers/app_settings.dart';
import 'package:clinical_narrative_app/core/providers/chat_provider.dart';
import 'package:clinical_narrative_app/features/clinician/pages/clinician_login_page.dart';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _ClinicianMenuAction { login, register, switchAccount, logout }

class ClinicianNavigationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ClinicianNavigationAppBar({
    required this.title,
    super.key,
    this.showHomeButton = false,
    this.extraActions = const <Widget>[],
  });

  final Widget title;
  final bool showHomeButton;
  final List<Widget> extraActions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: showHomeButton
          ? IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: 'Voltar ao início',
              onPressed: () => AppNavigator.toDemographics(context),
            )
          : null,
      title: title,
      actions: [
        ...extraActions,
        DsAccountMenuButton<_ClinicianMenuAction>(
          tooltip: 'Conta',
          icon: const Icon(Icons.person_outline),
          items: _buildMenuItems(context.watch<AppSettings>()),
          onSelected: (action) => _onMenuSelected(context, action),
        ),
      ],
    );
  }

  List<DsAccountMenuItem<_ClinicianMenuAction>> _buildMenuItems(
    AppSettings settings,
  ) {
    if (!settings.isLoggedIn) {
      return const [
        DsAccountMenuItem(
          value: _ClinicianMenuAction.login,
          label: 'Entrar',
          icon: Icons.login,
        ),
        DsAccountMenuItem(
          value: _ClinicianMenuAction.register,
          label: 'Criar conta',
          icon: Icons.person_add_alt_1,
        ),
      ];
    }

    return const [
      DsAccountMenuItem(
        value: _ClinicianMenuAction.switchAccount,
        label: 'Trocar conta',
        icon: Icons.swap_horiz,
      ),
      DsAccountMenuItem(
        value: _ClinicianMenuAction.logout,
        label: 'Sair',
        icon: Icons.logout,
      ),
    ];
  }

  void _onMenuSelected(BuildContext context, _ClinicianMenuAction action) {
    switch (action) {
      case _ClinicianMenuAction.login:
        AppNavigator.toLogin(context);
        break;
      case _ClinicianMenuAction.register:
        AppNavigator.toRegistration(context);
        break;
      case _ClinicianMenuAction.switchAccount:
      case _ClinicianMenuAction.logout:
        context.read<AppSettings>().clearScreenerSession();
        context.read<ChatProvider>().reset();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const ClinicianLoginPage()),
          (route) => false,
        );
        break;
    }
  }
}
