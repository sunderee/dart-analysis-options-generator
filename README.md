# Analysis Options Generator

Dart-based CLI tool for automatically populating analysis_options.yaml file with all the available linting rules described by the [official documentation](https://dart.dev/tools/linter-rules).

**Motivation**: although VSCode has superb auto-complete functionality through Dart/Flutter plugins, newly generated Dart/Flutter projects are missing analysis options file with pre-populated linting rules and their explanations (similar to how TypeScript does it with `tsconfig.json`). As a result, many developers don't configure their linter following best practices, and manual configuration takes time.

This is an opinionated generator and will set the severity to every enabled rule to `error`.

## Usage

First, fetch dependencies and compile the app to a self-contained executable:

```bash
dart pub get
dart compile exe --output=analysis-options bin/analysis_options_generator.dart
```

Use `-h/--help` to learn how to use the package:

```
$ ./analysis-options --help
-p, --path (mandatory)     Absolute path to the analysis_options.yaml file.
-s, --style (mandatory)    Which style rules are you generating analysis options for?
                           [core, recommended, flutter]
-h, --[no-]help            Show the usage syntax.
```