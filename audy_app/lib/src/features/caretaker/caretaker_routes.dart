import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_routes.dart';
import '../../data/models/game_configuration.dart';
import '../../data/repositories/caretaker_repository.dart';
import '../../state/audy_controller.dart';
import '../../state/caretaker_controller.dart';
import '../parent/parent_dashboard.dart';
import '../parent/parent_profile_page.dart';
import '../parent/parent_child_progress_page.dart';
import '../teacher/teacher_dashboard.dart';
import '../teacher/teacher_profile_page.dart';
import '../teacher/teacher_child_progress_page.dart';
import 'assignments_rewards_page.dart';
import 'caretaker_shell.dart';
import 'caretaker_ui.dart';
import 'customization/customization_page.dart';
import 'customization/game_editor.dart';

class CaretakerEditorArguments {
  const CaretakerEditorArguments(this.childId, this.game);
  final String childId;
  final CaretakerGame game;
}

class CaretakerRoute extends StatelessWidget {
  const CaretakerRoute(this.route, {super.key});
  final String route;
  @override
  Widget build(BuildContext context) =>
      CaretakerAccountGuard(child: _page(context));
  Widget _page(BuildContext context) {
    final role = AudyScope.of(context).currentUser?.role;
    if (route == AppRoutes.caretaker) return const CaretakerShell();
    if (route == AppRoutes.caretakerChildren) {
      return const CaretakerShell(initialTab: 2, manageChildren: true);
    }
    if (route == AppRoutes.caretakerProfile) {
      return const CaretakerShell(initialTab: 2);
    }
    if (route == AppRoutes.caretakerCustomization) {
      return const _CustomizationEntry();
    }
    if (route == AppRoutes.caretakerAssignments) {
      return const CaretakerAssignmentsRewardsPage();
    }
    if (route == AppRoutes.caretakerEdit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is CaretakerEditorArguments) {
        return _CustomizationEntry(arguments: args);
      }
    }
    if (route.contains('/legacy/') && (role == 'parent' || role == 'teacher')) {
      final parent = role == 'parent';
      final page = switch (route) {
        AppRoutes.caretakerLegacyHome =>
          parent ? const ParentDashboard() : const TeacherDashboard(),
        AppRoutes.caretakerLegacyProgress =>
          parent
              ? const ParentChildProgressPage()
              : const TeacherChildProgressPage(),
        _ => parent ? const ParentProfilePage() : const TeacherProfilePage(),
      };
      return Scaffold(
        appBar: AppBar(
          title: Text(ct(context, 'Legacy tools', 'เครื่องมือเดิม')),
        ),
        body: page,
      );
    }
    final title = switch (route) {
      AppRoutes.caretakerStudyPlan => ct(context, 'Study Plan', 'แผนการเรียน'),
      AppRoutes.caretakerGuide => ct(context, 'Manual / Guide', 'คู่มือ'),
      AppRoutes.caretakerAssignments => ct(
        context,
        'Assignments & Rewards',
        'งานและรางวัล',
      ),
      _ => ct(context, 'Unavailable', 'ไม่พร้อมใช้งาน'),
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: CaretakerPageBody(
        children: [
          Center(
            child: Text(
              ct(
                context,
                'TBD — Not available in this phase',
                'TBD — ยังไม่เปิดใช้งานในระยะนี้',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomizationEntry extends StatefulWidget {
  const _CustomizationEntry({this.arguments});
  final CaretakerEditorArguments? arguments;
  @override
  State<_CustomizationEntry> createState() => _CustomizationEntryState();
}

class _CustomizationEntryState extends State<_CustomizationEntry> {
  CaretakerController? _controller;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final id = AudyScope.of(context).currentUser?.id;
    if (id != null) {
      _controller = CaretakerController(
        id,
        CaretakerRepository(Supabase.instance.client),
      );
      _controller!.load();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final args = widget.arguments;
        if (args == null) return CustomizationPage(controller: c);
        if (c.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (c.error != null) {
          return Scaffold(body: CaretakerNotice(c.error!, onRetry: c.load));
        }
        final child = c.children
            .where((ch) => ch.id == args.childId)
            .firstOrNull;
        if (child == null) {
          return Scaffold(
            body: Center(
              child: Text(
                ct(
                  context,
                  'Choose a child in your care list.',
                  'เลือกเด็กในความดูแล',
                ),
              ),
            ),
          );
        }
        return GameEditor(
          key: ValueKey('${child.id}:${args.game.key}'),
          child: child,
          game: args.game,
          repository: GameConfigurationRepository(Supabase.instance.client),
        );
      },
    );
  }
}
