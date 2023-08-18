import 'dart:convert';
import 'dart:io';

import 'package:analysis_options_generator/models.dart';
import 'package:collection/collection.dart';
import 'package:dart_scope_functions/dart_scope_functions.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

/// Initiates scraping of all the Dart/Flutter linter rules and parses the
/// results into a model for future processing.
Future<List<LinterRuleModel>> scrapeLinterRules() async {
  final linterRulesRawHTML = await _fetchHTMLOfLinterRules();
  final lintRuleCandidatesList = parse(linterRulesRawHTML)
          .querySelector('#page-content > article > div')
          ?.children ??
      [];

  final linterRules = <LinterRuleModel>[];
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
      linterRules.add(_parseLinterRule(item, lintRuleCandidatesList[i + 1]));
    }
  }

  return linterRules;
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

LinterRuleModel _parseLinterRule(Element current, Element nextElement) {
  // Title is the contents of the <a> tag's `id` attribute.
  final title = current.children.firstOrNull?.attributes['id'] ?? '';

  // Description can either be a text node, or a <code>/<type> node.
  final descriptionNodeCandidates = nextElement.nodes
      .where((item) =>
          item.nodeType == Node.TEXT_NODE ||
          (item.nodeType == Node.ELEMENT_NODE &&
                  (item as Element).localName == 'code' ||
              (item as Element).localName == 'type'))
      .where((item) => item.text?.trim().isNotEmpty == true);

  final descriptionStringBuffer = StringBuffer();
  for (final descriptionNode in descriptionNodeCandidates) {
    descriptionStringBuffer.write(descriptionNode.text ?? '');
  }
  final description = descriptionStringBuffer.toString();

  // Styles are located in <img> types and can be identified by the contents of
  // the `src` attribute. Status is just contents of the <em> tag.
  Set<StyleEnum> styles = {};
  String? status;
  for (final child in nextElement.children) {
    if (child.localName == 'em') {
      status = child.text.trim().toString();
    }

    child.children
        .where((item) => item.localName == 'img')
        .map((item) => item.attributes['src'])
        .whereType<String>()
        .map((item) => StyleEnum.fromSRCString(item))
        .whereType<StyleEnum>()
        .let((it) => styles.addAll(it));
  }

  return LinterRuleModel(title, description, styles, status);
}
