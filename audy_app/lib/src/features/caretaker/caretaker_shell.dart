import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../data/repositories/caretaker_repository.dart';
import '../../services/auth_service.dart';
import '../../state/audy_controller.dart';
import '../../state/caretaker_controller.dart';
import '../parent/parent_child_progress_page.dart';
import '../parent/parent_dashboard.dart';
import '../settings/app_settings_page.dart';
import '../teacher/teacher_dashboard.dart';
import 'caretaker_ui.dart';
import 'child_progress_page.dart';
import 'children_page.dart';
import 'customization/customization_page.dart';

class CaretakerShell extends StatefulWidget {
  const CaretakerShell({
    super.key,
    this.initialTab = 0,
    this.manageChildren = false,
    this.repository,
  });
  final int initialTab;
  final bool manageChildren;
  final CaretakerRepository? repository;
  @override
  State<CaretakerShell> createState() => _CaretakerShellState();
}

class _CaretakerShellState extends State<CaretakerShell> {
  CaretakerController? _controller;
  late int _tab = widget.initialTab;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final account = AudyScope.of(context).currentUser;
    if (_controller?.accountId == account?.id) return;
    _controller?.dispose();
    _controller = null;
    if (account?.mode == AppMode.caretaker) {
      _controller = CaretakerController(
        account!.id,
        widget.repository ?? CaretakerRepository(Supabase.instance.client),
      );
      _controller!.load();
      if (widget.manageChildren) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _manageChildren(_controller!);
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _open(Widget page) => Navigator.push<void>(
    context,
    MaterialPageRoute<void>(builder: (_) => CaretakerAccountGuard(child: page)),
  );

  Future<void> _manageChildren(CaretakerController c) => _open(
    Scaffold(
      appBar: AppBar(title: Text(ct(context, 'Manage Children', 'จัดการเด็ก'))),
      body: ListenableBuilder(
        listenable: c,
        builder: (_, _) => ChildrenPage(controller: c),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final account = AudyScope.of(context).currentUser;
    final c = _controller;
    if (c == null || account?.mode != AppMode.caretaker) {
      return Scaffold(
        body: Center(
          child: Text(
            ct(
              context,
              'Sign in as a Caretaker to continue.',
              'กรุณาเข้าสู่ระบบผู้ดูแล',
            ),
          ),
        ),
      );
    }
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => Scaffold(
        body: switch (_tab) {
          0 => _home(c),
          1 => CaretakerChildProgress(controller: c),
          _ => _profile(account!, c),
        },
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (index) => setState(() => _tab = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: ct(context, 'Home', 'หน้าหลัก'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.query_stats_rounded),
              label: ct(context, 'Child Progress', 'ความก้าวหน้า'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              label: ct(context, 'Profile', 'โปรไฟล์'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _home(CaretakerController c) => AudyResponsivePage(
    builder: (context, adaptive) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AudyPanel(
          adaptive: adaptive,
          child: Row(
            children: [
              const Icon(
                Icons.supervisor_account_rounded,
                color: AudyColors.skyBlue,
                size: 48,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ct(context, 'Caretaker Home', 'หน้าหลักผู้ดูแล'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      ct(
                        context,
                        'Welcome, ${AudyScope.of(context).currentUser?.name ?? ''}',
                        'ยินดีต้อนรับ ${AudyScope.of(context).currentUser?.name ?? ''}',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AudyAdaptiveGrid(
          adaptive: adaptive,
          phoneColumns: 1,
          tabletColumns: 2,
          desktopColumns: 2,
          items: [
            _homeCard(
              adaptive,
              'Study Plan',
              'แผนการเรียน',
              Icons.calendar_month_rounded,
              const Color(0xFFBDD8F2),
              AppRoutes.caretakerStudyPlan,
            ),
            _homeCard(
              adaptive,
              'Manual (Guide)',
              'คู่มือ',
              Icons.menu_book_rounded,
              const Color(0xFFF8C7DF),
              AppRoutes.caretakerGuide,
            ),
            AudyActionCard(
              adaptive: adaptive,
              title: ct(context, 'Customization', 'ปรับแต่งเกม'),
              icon: Icons.tune_rounded,
              color: const Color(0xFFC9E8C1),
              onTap: () => _open(CustomizationPage(controller: c)),
            ),
            _homeCard(
              adaptive,
              'Assignments & Rewards',
              'งานและรางวัล',
              Icons.card_giftcard_rounded,
              const Color(0xFFE7D8FA),
              AppRoutes.caretakerAssignments,
            ),
          ],
        ),
      ],
    ),
  );

  Widget _homeCard(
    AudyAdaptive adaptive,
    String en,
    String th,
    IconData icon,
    Color color,
    String route,
  ) => AudyActionCard(
    adaptive: adaptive,
    title: ct(context, '$en · TBD', '$th · TBD'),
    icon: icon,
    color: color,
    onTap: () => Navigator.pushNamed(context, route),
  );

  Widget _profile(
    UserProfile account,
    CaretakerController c,
  ) => AudyResponsivePage(
    builder: (context, adaptive) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ct(context, 'Profile', 'โปรไฟล์'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        AudyPanel(
          adaptive: adaptive,
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFFE7D8FA),
                child: Icon(
                  Icons.person_rounded,
                  size: 36,
                  color: AudyColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(account.email ?? ''),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          ct(context, 'My Children', 'เด็กที่เชื่อมโยง'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          ct(
            context,
            'In my care: ${c.children.length} / ${c.roster?.plannedCount ?? 0}',
            'ในความดูแล: ${c.children.length} / ${c.roster?.plannedCount ?? 0}',
          ),
        ),
        if (c.loading) const LinearProgressIndicator(),
        if (c.error != null) CaretakerNotice(c.error!, onRetry: c.load),
        if (!c.loading &&
            c.error == null &&
            (c.roster?.children.isEmpty ?? true))
          CaretakerNotice(
            ct(
              context,
              'Link an existing Student account to get started.',
              'เชื่อมโยงบัญชีเด็กเพื่อเริ่มต้น',
            ),
          ),
        for (final entry in c.roster?.children ?? <CaretakerChild>[]) ...[
          const SizedBox(height: 12),
          AudyPanel(
            adaptive: adaptive,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFBDD8F2),
                child: Icon(
                  Icons.child_care_rounded,
                  color: AudyColors.textPrimary,
                ),
              ),
              title: Text(entry.profile.name),
              subtitle: Text(
                '${ct(context, 'Age', 'อายุ')}: ${entry.profile.age} · '
                '${entry.inCare ? ct(context, 'In my care', 'อยู่ในความดูแล') : ct(context, 'Linked · not selected', 'เชื่อมโยงแล้ว · ยังไม่เลือก')}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                if (!entry.inCare) {
                  await _manageChildren(c);
                  return;
                }
                await c.select(entry.profile.id);
                if (mounted) setState(() => _tab = 1);
              },
            ),
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => _manageChildren(c),
          icon: const Icon(Icons.group_add_outlined),
          label: Text(ct(context, 'Manage Children', 'จัดการเด็ก')),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () =>
              _open(AppSettingsPage(legacyTools: _legacyTools(account))),
          icon: const Icon(Icons.settings_outlined),
          label: Text(ct(context, 'Settings', 'การตั้งค่า')),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () async {
            final navigator = Navigator.of(context);
            final logout = AudyScope.of(context).logout();
            navigator.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            await logout;
          },
          icon: const Icon(Icons.logout_rounded),
          label: Text(ct(context, 'Log out', 'ออกจากระบบ')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AudyColors.error,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );

  Widget? _legacyTools(UserProfile account) {
    if (account.role != 'parent' && account.role != 'teacher') return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ct(context, 'Legacy Tools', 'เครื่องมือเดิม'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          ct(
            context,
            'These tools use their original linked child lists.',
            'เครื่องมือเหล่านี้ใช้รายชื่อเด็กที่เชื่อมโยงเดิม',
          ),
        ),
        ListTile(
          minVerticalPadding: 16,
          leading: const Icon(Icons.assignment_outlined),
          title: Text(
            ct(context, 'Existing assignments & portal', 'งานและพอร์ทัลเดิม'),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _open(
            account.role == 'parent'
                ? const ParentDashboard()
                : const TeacherDashboard(),
          ),
        ),
        ListTile(
          minVerticalPadding: 16,
          leading: const Icon(Icons.card_giftcard_outlined),
          title: Text(ct(context, 'Existing rewards', 'รางวัลเดิม')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _open(
            ParentChildProgressPage(forTeacher: account.role == 'teacher'),
          ),
        ),
      ],
    );
  }
}
