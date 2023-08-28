import 'dart:io';

import 'package:analysis_options_generator/models.dart';
import 'package:dart_scope_functions/dart_scope_functions.dart';

const _strictTypeSettings = r'''
analyzer:
  exclude: ["build/**"]
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
''';
const _linterRules = r'''
linter:
  rules:
''';

Future<bool> writeYamlFile(
  String absoluteFilePath,
  StyleEnum style,
  List<LinterRuleModel> linterRules,
) async {
  final yamlFileContents = _constructYamlFile(style, linterRules);

  try {
    final analysisOptionsFile = File(absoluteFilePath);
    await analysisOptionsFile.writeAsString(yamlFileContents);
    return true;
  } catch (_) {
    return false;
  }
}

String _constructYamlFile(StyleEnum style, List<LinterRuleModel> linterRules) {
  final stringBuffer = StringBuffer();

  // Import line + strict type settings
  final importLine = switch (style) {
    StyleEnum.core => 'include: package:lints/core.yaml',
    StyleEnum.recommended => 'include: package:lints/recommended.yaml',
    StyleEnum.flutter => 'include: package:flutter_lints/flutter.yaml',
  };
  stringBuffer.also((it) {
    it.writeln(importLine);
    it.writeln();
    it.writeln(_strictTypeSettings);
  });

  // Errors
  stringBuffer.writeln('  errors:');
  linterRules
      .map((item) => item.shouldBeEnabled(style)
          ? '    ${item.title}: error'
          : '    # ${item.title}: error')
      .forEach((item) => stringBuffer.writeln(item));
  stringBuffer.writeln();

  // Linter rules
  stringBuffer.writeln(_linterRules);
  for (var item in linterRules) {
    final ruleLine = item.shouldBeEnabled(style)
        ? '    - ${item.title}'
        : '    # - ${item.title}';

    stringBuffer.writeln('    # ${item.description}');
    stringBuffer.writeln(ruleLine);
    stringBuffer.writeln();
  }

  return stringBuffer.toString();
}
