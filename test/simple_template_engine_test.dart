import 'package:simple_template_engine/simple_template_engine.dart';
import 'package:test/test.dart';

main() {
  final stopwatch = Stopwatch()..start();

  group('TemplateEngine Tests', () {
    test('Render plain text without expressions', () {
      final template = 'Hello, world!';

      final output = executeTemplate(template);

      expect(output.trim(), equals('Hello, world!'));
    });

    test('Render template with a single variable', () {
      final template = 'Hello, <% name %>!';

      final output = executeTemplate(template, name: 'Dart');

      expect(output.trim(), equals('Hello, Dart!'));
    });

    test('Render template with a conditional expression', () {
      final template = '''
      <% if (showGreeting) { %>
        Hello, world!
      <% } %>
      ''';

      var firstOutput = executeTemplate(template, showGreeting: true);
      final secondOutput = executeTemplate(template, showGreeting: false);

      expect(firstOutput.trim(), equals('Hello, world!'));
      expect(secondOutput.trim(), equals(''));
    });

    test('Render template with a loop', () {
      final template = '''
      <% for (var i = 0; i < 3; i++) { %>
        <p>Number: <% i %></p>
      <% } %>
      ''';

      final output = executeTemplate(template);

      expect(
          output.trim(),
          equals('''
              <p>Number: 0</p>
              <p>Number: 1</p>
              <p>Number: 2</p>'''
              .trim()));
    });

    test("Can't render template with a map", () {
      final template = '''
      <% for (var key in data.keys) { %>
        <p><% key %>: <% data[key] %></p>
      <% } %>
      ''';

      // ignore: prefer_function_declarations_over_variables
      final output = () {
        return executeTemplate(
          template,
          data: {'lang': 'Dart', 'type': 'Programming'},
        );
      };

      // dart_eval throws an UnimplementedError.
      expect(output, throwsA(anything));
    });

    test('Render template with list iteration', () {
      final template = '''
      <% for (var item in items) { %>
        <p>Item: <% item %></p>
      <% } %>
      ''';

      final output = executeTemplate(template, items: ['apple', 'banana']);

      expect(
          output.trim(),
          equals('''<p>Item: apple</p>
              <p>Item: banana</p>'''
              .trim()));
    });

    test('Render template with escaping special characters', () {
      final template = 'Special characters: <% symbols %>';

      final output = executeTemplate(template, symbols: '<>&"\'');

      expect(output.trim(), equals('Special characters: <>&"\''));
    });

    test('Render template with a set', () {
      final template = '''
      <% for (var item in items) { %>
        <p>Item: <% item %></p>
      <% } %>
      ''';

      final output = executeTemplate(template, items: {'apple', 'banana'});

      expect(
          output.trim(),
          equals('''<p>Item: apple</p>
              <p>Item: banana</p>'''
              .trim()));
    });

    test('Render template with nested expressions', () {
      final template = '''
      <% if (outerList.isNotEmpty) { %>
        <% for (var outer in outerList) { %>
          <div>
          <% if (outer['innerList'].isNotEmpty) { %>
            <% for (var inner in outer['innerList']) { %>
              <p>Inner: <% inner %></p>
            <% } %>
          <% } %>
          </div>
        <% } %>
      <% } %>
      ''';

      final output = executeTemplate(template, outerList: [
        {
          'innerList': [1, 2]
        },
        {
          'innerList': [3]
        }
      ]);

      expect(
          output.trim(),
          equals('''<div>
                                    <p>Inner: 1</p>
                          <p>Inner: 2</p>
                                </div>
                  <div>
                                    <p>Inner: 3</p>
                                </div>'''
              .trim()));
    });
  });

  print('Ran tests in ${stopwatch.elapsed.inMilliseconds}ms.');
}
