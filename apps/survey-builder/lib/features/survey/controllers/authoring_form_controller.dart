import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/foundation.dart';

abstract class AuthoringFormController extends ChangeNotifier {
  bool _saving = false;
  bool _isDirty = false;
  bool _hasSubmitted = false;
  DsFeedbackMessage? _feedback;

  bool get saving => _saving;
  bool get isDirty => _isDirty;
  bool get hasSubmitted => _hasSubmitted;
  DsFeedbackMessage? get feedback => _feedback;

  void markSubmitted() {
    _hasSubmitted = true;
    notifyListeners();
  }

  void markDirty() {
    if (_isDirty) {
      return;
    }
    _isDirty = true;
    notifyListeners();
  }

  void clearDirty() {
    if (!_isDirty) {
      return;
    }
    _isDirty = false;
    notifyListeners();
  }

  void setSaving(bool value) {
    if (_saving == value) {
      return;
    }
    _saving = value;
    notifyListeners();
  }

  void setFeedback(DsFeedbackMessage? feedback) {
    _feedback = feedback;
    notifyListeners();
  }

  void clearFeedback() => setFeedback(null);
}
