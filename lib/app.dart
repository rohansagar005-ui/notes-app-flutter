import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/notes/note_list_screen.dart';

class NotesApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4A90D9),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: StreamBuilder(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (_authService.isLoggedIn) {
            return const NoteListScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
