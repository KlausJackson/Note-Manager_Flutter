import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/features/auth/presentation/provider/auth_provider.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final drawerWidth = screenWidth * (isLandscape ? 0.30 : 0.55);
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Drawer(
          width: drawerWidth,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authProvider.isAuthenticated
                          ? authProvider.currentUser
                          : 'Default User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      authProvider.isAuthenticated ? '' : 'Guest',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // --- Navigation Items ---
              ListTile(
                leading: const Icon(Icons.note),
                title: const Text('Ghi chú'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/notes');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Rác'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/notes/trash');
                },
              ),
              const Divider(),

              // --- Auth Navigation ---
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Tài khoản'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer first
                  Navigator.of(context).pushNamed('/auth');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
