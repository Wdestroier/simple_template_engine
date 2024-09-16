import 'package:simple_template_engine/simple_template_engine.dart';

main() {
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
  
  // Prints:
  //  Skills:
  //    <p>Dart</p>
  //    <p>HTML</p>
}