import 'package:analysis_options_generator/scraper.dart';
import 'package:test/test.dart';

void main() {
  test('scraper', () async {
    final results = await scrapeLinterRules();
    expect(results, isNotEmpty);
  });
}
