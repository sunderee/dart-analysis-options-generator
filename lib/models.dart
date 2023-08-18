import 'package:meta/meta.dart';

enum StyleEnum {
  core,
  recommended,
  flutter;

  static StyleEnum? fromSRCString(String input) {
    if (input.endsWith('style-core.svg')) {
      return StyleEnum.core;
    } else if (input.endsWith('style-recommended.svg')) {
      return StyleEnum.recommended;
    } else if (input.endsWith('style-flutter.svg')) {
      return StyleEnum.flutter;
    } else {
      return null;
    }
  }
}

@immutable
final class LinterRuleModel {
  final String title;
  final String description;
  final Set<StyleEnum> styles;
  final String? status;

  const LinterRuleModel(
    this.title,
    this.description,
    this.styles,
    this.status,
  );

  bool shouldBeEnabled(StyleEnum desiredStyle) {
    if (status != null) {
      return false;
    }

    return styles.contains(desiredStyle);
  }
}
