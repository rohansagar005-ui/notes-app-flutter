import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/notes/notes_bloc.dart';
import 'blocs/connectivity/connectivity_bloc.dart';
import 'services/auth_service.dart';
import 'services/note_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/notes/note_list_screen.dart';
import 'screens/splash_screen.dart';

class NotesApp extends StatelessWidget {
  final AuthService authService;
  final NoteService noteService;

  const NotesApp({
    super.key,
    required this.authService,
    required this.noteService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authService: authService)
            ..add(const AuthCheckRequested()),
        ),
        BlocProvider<ConnectivityBloc>(
          create: (_) => ConnectivityBloc(),
        ),
        BlocProvider<NotesBloc>(
          create: (_) => NotesBloc(noteService: noteService),
        ),
      ],
      child: MaterialApp(
        title: 'Notes App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF4A90D9),
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthInitial) {
              return const SplashScreen();
            }
            if (state is Authenticated) {
              return const NoteListScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
