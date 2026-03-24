
import 'dart:ui_web' as ui;

import 'package:web/web.dart' as web;

String registerAudioView(String objectUrl) {
  final viewType = 'audio-player-${DateTime.now().millisecondsSinceEpoch}';
  ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final audio = web.HTMLAudioElement()
      ..controls = true
      ..src = objectUrl;
    return audio;
  });
  return viewType;
}
