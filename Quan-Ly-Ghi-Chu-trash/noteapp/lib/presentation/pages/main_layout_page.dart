import 'package:flutter/material.dart';
import 'package:noteapp/presentation/widgets/menu_drawer.dart';

class MainLayoutPage extends StatelessWidget {
  final String title;
  final Widget body;

  const MainLayoutPage({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const MenuDrawer(),
      body: body
    );
  }
}
