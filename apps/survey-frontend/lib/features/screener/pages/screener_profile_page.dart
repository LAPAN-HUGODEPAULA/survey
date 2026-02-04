import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/providers/api_provider.dart';
import 'package:survey_app/core/providers/app_settings.dart';

class ScreenerProfilePage extends StatefulWidget {
  const ScreenerProfilePage({super.key});

  @override
  State<ScreenerProfilePage> createState() => _ScreenerProfilePageState();
}

class _ScreenerProfilePageState extends State<ScreenerProfilePage> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final profile = settings.screenerProfile;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Avaliador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              settings.clearScreenerSession();
              context.read<ApiProvider>().clearAuthToken();
              context.go('/login');
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: profile == null
          ? _buildLoggedOutState(context)
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileField('CPF', profile.cpf),
                      _buildProfileField('Nome', '${profile.firstName} ${profile.surname}'),
                      _buildProfileField('E-mail', profile.email),
                      _buildProfileField('Telefone', profile.phone),
                      const Divider(),
                      Text('Endereço', style: Theme.of(context).textTheme.titleLarge),
                      _buildProfileField('CEP', profile.address.postalCode),
                      _buildProfileField('Rua', profile.address.street),
                      _buildProfileField('Número', profile.address.number),
                      if ((profile.address.complement ?? '').isNotEmpty)
                        _buildProfileField('Complemento', profile.address.complement!),
                      _buildProfileField('Bairro', profile.address.neighborhood),
                      _buildProfileField('Cidade', profile.address.city),
                      _buildProfileField('Estado', profile.address.state),
                      const Divider(),
                      Text(
                        'Informações Profissionais',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      _buildProfileField(
                        'Conselho',
                        profile.professionalCouncil.type,
                      ),
                      _buildProfileField(
                        'Registro',
                        profile.professionalCouncil.registrationNumber,
                      ),
                      _buildProfileField('Cargo', profile.jobTitle),
                      _buildProfileField('Formação', profile.degree),
                      if (profile.darvCourseYear != null)
                        _buildProfileField('Ano DARV', profile.darvCourseYear.toString()),
                    ],
                  ),
                ),
              ),
            ),
        );
  }

  Widget _buildLoggedOutState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Você precisa fazer login para ver seu perfil.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Ir para a tela de login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Adjust width as needed
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
