import 'package:flutter/material.dart';
import 'package:noteapp/app.dart';
import 'package:noteapp/core/dependencies/dependency_injection.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const App());
}
