import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:html/parser.dart';

/// Initiates scraping of all the Dart/Flutter linter rules and parses the
/// results into a model for future processing.
Future<void> scrapeLinterRules() async {
  final linterRulesRawHTML = await _fetchHTMLOfLinterRules();
  final lintRuleCandidatesList = parse(linterRulesRawHTML)
          .querySelector('#page-content > article > div')
          ?.children ??
      [];

  for (int i = 0; i < lintRuleCandidatesList.length; i++) {
    final item = lintRuleCandidatesList[i];

    // A linter rule node is identified by being a <p> tag, with a single child
    // node that's an <a> tag which has an attribute `id` that only contains
    // lowercase characters and underscores.
    if (item.localName == 'p' &&
        item.children.length == 1 &&
        item.children.firstOrNull?.localName == 'a' &&
        item.children.firstOrNull?.attributes['id']
                ?.let((it) => RegExp(r'^[a-z\_]*$').hasMatch(it)) ==
            true) {
      // Title is the contents of the <a> tag's `id` attribute.
      final title = item.children.firstOrNull?.attributes['id'];

      // For other values, we need to consult the next element in the
      // `linkRuleCandidatesList`.
      final description =
          lintRuleCandidatesList[i + 1].children.map((e) => e.innerHtml.trim());
      print((title, description));
    }
  }
}

/// This method simply fetches the raw contents of the official documentations
/// site for Dart/Flutter linter rules.
Future<String> _fetchHTMLOfLinterRules() async {
  final request = await HttpClient()
      .getUrl(Uri.parse('https://dart.dev/tools/linter-rules'))
    ..headers.also((it) {
      it.add(HttpHeaders.acceptHeader, ContentType.html.toString());
      it.add(HttpHeaders.contentTypeHeader, ContentType.html.toString());
    });
  final response = await request.close();
  if (response.statusCode != 200) {
    throw Exception('Unable to fetch HTML of linter rules');
  }

  return response.transform(Utf8Decoder(allowMalformed: true)).join();
}
