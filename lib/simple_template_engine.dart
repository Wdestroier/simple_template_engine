import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';

final executeTemplate = _TemplateEngine() as dynamic;

class _TemplateEngine {
  // Matches template expressions in the form of <% ... %>.
  final _templateExpressionRegex = RegExp(r'<%([^%>]+)?%>');
  // Matches control flow statements, except return.
  final _controlFlowKeywordsRegex = RegExp(
      r'^( )?(if|else|for|switch|case|default|break|continue|do|while|try|catch|finally|rethrow|{|})');

  @override
  noSuchMethod(invocation) {
    return (invocation.isMethod && invocation.memberName == #call)
        ? _call(invocation)
        : super.noSuchMethod(invocation);
  }

  _call(Invocation invocation) {
    // The first argument (positional) is the template String.
    final template = invocation.positionalArguments[0] as String;
    // The other arguments (named) are the template arguments.
    final arguments = _extractNamedArguments(invocation);

    return _interpretTemplate(template, arguments);
  }

  Map<String, dynamic> _extractNamedArguments(Invocation invocation) {
    return invocation.namedArguments
        .map((key, value) => MapEntry(_getArgumentName(key), value));
  }

  // Convert Symbol to String without dart:mirrors.
  String _getArgumentName(Symbol symbol) {
    final string = symbol.toString();
    final (start, end) = ('Symbol("'.length, string.length - '")'.length);
    return string.substring(start, end);
  }

  _interpretTemplate(String template, Map<String, dynamic> arguments) {
    final library = _generateLibrary(template, arguments);
    return _interpret(library, arguments);
  }

  // The library contains the generated Dart code from the template.
  String _generateLibrary(String template, Map<String, dynamic> arguments) {
    final signature = _generateSignature(arguments);
    final body = _generateBody(template);
    return '''
      import 'dart:core';

      String build($signature) {
        $body
      }
      ''';
  }

  String _generateSignature(Map<String, dynamic> templateArguments) {
    late final arguementNames = templateArguments.keys;

    return templateArguments.isEmpty
        ? ''
        : '{${arguementNames.map((name) => 'required $name').join(', ')}}';
  }

  String _generateBody(String template) {
    var body = StringBuffer('final result = [];\n');
    var cursor = 0;

    // Process each template expression and convert it into Dart code.
    for (final match in _templateExpressionRegex.allMatches(template)) {
      // Add plain text before the match.
      _addText(body, template.substring(cursor, match.start));
      // Add Dart code within the template.
      _addText(body, match.group(1)!, true);
      cursor = match.end;
    }

    // Add any remaining text.
    _addText(body, template.substring(cursor));
    body.write('return result.join();');

    return body.toString();
  }

  // Adds a piece of code, determining if it's Dart code or plain text.
  _addText(StringBuffer body, String text, [bool isDart = false]) {
    if (isDart) {
      body.write(_controlFlowKeywordsRegex.hasMatch(text)
          ? '$text\n'
          : 'result.add(${text.trim()});\n');
    } else if (text.isNotEmpty) {
      final escapedLine = text.replaceAll('"', r'\"');
      body.write('result.add("""$escapedLine""");\n');
    }
  }

  _interpret(String library, Map<String, dynamic> namedArgs) {
    // Compile and evaluate the code.
    final program = Compiler().compile({
      'simple_template_engine': {'main.dart': library}
    });
    final runtime = Runtime.ofProgram(program);

    // Wrap arguments using dart_eval compatible types.
    final boxedArgs = namedArgs.values.map(_wrapValue).toList();

    return _unwrapValue(runtime.executeLib(
        'package:simple_template_engine/main.dart', 'build', boxedArgs));
  }

  // Method to wrap different types in their respective $Value types.
  _wrapValue(value) {
    return switch (value) {
      String() => $String(value),
      List() => $List.wrap(value.map(_wrapValue).toList()),
      Map() => $Map.wrap(value.map(
          (k, v) => $MapEntry.wrap(MapEntry(_wrapValue(k), _wrapValue(v))))),
      Set() => $List.wrap(value.map(_wrapValue).toList()),
      int() => $int(value),
      double() => $double(value),
      bool() => $bool(value),
      null => $null(),
      _ => value
    };
  }

  // Method to unwrap different $Value types to their respective Dart types.
  _unwrapValue(value) => (value is $Value) ? value.$value : value;
}
