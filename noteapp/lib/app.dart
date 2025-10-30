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
//       child: MaterialApp(
//         title: 'NoteApp',
//         theme: ThemeData(
//           useMaterial3: true,
//           brightness: Brightness.dark,
//           colorScheme: ColorScheme.fromSeed(
//             seedColor: Colors.indigoAccent,
//             brightness: Brightness.dark,
//           ),
//         ),
//         onGenerateRoute: AppRouter.onGenerateRoute,
//         initialRoute: '/notes',
//       ),
//     );
//   }
// }

      child: const PostBuildSetup(), // <-- Use a new helper widget
    );
  }
}

/// This helper widget runs its logic only AFTER all providers have been created.
class PostBuildSetup extends StatefulWidget {
  const PostBuildSetup({super.key});

  @override
  State<PostBuildSetup> createState() => _PostBuildSetupState();
}

class _PostBuildSetupState extends State<PostBuildSetup> {
  @override
  void initState() {
    super.initState();
    // --- THIS IS THE WIRING ---
    // After the first frame is built, we can safely link our providers.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final noteProvider = context.read<NoteProvider>();
      // final tagProvider = context.read<TagProvider>();

      // Link the providers together.
      noteProvider.setAuthProvider(authProvider);
      // tagProvider.setAuthProvider(authProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This widget's only job is to return the main MaterialApp.
    return MaterialApp(
      title: 'NoteApp',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        // ...
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/notes',
    );
  }
}