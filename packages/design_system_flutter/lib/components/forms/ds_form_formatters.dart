import 'package:flutter/services.dart';

class DsFormFormatters {
  DsFormFormatters._();

  static List<TextInputFormatter> cpf() => <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ];

  static List<TextInputFormatter> cep() => <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(8),
      ];

  static List<TextInputFormatter> dateBr() => <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(8),
        const _DateBrInputFormatter(),
      ];

  static List<TextInputFormatter> phoneBr() => <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
        const _PhoneNumberInputFormatter(),
      ];

  static String digitsOnly(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String formatDateBr(String value) {
    final digits = digitsOnly(value);
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;
    final buffer = StringBuffer();

    for (var index = 0; index < limited.length; index += 1) {
      if (index == 2 || index == 4) {
        buffer.write('/');
      }
      buffer.write(limited[index]);
    }

    return buffer.toString();
  }
}

class _DateBrInputFormatter extends TextInputFormatter {
  const _DateBrInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = DsFormFormatters.formatDateBr(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _PhoneNumberInputFormatter extends TextInputFormatter {
  const _PhoneNumberInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = DsFormFormatters.digitsOnly(newValue.text);
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;

    final buffer = StringBuffer();
    for (var index = 0; index < limited.length; index += 1) {
      if (index == 0) {
        buffer.write('(');
      }
      if (index == 2) {
        buffer.write(') ');
      }
      if (index == 7) {
        buffer.write('-');
      }
      buffer.write(limited[index]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
