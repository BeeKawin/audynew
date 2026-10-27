import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/auth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import '../parent/child_profile_selector.dart';
import '../parent/parent_child_analytics.dart';

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AudyScope.of(context).loadTeacherStudents(force: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    return AudyResponsivePage(
      builder: (context, adaptive) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AudyBackButton(
              label: controller.tr('back_home'),
              onPressed: () {
                SoundService.instance.playTap();
                Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              },
            ),
            SizedBox(height: adaptive.space(24)),
            Text(
              controller.tr('profile'),
              style: TextStyle(
                fontSize: adaptive.space(30),
                fontWeight: FontWeight.w800,
                color: AudyColors.textPrimary,
              ),
            ),
            SizedBox(height: adaptive.space(8)),
            Text(
              'Manage student profiles and individual learning dashboards.',
              style: TextStyle(
                fontSize: adaptive.space(16),
                color: AudyColors.textLight,
              ),
            ),
            SizedBox(height: adaptive.space(24)),
            Wrap(
              spacing: adaptive.space(12),
              runSpacing: adaptive.space(12),
              children: [
                _TeacherProfileTabButton(
                  label: controller.tr('profile'),
                  icon: Icons.person_outline_rounded,
                  selected: _selectedTab == 0,
                  color: const Color(0xFFE7D8FA),
                  onTap: () => _selectTab(0),
                ),
                _TeacherProfileTabButton(
                  label: controller.tr('institution_panel'),
                  icon: Icons.school_outlined,
                  selected: _selectedTab == 1,
                  color: const Color(0xFFC9E8C1),
                  onTap: () => _selectTab(1),
                ),
                _TeacherProfileTabButton(
                  label: controller.tr('settings'),
                  icon: Icons.settings_outlined,
                  selected: _selectedTab == 2,
                  color: const Color(0xFFF8C7DF),
                  onTap: () => _selectTab(2),
                ),
              ],
            ),
            SizedBox(height: adaptive.space(22)),
            if (_selectedTab == 0)
              _TeacherProfileContent(adaptive: adaptive, controller: controller)
            else if (_selectedTab == 1)
              _TeacherInstitutionContent(
                adaptive: adaptive,
                controller: controller,
              )
            else
              _TeacherSettingsPlaceholder(adaptive: adaptive),
          ],
        );
      },
    );
  }

  void _selectTab(int tab) {
    SoundService.instance.playTap();
    setState(() => _selectedTab = tab);
  }
}

class _TeacherProfileContent extends StatelessWidget {
  const _TeacherProfileContent({
    required this.adaptive,
    required this.controller,
  });

  final AudyAdaptive adaptive;
  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    final teacher = controller.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AudyPanel(
          adaptive: adaptive,
          child: Row(
            children: [
              CircleAvatar(
                radius: adaptive.isPhone ? 34 : 42,
                backgroundColor: AudyColors.mintGreen.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.school_outlined,
                  size: 36,
                  color: AudyColors.textPrimary,
                ),
              ),
              SizedBox(width: adaptive.space(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher?.name ?? controller.tr('user'),
                      style: TextStyle(
                        fontSize: adaptive.space(24),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (teacher?.email != null) ...[
                      SizedBox(height: adaptive.space(4)),
                      Text(
                        teacher!.email!,
                        style: const TextStyle(color: AudyColors.textLight),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: adaptive.space(24)),
        Text(
          'Students under your care',
          style: TextStyle(
            fontSize: adaptive.space(20),
            fontWeight: FontWeight.w800,
            color: AudyColors.textPrimary,
          ),
        ),
        SizedBox(height: adaptive.space(12)),
        if (controller.isLoadingTeacherStudents &&
            controller.teacherStudents.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AudyColors.skyBlue),
            ),
          )
        else if (controller.teacherStudentsError != null &&
            controller.teacherStudents.isEmpty)
          AudyPanel(
            adaptive: adaptive,
            child: Text(
              controller.teacherStudentsError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AudyColors.error),
            ),
          )
        else if (controller.teacherStudents.isEmpty)
          AudyPanel(
            adaptive: adaptive,
            child: const Text(
              'No linked student accounts yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AudyColors.textLight),
            ),
          )
        else
          ...controller.teacherStudents.map(
            (student) => Padding(
              padding: EdgeInsets.only(bottom: adaptive.space(12)),
              child: _TeacherStudentCard(student: student, adaptive: adaptive),
            ),
          ),
        SizedBox(height: adaptive.space(12)),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              SoundService.instance.playTap();
              final navigator = Navigator.of(context);
              await controller.logout();
              if (navigator.mounted) {
                navigator.pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: Text(controller.tr('log_out')),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(48, 56),
              backgroundColor: AudyColors.error,
              foregroundColor: AudyColors.textOnColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _TeacherInstitutionContent extends StatelessWidget {
  const _TeacherInstitutionContent({
    required this.adaptive,
    required this.controller,
  });

  final AudyAdaptive adaptive;
  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    final student = controller.selectedTeacherStudent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChildProfileSelector(
          children: controller.teacherStudents,
          selectedChildId: controller.selectedTeacherStudentId,
          isLoading: controller.isLoadingTeacherStudents,
          errorMessage: controller.teacherStudentsError,
          label: 'Selected student',
          emptyMessage: 'No linked student accounts yet.',
          onRetry: () => controller.loadTeacherStudents(force: true),
          onSelected: controller.selectTeacherStudent,
        ),
        if (student != null) ...[
          SizedBox(height: adaptive.space(20)),
          ParentChildAnalytics(
            key: ValueKey(student.id),
            child: student,
            adaptive: adaptive,
          ),
        ],
      ],
    );
  }
}

class _TeacherStudentCard extends StatelessWidget {
  const _TeacherStudentCard({required this.student, required this.adaptive});

  final UserProfile student;
  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    final joined = student.createdAt.toLocal();
    return AudyPanel(
      adaptive: adaptive,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AudyColors.mintGreen.withValues(alpha: 0.2),
            child: const Icon(
              Icons.child_care_rounded,
              size: 30,
              color: AudyColors.mintGreen,
            ),
          ),
          SizedBox(width: adaptive.space(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: TextStyle(
                    fontSize: adaptive.space(18),
                    fontWeight: FontWeight.w800,
                    color: AudyColors.textPrimary,
                  ),
                ),
                SizedBox(height: adaptive.space(4)),
                Text(
                  'Age: ${student.age}',
                  style: const TextStyle(color: AudyColors.textLight),
                ),
                if (student.email != null)
                  Text(
                    student.email!,
                    style: const TextStyle(color: AudyColors.textLight),
                  ),
                Text(
                  'Joined: ${joined.day}/${joined.month}/${joined.year}',
                  style: const TextStyle(color: AudyColors.textLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherSettingsPlaceholder extends StatelessWidget {
  const _TeacherSettingsPlaceholder({required this.adaptive});

  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    return AudyPanel(
      adaptive: adaptive,
      child: const SizedBox(
        width: double.infinity,
        height: 120,
        child: Center(
          child: Text(
            'TBD',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AudyColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _TeacherProfileTabButton extends StatelessWidget {
  const _TeacherProfileTabButton({
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
    return Material(
      color: selected ? color : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AudyColors.textPrimary : AudyColors.borderLight,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: AudyColors.textPrimary),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
