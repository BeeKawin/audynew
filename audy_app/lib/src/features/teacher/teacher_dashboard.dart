import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
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

  String? _assignMessage;
  bool _assignIsError = false;

  // Homework form state
  String? _selectedStudentId;
  String _selectedGameType = 'emotion_classify';
  int _selectedTargetCount = 3;

  final List<Map<String, String>> _gameTypes = [
    {'key': 'emotion_classify', 'label': 'Emotion Recognition'},
    {'key': 'emotion_mimic', 'label': 'Emotion Mimicking'},
    {'key': 'minipuzzle', 'label': 'Mini Puzzle'},
    {'key': 'sorting', 'label': 'Shape Sorting'},
    {'key': 'reaction_time', 'label': 'Reaction Time'},
    {'key': 'reading', 'label': 'Read & Speak'},
    {'key': 'social_chat', 'label': 'Social Chat'},
  ];

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
        _wordMessage = 'Please enter a name or word.';
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
        await _authService.addClassWord(user.id, word, imageUrl: _selectedImageBase64);
        setState(() {
          _wordMessage = 'Added "$word" to class word bank!';
          _wordIsError = false;
          _wordController.clear();
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

  Future<void> _assignHomework() async {
    if (_selectedStudentId == null) {
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
        await _authService.assignHomework(
          user.id,
          _selectedStudentId!,
          _selectedGameType,
          _selectedTargetCount,
        );
        setState(() {
          _assignMessage = 'Successfully assigned homework!';
          _assignIsError = false;
        });
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

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    final user = controller.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Teacher Dashboard',
          style: AudyTypography.headingLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              SoundService.instance.playTap();
              await controller.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: AudyResponsivePage(
        scrollable: true,
        builder: (context, adaptive) {
          return Padding(
            padding: EdgeInsets.all(adaptive.space(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(adaptive.space(20)),
                  decoration: BoxDecoration(
                    color: AudyColors.mintGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
                    border: Border.all(color: AudyColors.mintGreen, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.school_rounded,
                        size: 48,
                        color: AudyColors.mintGreen,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${user?.name ?? 'Teacher'}!',
                              style: AudyTypography.headingSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage classroom, assign tasks, and customize learning content.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AudyColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: adaptive.space(24)),

                // Tab-like section layout
                _buildLinkStudentCard(adaptive),
                SizedBox(height: adaptive.space(24)),

                _buildAssignHomeworkCard(adaptive),
                SizedBox(height: adaptive.space(24)),

                _buildWordBankCard(adaptive),
                SizedBox(height: adaptive.space(24)),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AudyColors.skyBlue),
                    ),
                  )
                else if (_students.isEmpty) ...[
                  Text(
                    'Classroom Grid',
                    style: AudyTypography.headingSmall,
                  ),
                  SizedBox(height: adaptive.space(12)),
                  _buildEmptyStudentsCard(adaptive),
                ] else
                  _buildClassroomGrid(adaptive),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinkStudentCard(AudyAdaptive adaptive) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(adaptive.space(20)),
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
                        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
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
                      borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
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
      ),
    );
  }

  Widget _buildWordBankCard(AudyAdaptive adaptive) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(adaptive.space(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Class Vocabulary Word Bank (Cards)',
              style: AudyTypography.headingSmall.copyWith(fontSize: 18),
            ),
            SizedBox(height: adaptive.space(6)),
            Text(
              'Add custom cards with a subject name and an optional image for the "Read & Speak" game.',
              style: TextStyle(fontSize: 13, color: AudyColors.textLight),
            ),
            SizedBox(height: adaptive.space(16)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _wordController,
                    decoration: InputDecoration(
                      hintText: 'Enter subject name (e.g. Apple)',
                      prefixIcon: const Icon(Icons.label_outline_rounded),
                      filled: true,
                      fillColor: AudyColors.backgroundSoft.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
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
                  onPressed: _isAddingWord ? null : _addClassWord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AudyColors.skyBlue,
                    foregroundColor: AudyColors.textOnColor,
                    minimumSize: const Size(80, 56),
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
                      : const Icon(Icons.check_rounded),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(12)),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Add Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AudyColors.backgroundSoft,
                    foregroundColor: AudyColors.textPrimary,
                    minimumSize: const Size(120, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
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
                    icon: const Icon(Icons.delete_outline, color: AudyColors.error),
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
            if (_classWords.isNotEmpty) ...[
              SizedBox(height: adaptive.space(16)),
              Text(
                'Class Nouns / Cards Added:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AudyColors.textSecondary,
                ),
              ),
              SizedBox(height: adaptive.space(8)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _classWords.map((classWord) {
                  final hasImage = classWord.imageUrl != null && classWord.imageUrl!.isNotEmpty;
                  Widget? avatar;
                  if (hasImage) {
                    final imgStr = classWord.imageUrl!;
                    if (imgStr.startsWith('data:image')) {
                      final bytes = base64Decode(imgStr.split(',')[1]);
                      avatar = ClipOval(
                        child: Image.memory(bytes, width: 24, height: 24, fit: BoxFit.cover),
                      );
                    } else if (imgStr.startsWith('assets/')) {
                      avatar = ClipOval(
                        child: Image.asset(imgStr, width: 24, height: 24, fit: BoxFit.cover),
                      );
                    }
                  }
                  return Chip(
                    avatar: avatar,
                    label: Text(
                      classWord.word,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    backgroundColor: AudyColors.skyBlue.withValues(alpha: 0.15),
                    side: const BorderSide(color: AudyColors.skyBlue),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssignHomeworkCard(AudyAdaptive adaptive) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(adaptive.space(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Assign Classroom Tasks (Homework)',
              style: AudyTypography.headingSmall.copyWith(fontSize: 18),
            ),
            SizedBox(height: adaptive.space(16)),

            // Student selection dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedStudentId,
              hint: const Text('Select Student'),
              decoration: InputDecoration(
                labelText: 'Student',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                ),
              ),
              items: _students.map((student) {
                return DropdownMenuItem<String>(
                  value: student.id,
                  child: Text(student.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedStudentId = val);
              },
            ),
            SizedBox(height: adaptive.space(16)),

            // Game Type selection dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedGameType,
              decoration: InputDecoration(
                labelText: 'Task Game',
                prefixIcon: const Icon(Icons.sports_esports_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                ),
              ),
              items: _gameTypes.map((game) {
                return DropdownMenuItem<String>(
                  value: game['key'],
                  child: Text(game['label']!),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedGameType = val);
                }
              },
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
      ),
    );
  }

  Widget _buildEmptyStudentsCard(AudyAdaptive adaptive) {
    return Card(
      elevation: 2,
      color: AudyColors.backgroundSoft.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
      ),
      child: Padding(
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
              style: TextStyle(
                fontSize: 13,
                color: AudyColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildClassroomGrid(AudyAdaptive adaptive) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        side: const BorderSide(color: AudyColors.borderLight, width: 1.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(adaptive.space(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.group_rounded, color: AudyColors.skyBlue, size: 24),
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
                final activeAssignments = assignments.where((a) => !(a['is_completed'] as bool)).length;
                
                final avatarColors = [
                  AudyColors.skyBlue,
                  AudyColors.mintGreen,
                  AudyColors.activityRewards,
                  Colors.orange,
                  AudyColors.softLavender,
                  AudyColors.blushPink,
                ];
                final avatarColor = avatarColors[student.name.hashCode % avatarColors.length];

                return Container(
                  decoration: BoxDecoration(
                    color: AudyColors.backgroundCard,
                    borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: AudyColors.shadowSoft.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(
                      color: AudyColors.borderLight,
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AudySpacing.radiusMedium - 1.5),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          SoundService.instance.playTap();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentDetailPage(
                                student: student,
                                stats: _studentStats[student.id],
                                assignments: _studentAssignments[student.id] ?? [],
                                sessions: _studentSessions[student.id] ?? [],
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
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AudyColors.skyBlue.withValues(alpha: 0.15),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.assignment_late_rounded, size: 8, color: Colors.orange),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AudyColors.success.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_rounded, size: 8, color: AudyColors.success),
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
                                    backgroundColor: avatarColor.withValues(alpha: 0.15),
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
      ),
    );
  }
}
