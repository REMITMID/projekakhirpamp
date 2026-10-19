import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  User? get currentUser => _supabase.auth.currentUser;

  Future<String?> signUp(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _supabase.auth.signUp(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Terjadi kesalahan saat pendaftaran.';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _supabase.auth.signInWithPassword(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Terjadi kesalahan saat masuk.';
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }
}