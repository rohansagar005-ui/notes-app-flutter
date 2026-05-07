import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/services/auth_service.dart';
import 'package:notes_app/services/note_service.dart';
import 'package:notes_app/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(NotesApp(
      authService: AuthService(),
      noteService: NoteService(),
    ));
    expect(find.byType(NotesApp), findsOneWidget);
  });
}
