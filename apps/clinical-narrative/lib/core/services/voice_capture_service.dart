library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

import 'package:clinical_narrative_app/core/services/js_interop.dart' as js_interop;

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
  html.MediaRecorder? _recorder;
  final List<html.Blob> _chunks = [];
  Timer? _durationTimer;
  int _elapsedSeconds = 0;

  dynamic _speechRecognition;
  final StreamController<String> _previewController = StreamController.broadcast();
  final StreamController<String> _errorController = StreamController.broadcast();
  String _previewText = '';

  Stream<String> get previewStream => _previewController.stream;
  Stream<String> get errorStream => _errorController.stream;
  bool get isRecording => _recorder?.state == 'recording';

  Future<void> start() async {
    if (!kIsWeb) {
      throw UnsupportedError('Voice capture is only supported on web.');
    }
    _chunks.clear();
    _previewText = '';
    _elapsedSeconds = 0;

    final mediaDevices = html.window.navigator.mediaDevices;
    if (mediaDevices == null) {
      throw StateError('Media devices unavailable.');
    }
    final stream = await mediaDevices.getUserMedia({'audio': true});
    _recorder = html.MediaRecorder(stream, {'mimeType': config.mimeType});
    _recorder?.addEventListener('dataavailable', (event) {
      final data = (event as html.BlobEvent).data;
      if (data != null) {
        _chunks.add(data);
      }
    });
    _recorder?.addEventListener('stop', (_) {
      stream.getTracks().forEach((track) => track.stop());
    });
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

    final blob = html.Blob(_chunks, config.mimeType);
    final bytes = await _readBlob(blob);
    final objectUrl = html.Url.createObjectUrlFromBlob(blob);
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
    final window = html.window;
    return js_interop.hasProperty(window, 'SpeechRecognition') ||
        js_interop.hasProperty(window, 'webkitSpeechRecognition');
  }

  void _startPreview() {
    if (!isPreviewAvailable) {
      _previewController.add('Preview unavailable in this browser.');
      return;
    }
    final window = html.window;
    final ctor = js_interop.hasProperty(window, 'SpeechRecognition')
        ? js_interop.getProperty(window, 'SpeechRecognition')
        : js_interop.getProperty(window, 'webkitSpeechRecognition');
    _speechRecognition = js_interop.callConstructor(ctor, []);
    js_interop.setProperty(_speechRecognition, 'continuous', true);
    js_interop.setProperty(_speechRecognition, 'interimResults', true);
    js_interop.setProperty(_speechRecognition, 'lang', config.language);

    js_interop.setProperty(_speechRecognition, 'onresult', js_interop.allowInterop((event) {
      final results = js_interop.getProperty(event, 'results');
      final length = js_interop.getProperty(results, 'length') as int? ?? 0;
      if (length == 0) return;
      final result = js_interop.getProperty(results, length - 1);
      final alternative = js_interop.getProperty(result, 0);
      final transcript = js_interop.getProperty(alternative, 'transcript')?.toString() ?? '';
      if (transcript.isNotEmpty) {
        _previewText = transcript;
        _previewController.add(_previewText);
      }
    }));

    js_interop.setProperty(_speechRecognition, 'onerror', js_interop.allowInterop((event) {
      final error = js_interop.getProperty(event, 'error')?.toString() ?? 'speech_error';
      _errorController.add(error);
    }));

    js_interop.callMethod(_speechRecognition, 'start', []);
  }

  void _stopPreview() {
    if (_speechRecognition != null) {
      try {
        js_interop.callMethod(_speechRecognition, 'stop', []);
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

  Future<Uint8List> _readBlob(html.Blob blob) {
    final completer = Completer<Uint8List>();
    final reader = html.FileReader();
    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result is ByteBuffer) {
        completer.complete(Uint8List.view(result));
      } else if (result is Uint8List) {
        completer.complete(result);
      } else {
        completer.complete(Uint8List(0));
      }
    });
    reader.onError.listen((_) {
      completer.complete(Uint8List(0));
    });
    reader.readAsArrayBuffer(blob);
    return completer.future;
  }
}
