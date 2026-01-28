import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/providers/api_provider.dart';
import 'package:survey_app/core/providers/app_settings.dart';

enum _ProfileMenuAction { login, profile, settings, logout }

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('LAPAN Survey'),
        actions: [
          PopupMenuButton<_ProfileMenuAction>(
            tooltip: 'Perfil',
            icon: const Icon(Icons.person),
            onSelected: (action) {
              switch (action) {
                case _ProfileMenuAction.login:
                  context.go('/login');
                  break;
                case _ProfileMenuAction.profile:
                  context.go('/profile');
                  break;
                case _ProfileMenuAction.settings:
                  context.go('/settings');
                  break;
                case _ProfileMenuAction.logout:
                  settings.clearScreenerSession();
                  context.read<ApiProvider>().clearAuthToken();
                  context.go('/login');
                  break;
              }
            },
            itemBuilder: (context) {
              if (!settings.isLoggedIn) {
                return const [
                  PopupMenuItem(
                    value: _ProfileMenuAction.login,
                    child: Text('Login'),
                  ),
                  PopupMenuItem(
                    value: _ProfileMenuAction.settings,
                    child: Text('Configurações'),
                  ),
                ];
              }
              return const [
                PopupMenuItem(
                  value: _ProfileMenuAction.profile,
                  child: Text('Perfil'),
                ),
                PopupMenuItem(
                  value: _ProfileMenuAction.settings,
                  child: Text('Configurações'),
                ),
                PopupMenuItem(
                  value: _ProfileMenuAction.logout,
                  child: Text('Sair'),
                ),
              ];
            },
          ),
        ],
      ),
      body: child,
    );
  }
}
