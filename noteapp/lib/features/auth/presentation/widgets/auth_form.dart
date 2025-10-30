import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/features/auth/presentation/provider/auth_provider.dart';

class AuthForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const AuthForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool _isLogin = true;
  bool _isHidePassword = true;

  void _submit() {
    final authProvider = context.read<AuthProvider>();
    final username = widget.usernameController.text.trim();
    final password = widget.passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin.')),
      );
      return;
    }

    if (_isLogin) {
      authProvider.login(username: username, password: password);
    } else {
      authProvider.register(username: username, password: password);
    }
  }

  TextField buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isHidePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isHidePassword = !_isHidePassword;
                  });
                },
              )
            : null,
      ),
      obscureText: isPassword ? _isHidePassword : false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTextField(
          controller: widget.usernameController,
          labelText: 'Tên đăng nhập',
        ),
        const SizedBox(height: 8),
        buildTextField(
          controller: widget.passwordController,
          labelText: 'Mật khẩu',
          isPassword: true,
        ),
        const SizedBox(height: 10),

        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.status == AuthStatus.authenticating) {
              return const CircularProgressIndicator();
            }
            return ElevatedButton(
              onPressed: _submit,
              child: Text(_isLogin ? 'Đăng nhập' : 'Đăng ký'),
            );
          },
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(_isLogin ? 'Đăng ký' : 'Đăng nhập'),
            ),
            TextButton(
              onPressed: () => context.read<AuthProvider>().logout(),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => context.read<AuthProvider>().deleteUser(
            username: widget.usernameController.text.trim(),
            password: widget.passwordController.text.trim(),
          ),
          child: const Text(
            'Xóa tài khoản',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
