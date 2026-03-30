// Display & loose input helpers for Indonesian Rupiah (integer, no sen).

num? coerceNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString());
}

// e.g. `25000` -> `Rp25.000`; `null` -> `''`.
String formatRupiah(num? value) {
  if (value == null) return '';
  var n = value.round();
  if (n == 0) return 'Rp0';
  final neg = n < 0;
  if (neg) n = -n;

  final parts = <String>[];
  var rest = n;
  while (rest > 999) {
    parts.add((rest % 1000).toString().padLeft(3, '0'));
    rest ~/= 1000;
  }
  parts.add(rest.toString());
  final core = parts.reversed.join('.');
  return '${neg ? '-' : ''}Rp$core';
}

/// Parses typed price: strips spaces, dots (ribuan), commas. No decimal fraction.
num? parseIdrPriceInput(String raw) {
  var t = raw.trim();
  if (t.isEmpty) return null;
  t = t.replaceAll(RegExp(r'\s'), '');
  // Allow user inputs like "Rp25.000" / "25.000" / "25,000".
  // We only support integer (no decimals) for inventory price.
  t = t.replaceAll(RegExp(r'[^0-9-]'), '');
  if (t.isEmpty) return null;
  return num.tryParse(t);
}
