import 'package:flutter/material.dart';
import 'package:noteapp/features/auth/presentation/pages/auth_page.dart';
import 'package:noteapp/features/notes/domain/entities/note.dart';
import 'package:noteapp/features/notes/presentation/pages/edit_page.dart';
import 'package:noteapp/features/notes/presentation/pages/notes_page.dart';
import 'package:noteapp/features/notes/presentation/pages/trash_page.dart';
import 'package:noteapp/presentation/pages/main_layout_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/auth') {
      return MaterialPageRoute(builder: (_) => const AuthPage());
    } else if (settings.name == '/notes') {
      return MaterialPageRoute(
        builder: (_) => const MainLayoutPage(title: 'Notes', body: NotesPage()),
      );
    } else if (settings.name == '/notes/create') {
      return MaterialPageRoute(builder: (_) => const NoteEditPage());
    } else if (settings.name == '/notes/edit') {
      final note = settings.arguments as Note?;
      if (note != null) {
        return MaterialPageRoute(builder: (_) => NoteEditPage(note: note));
      } else {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('No note provided for editing')),
          ),
        );
      }
    } else if (settings.name == '/notes/trash') {
      return MaterialPageRoute(
        builder: (_) => const MainLayoutPage(title: 'Trash', body: TrashPage()),
      );
    } else {
      return MaterialPageRoute(
        builder: (_) =>
            const Scaffold(body: Center(child: Text('Route not found'))),
      );
    }
  }
}
