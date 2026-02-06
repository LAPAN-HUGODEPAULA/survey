library;

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:clinical_narrative_app/core/models/chat_message.dart';
import 'package:clinical_narrative_app/core/models/chat_session.dart';
import 'package:clinical_narrative_app/core/models/document_models.dart';
import 'package:clinical_narrative_app/core/models/template_models.dart';
import 'package:clinical_narrative_app/core/models/transcription_models.dart';
import 'package:clinical_narrative_app/core/services/api_config.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({Dio? client})
      : _client = client ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.dioBaseUrl,
                headers: ApiConfig.defaultHeaders,
              ),
            );

  final Dio _client;
  ChatSession? _session;
  final List<ChatMessage> _messages = [];
  final List<_PendingMessage> _pendingQueue = [];
  WebSocketChannel? _channel;
  StreamSubscription<html.Event>? _onlineSub;
  StreamSubscription<html.Event>? _offlineSub;
  Timer? _analysisDebounce;

  bool _isLoading = false;
  bool _isOffline = false;
  bool _isProcessing = false;
  String? _error;
  List<Map<String, dynamic>> _suggestions = [];
  List<Map<String, dynamic>> _alerts = [];
  List<Map<String, dynamic>> _entities = [];
  List<Map<String, dynamic>> _hypotheses = [];
  List<Map<String, dynamic>> _knowledge = [];
  String? _analysisPhase;
  DocumentPreview? _documentPreview;
  List<TemplateRecord> _templates = [];
  TemplatePreview? _templatePreview;
  TranscriptionResponse? _transcription;

  ChatSession? get session => _session;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  List<Map<String, dynamic>> get suggestions => List.unmodifiable(_suggestions);
  List<Map<String, dynamic>> get alerts => List.unmodifiable(_alerts);
  List<Map<String, dynamic>> get entities => List.unmodifiable(_entities);
  List<Map<String, dynamic>> get hypotheses => List.unmodifiable(_hypotheses);
  List<Map<String, dynamic>> get knowledge => List.unmodifiable(_knowledge);
  String? get analysisPhase => _analysisPhase;
  DocumentPreview? get documentPreview => _documentPreview;
  List<TemplateRecord> get templates => List.unmodifiable(_templates);
  TemplatePreview? get templatePreview => _templatePreview;
  TranscriptionResponse? get transcription => _transcription;

  Future<List<Map<String, dynamic>>> fetchTemplateDocumentTypes() async {
    final response = await _client.get<List<dynamic>>('/templates/document-types');
    final data = response.data;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<List<TemplateRecord>> fetchTemplates({
    String? documentType,
    String? query,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '/templates',
      queryParameters: {
        if (documentType != null && documentType.isNotEmpty) 'documentType': documentType,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );
    final data = response.data;
    if (data is! List) return const [];
    _templates = data
        .whereType<Map>()
        .map((item) => TemplateRecord.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    notifyListeners();
    return _templates;
  }

  Future<TemplatePreview?> previewTemplate({
    required String templateId,
    Map<String, dynamic>? sampleData,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/templates/$templateId/preview',
      data: {
        if (sampleData != null) 'sampleData': sampleData,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      _templatePreview = TemplatePreview.fromJson(data);
      notifyListeners();
      return _templatePreview;
    }
    return null;
  }

  Future<TranscriptionResponse?> transcribeAudio({
    required String audioBase64,
    required String audioFormat,
    int? sampleRate,
    int? channels,
    int? durationSeconds,
    String? language,
    bool clinicalMode = true,
    double? confidenceThreshold,
    String? previewText,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/voice/transcriptions',
      data: {
        'audioBase64': audioBase64,
        'audioFormat': audioFormat,
        if (sampleRate != null) 'sampleRate': sampleRate,
        if (channels != null) 'channels': channels,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
        if (language != null) 'language': language,
        'clinicalMode': clinicalMode,
        if (confidenceThreshold != null) 'confidenceThreshold': confidenceThreshold,
        if (previewText != null) 'previewText': previewText,
        if (metadata != null) 'metadata': metadata,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      _transcription = TranscriptionResponse.fromJson(data);
      notifyListeners();
      return _transcription;
    }
    return null;
  }

  Future<void> initialize({String? patientId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _setupConnectivityListeners();

    try {
      final recovered = await _recoverSession();
      if (recovered != null) {
        _session = recovered;
      } else {
        _session = await _createSession(patientId: patientId);
      }
      await _loadMessages();
      await _connectWebSocket();
      _scheduleAnalysis();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePhase(String phase) async {
    if (_session == null) return;
    final response = await _client.patch<Map<String, dynamic>>(
      '/chat/sessions/${_session!.id}',
      data: {'phase': phase},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      _session = ChatSession.fromJson(data);
      notifyListeners();
    }
  }

  Future<void> completeSession() async {
    if (_session == null) return;
    final response = await _client.post<Map<String, dynamic>>(
      '/chat/sessions/${_session!.id}/complete',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      _session = ChatSession.fromJson(data);
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    if (_session == null || content.trim().isEmpty) return;
    final trimmed = content.trim();
    final pending = _PendingMessage(
      tempId: 'temp-${DateTime.now().microsecondsSinceEpoch}',
      content: trimmed,
    );
    final pendingMessage = ChatMessage(
      id: pending.tempId,
      sessionId: _session!.id,
      role: 'clinician',
      messageType: 'user',
      content: trimmed,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      isPending: true,
    );
    _messages.add(pendingMessage);
    _isProcessing = true;
    notifyListeners();

    if (_isOffline) {
      _pendingQueue.add(pending);
      return;
    }

    await _sendPending(pending);
    _scheduleAnalysis();
  }

  Future<DocumentPreview?> generateDocumentPreview({
    required String documentType,
    String? title,
    String? body,
  }) async {
    if (_session == null) return null;
    final response = await _client.post<Map<String, dynamic>>(
      '/documents/preview',
      data: {
        'sessionId': _session!.id,
        'documentType': documentType,
        if (title != null) 'title': title,
        if (body != null) 'body': body,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      _documentPreview = DocumentPreview.fromJson(data);
      notifyListeners();
      return _documentPreview;
    }
    return null;
  }

  Future<DocumentRecord?> exportDocument({
    required String documentType,
    required String title,
    required String body,
  }) async {
    if (_session == null) return null;
    final response = await _client.post<Map<String, dynamic>>(
      '/documents/export',
      data: {
        'sessionId': _session!.id,
        'documentType': documentType,
        'title': title,
        'body': body,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return DocumentRecord.fromJson(data);
    }
    return null;
  }

  Future<void> editMessage(ChatMessage message, String content) async {
    if (message.id.startsWith('temp-')) return;
    final response = await _client.patch<Map<String, dynamic>>(
      '/chat/messages/${message.id}',
      data: {'content': content},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      _replaceMessage(ChatMessage.fromJson(data));
    }
  }

  Future<void> deleteMessage(ChatMessage message) async {
    if (message.id.startsWith('temp-')) {
      _messages.removeWhere((item) => item.id == message.id);
      notifyListeners();
      return;
    }
    final response = await _client.delete<Map<String, dynamic>>(
      '/chat/messages/${message.id}',
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      _replaceMessage(ChatMessage.fromJson(data));
    }
  }

  void disposeConnections() {
    _channel?.sink.close();
    _onlineSub?.cancel();
    _offlineSub?.cancel();
    _analysisDebounce?.cancel();
  }

  @override
  void dispose() {
    disposeConnections();
    super.dispose();
  }

  Future<ChatSession> _createSession({String? patientId}) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/chat/sessions',
      data: {
        if (patientId != null && patientId.isNotEmpty) 'patientId': patientId,
      },
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid session response');
    }
    final session = ChatSession.fromJson(data);
    _storeSessionId(session.id);
    return session;
  }

  Future<ChatSession?> _recoverSession() async {
    final storedId = _readSessionId();
    if (storedId == null) return null;
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/chat/sessions/$storedId',
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      final session = ChatSession.fromJson(data);
      if (session.status == 'completed') {
        _clearSessionId();
        return null;
      }
      return session;
    } catch (_) {
      _clearSessionId();
      return null;
    }
  }

  Future<void> _loadMessages() async {
    if (_session == null) return;
    final response = await _client.get<List<dynamic>>(
      '/chat/sessions/${_session!.id}/messages',
    );
    final data = response.data ?? [];
    _messages
      ..clear()
      ..addAll(
        data
            .whereType<Map<String, dynamic>>()
            .map(ChatMessage.fromJson),
      );
    _scheduleAnalysis();
  }

  Future<void> _connectWebSocket() async {
    if (_session == null) return;
    final wsUrl = _buildWebSocketUrl(_session!.id);
    _channel?.sink.close();
    _channel = WebSocketChannel.connect(wsUrl);
    _channel!.stream.listen(
      (event) {
        if (event is Map) {
          _handleWsEvent(Map<String, dynamic>.from(event));
        } else if (event is String) {
          try {
            final data = jsonDecode(event);
            if (data is Map<String, dynamic>) {
              _handleWsEvent(data);
            }
          } catch (_) {}
        }
      },
      onError: (_) {},
      onDone: () {},
    );
  }

  void _handleWsEvent(Map<String, dynamic> payload) {
    final type = payload['type'];
    final messageData = payload['message'];
    if (messageData is Map<String, dynamic>) {
      final message = ChatMessage.fromJson(messageData);
      if (type == 'message_created') {
        _replaceMessage(message, allowAppend: true);
      } else if (type == 'message_updated' || type == 'message_deleted') {
        _replaceMessage(message);
      }
      if (message.role != 'clinician') {
        _isProcessing = false;
      }
      notifyListeners();
      _scheduleAnalysis();
    }
  }

  Future<void> _sendPending(_PendingMessage pending) async {
    if (_session == null) return;
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/chat/sessions/${_session!.id}/messages',
        data: {
          'role': 'clinician',
          'messageType': 'user',
          'content': pending.content,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final message = ChatMessage.fromJson(data);
        _messages.removeWhere((item) => item.id == pending.tempId);
        _replaceMessage(message);
      }
      _pendingQueue.removeWhere((item) => item.tempId == pending.tempId);
    } catch (_) {
      _markPendingError(pending.tempId);
      _pendingQueue.add(pending);
    }
  }

  void _markPendingError(String tempId) {
    final index = _messages.indexWhere((msg) => msg.id == tempId);
    if (index == -1) return;
    _messages[index] = _messages[index].copyWith(hasError: true);
    notifyListeners();
  }

  void _replaceMessage(ChatMessage message, {bool allowAppend = false}) {
    final index = _messages.indexWhere((msg) => msg.id == message.id);
    if (index == -1) {
      if (allowAppend) {
        _messages.add(message);
      }
      return;
    }
    _messages[index] = message;
    notifyListeners();
  }

  void _scheduleAnalysis() {
    _analysisDebounce?.cancel();
    _analysisDebounce = Timer(const Duration(milliseconds: 500), _refreshAnalysis);
  }

  Future<void> _refreshAnalysis() async {
    if (_session == null || _messages.isEmpty) return;
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/clinical_writer/analysis',
        data: {
          'sessionId': _session!.id,
          'phase': _session!.phase,
          'messages': _messages
              .where((msg) => msg.deletedAt == null)
              .map(
                (msg) => {
                  'role': msg.role,
                  'content': msg.content,
                  'messageType': msg.messageType,
                },
              )
              .toList(),
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        _suggestions = _castList(data['suggestions']);
        _alerts = _castList(data['alerts']);
        _entities = _castList(data['entities']);
        _hypotheses = _castList(data['hypotheses']);
        _knowledge = _castList(data['knowledge']);
        _analysisPhase = data['phase']?.toString();
        notifyListeners();
      }
    } catch (_) {
      // analysis errors should not block chat flow
    }
  }

  List<Map<String, dynamic>> _castList(Object? raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }

  Uri _buildWebSocketUrl(String sessionId) {
    final rawBase = ApiConfig.baseUrl;
    final parsed = Uri.parse(rawBase);
    final resolvedBase = parsed.hasScheme ? parsed : Uri.base.resolve(rawBase);
    final wsUri = resolvedBase.resolve('chat/sessions/$sessionId/ws');
    final scheme = wsUri.scheme == 'https' ? 'wss' : 'ws';
    return wsUri.replace(scheme: scheme);
  }

  void _setupConnectivityListeners() {
    if (!kIsWeb) return;
    _isOffline = !(html.window.navigator.onLine ?? true);
    _onlineSub?.cancel();
    _offlineSub?.cancel();
    _onlineSub = html.window.onOnline.listen((_) {
      _isOffline = false;
      _retryPending();
      notifyListeners();
    });
    _offlineSub = html.window.onOffline.listen((_) {
      _isOffline = true;
      notifyListeners();
    });
  }

  Future<void> _retryPending() async {
    if (_pendingQueue.isEmpty) return;
    final queued = List<_PendingMessage>.from(_pendingQueue);
    _pendingQueue.clear();
    for (final item in queued) {
      await _sendPending(item);
    }
  }

  String? _readSessionId() {
    if (!kIsWeb) return null;
    return html.window.localStorage['clinical_narrative_chat_session_id'];
  }

  void _storeSessionId(String sessionId) {
    if (!kIsWeb) return;
    html.window.localStorage['clinical_narrative_chat_session_id'] = sessionId;
  }

  void _clearSessionId() {
    if (!kIsWeb) return;
    html.window.localStorage.remove('clinical_narrative_chat_session_id');
  }
}

class _PendingMessage {
  _PendingMessage({required this.tempId, required this.content});

  final String tempId;
  final String content;
}
