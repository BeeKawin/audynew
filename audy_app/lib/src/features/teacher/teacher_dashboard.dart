import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/auth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import 'student_detail_page.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final _authService = AuthService();
  final _studentEmailController = TextEditingController();
  final _wordController = TextEditingController();

  List<UserProfile> _students = [];
  final Map<String, Map<String, dynamic>> _studentStats = {};
  final Map<String, List<Map<String, dynamic>>> _studentAssignments = {};
  final Map<String, List<Map<String, dynamic>>> _studentSessions = {};
  List<ClassWord> _classWords = [];
  bool _isLoading = true;
  bool _isLinking = false;
  bool _isAddingWord = false;
  bool _isAssigning = false;

  // Which portal section chip is selected — Classroom / Assignments /
  // Flashcards / Account — mirroring the chip-tab pattern used on the
  // student-facing ProfilePage.
  int _selectedPortalTab = 0;

  String? _selectedImageBase64;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 70,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBase64 = 'data:image/png;base64,${base64Encode(bytes)}';
        });
      }
    } catch (e) {
      debugPrint('Pick image error: $e');
    }
  }

  String? _linkMessage;
  bool _linkIsError = false;

  String? _wordMessage;
  bool _wordIsError = false;

  String _selectedWordType = 'noun';

  String? _assignMessage;
  bool _assignIsError = false;

  // Homework form state
  bool _assignToWholeClass = false;
  String? _selectedStudentId;
  String _selectedGameType = 'emotion_classify';
  int _selectedTargetCount = 3;

  final List<Map<String, String>> _gameTypes = [
    {'key': 'emotion_classify', 'label': 'Emotion Recognition'},
    // {'key': 'emotion_mimic', 'label': 'Emotion Mimicking'},
    {'key': 'minipuzzle', 'label': 'Mini Puzzle'},
    {'key': 'sorting', 'label': 'Shape Sorting'},
    {'key': 'reaction_time', 'label': 'Reaction Time'},
    {'key': 'reading', 'label': 'Read & Speak'},
    {'key': 'social_chat', 'label': 'Social Chat'},
  ];

  // Friendly labels for every game type — used by both the recommendation
  // engine and the assignment progress list.
  static const Map<String, String> _gameLabels = {
    'emotion_classify': 'Emotion Recognition',
    'minipuzzle': 'Mini Puzzle',
    'sorting': 'Shape Sorting',
    'reaction_time': 'Reaction Time',
    'reading': 'Read & Speak',
    'social_chat': 'Social Chat',
    'flashcard': 'Flashcard Game',
    'fruit_catching_bear': 'Fruit Catching Bear',
  };

  static const Map<String, IconData> _gameIcons = {
    'emotion_classify': Icons.emoji_emotions_rounded,
    'minipuzzle': Icons.extension_rounded,
    'sorting': Icons.category_rounded,
    'reaction_time': Icons.bolt_rounded,
    'reading': Icons.menu_book_rounded,
    'social_chat': Icons.chat_bubble_rounded,
  };

  static const Map<String, Color> _gameColors = {
    'emotion_classify': AudyColors.blushPink,
    'minipuzzle': AudyColors.softLavender,
    'sorting': AudyColors.mintGreen,
    'reaction_time': AudyColors.skyBlue,
    'reading': AudyColors.activityRewards,
    'social_chat': Color(0xFFC7D2FE),
  };

  // Shared avatar palette so a student's color stays consistent between the
  // classroom grid and the assignment student picker.
  static const List<Color> _avatarColors = [
    AudyColors.skyBlue,
    AudyColors.mintGreen,
    AudyColors.activityRewards,
    Colors.orange,
    AudyColors.softLavender,
    AudyColors.blushPink,
  ];

  Color _avatarColorFor(String name) =>
      _avatarColors[name.hashCode % _avatarColors.length];

  String _wordCategoryLabel(String? category) {
    switch (category) {
      case 'pronoun':
        return 'Pronoun';
      case 'noun':
        return 'Noun';
      case 'verb':
        return 'Action';
      case 'adjective':
        return 'Feeling';
      case 'adverb':
        return 'Adverb';
      default:
        return 'Noun';
    }
  }

  Color _wordCategoryColor(String? category) {
    switch (category) {
      case 'pronoun':
        return AudyColors.skyBlue;
      case 'noun':
        return AudyColors.mintGreen;
      case 'verb':
        return Colors.orange;
      case 'adjective':
        return AudyColors.blushPink;
      case 'adverb':
        return AudyColors.softLavender;
      default:
        return AudyColors.mintGreen;
    }
  }

  static const List<Map<String, String>> _wordTypes = [
    {'key': 'pronoun', 'label': 'Pronoun'},
    {'key': 'noun', 'label': 'Noun'},
    {'key': 'verb', 'label': 'Action'},
    {'key': 'adjective', 'label': 'Feeling'},
    {'key': 'adverb', 'label': 'Adverb'},
  ];

  static const Map<String, IconData> _wordTypeIcons = {
    'pronoun': Icons.person_outline_rounded,
    'noun': Icons.category_outlined,
    'verb': Icons.directions_run_rounded,
    'adjective': Icons.mood_rounded,
    'adverb': Icons.bolt_rounded,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadTeacherData();
      }
    });
  }

  @override
  void dispose() {
    _studentEmailController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  Future<void> _loadTeacherData() async {
    setState(() => _isLoading = true);
    final user = AudyScope.of(context).currentUser;
    if (user != null) {
      // Load classroom students
      final students = await _authService.fetchStudents(user.id);
      setState(() {
        _students = students;
        if (students.isNotEmpty && _selectedStudentId == null) {
          _selectedStudentId = students.first.id;
        }
      });

      // Load stats & assignments for each student
      for (final student in students) {
        final stats = await _authService.fetchStudentStats(student.id);
        if (stats != null) {
          setState(() {
            _studentStats[student.id] = stats;
          });
        }
        final assignments = await _authService.fetchAssignments(student.id);
        setState(() {
          _studentAssignments[student.id] = assignments;
        });
        final sessions = await _authService.fetchStudentSessions(student.id);
        setState(() {
          _studentSessions[student.id] = sessions;
        });
      }

      // Load custom class words
      final classWords = await _authService.fetchClassWords(user.id);
      setState(() {
        _classWords = classWords;
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _linkStudent() async {
    final email = _studentEmailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _linkMessage = 'Please enter student\'s email.';
        _linkIsError = true;
      });
      return;
    }

    setState(() {
      _isLinking = true;
      _linkMessage = null;
    });

    SoundService.instance.playTap();

    try {
      final user = AudyScope.of(context).currentUser;
      if (user != null) {
        await _authService.linkStudentToTeacher(user.id, email);
        setState(() {
          _linkMessage = 'Successfully added student to classroom!';
          _linkIsError = false;
          _studentEmailController.clear();
        });
        await _loadTeacherData();
      }
    } catch (e) {
      setState(() {
        _linkMessage = e.toString().replaceAll('Exception: ', '');
        _linkIsError = true;
      });
    } finally {
      setState(() => _isLinking = false);
    }
  }

  Future<void> _addClassWord() async {
    final word = _wordController.text.trim();
    if (word.isEmpty) {
      setState(() {
        _wordMessage = 'Please enter a word.';
        _wordIsError = true;
      });
      return;
    }

    setState(() {
      _isAddingWord = true;
      _wordMessage = null;
    });

    SoundService.instance.playTap();

    try {
      final user = AudyScope.of(context).currentUser;
      if (user != null) {
        await _authService.addClassWord(
          user.id,
          word,
          category: _selectedWordType,
          imageUrl: _selectedImageBase64,
        );
        setState(() {
          _wordMessage = 'Added custom Flashcard card: "$word"!';
          _wordIsError = false;
          _wordController.clear();
          _selectedWordType = 'noun';
          _selectedImageBase64 = null;
        });
        await _loadTeacherData();
      }
    } catch (e) {
      setState(() {
        _wordMessage = e.toString().replaceAll('Exception: ', '');
        _wordIsError = true;
      });
    } finally {
      setState(() => _isAddingWord = false);
    }
  }

  Future<void> _removeClassWord(ClassWord word) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        ),
        title: const Text('Remove flashcard?'),
        content: Text('Remove "${word.word}" from the class word bank?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AudyColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    SoundService.instance.playTap();
    final previous = List<ClassWord>.from(_classWords);
    setState(() => _classWords.removeWhere((w) => w.id == word.id));

    try {
      await _authService.deleteClassWord(word.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          _classWords = previous;
          _wordMessage = 'Could not remove "${word.word}". Please try again.';
          _wordIsError = true;
        });
      }
    }
  }

  Future<void> _showAssignmentActions(
    String studentId,
    Map<String, dynamic> assignment,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AudyColors.backgroundCard,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AudySpacing.radiusXLarge),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AudyColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _AssignmentActionTile(
                icon: Icons.tune_rounded,
                label: 'Edit target count',
                color: AudyColors.skyBlue,
                onTap: () => Navigator.pop(sheetContext, 'edit_target'),
              ),
              _AssignmentActionTile(
                icon: Icons.trending_up_rounded,
                label: 'Adjust progress',
                color: AudyColors.mintGreen,
                onTap: () => Navigator.pop(sheetContext, 'adjust_progress'),
              ),
              _AssignmentActionTile(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Assign to another student',
                color: AudyColors.softLavender,
                onTap: () => Navigator.pop(sheetContext, 'reassign'),
              ),
              _AssignmentActionTile(
                icon: Icons.delete_outline_rounded,
                label: 'Delete assignment',
                color: AudyColors.error,
                onTap: () => Navigator.pop(sheetContext, 'delete'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (action == null || !mounted) return;
    switch (action) {
      case 'edit_target':
        await _editAssignmentTarget(studentId, assignment);
        break;
      case 'adjust_progress':
        await _adjustAssignmentProgress(studentId, assignment);
        break;
      case 'reassign':
        await _reassignAssignment(assignment);
        break;
      case 'delete':
        await _deleteAssignment(studentId, assignment);
        break;
    }
  }

  Future<void> _editAssignmentTarget(
    String studentId,
    Map<String, dynamic> assignment,
  ) async {
    final assignmentId = assignment['id'] as String;
    final currentCount = (assignment['current_count'] as num?)?.toInt() ?? 0;
    final originalTarget = (assignment['target_count'] as num?)?.toInt() ?? 1;
    var target = originalTarget;

    final newTarget = await showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
          ),
          title: const Text('Edit target count'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$target times',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AudyColors.skyBlue,
                ),
              ),
              Slider(
                value: target.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: AudyColors.skyBlue,
                inactiveColor: AudyColors.borderLight,
                onChanged: (val) => setDialogState(() => target = val.toInt()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, target),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (newTarget == null || newTarget == originalTarget) return;

    try {
      await _authService.updateAssignmentTarget(
        assignmentId,
        newTarget,
        currentCount,
      );
      await _loadTeacherData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update the target count.')),
        );
      }
    }
  }

  Future<void> _adjustAssignmentProgress(
    String studentId,
    Map<String, dynamic> assignment,
  ) async {
    final assignmentId = assignment['id'] as String;
    final target = (assignment['target_count'] as num?)?.toInt() ?? 1;
    final originalCurrent =
        ((assignment['current_count'] as num?)?.toInt() ?? 0).clamp(0, target);
    var current = originalCurrent;

    final newCurrent = await showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
          ),
          title: const Text('Adjust progress'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$current / $target',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AudyColors.mintGreen,
                ),
              ),
              Slider(
                value: current.toDouble(),
                min: 0,
                max: target.toDouble(),
                divisions: target > 0 ? target : 1,
                activeColor: AudyColors.mintGreen,
                inactiveColor: AudyColors.borderLight,
                onChanged: (val) => setDialogState(() => current = val.toInt()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, current),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (newCurrent == null || newCurrent == originalCurrent) return;

    try {
      await _authService.updateAssignmentProgress(
        assignmentId,
        newCurrent,
        newCurrent >= target,
      );
      await _loadTeacherData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update progress.')),
        );
      }
    }
  }

  Future<void> _reassignAssignment(Map<String, dynamic> assignment) async {
    final gameType = (assignment['game_type'] ?? '').toString();
    final target = (assignment['target_count'] as num?)?.toInt() ?? 1;
    final currentStudentId = assignment['student_id'] as String?;

    final candidates = _students
        .where((s) => s.id != currentStudentId)
        .toList();
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other students to assign to.')),
      );
      return;
    }

    final chosen = await showDialog<UserProfile>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        ),
        title: const Text('Assign to another student'),
        content: SizedBox(
          width: double.maxFinite,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: candidates.map((s) {
              return _StudentPickerChip(
                name: s.name,
                color: _avatarColorFor(s.name),
                selected: false,
                onTap: () => Navigator.pop(dialogContext, s),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (chosen == null || !mounted) return;

    final user = AudyScope.of(context).currentUser;
    if (user == null) return;

    try {
      await _authService.assignHomework(user.id, chosen.id, gameType, target);
      await _loadTeacherData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Assigned to ${chosen.name}!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not reassign the task.')),
        );
      }
    }
  }

  Future<void> _deleteAssignment(
    String studentId,
    Map<String, dynamic> assignment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        ),
        title: const Text('Delete assignment?'),
        content: const Text(
          "This removes the task and its progress. This can't be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AudyColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final assignmentId = assignment['id'] as String;
    SoundService.instance.playTap();
    final previous = List<Map<String, dynamic>>.from(
      _studentAssignments[studentId] ?? const [],
    );
    setState(() {
      _studentAssignments[studentId] = previous
          .where((a) => a['id'] != assignmentId)
          .toList();
    });

    try {
      await _authService.deleteAssignment(assignmentId);
    } catch (e) {
      if (mounted) {
        setState(() => _studentAssignments[studentId] = previous);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete the assignment.')),
        );
      }
    }
  }

  List<_TeacherRecommendation> _getRecommendations() {
    final List<_TeacherRecommendation> recs = [];
    final gameLabels = _gameLabels;

    final Map<String, String> targetedSkills = {
      'emotion_classify': 'Identify Facial Expressions & Emotions',
      'minipuzzle': 'Spatial Reasoning & Pattern Recognition',
      'sorting': 'Classification & Visual Association',
      'reaction_time': 'Focus, Attention, & Processing Speed',
      'reading': 'Speech, Vocabulary, & Pronunciation',
      'social_chat': 'Conversational & Social Interaction',
      'flashcard': 'Sentence Ordering & Grammar',
      'fruit_catching_bear': 'Motor Skills & Hand-Eye Coordination',
    };

    if (_assignToWholeClass) {
      final Map<String, double> accSums = {};
      final Map<String, int> sessionCounts = {};

      for (final sList in _studentSessions.values) {
        for (final s in sList) {
          final gType = (s['gameType'] ?? s['game_type'] ?? '').toString();
          final acc = (s['accuracy_percent'] as num?)?.toDouble() ?? 0.0;
          accSums[gType] = (accSums[gType] ?? 0.0) + acc;
          sessionCounts[gType] = (sessionCounts[gType] ?? 0) + 1;
        }
      }

      for (final key in gameLabels.keys) {
        final sessionsCount = sessionCounts[key] ?? 0;
        if (sessionsCount > 0) {
          final avg = accSums[key]! / sessionsCount;
          if (avg < 70) {
            recs.add(
              _TeacherRecommendation(
                gameType: key,
                label: gameLabels[key]!,
                reason: 'Class needs practice (low average: ${avg.round()}%)',
                targetSkill: targetedSkills[key]!,
              ),
            );
          } else if (avg >= 70 && avg < 85) {
            recs.add(
              _TeacherRecommendation(
                gameType: key,
                label: gameLabels[key]!,
                reason: 'Reinforce class skill (average: ${avg.round()}%)',
                targetSkill: targetedSkills[key]!,
              ),
            );
          }
        } else {
          recs.add(
            _TeacherRecommendation(
              gameType: key,
              label: gameLabels[key]!,
              reason: 'Unplayed class activity (explore)',
              targetSkill: targetedSkills[key]!,
            ),
          );
        }
      }
    } else {
      if (_selectedStudentId != null) {
        final studentSessions = _studentSessions[_selectedStudentId!] ?? [];
        final Map<String, double> accSums = {};
        final Map<String, int> sessionCounts = {};

        for (final s in studentSessions) {
          final gType = (s['gameType'] ?? s['game_type'] ?? '').toString();
          final acc = (s['accuracy_percent'] as num?)?.toDouble() ?? 0.0;
          accSums[gType] = (accSums[gType] ?? 0.0) + acc;
          sessionCounts[gType] = (sessionCounts[gType] ?? 0) + 1;
        }

        for (final key in gameLabels.keys) {
          final sessionsCount = sessionCounts[key] ?? 0;
          if (sessionsCount > 0) {
            final avg = accSums[key]! / sessionsCount;
            if (avg < 70) {
              recs.add(
                _TeacherRecommendation(
                  gameType: key,
                  label: gameLabels[key]!,
                  reason: 'Student needs practice (low score: ${avg.round()}%)',
                  targetSkill: targetedSkills[key]!,
                ),
              );
            } else if (avg >= 70 && avg < 85) {
              recs.add(
                _TeacherRecommendation(
                  gameType: key,
                  label: gameLabels[key]!,
                  reason: 'Reinforce student skill (score: ${avg.round()}%)',
                  targetSkill: targetedSkills[key]!,
                ),
              );
            }
          } else {
            recs.add(
              _TeacherRecommendation(
                gameType: key,
                label: gameLabels[key]!,
                reason: 'Unplayed student activity (explore)',
                targetSkill: targetedSkills[key]!,
              ),
            );
          }
        }
      }
    }

    recs.sort((a, b) {
      int getPriority(String reason) {
        if (reason.contains('needs practice') ||
            reason.contains('Needs practice'))
          return 1;
        if (reason.contains('Unplayed')) return 2;
        return 3;
      }

      return getPriority(a.reason).compareTo(getPriority(b.reason));
    });

    return recs.take(3).toList();
  }

  Future<void> _assignHomework() async {
    if (!_assignToWholeClass && _selectedStudentId == null) {
      setState(() {
        _assignMessage = 'Please select a student first.';
        _assignIsError = true;
      });
      return;
    }

    setState(() {
      _isAssigning = true;
      _assignMessage = null;
    });

    SoundService.instance.playTap();

    try {
      final user = AudyScope.of(context).currentUser;
      if (user != null) {
        if (_assignToWholeClass) {
          for (final student in _students) {
            await _authService.assignHomework(
              user.id,
              student.id,
              _selectedGameType,
              _selectedTargetCount,
            );
          }
          setState(() {
            _assignMessage = 'Successfully assigned task to the entire class!';
            _assignIsError = false;
          });
        } else {
          await _authService.assignHomework(
            user.id,
            _selectedStudentId!,
            _selectedGameType,
            _selectedTargetCount,
          );
          setState(() {
            _assignMessage = 'Successfully assigned task!';
            _assignIsError = false;
          });
        }
        await _loadTeacherData();
      }
    } catch (e) {
      setState(() {
        _assignMessage = e.toString().replaceAll('Exception: ', '');
        _assignIsError = true;
      });
    } finally {
      setState(() => _isAssigning = false);
    }
  }

  static const List<_PortalTabSpec> _portalTabs = [
    _PortalTabSpec(
      label: 'Classroom',
      icon: Icons.group_rounded,
      color: Color(0xFFBDD8F2),
    ),
    _PortalTabSpec(
      label: 'Assignments',
      icon: Icons.assignment_turned_in_rounded,
      color: Color(0xFFC9E8C1),
    ),
    _PortalTabSpec(
      label: 'Flashcards',
      icon: Icons.style_rounded,
      color: Color(0xFFE7D8FA),
    ),
    _PortalTabSpec(
      label: 'Account',
      icon: Icons.settings_outlined,
      color: Color(0xFFF8C7DF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    final user = controller.currentUser;

    final activeAssignments = _studentAssignments.values
        .expand((list) => list)
        .where((a) => !(a['is_completed'] as bool))
        .length;

    return AudyResponsivePage(
      scrollable: true,
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — mascot-style badge + title, matching the student pages.
            Center(
              child: Column(
                children: [
                  AudyBadgeIcon(
                    icon: Icons.school_rounded,
                    size: adaptive.space(96),
                    background: AudyColors.mintGreen.withValues(alpha: 0.18),
                    foreground: AudyColors.mintGreen,
                  ),
                  SizedBox(height: adaptive.space(16)),
                  Text(
                    'Teacher Portal',
                    style: AudyTypography.headingLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: adaptive.space(8)),
                  Text(
                    'Welcome, ${user?.name ?? 'Teacher'}! Manage your classroom below.',
                    textAlign: TextAlign.center,
                    style: AudyTypography.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(height: adaptive.space(24)),

            _buildStatsRow(adaptive, activeAssignments),
            SizedBox(height: adaptive.space(24)),

            // Section chips — the teacher portal's own navbar, in the same
            // style as the chip tabs on the student ProfilePage.
            Wrap(
              spacing: adaptive.space(12),
              runSpacing: adaptive.space(12),
              children: List.generate(_portalTabs.length, (index) {
                final tab = _portalTabs[index];
                return _PortalTabChip(
                  label: tab.label,
                  icon: tab.icon,
                  color: tab.color,
                  selected: _selectedPortalTab == index,
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => _selectedPortalTab = index);
                  },
                );
              }),
            ),
            SizedBox(height: adaptive.space(24)),

            if (_selectedPortalTab == 0) _buildClassroomSection(adaptive),
            if (_selectedPortalTab == 1) _buildAssignmentsSection(adaptive),
            if (_selectedPortalTab == 2) _buildWordBankCard(adaptive),
            if (_selectedPortalTab == 3)
              _buildAccountSection(adaptive, controller),
          ],
        );
      },
    );
  }

  Widget _buildStatsRow(AudyAdaptive adaptive, int activeAssignments) {
    final stats = [
      (_students.length, 'Students', Icons.group_rounded, AudyColors.skyBlue),
      (
        activeAssignments,
        'Active Tasks',
        Icons.assignment_late_rounded,
        Colors.orange,
      ),
      (
        _classWords.length,
        'Flashcards',
        Icons.style_rounded,
        AudyColors.blushPink,
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) SizedBox(width: adaptive.space(12)),
          Expanded(
            child: _TeacherStatTile(
              count: stats[i].$1,
              label: stats[i].$2,
              icon: stats[i].$3,
              color: stats[i].$4,
              adaptive: adaptive,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAssignmentsSection(AudyAdaptive adaptive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAssignmentProgressCard(adaptive),
        SizedBox(height: adaptive.space(20)),
        _buildAssignHomeworkCard(adaptive),
      ],
    );
  }

  Widget _buildAssignmentProgressCard(AudyAdaptive adaptive) {
    final entries = <(UserProfile, Map<String, dynamic>)>[];
    for (final student in _students) {
      for (final assignment in _studentAssignments[student.id] ?? const []) {
        entries.add((student, assignment));
      }
    }
    // Show what still needs attention first.
    entries.sort((a, b) {
      final aDone = a.$2['is_completed'] as bool? ?? false;
      final bDone = b.$2['is_completed'] as bool? ?? false;
      if (aDone == bDone) return 0;
      return aDone ? 1 : -1;
    });

    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Assignment Progress',
            style: AudyTypography.headingSmall.copyWith(fontSize: 18),
          ),
          SizedBox(height: adaptive.space(6)),
          Text(
            'See how each student is doing on their assigned tasks.',
            style: TextStyle(fontSize: 13, color: AudyColors.textLight),
          ),
          SizedBox(height: adaptive.space(16)),
          if (entries.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AudyColors.backgroundSoft.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                border: Border.all(color: AudyColors.borderLight, width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    color: AudyColors.textLight,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No assignments yet — create one below to track progress here.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AudyColors.textLight,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...entries.map((entry) {
              final student = entry.$1;
              final assignment = entry.$2;
              final gameType = (assignment['game_type'] ?? '').toString();
              return _AssignmentProgressTile(
                studentName: student.name,
                avatarColor: _avatarColorFor(student.name),
                gameLabel: _gameLabels[gameType] ?? gameType,
                gameIcon: _gameIcons[gameType] ?? Icons.sports_esports_rounded,
                gameColor: _gameColors[gameType] ?? AudyColors.skyBlue,
                current: (assignment['current_count'] as num?)?.toInt() ?? 0,
                target: (assignment['target_count'] as num?)?.toInt() ?? 1,
                isCompleted: assignment['is_completed'] as bool? ?? false,
                onManage: () => _showAssignmentActions(student.id, assignment),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildClassroomSection(AudyAdaptive adaptive) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: AudyColors.skyBlue),
        ),
      );
    }
    if (_students.isEmpty) {
      return _buildEmptyStudentsCard(adaptive);
    }
    return _buildClassroomGrid(adaptive);
  }

  Widget _buildAccountSection(
    AudyAdaptive adaptive,
    AudyController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLinkStudentCard(adaptive),
        SizedBox(height: adaptive.space(20)),
        AudyPanel(
          adaptive: adaptive,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sign Out',
                style: AudyTypography.headingSmall.copyWith(fontSize: 18),
              ),
              SizedBox(height: adaptive.space(6)),
              Text(
                'Sign out of the teacher portal on this device.',
                style: TextStyle(fontSize: 13, color: AudyColors.textLight),
              ),
              SizedBox(height: adaptive.space(16)),
              OutlinedButton.icon(
                onPressed: () async {
                  SoundService.instance.playTap();
                  // Clear the whole stack and leave for login immediately so
                  // the teacher shell never re-renders as the student
                  // dashboard while sign-out finishes in the background.
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                  await controller.logout();
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AudyColors.error,
                  side: BorderSide(
                    color: AudyColors.error.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AudySpacing.radiusMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkStudentCard(AudyAdaptive adaptive) {
    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add Student to Class',
            style: AudyTypography.headingSmall.copyWith(fontSize: 18),
          ),
          SizedBox(height: adaptive.space(6)),
          Text(
            'Invite student by email to include them in your classroom list.',
            style: TextStyle(fontSize: 13, color: AudyColors.textLight),
          ),
          SizedBox(height: adaptive.space(16)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _studentEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'student@email.com',
                    prefixIcon: const Icon(Icons.person_add_alt_1_outlined),
                    filled: true,
                    fillColor: AudyColors.backgroundSoft.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AudySpacing.radiusMedium,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isLinking ? null : _linkStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AudyColors.mintGreen,
                  foregroundColor: AudyColors.textOnColor,
                  minimumSize: const Size(80, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AudySpacing.radiusMedium,
                    ),
                  ),
                ),
                child: _isLinking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AudyColors.textOnColor,
                        ),
                      )
                    : const Icon(Icons.add_rounded),
              ),
            ],
          ),
          if (_linkMessage != null) ...[
            SizedBox(height: adaptive.space(12)),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _linkIsError
                    ? AudyColors.error.withValues(alpha: 0.1)
                    : AudyColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                border: Border.all(
                  color: _linkIsError
                      ? AudyColors.error.withValues(alpha: 0.3)
                      : AudyColors.success.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _linkMessage!,
                style: TextStyle(
                  fontSize: 13,
                  color: _linkIsError ? AudyColors.error : AudyColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWordBankCard(AudyAdaptive adaptive) {
    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Class Flashcard Custom Cards',
            style: AudyTypography.headingSmall.copyWith(fontSize: 18),
          ),
          SizedBox(height: adaptive.space(6)),
          Text(
            'Add custom cards with a word, its type, and an image for the Flashcard sentence game.',
            style: TextStyle(fontSize: 13, color: AudyColors.textLight),
          ),
          SizedBox(height: adaptive.space(16)),

          // Word Input field
          TextField(
            controller: _wordController,
            decoration: InputDecoration(
              labelText: 'Word / Text',
              hintText: 'Enter card text (e.g. Sleep)',
              prefixIcon: const Icon(Icons.label_outline_rounded),
              filled: true,
              fillColor: AudyColors.backgroundSoft.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
              ),
            ),
          ),
          SizedBox(height: adaptive.space(16)),

          // Word Type picker
          Text(
            'Word Type',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AudyColors.textSecondary,
            ),
          ),
          SizedBox(height: adaptive.space(8)),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _wordTypes.map((type) {
              final key = type['key']!;
              return _PortalTabChip(
                label: type['label']!,
                icon: _wordTypeIcons[key] ?? Icons.category_outlined,
                color: _wordCategoryColor(key).withValues(alpha: 0.28),
                selected: _selectedWordType == key,
                onTap: () {
                  SoundService.instance.playTap();
                  setState(() => _selectedWordType = key);
                },
              );
            }).toList(),
          ),
          SizedBox(height: adaptive.space(16)),

          // Card Image Picker row
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_outlined),
                label: const Text('Add Card Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AudyColors.backgroundSoft,
                  foregroundColor: AudyColors.textPrimary,
                  minimumSize: const Size(140, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AudySpacing.radiusMedium,
                    ),
                  ),
                ),
              ),
              if (_selectedImageBase64 != null) ...[
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(_selectedImageBase64!.split(',')[1]),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => setState(() => _selectedImageBase64 = null),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AudyColors.error,
                  ),
                ),
              ],
            ],
          ),
          if (_wordMessage != null) ...[
            SizedBox(height: adaptive.space(12)),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _wordIsError
                    ? AudyColors.error.withValues(alpha: 0.1)
                    : AudyColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                border: Border.all(
                  color: _wordIsError
                      ? AudyColors.error.withValues(alpha: 0.3)
                      : AudyColors.success.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _wordMessage!,
                style: TextStyle(
                  fontSize: 13,
                  color: _wordIsError ? AudyColors.error : AudyColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          SizedBox(height: adaptive.space(16)),

          ElevatedButton(
            onPressed: _isAddingWord ? null : _addClassWord,
            style: ElevatedButton.styleFrom(
              backgroundColor: AudyColors.skyBlue,
              foregroundColor: AudyColors.textOnColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
              ),
            ),
            child: _isAddingWord
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AudyColors.textOnColor,
                    ),
                  )
                : const Text('Add Custom Flashcard Card'),
          ),

          if (_classWords.isNotEmpty) ...[
            const Divider(color: AudyColors.borderLight, height: 32),
            Text(
              'Classroom Custom Flashcards — tap the ✕ to remove one',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AudyColors.textSecondary,
              ),
            ),
            SizedBox(height: adaptive.space(12)),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: _classWords.map((classWord) {
                return _ClassWordTile(
                  word: classWord,
                  label: _wordCategoryLabel(classWord.category),
                  color: _wordCategoryColor(classWord.category),
                  onDelete: () => _removeClassWord(classWord),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssignHomeworkCard(AudyAdaptive adaptive) {
    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Assign Classroom Tasks (Homework)',
            style: AudyTypography.headingSmall.copyWith(fontSize: 18),
          ),
          SizedBox(height: adaptive.space(16)),

          // Toggle for Assign Target
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => _assignToWholeClass = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_assignToWholeClass
                          ? AudyColors.skyBlue
                          : AudyColors.backgroundSoft.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        AudySpacing.radiusMedium,
                      ),
                      border: Border.all(
                        color: !_assignToWholeClass
                            ? AudyColors.skyBlue
                            : AudyColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Individual Student',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: !_assignToWholeClass
                              ? AudyColors.textOnColor
                              : AudyColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    SoundService.instance.playTap();
                    setState(() => _assignToWholeClass = true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _assignToWholeClass
                          ? AudyColors.skyBlue
                          : AudyColors.backgroundSoft.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        AudySpacing.radiusMedium,
                      ),
                      border: Border.all(
                        color: _assignToWholeClass
                            ? AudyColors.skyBlue
                            : AudyColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Entire Class',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _assignToWholeClass
                              ? AudyColors.textOnColor
                              : AudyColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: adaptive.space(16)),

          // Student picker (only if Individual Student is chosen)
          if (!_assignToWholeClass) ...[
            Text(
              'Select Student',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AudyColors.textSecondary,
              ),
            ),
            SizedBox(height: adaptive.space(8)),
            if (_students.isEmpty)
              Text(
                'Add a student from the Account tab first.',
                style: TextStyle(fontSize: 13, color: AudyColors.textLight),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _students.map((student) {
                  return _StudentPickerChip(
                    name: student.name,
                    color: _avatarColorFor(student.name),
                    selected: _selectedStudentId == student.id,
                    onTap: () {
                      SoundService.instance.playTap();
                      setState(() => _selectedStudentId = student.id);
                    },
                  );
                }).toList(),
              ),
            SizedBox(height: adaptive.space(16)),
          ],

          // Game Type picker
          Text(
            'Task Game',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AudyColors.textSecondary,
            ),
          ),
          SizedBox(height: adaptive.space(8)),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _gameTypes.map((game) {
              final key = game['key']!;
              return _PortalTabChip(
                label: game['label']!,
                icon: _gameIcons[key] ?? Icons.sports_esports_rounded,
                color: (_gameColors[key] ?? AudyColors.skyBlue).withValues(
                  alpha: 0.28,
                ),
                selected: _selectedGameType == key,
                onTap: () {
                  SoundService.instance.playTap();
                  setState(() => _selectedGameType = key);
                },
              );
            }).toList(),
          ),
          SizedBox(height: adaptive.space(16)),

          // Target Count slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Target Session Completions',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AudyColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$_selectedTargetCount times',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AudyColors.skyBlue,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _selectedTargetCount.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: AudyColors.skyBlue,
                inactiveColor: AudyColors.borderLight,
                onChanged: (val) {
                  setState(() => _selectedTargetCount = val.toInt());
                },
              ),
            ],
          ),
          SizedBox(height: adaptive.space(12)),

          // Recommendations list
          () {
            final recs = _getRecommendations();
            if (recs.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(color: AudyColors.borderLight, height: 24),
                Text(
                  'Recommended Tasks',
                  style: AudyTypography.headingSmall.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  _assignToWholeClass
                      ? 'Based on class-wide skill performance'
                      : (_selectedStudentId == null
                            ? 'Select a student to see suggestions'
                            : 'Based on student\'s individual needs'),
                  style: TextStyle(fontSize: 12, color: AudyColors.textLight),
                ),
                const SizedBox(height: 10),
                ...recs.map((rec) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AudyColors.backgroundSoft.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(
                          AudySpacing.radiusMedium,
                        ),
                        border: Border.all(
                          color: AudyColors.borderLight,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.insights_rounded,
                            color: AudyColors.skyBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rec.label,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AudyColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  rec.reason,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Skill: ${rec.targetSkill}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AudyColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              SoundService.instance.playTap();
                              setState(() {
                                _selectedGameType = rec.gameType;
                                _selectedTargetCount = 3;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AudyColors.skyBlue,
                              foregroundColor: AudyColors.textOnColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AudySpacing.radiusSmall,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Use',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          }(),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: _isAssigning ? null : _assignHomework,
            icon: const Icon(Icons.assignment_turned_in_rounded),
            label: const Text('Assign Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AudyColors.mintGreen,
              foregroundColor: AudyColors.textOnColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
              ),
            ),
          ),
          if (_assignMessage != null) ...[
            SizedBox(height: adaptive.space(12)),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _assignIsError
                    ? AudyColors.error.withValues(alpha: 0.1)
                    : AudyColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                border: Border.all(
                  color: _assignIsError
                      ? AudyColors.error.withValues(alpha: 0.3)
                      : AudyColors.success.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _assignMessage!,
                style: TextStyle(
                  fontSize: 13,
                  color: _assignIsError ? AudyColors.error : AudyColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyStudentsCard(AudyAdaptive adaptive) {
    return AudyPanel(
      adaptive: adaptive,
      padding: EdgeInsets.all(adaptive.space(32)),
      child: Column(
        children: [
          const Icon(
            Icons.group_outlined,
            size: 64,
            color: AudyColors.borderLight,
          ),
          SizedBox(height: adaptive.space(12)),
          const Text(
            'Classroom is empty.',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AudyColors.textSecondary,
            ),
          ),
          SizedBox(height: adaptive.space(4)),
          const Text(
            'Add student accounts using their emails above to track progress.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AudyColors.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildClassroomGrid(AudyAdaptive adaptive) {
    return AudyPanel(
      adaptive: adaptive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.group_rounded,
                color: AudyColors.skyBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'My Classroom (${_students.length} Enrolled)',
                style: AudyTypography.headingSmall.copyWith(fontSize: 18),
              ),
            ],
          ),
          SizedBox(height: adaptive.space(6)),
          Text(
            'Click on a student\'s profile card to view their detailed performance profile, completed sessions, and assignments.',
            style: TextStyle(fontSize: 13, color: AudyColors.textLight),
          ),
          SizedBox(height: adaptive.space(20)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: adaptive.isTablet || adaptive.isDesktop ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.78,
            ),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              final stats = _studentStats[student.id];
              final points = stats?['learning_points'] ?? 0;
              final streak = stats?['day_streak'] ?? 0;
              final assignments = _studentAssignments[student.id] ?? [];
              final activeAssignments = assignments
                  .where((a) => !(a['is_completed'] as bool))
                  .length;

              final avatarColor = _avatarColorFor(student.name);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: AudyColors.shadowSoft.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AudyColors.borderLight, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AudySpacing.radiusMedium - 1.5,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        SoundService.instance.playTap();
                        double classAvgAccuracy = 0;
                        int totalSessionsCount = 0;
                        for (final sList in _studentSessions.values) {
                          for (final s in sList) {
                            classAvgAccuracy +=
                                (s['accuracy_percent'] as num?)?.toDouble() ??
                                0.0;
                            totalSessionsCount++;
                          }
                        }
                        final avgAcc = totalSessionsCount > 0
                            ? classAvgAccuracy / totalSessionsCount
                            : 0.0;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentDetailPage(
                              student: student,
                              stats: _studentStats[student.id],
                              assignments:
                                  _studentAssignments[student.id] ?? [],
                              sessions: _studentSessions[student.id] ?? [],
                              classAverageAccuracy: avgAcc,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Top: Age & Status Badges
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AudyColors.skyBlue.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Age ${student.age}',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AudyColors.textSecondary,
                                    ),
                                  ),
                                ),
                                if (activeAssignments > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.assignment_late_rounded,
                                          size: 8,
                                          color: Colors.orange,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '$activeAssignments tasks',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (assignments.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AudyColors.success.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          size: 8,
                                          color: AudyColors.success,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          'Done',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AudyColors.success,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const Spacer(),
                            // Center: Avatar
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: avatarColor.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: avatarColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  child: Icon(
                                    Icons.face_rounded,
                                    color: avatarColor,
                                    size: 36,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Bottom: Name & Badges
                            Text(
                              student.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AudyTypography.cardTitle.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 13,
                                  color: AudyColors.activityRewards,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '$points',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AudyColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  size: 13,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '$streak',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AudyColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TeacherRecommendation {
  const _TeacherRecommendation({
    required this.gameType,
    required this.label,
    required this.reason,
    required this.targetSkill,
  });

  final String gameType;
  final String label;
  final String reason;
  final String targetSkill;
}

class _PortalTabSpec {
  const _PortalTabSpec({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

/// Pill-shaped section chip — the teacher portal's own navbar, styled to
/// match the chip tabs on the student-facing ProfilePage.
class _PortalTabChip extends StatelessWidget {
  const _PortalTabChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          border: selected
              ? Border.all(color: const Color(0xFF5D6A7E), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA5B4C7).withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF243A5A)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF243A5A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small at-a-glance stat card for the portal home header (students, active
/// tasks, flashcards) — reuses the app's card/shadow/typography tokens.
class _TeacherStatTile extends StatelessWidget {
  const _TeacherStatTile({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
    required this.adaptive,
  });

  final int count;
  final String label;
  final IconData icon;
  final Color color;
  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: adaptive.space(14),
        horizontal: adaptive.space(8),
      ),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
        border: Border.all(color: AudyColors.borderLight, width: 1),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: adaptive.space(24)),
          SizedBox(height: adaptive.space(6)),
          Text(
            '$count',
            style: AudyTypography.starCount.copyWith(
              fontSize: adaptive.space(22),
            ),
          ),
          SizedBox(height: adaptive.space(2)),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AudyTypography.bodySmall.copyWith(
              fontSize: adaptive.space(11),
              color: AudyColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// A flashcard-game-styled tile for one custom class word — mirrors
/// [FlashcardWordCard]'s look (colored border, circular badge, category
/// pill) so the word bank reads like the actual game, with a delete "✕"
/// badge in the corner to remove the card.
class _ClassWordTile extends StatelessWidget {
  const _ClassWordTile({
    required this.word,
    required this.label,
    required this.color,
    required this.onDelete,
  });

  final ClassWord word;
  final String label;
  final Color color;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final imageUrl = word.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    Widget avatarChild = Icon(Icons.style_rounded, color: color, size: 28);
    if (hasImage) {
      if (imageUrl.startsWith('data:image')) {
        final bytes = base64Decode(imageUrl.split(',')[1]);
        avatarChild = ClipOval(
          child: Image.memory(bytes, width: 52, height: 52, fit: BoxFit.cover),
        );
      } else if (imageUrl.startsWith('assets/')) {
        avatarChild = ClipOval(
          child: Image.asset(
            imageUrl,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    return Container(
      width: 116,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        border: Border.all(color: color, width: 2.5),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Center(child: avatarChild),
              ),
              const SizedBox(height: 10),
              Text(
                word.word,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AudyColors.textPrimary,
                ),
              ),
            ],
          ),
          Positioned(
            top: -10,
            right: -10,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AudyColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small pill-shaped avatar chip for picking a single student — used by the
/// assignment form's "Individual Student" mode.
class _StudentPickerChip extends StatelessWidget {
  const _StudentPickerChip({
    required this.name,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.22)
              : AudyColors.backgroundSoft.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : AudyColors.borderLight,
            width: selected ? 2 : 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(Icons.face_rounded, size: 14, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected
                    ? AudyColors.textPrimary
                    : AudyColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One row in the "Assignment Progress" list — a student, the task they were
/// given, and a progress bar toward the target count.
class _AssignmentProgressTile extends StatelessWidget {
  const _AssignmentProgressTile({
    required this.studentName,
    required this.avatarColor,
    required this.gameLabel,
    required this.gameIcon,
    required this.gameColor,
    required this.current,
    required this.target,
    required this.isCompleted,
    required this.onManage,
  });

  final String studentName;
  final Color avatarColor;
  final String gameLabel;
  final IconData gameIcon;
  final Color gameColor;
  final int current;
  final int target;
  final bool isCompleted;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final barColor = isCompleted ? AudyColors.success : gameColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AudyColors.backgroundSoft.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
        border: Border.all(color: AudyColors.borderLight, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor.withValues(alpha: 0.18),
            child: Icon(Icons.face_rounded, color: avatarColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        studentName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AudyColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(gameIcon, size: 14, color: gameColor),
                    const SizedBox(width: 4),
                    Text(
                      gameLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: gameColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AudyColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCompleted ? 'Completed 🎉' : '$current / $target',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? AudyColors.success
                        : AudyColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onManage,
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.more_vert_rounded,
                size: 20,
                color: AudyColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One row inside the "manage assignment" bottom sheet.
class _AssignmentActionTile extends StatelessWidget {
  const _AssignmentActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AudyColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
