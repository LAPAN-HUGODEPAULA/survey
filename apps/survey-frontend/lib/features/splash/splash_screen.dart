import 'dart:async';

import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(
      const Duration(seconds: 3),
      () => context.go('/demographics'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DsScaffold(
      scrollable: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: DsSection(
            eyebrow: 'Plataforma profissional',
            title: 'LAPAN Questionarios',
            subtitle:
                'Preparando o fluxo de triagem para a sessao do avaliador.',
            child: Column(
              children: [
                Image.asset('assets/images/logo_rect.png', height: 200),
                const SizedBox(height: 20),
                Text(
                  'Laboratorio de Pesquisa Aplicada a Neurovisao',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Prof. Hugo de Paula, Ph. D.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }
}
