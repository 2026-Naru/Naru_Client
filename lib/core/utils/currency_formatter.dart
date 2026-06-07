class CurrencyFormatter {
  static const double krwPerUsd = 1350.5;

  const CurrencyFormatter._();

  static String formatKrw(num krw) {
    final value = krw / krwPerUsd;
    final sign = value < 0 ? '-' : '';
    return '$sign\$${value.abs().toStringAsFixed(2)}';
  }

  static String krwTextToUsd(String text) {
    return text.replaceAllMapped(
      RegExp(r'([+-]?\s*)?₩\s*([\d,]+)(?:\(~([\d,]+)\))?'),
      (match) {
        final prefix = match.group(1) ?? '';
        final first = _parseKrw(match.group(2)!);
        final second = match.group(3);
        final converted = '$prefix${formatKrw(first)}';
        if (second == null) return converted;
        return '$converted(~${formatKrw(_parseKrw(second))})';
      },
    );
  }

  static int _parseKrw(String value) {
    return int.parse(value.replaceAll(',', ''));
  }
}
