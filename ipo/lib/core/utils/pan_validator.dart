class PanValidator {
  static final RegExp _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

  static bool isValid(String? pan) {
    if (pan == null || pan.trim().isEmpty) return false;
    return _panRegex.hasMatch(pan.trim().toUpperCase());
  }

  static String mask(String pan) {
    final clean = pan.trim().toUpperCase();
    if (clean.length != 10) return '**********';
    return '${clean.substring(0, 5)}****${clean.substring(9)}';
  }
}
