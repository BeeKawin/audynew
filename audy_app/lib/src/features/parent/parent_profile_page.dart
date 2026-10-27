import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/auth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import 'child_profile_selector.dart';
import 'parent_child_analytics.dart';

class ParentProfilePage extends StatefulWidget {
  const ParentProfilePage({super.key});

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AudyScope.of(context).loadParentChildren();
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
              controller.tr('parent_profile_description'),
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
                _ParentTabButton(
                  label: controller.tr('profile'),
                  icon: Icons.person_outline_rounded,
                  selected: _selectedTab == 0,
                  color: const Color(0xFFE7D8FA),
                  onTap: () => _selectTab(0),
                ),
                _ParentTabButton(
                  label: controller.tr('parent_dashboard'),
                  icon: Icons.query_stats_rounded,
                  selected: _selectedTab == 1,
                  color: const Color(0xFFBDD8F2),
                  onTap: () => _selectTab(1),
                ),
                _ParentTabButton(
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
              _ParentProfileContent(adaptive: adaptive, controller: controller)
            else if (_selectedTab == 1)
              _ParentAnalyticsContent(
                adaptive: adaptive,
                controller: controller,
              )
            else
              AudyPanel(
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
              ),
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

class _ParentProfileContent extends StatelessWidget {
  const _ParentProfileContent({
    required this.adaptive,
    required this.controller,
  });

  final AudyAdaptive adaptive;
  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    final parent = controller.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AudyPanel(
          adaptive: adaptive,
          child: Row(
            children: [
              CircleAvatar(
                radius: adaptive.isPhone ? 34 : 42,
                backgroundColor: const Color(0xFFE7D8FA),
                child: const Icon(
                  Icons.person_outline_rounded,
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
                      parent?.name ?? controller.tr('user'),
                      style: TextStyle(
                        fontSize: adaptive.space(24),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (parent?.email != null) ...[
                      SizedBox(height: adaptive.space(4)),
                      Text(
                        parent!.email!,
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
          controller.tr('children_under_care'),
          style: TextStyle(
            fontSize: adaptive.space(20),
            fontWeight: FontWeight.w800,
            color: AudyColors.textPrimary,
          ),
        ),
        SizedBox(height: adaptive.space(12)),
        if (controller.isLoadingParentChildren &&
            controller.parentChildren.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AudyColors.skyBlue),
            ),
          )
        else if (controller.parentChildren.isEmpty)
          AudyPanel(
            adaptive: adaptive,
            child: Text(
              controller.tr('no_linked_children'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AudyColors.textLight),
            ),
          )
        else
          ...controller.parentChildren.map(
            (child) => Padding(
              padding: EdgeInsets.only(bottom: adaptive.space(12)),
              child: _ChildCard(child: child, adaptive: adaptive),
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

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child, required this.adaptive});

  final UserProfile child;
  final AudyAdaptive adaptive;

  @override
  Widget build(BuildContext context) {
    final joined = child.createdAt.toLocal();
    return AudyPanel(
      adaptive: adaptive,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AudyColors.blushPink.withValues(alpha: 0.2),
            child: const Icon(
              Icons.child_care_rounded,
              size: 30,
              color: AudyColors.blushPink,
            ),
          ),
          SizedBox(width: adaptive.space(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: TextStyle(
                    fontSize: adaptive.space(18),
                    fontWeight: FontWeight.w800,
                    color: AudyColors.textPrimary,
                  ),
                ),
                SizedBox(height: adaptive.space(4)),
                Text(
                  'Age: ${child.age}',
                  style: const TextStyle(color: AudyColors.textLight),
                ),
                if (child.email != null)
                  Text(
                    child.email!,
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

class _ParentAnalyticsContent extends StatelessWidget {
  const _ParentAnalyticsContent({
    required this.adaptive,
    required this.controller,
  });

  final AudyAdaptive adaptive;
  final AudyController controller;

  @override
  Widget build(BuildContext context) {
    final child = controller.selectedParentChild;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChildProfileSelector(
          children: controller.parentChildren,
          selectedChildId: controller.selectedParentChildId,
          isLoading: controller.isLoadingParentChildren,
          errorMessage: controller.parentChildrenError,
          label: controller.tr('selected_child'),
          emptyMessage: controller.tr('no_linked_children'),
          onRetry: () => controller.loadParentChildren(force: true),
          onSelected: controller.selectParentChild,
        ),
        if (child != null) ...[
          SizedBox(height: adaptive.space(20)),
          ParentChildAnalytics(
            key: ValueKey(child.id),
            child: child,
            adaptive: adaptive,
          ),
        ],
      ],
    );
  }
}

class _ParentTabButton extends StatelessWidget {
  const _ParentTabButton({
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
