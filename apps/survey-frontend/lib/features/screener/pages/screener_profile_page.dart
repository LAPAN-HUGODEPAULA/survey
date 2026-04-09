import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/providers/app_settings.dart';
import 'package:survey_app/shared/widgets/screener_navigation_app_bar.dart';

class ScreenerProfilePage extends StatelessWidget {
  const ScreenerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final profile = settings.screenerProfile;

    return DsScaffold(
      appBar: const ScreenerNavigationAppBar(
        currentRoute: '/profile',
        title: Text('Perfil do Avaliador'),
      ),
      scrollable: true,
      body: profile == null
          ? const _LoggedOutState()
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DsSection(
                      eyebrow: 'Conta',
                      title: 'Dados pessoais',
                      subtitle:
                          'Confira as informacoes principais da conta profissional.',
                      child: Column(
                        children: [
                          _ProfileField(label: 'CPF', value: profile.cpf),
                          _ProfileField(
                            label: 'Nome',
                            value: '${profile.firstName} ${profile.surname}',
                          ),
                          _ProfileField(label: 'E-mail', value: profile.email),
                          _ProfileField(
                            label: 'Telefone',
                            value: profile.phone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DsSection(
                      title: 'Endereco',
                      child: Column(
                        children: [
                          _ProfileField(
                            label: 'CEP',
                            value: profile.address.postalCode,
                          ),
                          _ProfileField(
                            label: 'Rua',
                            value: profile.address.street,
                          ),
                          _ProfileField(
                            label: 'Numero',
                            value: profile.address.number,
                          ),
                          if ((profile.address.complement ?? '').isNotEmpty)
                            _ProfileField(
                              label: 'Complemento',
                              value: profile.address.complement!,
                            ),
                          _ProfileField(
                            label: 'Bairro',
                            value: profile.address.neighborhood,
                          ),
                          _ProfileField(
                            label: 'Cidade',
                            value: profile.address.city,
                          ),
                          _ProfileField(
                            label: 'Estado',
                            value: profile.address.state,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DsSection(
                      title: 'Informacoes profissionais',
                      child: Column(
                        children: [
                          _ProfileField(
                            label: 'Conselho',
                            value: profile.professionalCouncil.type,
                          ),
                          _ProfileField(
                            label: 'Registro',
                            value:
                                profile.professionalCouncil.registrationNumber,
                          ),
                          _ProfileField(
                            label: 'Cargo',
                            value: profile.jobTitle,
                          ),
                          _ProfileField(
                            label: 'Formacao',
                            value: profile.degree,
                          ),
                          if (profile.darvCourseYear != null)
                            _ProfileField(
                              label: 'Ano DARV',
                              value: profile.darvCourseYear.toString(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _LoggedOutState extends StatelessWidget {
  const _LoggedOutState();

  @override
  Widget build(BuildContext context) {
    return DsEmptyState(
      visual: const Icon(Icons.lock_outline, size: 52),
      title: 'Sessão expirada',
      description: 'Entre novamente para acessar seus dados profissionais.',
      actionLabel: 'Ir para login',
      onAction: () => context.go('/login'),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
