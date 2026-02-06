library;

import 'dart:async';
import 'dart:ui' as ui;

import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import 'package:clinical_narrative_app/core/models/chat_message.dart';
import 'package:clinical_narrative_app/core/models/chat_session.dart';
import 'package:clinical_narrative_app/core/providers/app_settings.dart';
import 'package:clinical_narrative_app/core/providers/chat_provider.dart';
import 'package:clinical_narrative_app/core/services/voice_capture_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _voiceTextController = TextEditingController();
  final _scrollController = ScrollController();
  bool _voiceMode = false;
  VoiceCaptureService? _voiceService;
  VoiceCaptureResult? _voiceResult;
  String? _voiceError;
  String? _audioViewType;
  bool _isRecording = false;
  bool _isTranscribing = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _voiceService = VoiceCaptureService();
      _voiceService?.previewStream.listen((text) {
        if (_isRecording) {
          _voiceTextController.text = text;
          setState(() {});
        }
      });
      _voiceService?.errorStream.listen((error) {
        setState(() {
          _voiceError = _mapVoiceError(error);
        });
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patientId = context.read<AppSettings>().patient.medicalRecordId;
      context.read<ChatProvider>().initialize(patientId: patientId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _voiceTextController.dispose();
    _scrollController.dispose();
    _voiceService?.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _send(ChatProvider provider) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final stopwatch = Stopwatch()..start();
    provider.sendMessage(text);
    _scrollToBottom();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      stopwatch.stop();
      if (kDebugMode) {
        debugPrint('Chat send UI response: ${stopwatch.elapsedMilliseconds}ms');
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingSeconds = 0;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _recordingSeconds += 1;
      });
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
  }

  String _formatDuration(String? startIso, String? endIso) {
    final start = DateTime.tryParse(startIso ?? '');
    if (start == null) return '--:--';
    final end = endIso != null ? DateTime.tryParse(endIso) : null;
    final duration = (end ?? DateTime.now()).difference(start);
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatTime(String? iso) {
    final parsed = DateTime.tryParse(iso ?? '');
    if (parsed == null) return '';
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _sessionStatusLabel(ChatSession? session, bool isLoading) {
    if (isLoading) return 'Starting';
    if (session == null) return 'New';
    if (session.status.toLowerCase() == 'completed') return 'Finished';
    return 'Active';
  }

  DsStatusType _sessionStatusType(ChatSession? session, bool isLoading) {
    if (isLoading) return DsStatusType.info;
    if (session == null) return DsStatusType.neutral;
    if (session.status.toLowerCase() == 'completed') return DsStatusType.success;
    return DsStatusType.info;
  }

  String _voiceStatusLabel() {
    if (_voiceError != null) return 'Voice error';
    if (_isRecording) return 'Recording';
    if (_isTranscribing) return 'Transcribing';
    if (_voiceService == null) return 'Voice unsupported';
    if (!_voiceService!.isPreviewAvailable) return 'Preview unavailable';
    return 'Ready';
  }

  DsStatusType _voiceStatusType() {
    if (_voiceError != null) return DsStatusType.error;
    if (_isRecording) return DsStatusType.warning;
    if (_isTranscribing) return DsStatusType.info;
    if (_voiceService == null) return DsStatusType.neutral;
    if (!_voiceService!.isPreviewAvailable) return DsStatusType.warning;
    return DsStatusType.success;
  }

  Widget _buildSessionHeader(ChatProvider provider, ChatSession? session, String phase) {
    final statusLabel = _sessionStatusLabel(session, provider.isLoading);
    final statusType = _sessionStatusType(session, provider.isLoading);
    final duration = _formatDuration(session?.createdAt, session?.completedAt);
    final statusIcon = statusType == DsStatusType.success
        ? Icons.check_circle
        : statusType == DsStatusType.info
            ? Icons.pending_actions
            : Icons.radio_button_unchecked;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Session',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              DsStatusChip(label: statusLabel, type: statusType, icon: statusIcon),
              const Spacer(),
              if (provider.isOffline)
                DsStatusIndicator(
                  label: 'Offline',
                  color: Theme.of(context).colorScheme.error,
                  liveRegion: true,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Duration $duration',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: phase,
                items: const [
                  DropdownMenuItem(value: 'intake', child: Text('Intake')),
                  DropdownMenuItem(value: 'assessment', child: Text('Assessment')),
                  DropdownMenuItem(value: 'plan', child: Text('Plan')),
                  DropdownMenuItem(value: 'wrap_up', child: Text('Wrap-up')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    provider.updatePhase(value);
                  }
                },
              ),
              const Spacer(),
              Text(session?.status ?? 'active'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoicePanel(ChatProvider provider, bool inputEnabled) {
    final statusLabel = _voiceStatusLabel();
    final statusType = _voiceStatusType();
    final statusIcon = _voiceError != null
        ? Icons.error_outline
        : _isRecording
            ? Icons.mic
            : _isTranscribing
                ? Icons.auto_awesome
                : _voiceService == null
                    ? Icons.mic_off
                    : Icons.check_circle;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Voice capture',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              DsStatusChip(label: statusLabel, type: statusType, icon: statusIcon),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Audio is used only for transcription and discarded after processing.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (_voiceError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _voiceError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              DsFilledButton(
                label: 'Start',
                icon: Icons.mic,
                onPressed: (!inputEnabled || _isRecording) ? null : _startRecording,
              ),
              const SizedBox(width: 8),
              DsOutlinedButton(
                label: 'Stop',
                icon: Icons.stop,
                onPressed: (!inputEnabled || !_isRecording) ? null : _stopRecording,
              ),
              const SizedBox(width: 12),
              if (_voiceService != null && !_voiceService!.isPreviewAvailable)
                const Text('Live preview unavailable in this browser'),
            ],
          ),
          const SizedBox(height: 8),
          if (_isRecording) DsRecordingIndicator(seconds: _recordingSeconds),
          if (_isRecording) const SizedBox(height: 6),
          if (_isRecording)
            const LinearProgressIndicator(minHeight: 4),
          if (_audioViewType != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: HtmlElementView(viewType: _audioViewType!),
            ),
          ],
          const SizedBox(height: 8),
          TextField(
            controller: _voiceTextController,
            decoration: const InputDecoration(
              labelText: 'Preview text',
              hintText: 'Live preview (editable)',
            ),
            minLines: 2,
            maxLines: 4,
            enabled: inputEnabled,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              DsOutlinedButton(
                label: 'Use Preview Text',
                onPressed: !inputEnabled || _voiceTextController.text.trim().isEmpty
                    ? null
                    : () {
                        _controller.text = _voiceTextController.text.trim();
                      },
              ),
              const SizedBox(width: 8),
              DsFilledButton(
                label: _isTranscribing ? 'Transcribing...' : 'Send for Transcription',
                onPressed: !inputEnabled || _isTranscribing
                    ? null
                    : () => _submitVoiceTranscription(provider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmEndSession(ChatProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DsDialog(
        title: 'End consultation?',
        content: const Text('This will complete the current session.'),
        actions: [
          DsTextButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
          ),
          DsFilledButton(
            label: 'End',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.completeSession();
    }
  }

  Future<void> _openDocumentDialog(ChatProvider provider) async {
    final fallbackDocumentTypes = [
      {'id': 'consultation_record', 'label': 'Consultation Record'},
      {'id': 'prescription', 'label': 'Prescription'},
      {'id': 'referral', 'label': 'Referral'},
      {'id': 'certificate', 'label': 'Certificate'},
      {'id': 'technical_report', 'label': 'Technical Report'},
      {'id': 'clinical_progress', 'label': 'Clinical Progress'},
    ];
    final fetchedTypes = await provider.fetchTemplateDocumentTypes();
    final documentTypes = fetchedTypes.isNotEmpty ? fetchedTypes : fallbackDocumentTypes;
    final defaultType =
        documentTypes.first['id']?.toString() ?? 'consultation_record';
    var selectedDocumentType = defaultType;

    await provider.fetchTemplates(documentType: selectedDocumentType);
    final preview = await provider.generateDocumentPreview(
      documentType: selectedDocumentType,
    );
    if (!mounted || preview == null) return;

    final titleController = TextEditingController(text: preview.title);
    final bodyController = TextEditingController(text: preview.body);
    final searchController = TextEditingController();
    var selectedTemplateId = provider.templates.isNotEmpty ? provider.templates.first.id : '';
    var missingFields = preview.missingFields;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final templates = provider.templates;
            return DsDialog(
              title: 'Generate Document',
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (missingFields.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Missing fields: ${missingFields.join(', ')}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      DropdownButtonFormField<String>(
                        key: ValueKey('doc-type-$selectedDocumentType'),
                        initialValue: selectedDocumentType,
                        decoration: const InputDecoration(labelText: 'Document type'),
                        items: documentTypes
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item['id']?.toString() ?? '',
                                child: Text(item['label']?.toString() ?? ''),
                              ),
                            )
                            .where((item) => item.value != null && item.value!.isNotEmpty)
                            .toList(),
                        onChanged: (value) async {
                          if (value == null || value.isEmpty) return;
                          selectedDocumentType = value;
                          await provider.fetchTemplates(documentType: value);
                          setState(() {
                            selectedTemplateId = provider.templates.isNotEmpty
                                ? provider.templates.first.id
                                : '';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(labelText: 'Search templates'),
                        onChanged: (value) async {
                          await provider.fetchTemplates(
                            documentType: selectedDocumentType,
                            query: value.trim(),
                          );
                          setState(() {
                            if (provider.templates.isNotEmpty) {
                              selectedTemplateId = provider.templates.first.id;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        key: ValueKey('template-$selectedTemplateId'),
                        initialValue: selectedTemplateId.isNotEmpty ? selectedTemplateId : null,
                        decoration: const InputDecoration(labelText: 'Template'),
                        items: templates
                            .map(
                              (template) => DropdownMenuItem<String>(
                                value: template.id,
                                child: Text('${template.name} (v${template.version})'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTemplateId = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: bodyController,
                        decoration: const InputDecoration(labelText: 'Body'),
                        maxLines: 8,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                DsTextButton(
                  label: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
                DsOutlinedButton(
                  label: 'Preview Template',
                  onPressed: selectedTemplateId.isEmpty
                      ? null
                      : () async {
                          final patient = context.read<AppSettings>().patient;
                          final narrative = context.read<AppSettings>().narrative;
                          final sampleData = {
                            'patient': {
                              'name': patient.name,
                              'medicalRecordId': patient.medicalRecordId,
                            },
                            'narrative': narrative,
                          };
                          final templatePreview = await provider.previewTemplate(
                            templateId: selectedTemplateId,
                            sampleData: sampleData,
                          );
                          if (templatePreview == null) return;
                          setState(() {
                            titleController.text = templatePreview.title;
                            bodyController.text = templatePreview.body;
                            missingFields = templatePreview.missingFields;
                          });
                          _openHtmlPreview(templatePreview.html);
                        },
                ),
                DsFilledButton(
                  label: 'Preview',
                  onPressed: () async {
                    final updatedPreview = await provider.generateDocumentPreview(
                      documentType: selectedDocumentType,
                      title: titleController.text.trim(),
                      body: bodyController.text.trim(),
                    );
                    if (updatedPreview == null) return;
                    _openHtmlPreview(updatedPreview.html);
                  },
                ),
                DsFilledButton(
                  label: 'Export PDF/Print',
                  onPressed: () async {
                    final record = await provider.exportDocument(
                      documentType: selectedDocumentType,
                      title: titleController.text.trim(),
                      body: bodyController.text.trim(),
                    );
                    if (record != null) {
                      _openHtmlPreview(record.html);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openHtmlPreview(String htmlContent) {
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
  }

  String _mapVoiceError(String code) {
    switch (code) {
      case 'not-allowed':
      case 'permission-denied':
        return 'Microphone permission denied. Please enable access in your browser settings.';
      case 'not-found':
        return 'No microphone detected. Please connect a device and try again.';
      default:
        return 'Unable to access the microphone. Please try again.';
    }
  }

  Future<void> _startRecording() async {
    if (_voiceService == null) {
      setState(() {
        _voiceError = 'Voice capture is only supported in web browsers.';
      });
      return;
    }
    final stopwatch = Stopwatch()..start();
    setState(() {
      _voiceError = null;
      _isRecording = true;
      _voiceResult = null;
      _audioViewType = null;
      _voiceTextController.clear();
    });
    _startRecordingTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      stopwatch.stop();
      if (kDebugMode) {
        debugPrint('Voice start UI response: ${stopwatch.elapsedMilliseconds}ms');
      }
    });
    try {
      await _voiceService?.start();
    } catch (e) {
      setState(() {
        _voiceError = 'Unable to start recording. Please check microphone permissions.';
        _isRecording = false;
      });
      _stopRecordingTimer();
    }
  }

  Future<void> _stopRecording() async {
    if (_voiceService == null) return;
    try {
      final result = await _voiceService!.stop();
      _registerAudioView(result.objectUrl);
      setState(() {
        _voiceResult = result;
        _isRecording = false;
        if (_voiceTextController.text.isEmpty) {
          _voiceTextController.text = result.previewText;
        }
      });
      _stopRecordingTimer();
    } catch (e) {
      setState(() {
        _voiceError = 'Unable to stop recording. Please try again.';
        _isRecording = false;
      });
      _stopRecordingTimer();
    }
  }

  void _registerAudioView(String objectUrl) {
    if (!kIsWeb) return;
    final viewType = 'audio-player-${DateTime.now().millisecondsSinceEpoch}';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final audio = html.AudioElement()
        ..controls = true
        ..src = objectUrl;
      return audio;
    });
    setState(() {
      _audioViewType = viewType;
    });
  }

  Future<void> _submitVoiceTranscription(ChatProvider provider) async {
    final result = _voiceResult;
    if (result == null) return;
    setState(() => _isTranscribing = true);
    try {
      final response = await provider.transcribeAudio(
        audioBase64: _voiceService!.toBase64(result.bytes),
        audioFormat: result.mimeType,
        durationSeconds: result.durationSeconds,
        language: 'pt-BR',
        previewText: _voiceTextController.text.trim().isEmpty
            ? result.previewText
            : _voiceTextController.text.trim(),
        metadata: {
          'sourceApp': 'clinical-narrative',
        },
      );
      if (response != null && response.text.isNotEmpty) {
        _controller.text = response.text;
      }
    } catch (_) {
      setState(() {
        _voiceError = 'Transcription failed. Please edit the text manually.';
      });
    } finally {
      setState(() => _isTranscribing = false);
    }
  }

  Future<void> _editMessage(ChatProvider provider, ChatMessage message) async {
    final controller = TextEditingController(text: message.content);
    final updated = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(
          controller: controller,
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (updated != null && updated.isNotEmpty) {
      await provider.editMessage(message, updated);
    }
  }

  Widget _buildMessage(ChatMessage message, ChatProvider provider) {
    final isClinician = message.role == 'clinician';
    final alignment = isClinician ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final role = isClinician ? DsChatRole.clinician : DsChatRole.patient;
    final labelParts = <String>[isClinician ? 'Clinician' : 'Assistant'];
    if (message.messageType.isNotEmpty && message.messageType != 'user') {
      labelParts.add(message.messageType.toUpperCase());
    }
    final timestamp = _formatTime(message.createdAt);
    if (timestamp.isNotEmpty) {
      labelParts.add(timestamp);
    }

    return Column(
      crossAxisAlignment: alignment,
      children: [
        DsChatBubble(
          message: message.content,
          role: role,
          label: labelParts.join(' • '),
          isPending: message.isPending,
          hasError: message.hasError,
          deleted: message.deletedAt != null,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Copy message',
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () => Clipboard.setData(ClipboardData(text: message.content)),
            ),
            if (isClinician && message.deletedAt == null)
              IconButton(
                tooltip: 'Edit message',
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _editMessage(provider, message),
              ),
            if (isClinician && message.deletedAt == null)
              IconButton(
                tooltip: 'Delete message',
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () => provider.deleteMessage(message),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          final session = provider.session;
          final phase = session?.phase ?? 'intake';
          final analysisPhase = provider.analysisPhase;
          final isSessionCompleted = session?.status.toLowerCase() == 'completed';
          final inputEnabled = !provider.isOffline && !isSessionCompleted;
          final messageCount = provider.messages.length;

          if (messageCount > _lastMessageCount) {
            final newest = provider.messages.last;
            final speaker = newest.role == 'clinician' ? 'Clinician' : 'Assistant';
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              SemanticsService.sendAnnouncement(
                View.of(context),
                'New message from $speaker',
                Directionality.of(context),
              );
            });
          }
          _lastMessageCount = messageCount;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Clinical Conversation'),
              actions: [
                if (provider.isOffline)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: DsStatusIndicator(
                        label: 'Offline',
                        color: Theme.of(context).colorScheme.error,
                        liveRegion: true,
                      ),
                    ),
                  ),
              ],
            ),
            body: Column(
              children: [
                if (provider.isLoading)
                  const LinearProgressIndicator(minHeight: 2),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: _buildSessionHeader(provider, session, phase),
                  ),
                ),
                Expanded(
                  child: FocusTraversalOrder(
                    order: const NumericFocusOrder(2),
                    child: Semantics(
                      label: 'Conversation messages',
                      child: provider.messages.isEmpty
                          ? const DsEmpty(message: 'No messages yet.')
                          : ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: provider.messages.length,
                              itemBuilder: (context, index) {
                                final message = provider.messages[index];
                                return _buildMessage(message, provider);
                              },
                              separatorBuilder: (context, index) => const SizedBox(height: 4),
                            ),
                    ),
                  ),
                ),
                if (provider.alerts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: _InsightPanel(
                      title: 'Alerts',
                      items: provider.alerts
                          .map((item) => '${item['severity'] ?? 'info'}: ${item['text'] ?? ''}')
                          .toList(),
                    ),
                  ),
                if (provider.suggestions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: _InsightPanel(
                      title: 'Suggestions',
                      items: provider.suggestions
                          .map((item) => item['text']?.toString() ?? '')
                          .where((text) => text.isNotEmpty)
                          .toList(),
                    ),
                  ),
                if (provider.hypotheses.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: _InsightPanel(
                      title: 'Hypotheses',
                      items: provider.hypotheses
                          .map((item) => item['label']?.toString() ?? '')
                          .where((text) => text.isNotEmpty)
                          .toList(),
                    ),
                  ),
                if (provider.entities.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: _InsightPanel(
                      title: 'Entities',
                      items: provider.entities
                          .map((item) => '${item['type'] ?? ''}: ${item['value'] ?? ''}')
                          .toList(),
                    ),
                  ),
                if (provider.knowledge.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: _InsightPanel(
                      title: 'Knowledge',
                      items: provider.knowledge
                          .map((item) => item['label']?.toString() ?? '')
                          .where((text) => text.isNotEmpty)
                          .toList(),
                    ),
                  ),
                if (provider.isProcessing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: DsStatusIndicator(
                      label: 'Processing response...',
                      color: Theme.of(context).colorScheme.primary,
                      liveRegion: true,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      FocusTraversalOrder(
                        order: const NumericFocusOrder(3),
                        child: Row(
                          children: [
                            Semantics(
                              button: true,
                              label: _voiceMode ? 'Disable voice mode' : 'Enable voice mode',
                              child: IconButton(
                                icon: Icon(_voiceMode ? Icons.mic : Icons.mic_none),
                                tooltip: _voiceMode ? 'Disable voice mode' : 'Enable voice mode',
                                onPressed: inputEnabled
                                    ? () {
                                        setState(() => _voiceMode = !_voiceMode);
                                      }
                                    : null,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  labelText: 'Message',
                                  hintText: _voiceMode
                                      ? 'Voice mode enabled'
                                      : 'Type your message',
                                ),
                                minLines: 1,
                                maxLines: 4,
                                enabled: inputEnabled,
                                textInputAction: TextInputAction.send,
                                onSubmitted: inputEnabled ? (_) => _send(provider) : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            DsFilledButton(
                              label: 'Send',
                              onPressed: inputEnabled ? () => _send(provider) : null,
                            ),
                          ],
                        ),
                      ),
                      if (_voiceMode)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: FocusTraversalOrder(
                            order: const NumericFocusOrder(4),
                            child: _buildVoicePanel(provider, inputEnabled),
                          ),
                        ),
                      const SizedBox(height: 8),
                      FocusTraversalOrder(
                        order: const NumericFocusOrder(5),
                        child: Row(
                          children: [
                            DsOutlinedButton(
                              label: 'Generate Document',
                              onPressed: provider.isOffline ? null : () => _openDocumentDialog(provider),
                            ),
                            const SizedBox(width: 8),
                            DsOutlinedButton(
                              label: 'End Consultation',
                              onPressed: provider.isOffline || isSessionCompleted
                                  ? null
                                  : () => _confirmEndSession(provider),
                            ),
                            const Spacer(),
                            if (analysisPhase != null && analysisPhase.isNotEmpty)
                              Text('AI phase: $analysisPhase'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(item),
            ),
        ],
      ),
    );
  }
}
