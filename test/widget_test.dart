import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/app.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(NotesApp());
    expect(find.text('Sign In'), findsWidgets);
  });
}
