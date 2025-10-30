import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/features/auth/presentation/provider/auth_provider.dart';
import 'package:noteapp/features/auth/presentation/widgets/auth_form.dart';
import 'package:noteapp/features/auth/presentation/widgets/user_list.dart';
import 'package:noteapp/presentation/widgets/show_dialogs.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _authProvider.addListener(_handleAuthChanges);
  }

  @override
  void dispose() {
    _authProvider.removeListener(_handleAuthChanges);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuthChanges() {
    final message = _authProvider.popMessage;
    if (message == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_authProvider.status == AuthStatus.error) {
        ShowDialogs.showInfoDialog(
          context: context,
          title: 'Lỗi!',
          message: message,
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
        centerTitle: true,
        title: Consumer<AuthProvider>(
          builder: (context, provider, child) {
            return const Text(
              'Đăng Nhập / Đăng Ký',
              style: TextStyle(fontSize: 14),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- Auth Form ---
                AuthForm(
                  usernameController: _usernameController,
                  passwordController: _passwordController,
                ),
                const Divider(height: 20),

                // --- Profile List ---
                const Text(
                  'Người dùng đã lưu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 300,
                  child: UserList(
                    onUserSelected: (user) {
                      _usernameController.text = user.username;
                    },
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}
