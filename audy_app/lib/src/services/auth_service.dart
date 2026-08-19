import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/game_session_model.dart';

/// User profile model stored in Supabase profiles table
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.createdAt,
    required this.role,
    this.email,
    this.parentId,
    this.teacherId,
  });

  final String id;
  final String name;
  final int age;
  final DateTime createdAt;
  final String role; // 'child', 'parent', 'teacher'
  final String? email;
  final String? parentId;
  final String? teacherId;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      role: json['role'] as String? ?? 'child',
      email: json['email'] as String?,
      parentId: json['parent_id'] as String?,
      teacherId: json['teacher_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'created_at': createdAt.toIso8601String(),
      'role': role,
      'email': email,
      'parent_id': parentId,
      'teacher_id': teacherId,
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

  /// Sign up with email, password, name, age, and role
  /// Profile row is created automatically by database trigger
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
    required String role,
  }) async {
    try {
      // Create auth user with profile data in metadata
      // The database trigger will read this and create the profile row
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim(), 'age': age, 'role': role},
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

  /// Link a child to a parent by child's email.
  ///
  /// Uses the `link_child_by_email` SECURITY DEFINER RPC: profiles RLS only
  /// lets a user read/update their own row, so the parent cannot look up or
  /// update the child's row directly. The RPC does the role-checked update.
  Future<void> linkChildToParent(String parentId, String childEmail) async {
    try {
      await _client.rpc(
        'link_child_by_email',
        params: {'child_email': childEmail.trim()},
      );
    } on PostgrestException catch (e) {
      debugPrint('linkChildToParent error: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('linkChildToParent error: $e');
      rethrow;
    }
  }

  /// Link a student to a teacher by student's email.
  ///
  /// Uses the `link_student_by_email` SECURITY DEFINER RPC for the same RLS
  /// reason as [linkChildToParent].
  Future<void> linkStudentToTeacher(
    String teacherId,
    String studentEmail,
  ) async {
    try {
      await _client.rpc(
        'link_student_by_email',
        params: {'student_email': studentEmail.trim()},
      );
    } on PostgrestException catch (e) {
      debugPrint('linkStudentToTeacher error: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('linkStudentToTeacher error: $e');
      rethrow;
    }
  }

  /// Fetch children linked to a parent
  Future<List<UserProfile>> fetchChildren(String parentId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('parent_id', parentId);

      return (response as List)
          .map((json) => UserProfile.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('fetchChildren error: $e');
      return [];
    }
  }

  /// Fetch students linked to a teacher
  Future<List<UserProfile>> fetchStudents(String teacherId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('teacher_id', teacherId);

      return (response as List)
          .map((json) => UserProfile.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('fetchStudents error: $e');
      return [];
    }
  }

  /// Fetch student statistics
  Future<Map<String, dynamic>?> fetchStudentStats(String studentId) async {
    try {
      final response = await _client
          .from('student_stats')
          .select()
          .eq('student_id', studentId)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('fetchStudentStats error: $e');
      return null;
    }
  }

  /// Sync student statistics to Supabase
  Future<void> syncStudentStats(
    String studentId, {
    required int learningPoints,
    required int gamesPlayed,
    required int dayStreak,
  }) async {
    try {
      await _client.from('student_stats').upsert({
        'student_id': studentId,
        'learning_points': learningPoints,
        'games_played': gamesPlayed,
        'day_streak': dayStreak,
        'last_played_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('syncStudentStats error: $e');
    }
  }

  /// Push a completed game session to Supabase for dashboard analytics.
  ///
  /// Best-effort: swallows errors like [syncStudentStats] so gameplay is never
  /// blocked by a failed sync.
  Future<void> syncGameSession(
    String studentId,
    GameSessionData session,
  ) async {
    try {
      await _client.from('game_sessions').insert({
        'student_id': studentId,
        'game_type': session.gameType,
        'difficulty': session.difficulty,
        'correct_actions': session.correctActions,
        'total_actions': session.totalActions,
        'accuracy_percent': session.accuracyPercent,
        'stars_earned': session.starsEarned,
        'duration_seconds': session.durationSeconds,
        'session_ended_at': session.sessionEndedAt.toIso8601String(),
      });
    } catch (e) {
      debugPrint('syncGameSession error: $e');
    }
  }

  /// Fetch a student's recorded game sessions (newest first) for dashboards.
  Future<List<Map<String, dynamic>>> fetchStudentSessions(
    String studentId, {
    int limit = 200,
  }) async {
    try {
      final response = await _client
          .from('game_sessions')
          .select()
          .eq('student_id', studentId)
          .order('session_ended_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('fetchStudentSessions error: $e');
      return [];
    }
  }

  /// Assign homework to a student
  Future<void> assignHomework(
    String teacherId,
    String studentId,
    String gameType,
    int targetCount,
  ) async {
    try {
      await _client.from('assignments').insert({
        'teacher_id': teacherId,
        'student_id': studentId,
        'game_type': gameType,
        'target_count': targetCount,
        'current_count': 0,
        'is_completed': false,
      });
    } catch (e) {
      debugPrint('assignHomework error: $e');
      rethrow;
    }
  }

  /// Fetch assignments for a student
  Future<List<Map<String, dynamic>>> fetchAssignments(String studentId) async {
    try {
      final response = await _client
          .from('assignments')
          .select()
          .eq('student_id', studentId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('fetchAssignments error: $e');
      return [];
    }
  }

  /// Update assignment progress
  Future<void> updateAssignmentProgress(
    String assignmentId,
    int progress,
    bool isCompleted,
  ) async {
    try {
      await _client
          .from('assignments')
          .update({'current_count': progress, 'is_completed': isCompleted})
          .eq('id', assignmentId);
    } catch (e) {
      debugPrint('updateAssignmentProgress error: $e');
      rethrow;
    }
  }

  /// Change how many completions an assignment requires. Re-derives
  /// is_completed from the (unchanged) current progress against the new
  /// target so a lowered target can flip an assignment to complete.
  Future<void> updateAssignmentTarget(
    String assignmentId,
    int targetCount,
    int currentCount,
  ) async {
    try {
      await _client
          .from('assignments')
          .update({
            'target_count': targetCount,
            'is_completed': currentCount >= targetCount,
          })
          .eq('id', assignmentId);
    } catch (e) {
      debugPrint('updateAssignmentTarget error: $e');
      rethrow;
    }
  }

  /// Permanently remove an assignment (a teacher "disabling" a task).
  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _client.from('assignments').delete().eq('id', assignmentId);
    } catch (e) {
      debugPrint('deleteAssignment error: $e');
      rethrow;
    }
  }

  /// Add custom classmate name/noun to class word bank
  Future<void> addClassWord(
    String teacherId,
    String word, {
    String? category,
    String? imageUrl,
  }) async {
    try {
      await _client.from('class_words').insert({
        'teacher_id': teacherId,
        'word': word.trim(),
        'category': category ?? 'noun',
        'image_url': imageUrl,
      });
    } catch (e) {
      debugPrint('addClassWord error: $e');
      rethrow;
    }
  }

  /// Remove a custom flashcard word from the classroom word bank
  Future<void> deleteClassWord(String wordId) async {
    try {
      await _client.from('class_words').delete().eq('id', wordId);
    } catch (e) {
      debugPrint('deleteClassWord error: $e');
      rethrow;
    }
  }

  /// Fetch custom words for a classroom (from teacher ID)
  Future<List<ClassWord>> fetchClassWords(String teacherId) async {
    try {
      final response = await _client
          .from('class_words')
          .select('*')
          .eq('teacher_id', teacherId);
      return (response as List)
          .map((json) => ClassWord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('fetchClassWords error: $e');
      return [];
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

class ClassWord {
  final String id;
  final String word;
  final String? category;
  final String? imageUrl;

  const ClassWord({
    required this.id,
    required this.word,
    this.category,
    this.imageUrl,
  });

  factory ClassWord.fromJson(Map<String, dynamic> json) {
    return ClassWord(
      id: json['id'] as String? ?? '',
      word: json['word'] as String? ?? '',
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}
