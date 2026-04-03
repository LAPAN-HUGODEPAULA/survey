import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:patient_app/core/providers/app_settings.dart';
import 'package:patient_app/features/legal/pages/initial_notice_page.dart';
import 'package:patient_app/features/welcome/pages/welcome_page.dart';
import 'package:provider/provider.dart';

class PatientEntryPage extends StatefulWidget {
  const PatientEntryPage({super.key});

  @override
  State<PatientEntryPage> createState() => _PatientEntryPageState();
}

class _PatientEntryPageState extends State<PatientEntryPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _initialized = true;
    context.read<AppSettings>().loadInitialNoticeAgreement();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        if (settings.isLoadingInitialNotice) {
          return const DsScaffold(
            title: 'Carregando',
            subtitle: 'Preparando a experiencia compartilhada do paciente.',
            body: DsLoading(),
          );
        }

        if (!settings.hasAcceptedInitialNotice) {
          return const InitialNoticePage();
        }

        return const WelcomePage();
      },
    );
  }
}
