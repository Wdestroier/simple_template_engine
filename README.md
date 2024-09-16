# Simple Template Engine

A dynamic template rendering engine for Dart that allows inline Dart expressions and control structures within your templates. This engine uses dart_eval to parse and execute templates, enabling features such as conditional rendering, loops, and more.

## Installation

Add the following to your pubspec.yaml:
```yaml
dependencies:
  simple_template_engine: ^1.0.0
```

## Usage
```dart
import 'package:simple_template_engine/simple_template_engine.dart';
```

### Basic example
```dart
main() {
  var template = '''
  Hello, <% name %>!
  Today is <% DateTime.now().weekday %>.
  ''';

  var output = executeTemplate(
    template,
    name: 'Dart Enthusiast',
  );

  print(output);
}
```

### Control structures example

```dart
var template = '''
<% if (showSkills) { %>
  Skills:
  <% for (final skill in skills) { %>
    <p><% skill %></p>
  <% } %>
<% } else { %>
  No skills to show.
<% } %>
''';

var output = executeTemplate(
  template,
  skills: ['Dart', 'HTML'],
  showSkills: true,
);

print(output);
```

### HTML server example

```dart
// Don't forget to add the shelf_router package too:
// dart pub add shelf_router

// ignore_for_file: implicit_call_tearoffs, depend_on_referenced_packages

import 'dart:math';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:simple_template_engine/simple_template_engine.dart';

main() async {
  final router = Router();
  mapHelloPage(router);

  final server = await serve(router, 'localhost', 8080);
  print('Server running on http://localhost:${server.port}');
}

mapHelloPage(Router router) {
  router.get('/<name>', (Request request, String name) {
    // Define a template with inline CSS and a dynamic greeting.
    final pageTemplate = '''
      <html>
      <head>
        <style>
          body {
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            text-align: center;
          }
          .greeting {
            font-size: 2em;
            color: hsl(<% colorHue %>, 100%, 40%);
            animation: pulse 2s infinite;
          }
          @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
          }
        </style>
      </head>
      <body>
        <div class="greeting">Hello, <% name %>!</div>
      </body>
      </html>
    ''';

    return Response.ok(
      // Response body:
      executeTemplate(
        pageTemplate,
        name: const HtmlEscape().convert(name), // Escape user input.
        colorHue: Random().nextInt(360), // Generate random color.
      ),
      // Response headers:
      headers: {'Content-Type': 'text/html'},
    );
  });
}
```

## License

This project is licensed under the BSD (3-Clause) License - see the LICENSE file for details.