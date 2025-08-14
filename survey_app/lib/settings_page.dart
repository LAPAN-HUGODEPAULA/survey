// lib/settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:survey_app/providers/app_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _screenerNameController;

  @override
  void initState() {
    super.initState();
    // Inicia a busca pelos questionários disponíveis
    // Usamos listen: false aqui porque estamos em initState
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

  // Função para extrair um nome legível do caminho do arquivo
  String getSurveyNameFromPath(String path) {
    // Exemplo: 'assets/surveys/lapan_q7.json' -> 'lapan_q7'
    return path.split('/').last.replaceAll('.json', '');
  }

  @override
  Widget build(BuildContext context) {
    // Usa um Consumer para reconstruir a UI quando as configurações mudarem
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
              // Campo para o nome do Screener
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

              // Caixa de seleção para o questionário
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

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Volta para a tela anterior
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
