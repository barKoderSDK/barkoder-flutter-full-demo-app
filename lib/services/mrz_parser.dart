class MRZParser {
  static List<Map<String, String>> parse(String text) {
    final fields = <Map<String, String>>[];
    final lines = text.split('\n');

    for (final line in lines) {
      final match = RegExp(r'^([^:]+):\s*(.+)$').firstMatch(line);
      if (match != null) {
        final key = match.group(1)?.trim() ?? '';
        final value = match.group(2)?.trim() ?? '';
        final label = key
            .split('_')
            .map((word) =>
                word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
            .join(' ');
        fields.add({'id': key, 'label': label, 'value': value});
      }
    }

    return fields;
  }

  static bool isMRZ(String type) {
    return type.toLowerCase() == 'mrz' ||
        type.toLowerCase() == 'iddocument' ||
        type.toLowerCase() == 'id document';
  }
}
