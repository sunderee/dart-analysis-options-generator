import 'dart:io';

import 'package:analysis_options_generator/analysis_options_generator.dart';
import 'package:args/args.dart';
import 'package:dart_scope_functions/dart_scope_functions.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'path',
      abbr: 'p',
      mandatory: true,
      help: 'Absolute path to the analysis_options.yaml file.',
    )
    ..addOption(
      'style',
      abbr: 's',
      mandatory: true,
      allowed: ['core', 'recommended', 'flutter'],
      help: 'Which style rules are you generating analysis options for?',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show the usage syntax.',
    );

  try {
    final results = parser.parse(arguments);
    if (results.wasParsed('help')) {
      print(parser.usage);
      exit(0);
    }

    final path = results['path'] as String?;
    if (path == null) {
      print(_red('Option path is mandatory.'));
      exit(1);
    }

    if (path.isEmpty) {
      print(_red('Option path cannot be empty.'));
      exit(1);
    }

    final desiredStyle =
        (results['style'] as String?)?.let((it) => StyleEnum.fromString(it));
    if (desiredStyle == null) {
      print(_red('Desired style is missing'));
      exit(1);
    }

    print(_yellow('Starting the job...'));
    print(_yellow('  1. Scrape linting rules'));
    final rules = await scrapeLinterRules();

    print(_yellow('  2. Write to YAML file'));
    final yamlWriteResult = await writeYamlFile(path, desiredStyle, rules);

    if (yamlWriteResult) {
      print(_green('Done!'));
    } else {
      print(_red('Error!!!'));
    }
    exit(0);
  } on FormatException catch (_) {
    print(_red('Something went wrong'));
    exit(1);
  }
}

String _red(String message) => '\u001b[31m$message\u001b[0m';
String _green(String message) => '\u001b[32m$message\u001b[0m';
String _yellow(String message) => '\u001b[33m$message\u001b[0m';
