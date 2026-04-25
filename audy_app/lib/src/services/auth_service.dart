import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// User profile model stored in Supabase profiles table
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int age;
  final DateTime createdAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Auth service wrapping Supabase auth operations
/// Provides sign in, sign up, sign out, and profile management
class AuthService {
  final _client = Supabase.instance.client;

  /// Get the current authenticated user (or null if not logged in)
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is currently logged in
  bool get isLoggedIn => currentUser != null;

  /// Stream of auth state changes
  Stream<AuthState> get authStateStream => _client.auth.onAuthStateChange;

  /// Sign in with email and password
  /// Returns the User on success, throws exception on failure
  Future<User> signIn({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        throw Exception(
          'Sign in failed. Please check your email and password.',
        );
      }

      return response.user!;
    } on AuthException catch (e) {
      throw Exception(_getFriendlyErrorMessage(e.message));
    } catch (e) {
      throw Exception('Sign in failed. Please try again.');
    }
  }

  /// Sign up with email, password, name, and age
  /// Profile row is created automatically by database trigger
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
  }) async {
    try {
      // Create auth user with profile data in metadata
      // The database trigger will read this and create the profile row
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim(), 'age': age},
      );

      if (response.user == null) {
        throw Exception('Sign up failed. Please try again.');
      }

      // Profile is created automatically by the database trigger
      // handle_new_user() reads raw_user_meta_data and inserts into profiles
      return response.user!;
    } on AuthException catch (e) {
      throw Exception(_getFriendlyErrorMessage(e.message));
    } catch (e) {
      debugPrint('Sign up error: $e');
      throw Exception('Sign up failed. Please try again.');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      // Still proceed even if there's an error
    }
  }

  /// Fetch the profile for a given user ID
  /// Returns null if profile not found
  Future<UserProfile?> fetchProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('Fetch profile error: $e');
      return null;
    }
  }

  /// Get current user's profile (convenience method)
  Future<UserProfile?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;
    return fetchProfile(user.id);
  }

  /// Update user profile
  Future<void> updateProfile({String? name, int? age}) async {
    final user = currentUser;
    if (user == null) throw Exception('Not logged in');

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name.trim();
    if (age != null) updates['age'] = age;

    if (updates.isNotEmpty) {
      await _client.from('profiles').update(updates).eq('id', user.id);
    }
  }

  /// Convert Supabase error messages to user-friendly messages
  String _getFriendlyErrorMessage(String error) {
    final lower = error.toLowerCase();

    if (lower.contains('invalid credentials')) {
      return 'Email or password is incorrect. Please try again.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please check your email to confirm your account.';
    }
    if (lower.contains('user not found')) {
      return 'No account found with this email.';
    }
    if (lower.contains('email already registered')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('password')) {
      return 'Password must be at least 6 characters long.';
    }

    return 'Something went wrong. Please try again.';
  }
}
