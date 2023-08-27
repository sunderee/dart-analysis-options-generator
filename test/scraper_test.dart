import 'package:analysis_options_generator/models.dart';
import 'package:analysis_options_generator/scraper.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';

void main() {
  test('scraper', () async {
    final results = await scrapeLinterRules();

    final controlFlowInFinallyRule = results
        .firstWhereOrNull((item) => item.title == 'control_flow_in_finally');
    expect(controlFlowInFinallyRule, isNotNull);
    expect(
      controlFlowInFinallyRule?.title,
      equals('control_flow_in_finally'),
    );
    expect(
      controlFlowInFinallyRule?.description,
      equals('Avoid control flow in finally blocks.'),
    );
    expect(
      controlFlowInFinallyRule?.styles,
      containsAll([StyleEnum.recommended, StyleEnum.flutter]),
    );

    final useBuildContextSynchronouslyRule = results.firstWhereOrNull(
        (item) => item.title == 'use_build_context_synchronously');
    expect(useBuildContextSynchronouslyRule, isNotNull);
    expect(useBuildContextSynchronouslyRule?.status, '(Experimental)');
    expect(
      useBuildContextSynchronouslyRule?.shouldBeEnabled(StyleEnum.flutter),
      isFalse,
    );

    expect(results, isNotEmpty);
  });
}
