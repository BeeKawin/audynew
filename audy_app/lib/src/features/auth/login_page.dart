import 'package:flutter/material.dart';
import '../../core/build_config.dart';
import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/auth_service.dart';
import '../../services/sound_service.dart';
import '../../state/audy_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.authService});
  final AuthService? authService;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final _authService = widget.authService ?? AuthService();

  // Mode toggle
  bool _isSignUp = false;

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  // Age picker state
  int _selectedAge = 10;
  String _selectedRole = 'child';

  // Loading and error states
  bool _isLoading = false;
  bool get _busy => _isLoading || AudyScope.of(context).isLoggingOut;
  String? _errorMessage;
  String? _successMessage;

  String _tr(String key, {Map<String, String>? params}) {
    return AudyScope.of(context).tr(key, params: params);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AudyResponsivePage(
      scrollable: true,
      builder: (context, adaptive) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mascot at top
            Image.asset(
              'assets/mascot/login_mascot.png',
              width: 168,
              height: 168,
            ),
            SizedBox(height: adaptive.space(24)),

            // App Title
            Text(
              'AUDY',
              style: AudyTypography.displayMedium.copyWith(
                color: AudyColors.skyBlue,
                fontSize: adaptive.space(56),
              ),
            ),
            SizedBox(height: adaptive.space(8)),
            Text(
              _tr('learning_buddy'),
              style: TextStyle(
                fontSize: adaptive.space(16),
                color: AudyColors.textLight,
              ),
            ),
            SizedBox(height: adaptive.space(32)),

            // Mode toggle pill
            _buildModeToggle(adaptive),
            SizedBox(height: adaptive.space(28)),

            // Input fields
            _buildInputFields(adaptive),
            SizedBox(height: adaptive.space(24)),

            // Error/Success messages
            if (_errorMessage != null)
              _buildMessage(_errorMessage!, isError: true),
            if (_successMessage != null)
              _buildMessage(_successMessage!, isError: false),
            if (_errorMessage != null || _successMessage != null)
              SizedBox(height: adaptive.space(16)),

            // Submit button
            _buildSubmitButton(adaptive),
            if (BuildConfig.enableDebugAccounts) _buildDebugMenu(adaptive),
          ],
        );
      },
    );
  }

  Widget _buildModeToggle(AudyAdaptive adaptive) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AudyColors.borderLight, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sign In button
          _buildModeButton(
            label: _tr('sign_in'),
            isSelected: !_isSignUp,
            onTap: () {
              SoundService.instance.playTap();
              setState(() {
                _isSignUp = false;
                _errorMessage = null;
                _successMessage = null;
              });
            },
          ),
          // Sign Up button
          _buildModeButton(
            label: _tr('sign_up'),
            isSelected: _isSignUp,
            onTap: () {
              SoundService.instance.playTap();
              setState(() {
                _isSignUp = true;
                _errorMessage = null;
                _successMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AudyColors.skyBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isSelected ? AudyColors.textOnColor : AudyColors.textLight,
          ),
        ),
      ),
    );
  }

  Widget _buildInputFields(AudyAdaptive adaptive) {
    return Container(
      padding: EdgeInsets.all(adaptive.space(24)),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(AudySpacing.radiusLarge),
        border: Border.all(color: AudyColors.borderLight, width: 1),
        boxShadow: AudyShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          _buildTextField(
            controller: _emailController,
            label: _tr('email'),
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isPassword: false,
          ),
          SizedBox(height: adaptive.space(16)),

          // Password field
          _buildTextField(
            controller: _passwordController,
            label: _tr('password'),
            icon: Icons.lock_outline,
            keyboardType: TextInputType.text,
            isPassword: true,
          ),

          // Sign up extra fields
          if (_isSignUp) ...[
            SizedBox(height: adaptive.space(16)),

            // Name field
            _buildTextField(
              controller: _nameController,
              label: _tr('your_name'),
              icon: Icons.person_outline,
              keyboardType: TextInputType.text,
              isPassword: false,
            ),
            SizedBox(height: adaptive.space(16)),

            // Role selector
            _buildRoleSelector(adaptive),

            // Age picker
            if (_selectedRole == 'child') ...[
              SizedBox(height: adaptive.space(16)),
              _buildAgePicker(adaptive),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildRoleSelector(AudyAdaptive adaptive) {
    final roles = [
      {'key': 'child', 'label': 'Child', 'icon': Icons.child_care_rounded},
      {
        'key': 'caretaker',
        'label': AudyScope.of(context).currentLanguage == 'th'
            ? 'ผู้ดูแล'
            : 'Caretaker',
        'icon': Icons.supervisor_account_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a...',
          style: TextStyle(
            fontSize: adaptive.space(14),
            fontWeight: FontWeight.w700,
            color: AudyColors.textLight,
          ),
        ),
        SizedBox(height: adaptive.space(8)),
        Row(
          children: roles.map((role) {
            final isSelected = _selectedRole == role['key'];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  SoundService.instance.playTap();
                  setState(() {
                    _selectedRole = role['key'] as String;
                  });
                },
                child: Container(
                  height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AudyColors.skyBlue
                        : AudyColors.backgroundCard,
                    borderRadius: BorderRadius.circular(
                      AudySpacing.radiusMedium,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? AudyColors.skyBlue
                          : AudyColors.borderLight,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        role['icon'] as IconData,
                        color: isSelected
                            ? AudyColors.textOnColor
                            : AudyColors.textLight,
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AudyColors.textOnColor
                              : AudyColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    required bool isPassword,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AudyColors.textLight, fontSize: 14),
        prefixIcon: Icon(icon, color: AudyColors.textLight),
        filled: true,
        fillColor: AudyColors.backgroundPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
          borderSide: BorderSide(color: AudyColors.skyBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildAgePicker(AudyAdaptive adaptive) {
    return Container(
      padding: EdgeInsets.all(adaptive.space(16)),
      decoration: BoxDecoration(
        color: AudyColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cake_outlined, color: AudyColors.textLight, size: 20),
              const SizedBox(width: 8),
              Text(
                _tr('age'),
                style: TextStyle(fontSize: 14, color: AudyColors.textLight),
              ),
            ],
          ),
          SizedBox(height: adaptive.space(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrement button
              _buildAgeButton(
                icon: Icons.remove,
                onTap: () {
                  SoundService.instance.playTap();
                  if (_selectedAge > 3) {
                    setState(() => _selectedAge--);
                  }
                },
              ),
              SizedBox(width: adaptive.space(24)),

              // Age display
              Container(
                width: adaptive.space(80),
                padding: EdgeInsets.symmetric(
                  vertical: adaptive.space(12),
                  horizontal: adaptive.space(16),
                ),
                decoration: BoxDecoration(
                  color: AudyColors.backgroundCard,
                  borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
                  border: Border.all(color: AudyColors.skyBlue, width: 2),
                ),
                child: Center(
                  child: Text(
                    '$_selectedAge',
                    style: TextStyle(
                      fontSize: adaptive.space(24),
                      fontWeight: FontWeight.w800,
                      color: AudyColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: adaptive.space(24)),

              // Increment button
              _buildAgeButton(
                icon: Icons.add,
                onTap: () {
                  SoundService.instance.playTap();
                  if (_selectedAge < 25) {
                    setState(() => _selectedAge++);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AudyColors.skyBlue.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AudyColors.skyBlue, size: 24),
      ),
    );
  }

  Widget _buildMessage(String message, {required bool isError}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError
            ? AudyColors.error.withValues(alpha: 0.1)
            : AudyColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
        border: Border.all(
          color: isError
              ? AudyColors.error.withValues(alpha: 0.3)
              : AudyColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? AudyColors.error : AudyColors.success,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isError ? AudyColors.error : AudyColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AudyAdaptive adaptive) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _busy ? null : _handleSubmit,
        icon: _busy
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AudyColors.textOnColor,
                ),
              )
            : Icon(_isSignUp ? Icons.person_add : Icons.login, size: 24),
        label: Text(
          AudyScope.of(context).isLoggingOut
              ? (AudyScope.of(context).currentLanguage == 'th'
                    ? 'กำลังออกจากระบบ…'
                    : 'Signing out…')
              : _busy
              ? (_isSignUp ? _tr('creating_account') : _tr('signing_in'))
              : (_isSignUp ? _tr('create_account') : _tr('sign_in')),
          style: TextStyle(
            fontSize: adaptive.space(18),
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AudyColors.skyBlue,
          foregroundColor: AudyColors.textOnColor,
          padding: EdgeInsets.symmetric(
            horizontal: adaptive.space(32),
            vertical: adaptive.space(16),
          ),
          minimumSize: const Size(48, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 4,
          shadowColor: AudyColors.skyBlue.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildDebugMenu(AudyAdaptive adaptive) {
    return Container(
      margin: EdgeInsets.only(top: adaptive.space(16)),
      padding: EdgeInsets.all(adaptive.space(16)),
      decoration: BoxDecoration(
        color: AudyColors.backgroundCard,
        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
        border: Border.all(
          color: AudyColors.borderLight.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bug_report_rounded,
                color: AudyColors.skyBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'Developer Debug Menu',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AudyColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: adaptive.space(12)),
          Row(
            children: [
              Expanded(
                child: _buildDebugButton(
                  label: 'Student',
                  icon: Icons.child_care_rounded,
                  color: AudyColors.skyBlue,
                  onTap: () => _handleDebugLogin(
                    email: 'test@audy.com',
                    password: 'password123',
                    mode: AppMode.child,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDebugButton(
                  label: 'Caretaker',
                  icon: Icons.supervisor_account_rounded,
                  color: AudyColors.mintGreen,
                  onTap: () => _handleDebugLogin(
                    email: 'caretaker@gmail.com',
                    password: 'audy123',
                    mode: AppMode.caretaker,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebugButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _busy ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDebugLogin({
    required String email,
    required String password,
    required AppMode mode,
  }) async {
    if (_busy) return;
    SoundService.instance.playTap();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      await _authService.signIn(email: email, password: password);
      final profile = await _authService.getCurrentProfile();
      if (profile == null || profile.mode != mode) {
        await _authService.signOut();
        throw StateError('The debug account has an unexpected role.');
      }
      if (!mounted) return;
      await AudyScope.of(context).setUser(profile);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboard,
        (_) => false,
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _emailController.text = email;
          _isSignUp = false;
          _errorMessage = AudyScope.of(context).currentLanguage == 'th'
              ? '\u0e40\u0e02\u0e49\u0e32\u0e2a\u0e39\u0e48\u0e23\u0e30\u0e1a\u0e1a\u0e44\u0e21\u0e48\u0e2a\u0e33\u0e40\u0e23\u0e47\u0e08 \u0e01\u0e23\u0e38\u0e13\u0e32\u0e25\u0e2d\u0e07\u0e2d\u0e35\u0e01\u0e04\u0e23\u0e31\u0e49\u0e07'
              : 'Could not sign in to $email. Please try again or sign in manually.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    SoundService.instance.playTap();

    // Validate inputs
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _errorMessage = _tr('enter_email'));
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorMessage = _tr('enter_password'));
      return;
    }

    if (_isSignUp) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        setState(() => _errorMessage = _tr('enter_name'));
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      if (_isSignUp) {
        // Sign up
        await _authService.signUp(
          email: email,
          password: password,
          name: _nameController.text.trim(),
          age: _selectedRole == 'child' ? _selectedAge : 0,
          role: _selectedRole,
        );

        // Get profile and set in controller
        final profile = await _authService.getCurrentProfile();
        if (profile != null && mounted) {
          await AudyScope.of(context).setUser(profile);
          if (!mounted) return;
          if (profile.role == 'child') {
            Navigator.pushReplacementNamed(context, AppRoutes.preferences);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          }
          return;
        }
      } else {
        // Sign in
        await _authService.signIn(email: email, password: password);

        // Get user profile and set in controller
        final profile = await _authService.getCurrentProfile();
        if (profile != null && mounted) {
          await AudyScope.of(context).setUser(profile);
          if (!mounted) return;
        }

        // Navigate to dashboard
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        }
      }
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
