
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:clinical_narrative_app/core/services/js_interop.dart' as js_interop;
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class VoiceCaptureConfig {
  const VoiceCaptureConfig({
    this.mimeType = 'audio/webm',
    this.maxDurationSeconds = 120,
    this.language = 'pt-BR',
  });

  final String mimeType;
  final int maxDurationSeconds;
  final String language;
}

class VoiceCaptureResult {
  VoiceCaptureResult({
    required this.bytes,
    required this.mimeType,
    required this.durationSeconds,
    required this.previewText,
    required this.objectUrl,
  });

  final Uint8List bytes;
  final String mimeType;
  final int durationSeconds;
  final String previewText;
  final String objectUrl;
}

class VoiceCaptureService {
  VoiceCaptureService({VoiceCaptureConfig? config})
      : config = config ?? const VoiceCaptureConfig();

  final VoiceCaptureConfig config;
  web.MediaRecorder? _recorder;
  final List<web.Blob> _chunks = [];
  Timer? _durationTimer;
  int _elapsedSeconds = 0;

  web.SpeechRecognition? _speechRecognition;
  final StreamController<String> _previewController = StreamController.broadcast();
  final StreamController<String> _errorController = StreamController.broadcast();
  String _previewText = '';

  Stream<String> get previewStream => _previewController.stream;
  Stream<String> get errorStream => _errorController.stream;
  bool get isRecording => _recorder?.state == 'recording';

  Future<void> start() async {
    if (!kIsWeb) {
      throw UnsupportedError('A captura de voz é compatível apenas na web.');
    }
    _chunks.clear();
    _previewText = '';
    _elapsedSeconds = 0;

    final mediaDevices = web.window.navigator.mediaDevices;
    final constraints = web.MediaStreamConstraints(audio: true.toJS);
    final stream = await mediaDevices.getUserMedia(constraints).toDart;
    _recorder = web.MediaRecorder(
      stream,
      web.MediaRecorderOptions(mimeType: config.mimeType),
    );
    _recorder?.addEventListener(
      'dataavailable',
      ((web.Event event) {
        final data = (event as web.BlobEvent).data;
        _chunks.add(data);
      }).toJS,
    );
    _recorder?.addEventListener(
      'stop',
      ((web.Event _) {
        for (final track in stream.getTracks().toDart) {
          track.stop();
        }
      }).toJS,
    );
    _recorder?.start();
    _startPreview();
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds += 1;
      if (_elapsedSeconds >= config.maxDurationSeconds) {
        stop();
      }
    });
  }

  Future<VoiceCaptureResult> stop() async {
    _durationTimer?.cancel();
    _stopPreview();
    _recorder?.stop();

    final parts = _chunks.map((chunk) => chunk as web.BlobPart).toList().toJS;
    final blob = web.Blob(parts, web.BlobPropertyBag(type: config.mimeType));
    final bytes = await _readBlob(blob);
    final objectUrl = web.URL.createObjectURL(blob);
    return VoiceCaptureResult(
      bytes: bytes,
      mimeType: config.mimeType,
      durationSeconds: _elapsedSeconds,
      previewText: _previewText,
      objectUrl: objectUrl,
    );
  }

  String toBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  bool get isPreviewAvailable {
    if (!kIsWeb) return false;
    final window = web.window;
    return js_interop.hasProperty(window, 'SpeechRecognition') ||
        js_interop.hasProperty(window, 'webkitSpeechRecognition');
  }

  void _startPreview() {
    if (!isPreviewAvailable) {
      _previewController.add('Pré-visualização indisponível neste navegador.');
      return;
    }
    final window = web.window;
    final ctor = js_interop.hasProperty(window, 'SpeechRecognition')
        ? js_interop.getProperty<JSFunction?>(window, 'SpeechRecognition')
        : js_interop.getProperty<JSFunction?>(window, 'webkitSpeechRecognition');
    final recognitionObject = js_interop.callConstructor(ctor, []);
    if (recognitionObject == null) {
      _previewController.add('Pré-visualização indisponível neste navegador.');
      return;
    }
    _speechRecognition = recognitionObject as web.SpeechRecognition;
    _speechRecognition!
      ..continuous = true
      ..interimResults = true
      ..lang = config.language;

    void onResult(web.Event event) {
      final resultEvent = event as web.SpeechRecognitionEvent;
      final results = resultEvent.results;
      if (results.length == 0) return;
      final result = results.item(results.length - 1);
      final alternative = result.item(0);
      final transcript = alternative.transcript;
      if (transcript.isNotEmpty) {
        _previewText = transcript;
        _previewController.add(_previewText);
      }
    }
    _speechRecognition!.onresult = onResult.toJS as web.EventHandler;

    void onError(web.Event event) {
      final errorEvent = event as web.SpeechRecognitionErrorEvent;
      final error = errorEvent.error;
      _errorController.add(error);
    }
    _speechRecognition!.onerror = onError.toJS as web.EventHandler;

    _speechRecognition!.start();
  }

  void _stopPreview() {
    if (_speechRecognition != null) {
      try {
        _speechRecognition!.stop();
      } catch (_) {}
    }
    _speechRecognition = null;
  }

  void dispose() {
    _durationTimer?.cancel();
    _stopPreview();
    _previewController.close();
    _errorController.close();
  }

  Future<Uint8List> _readBlob(web.Blob blob) async {
    try {
      final jsBuffer = await blob.arrayBuffer().toDart;
      final buffer = jsBuffer.toDart;
      return Uint8List.view(buffer);
    } catch (_) {
      return Uint8List(0);
    }
  }
}
