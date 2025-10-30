import 'package:flutter/material.dart';

// entity
import 'package:noteapp/features/auth/domain/entities/user.dart';

// usecases
import 'package:noteapp/features/auth/domain/usecases/login.dart';
import 'package:noteapp/features/auth/domain/usecases/register.dart';
import 'package:noteapp/features/auth/domain/usecases/logout.dart';
import 'package:noteapp/features/auth/domain/usecases/delete_user.dart';
import 'package:noteapp/features/auth/domain/usecases/get_saved_users.dart';
import 'package:noteapp/features/auth/domain/usecases/delete_saved_user.dart';
import 'package:noteapp/features/auth/domain/usecases/get_current_user.dart';
import 'package:noteapp/features/notes/presentation/provider/note_provider.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, error }

class AuthProvider with ChangeNotifier {
  // --- Usecase Dependencies ---
  final Login loginUsecase;
  final Register registerUsecase;
  final Logout logoutUsecase;
  final DeleteUser deleteUserUsecase;
  final GetSavedUsers getSavedUsersUsecase;
  final DeleteSavedUser deleteSavedUserUsecase;
  final GetCurrentUser getCurrentUserUsecase;
  final NoteProvider noteProvider;

  // --- State Properties ---
  AuthStatus _status = AuthStatus.unauthenticated;
  String _message = '';
  List<User> _profiles = [];
  String _currentUser = 'default';

  // --- Constructor ---
  AuthProvider({
    required this.loginUsecase,
    required this.registerUsecase,
    required this.logoutUsecase,
    required this.deleteUserUsecase,
    required this.getSavedUsersUsecase,
    required this.deleteSavedUserUsecase,
    required this.getCurrentUserUsecase,
    required this.noteProvider,
  }) {
    _initialize();
  }

  // --- Getters for the UI ---
  AuthStatus get status => _status;
  List<User> get profiles => _profiles;
  String get currentUser => _currentUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get popMessage {
    if (_message.isEmpty) return null;
    final msg = _message;
    _message = '';
    return msg;
  }

  // --- Initialization ---
  Future<void> _initialize() async {
    await Future.wait([_checkAuthState(), fetchProfiles()]);
  }

  Future<void> _checkAuthState() async {
    String? user = await getCurrentUserUsecase();
    if (user != null) {
      _currentUser = user;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
  }

  Future<void> fetchProfiles() async {
    _profiles = await getSavedUsersUsecase();
    notifyListeners();
  }

  // helper function
  Future<void> _handleAuth(Future<void> Function() authAction) async {
    _status = AuthStatus.authenticating;
    _message = '';
    notifyListeners();
    try {
      await authAction();
      _status = AuthStatus.authenticated;
      _message = 'Thanh cong!';
    } catch (e) {
      _status = AuthStatus.error;
      _message = e.toString();
    }
    notifyListeners();
  }

  bool _ensureAuthenticated() {
    if (_status != AuthStatus.authenticated && _status != AuthStatus.error) {
      _message = 'Chưa đăng nhập.';
      notifyListeners();
      return false;
    }
    return true;
  }

  // --- Public Methods for UI ---
  Future<void> login({
    required String username,
    required String password,
  }) async {
    await _handleAuth(() async {
      await loginUsecase(username: username, password: password);
      _currentUser = username;
      await fetchProfiles();
    });
  }

  Future<void> register({
    required String username,
    required String password,
  }) async {
    await _handleAuth(() async {
      await registerUsecase(username: username, password: password);
      _currentUser = username;
      await fetchProfiles();
    });
  }

  Future<void> logout() async {
    if (!_ensureAuthenticated()) return;
    await logoutUsecase();
    noteProvider.clearNotes();
    _status = AuthStatus.unauthenticated;
    _message = 'Đăng xuất thành công.';
    notifyListeners();
  }

  Future<void> deleteUser({
    required String username,
    required String password,
  }) async {
    if (!_ensureAuthenticated()) return;
    await _handleAuth(() async {
      await deleteUserUsecase(username: username, password: password);
      _currentUser = 'default';
      await fetchProfiles();
    });
  }

  Future<void> deleteSavedUser(String username) async {
    await deleteSavedUserUsecase(username: username);
    await fetchProfiles();
  }
}
