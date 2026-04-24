import 'package:flutter/material.dart';
import '../../core/app_routes.dart';
import '../../core/audy_theme.dart';
import '../../core/audy_ui.dart';
import '../../services/auth_service.dart';
import '../../services/sound_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();

  // Mode toggle
  bool _isSignUp = false;

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  // Age picker state
  int _selectedAge = 10;

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

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
            const AudyMascot(size: 140),
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
              'Your Learning Buddy',
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
            label: 'Sign In',
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
            label: 'Sign Up',
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
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            isPassword: false,
          ),
          SizedBox(height: adaptive.space(16)),

          // Password field
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
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
              label: 'Your Name',
              icon: Icons.person_outline,
              keyboardType: TextInputType.text,
              isPassword: false,
            ),
            SizedBox(height: adaptive.space(16)),

            // Age picker
            _buildAgePicker(adaptive),
          ],
        ],
      ),
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
                'Age',
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
          color: AudyColors.skyBlue.withOpacity(0.2),
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
            ? AudyColors.error.withOpacity(0.1)
            : AudyColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AudySpacing.radiusMedium),
        border: Border.all(
          color: isError
              ? AudyColors.error.withOpacity(0.3)
              : AudyColors.success.withOpacity(0.3),
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
        onPressed: _isLoading ? null : _handleSubmit,
        icon: _isLoading
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
          _isLoading
              ? (_isSignUp ? 'Creating account...' : 'Signing in...')
              : (_isSignUp ? 'Create Account' : 'Sign In'),
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
          shadowColor: AudyColors.skyBlue.withOpacity(0.4),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    SoundService.instance.playTap();

    // Validate inputs
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email.');
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password.');
      return;
    }

    if (_isSignUp) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        setState(() => _errorMessage = 'Please enter your name.');
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
          age: _selectedAge,
        );

        setState(() {
          _successMessage = 'Account created! Please sign in.';
          _isSignUp = false;
        });
      } else {
        // Sign in
        await _authService.signIn(email: email, password: password);

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
