import 'package:analysis_options_generator/scraper.dart';
import 'package:test/test.dart';

void main() {
  test('scraper', () async {
    await scrapeLinterRules();

    expect(2 + 2, equals(4));
  });
}
