import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/core/providers/api_provider.dart'; // Will be used for logout
import 'package:survey_backend_api/survey_backend_api.dart'; // Will be used for ScreenerModel

class ScreenerProfilePage extends StatefulWidget {
  const ScreenerProfilePage({super.key});

  @override
  State<ScreenerProfilePage> createState() => _ScreenerProfilePageState();
}

class _ScreenerProfilePageState extends State<ScreenerProfilePage> {
  // Placeholder data for the screener profile
  // In a real application, this would be fetched from the backend for the logged-in user.
  final ScreenerModel _screener = ScreenerModel((b) => b
    ..cpf = '111.111.111-11'
    ..firstName = 'Maria'
    ..surname = 'Henriques Moreira Vale'
    ..email = 'maria.vale@holhos.com'
    ..password = '' // Password should not be displayed
    ..phone = '31988447613'
    ..address.postalCode = '27090639'
    ..address.street = 'Praça da Liberdade'
    ..address.number = '932'
    ..address.complement = 'Apto 101'
    ..address.neighborhood = 'Savassi'
    ..address.city = 'Belo Horizonte'
    ..address.state = 'MG'
    ..professionalCouncil.type = 'CRP'
    ..professionalCouncil.registrationNumber = '12543'
    ..jobTitle = 'Psychologist'
    ..degree = 'Psychology'
    ..darvCourseYear = 2019
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Screener'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement actual logout logic (clear token, navigate to login)
              context.go('/login');
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileField('CPF', _screener.cpf),
            _buildProfileField('Nome', '${_screener.firstName} ${_screener.surname}'),
            _buildProfileField('E-mail', _screener.email),
            _buildProfileField('Telefone', _screener.phone),
            const Divider(),
            Text('Endereço', style: Theme.of(context).textTheme.titleLarge),
            _buildProfileField('CEP', _screener.address.postalCode),
            _buildProfileField('Rua', _screener.address.street),
            _buildProfileField('Número', _screener.address.number),
            if (_screener.address.complement != null && _screener.address.complement!.isNotEmpty)
              _buildProfileField('Complemento', _screener.address.complement!),
            _buildProfileField('Bairro', _screener.address.neighborhood),
            _buildProfileField('Cidade', _screener.address.city),
            _buildProfileField('Estado', _screener.address.state),
            const Divider(),
            Text('Informações Profissionais', style: Theme.of(context).textTheme.titleLarge),
            _buildProfileField('Conselho', _screener.professionalCouncil.type ?? 'N/A'),
            _buildProfileField('Registro', _screener.professionalCouncil.registrationNumber ?? 'N/A'),
            _buildProfileField('Cargo', _screener.jobTitle),
            _buildProfileField('Formação', _screener.degree),
            if (_screener.darvCourseYear != null)
              _buildProfileField('Ano DARV', _screener.darvCourseYear.toString()),
          ],
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
