# Simple Template Engine

A dynamic template rendering engine for Dart that allows inline Dart expressions and control structures within your templates. This engine uses dart_eval to parse and execute templates, enabling features such as conditional rendering, loops, and more.

## Installation

Add the following to your pubspec.yaml:
```yaml
dependencies:
  simple_template_engine:
    git:
      url: https://github.com/wdestroier/simple_template_engine.git

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

## License

This project is licensed under the BSD (3-Clause) License - see the LICENSE file for details.