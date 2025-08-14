/// Página de configurações da aplicação.
///
/// Permite configurar o nome do responsável pela aplicação do questionário
/// e selecionar qual questionário será utilizado dentre os disponíveis.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/providers/app_settings.dart';

/// Página de configurações da aplicação de questionários.
///
/// Fornece interface para:
/// - Definir o nome do profissional responsável (screener)
/// - Selecionar qual questionário será aplicado
///
/// As alterações são automaticamente persistidas através do [AppSettings] provider.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// Estado da página de configurações.
///
/// Gerencia o controlador do campo de texto do nome do responsável
/// e sincroniza as configurações com o provider global.
class _SettingsPageState extends State<SettingsPage> {
  /// Controlador para o campo de texto do nome do responsável
  late TextEditingController _screenerNameController;

  @override
  void initState() {
    super.initState();
    // Carrega os questionários disponíveis e inicializa o controlador
    final settings = Provider.of<AppSettings>(context, listen: false);
    settings.loadAvailableSurveys();
    _screenerNameController = TextEditingController(
      text: settings.screenerName,
    );
  }

  @override
  void dispose() {
    _screenerNameController.dispose();
    super.dispose();
  }

  /// Extrai um nome legível do caminho do arquivo de questionário.
  ///
  /// [path] - Caminho completo do arquivo (ex: 'assets/surveys/lapan_q7.json')
  ///
  /// Returns o nome do arquivo sem extensão (ex: 'lapan_q7')
  ///
  /// Exemplo:
  /// ```dart
  /// getSurveyNameFromPath('assets/surveys/lapan_q7.json') // retorna 'lapan_q7'
  /// ```
  String getSurveyNameFromPath(String path) {
    return path.split('/').last.replaceAll('.json', '');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Configurações'),
            backgroundColor: Colors.teal,
          ),
          body: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // Campo para o nome do responsável
              TextFormField(
                controller: _screenerNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Responsável (Screener)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Atualiza o nome nas configurações em tempo real
                  settings.setScreenerName(value);
                },
              ),
              const SizedBox(height: 24),

              // Seleção do questionário ativo
              const Text(
                'Selecione o Questionário Ativo:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (settings.availableSurveyPaths.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  value: settings.selectedSurveyPath,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  items: settings.availableSurveyPaths.map((path) {
                    return DropdownMenuItem(
                      value: path,
                      child: Text(getSurveyNameFromPath(path)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    settings.selectSurvey(value);
                  },
                ),

              const SizedBox(height: 40),

              // Botão de confirmação
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Salvar e Voltar'),
              ),
            ],
          ),
        );
      },
    );
  }
}
