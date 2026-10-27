import 'package:flutter/material.dart';

import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/auth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';
import 'child_profile_selector.dart';
import 'parent_child_analytics.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final _authService = AuthService();
  final _emailController = TextEditingController();

  bool _isLinking = false;
  String? _message;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AudyScope.of(context).loadParentChildren(force: true);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _linkChild() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _message = 'Please enter your child\'s email address.';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isLinking = true;
      _message = null;
    });
    SoundService.instance.playTap();

    try {
      final controller = AudyScope.of(context);
      final user = controller.currentUser;
      if (user == null) return;
      await _authService.linkChildToParent(user.id, email);
      await controller.loadParentChildren(force: true);
      if (!mounted) return;
      setState(() {
        _message = 'Child account linked successfully.';
        _isError = false;
        _emailController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = e.toString().replaceAll('Exception: ', '');
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _isLinking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudyScope.of(context);
    final user = controller.currentUser;
    final selectedChild = controller.selectedParentChild;

    return Scaffold(
      appBar: AppBar(
        title: Text('Parent Portal', style: AudyTypography.headingLarge),
      ),
      body: AudyResponsivePage(
        scrollable: true,
        builder: (context, adaptive) {
          return Padding(
            padding: EdgeInsets.all(adaptive.space(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(adaptive.space(20)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AudySpacing.radiusLarge,
                    ),
                    border: Border.all(color: AudyColors.skyBlue, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.supervisor_account_rounded,
                        size: 48,
                        color: AudyColors.skyBlue,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${user?.name ?? 'Parent'}!',
                              style: AudyTypography.headingSmall,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Choose a child to view their learning progress.',
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
                _buildLinkChildCard(adaptive),
                SizedBox(height: adaptive.space(24)),
                Text('Child Profile', style: AudyTypography.headingSmall),
                SizedBox(height: adaptive.space(12)),
                ChildProfileSelector(
                  children: controller.parentChildren,
                  selectedChildId: controller.selectedParentChildId,
                  isLoading: controller.isLoadingParentChildren,
                  errorMessage: controller.parentChildrenError,
                  label: 'Selected child',
                  emptyMessage: 'No linked child accounts yet.',
                  onRetry: () => controller.loadParentChildren(force: true),
                  onSelected: controller.selectParentChild,
                ),
                if (selectedChild != null) ...[
                  SizedBox(height: adaptive.space(20)),
                  ParentChildAnalytics(
                    key: ValueKey(selectedChild.id),
                    child: selectedChild,
                    adaptive: adaptive,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinkChildCard(AudyAdaptive adaptive) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
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
              'Link Child Account',
              style: AudyTypography.headingSmall.copyWith(fontSize: 18),
            ),
            SizedBox(height: adaptive.space(6)),
            const Text(
              'Enter the email address of your child\'s account to link it.',
              style: TextStyle(fontSize: 13, color: AudyColors.textLight),
            ),
            SizedBox(height: adaptive.space(16)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'child@email.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: AudyColors.backgroundSoft.withValues(
                        alpha: 0.1,
                      ),
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
                  onPressed: _isLinking ? null : _linkChild,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AudyColors.skyBlue,
                    foregroundColor: AudyColors.textOnColor,
                    minimumSize: const Size(56, 56),
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
                      : const Icon(Icons.link_rounded),
                ),
              ],
            ),
            if (_message != null) ...[
              SizedBox(height: adaptive.space(12)),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_isError ? AudyColors.error : AudyColors.success)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    fontSize: 13,
                    color: _isError ? AudyColors.error : AudyColors.success,
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
}
