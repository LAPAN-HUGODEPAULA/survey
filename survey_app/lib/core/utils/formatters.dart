library;

class Formatters {
  static String surveyFileStem(String path) {
    return path.split('/').last.replaceAll('.json', '');
  }

  static String prettifySurveyName(String path) {
    final stem = surveyFileStem(path).replaceAll('_', ' ').replaceAll('-', ' ');
    return stem
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static String formatIsoDateBr(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final dt = DateTime.parse(date.replaceAll(' ', 'T'));
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year.toString();
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$d/$m/$y às $hh:$mm';
    } catch (_) {
      return date;
    }
  }
}
