import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/core/routes/routes.dart';
import 'package:noteapp/core/dependencies/dependency_injection.dart'; // service locator

import 'package:noteapp/features/auth/presentation/provider/auth_provider.dart';
import 'package:noteapp/features/notes/presentation/provider/note_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => sl<NoteProvider>()),
      ],
      child: MaterialApp(
        title: 'NoteApp',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigoAccent,
            brightness: Brightness.dark,
          ),
        ),
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: '/notes',
      ),
    );
  }
}
