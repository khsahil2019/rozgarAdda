import 'dart:convert';
import 'dart:io';

void main() {
  final l10nDir = Directory('lib/l10n');
  if (!l10nDir.existsSync()) {
    print('Error: lib/l10n directory does not exist');
    exit(1);
  }

  final files = l10nDir.listSync().whereType<File>().where((f) => f.path.endsWith('.arb'));
  final Map<String, Map<String, String>> localizedValues = {};

  for (final file in files) {
    final name = file.uri.pathSegments.last;
    final langCode = name.replaceAll('app_', '').replaceAll('.arb', '');
    
    final content = file.readAsStringSync();
    final Map<String, dynamic> jsonMap = jsonDecode(content);
    
    final Map<String, String> translations = {};
    jsonMap.forEach((key, value) {
      if (!key.startsWith('@') && value is String) {
        translations[key] = value;
      }
    });
    
    localizedValues[langCode] = translations;
  }

  // Generate Dart code representation
  final buffer = StringBuffer();
  buffer.writeln('  static const Map<String, Map<String, String>> _localizedValues = {');
  
  // Sort languages for deterministic generation
  final sortedLangs = localizedValues.keys.toList()..sort();
  for (final lang in sortedLangs) {
    buffer.writeln("    '$lang': {");
    final translations = localizedValues[lang]!;
    final sortedKeys = translations.keys.toList()..sort();
    for (final key in sortedKeys) {
      final escapedVal = translations[key]!
          .replaceAll('\\', '\\\\')
          .replaceAll("'", "\\'")
          .replaceAll('\n', '\\n')
          .replaceAll('\r', '\\r');
      buffer.writeln("      '$key': '$escapedVal',");
    }
    buffer.writeln('    },');
  }
  buffer.writeln('  };');

  final targetFile = File('lib/localization/app_localizations.dart');
  if (!targetFile.existsSync()) {
    print('Error: Target file not found');
    exit(1);
  }

  var code = targetFile.readAsStringSync();
  final startTag = '// {{GENERATED_LOCALIZED_VALUES_START}}';
  final endTag = '// {{GENERATED_LOCALIZED_VALUES_END}}';
  
  final startIndex = code.indexOf(startTag);
  final endIndex = code.indexOf(endTag);
  
  if (startIndex == -1 || endIndex == -1) {
    print('Error: Placeholder tags not found in app_localizations.dart');
    exit(1);
  }
  
  final newCode = code.replaceRange(
    startIndex + startTag.length,
    endIndex,
    '\n${buffer.toString()}\n  ',
  );
  
  targetFile.writeAsStringSync(newCode);
  print('Successfully generated translations in app_localizations.dart');
}
