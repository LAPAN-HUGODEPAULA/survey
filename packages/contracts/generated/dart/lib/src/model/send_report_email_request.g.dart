// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_report_email_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SendReportEmailRequest extends SendReportEmailRequest {
  @override
  final String? reportText;

  factory _$SendReportEmailRequest(
          [void Function(SendReportEmailRequestBuilder)? updates]) =>
      (SendReportEmailRequestBuilder()..update(updates))._build();

  _$SendReportEmailRequest._({this.reportText}) : super._();
  @override
  SendReportEmailRequest rebuild(
          void Function(SendReportEmailRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SendReportEmailRequestBuilder toBuilder() =>
      SendReportEmailRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SendReportEmailRequest && reportText == other.reportText;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reportText.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SendReportEmailRequest')
          ..add('reportText', reportText))
        .toString();
  }
}

class SendReportEmailRequestBuilder
    implements Builder<SendReportEmailRequest, SendReportEmailRequestBuilder> {
  _$SendReportEmailRequest? _$v;

  String? _reportText;
  String? get reportText => _$this._reportText;
  set reportText(String? reportText) => _$this._reportText = reportText;

  SendReportEmailRequestBuilder() {
    SendReportEmailRequest._defaults(this);
  }

  SendReportEmailRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reportText = $v.reportText;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SendReportEmailRequest other) {
    _$v = other as _$SendReportEmailRequest;
  }

  @override
  void update(void Function(SendReportEmailRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SendReportEmailRequest build() => _build();

  _$SendReportEmailRequest _build() {
    final _$result = _$v ??
        _$SendReportEmailRequest._(
          reportText: reportText,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
