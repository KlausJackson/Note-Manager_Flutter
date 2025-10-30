import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/features/auth/domain/entities/user.dart';
import 'package:noteapp/features/auth/presentation/provider/auth_provider.dart';
import 'package:noteapp/presentation/widgets/show_dialogs.dart';

class UserList extends StatelessWidget {
  final Function(User) onUserSelected;
  UserList({super.key, required this.onUserSelected});
  final ShowDialogs showDialogs = ShowDialogs();

  String _formatDateTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.profiles.isEmpty) {
          return const Text('Không có người dùng nào.');
        }

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade700),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: authProvider.profiles.length,
            itemBuilder: (context, index) {
              final profile = authProvider.profiles[index];
              return Card(
                child: ListTile(
                  title: Text(profile.username),
                  subtitle: Text(
                    profile.lastSynced != null
                        ? _formatDateTime(profile.lastSynced!)
                        : 'Chưa bao giờ đồng bộ',
                  ),
                  onTap: () {
                    onUserSelected(profile);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ShowDialogs.showConfirmationDialog(
                            context: context,
                            title: 'Xóa người dùng',
                            message:
                                'Bạn có chắc chắn muốn xóa người dùng "${profile.username}" và dữ liệu của người dùng này không?',
                            confirmText: 'Xóa',
                            onConfirm: () {
                              context.read<AuthProvider>().deleteSavedUser(
                                profile.username,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
