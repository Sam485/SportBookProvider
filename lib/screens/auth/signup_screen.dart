import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/core/util/phone_utils.dart';
import 'package:flutter_application_1/features/Token/service/token_service.dart';
import 'package:flutter_application_1/features/User/Model/register_user_model.dart';
import 'package:flutter_application_1/features/User/Service/user_service.dart';
import 'package:flutter_application_1/routes/app_routes.dart';
import 'package:flutter_application_1/screens/auth/privacy_policy_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  String? _errorMessage;

  final _userService = getIt<UserService>();
  final _tokenService = getIt<TokenService>();

  @override
  void initState() {
    super.initState();
    _userService.addListener(_onUserServiceChanged);
  }

  @override
  void dispose() {
    _userService.removeListener(_onUserServiceChanged);
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onUserServiceChanged() {
    if (mounted) {
      setState(() {
        if (_userService.error.isNotEmpty) {
          _errorMessage = _userService.error;
        }
      });
    }
  }

  // ✅ Get user-friendly error message
  String _getUserFriendlyErrorMessage(String error) {
    final msg = error.toLowerCase();

    if (msg.contains('email already exists') ||
        msg.contains('user already exists') ||
        msg.contains('already registered') ||
        msg.contains('duplicate')) {
      return 'This email is already registered. Please use a different email or sign in.';
    } else if (msg.contains('phone already exists') ||
        msg.contains('phone number already')) {
      return 'This phone number is already registered.';
    } else if (msg.contains('invalid email') ||
        msg.contains('email format') ||
        msg.contains('must be a valid email')) {
      return 'Please enter a valid email address.';
    } else if (msg.contains('password') &&
        (msg.contains('weak') || msg.contains('minimum'))) {
      return 'Password is too weak. Please use at least 8 characters with letters and numbers.';
    } else if (msg.contains('timeout') || msg.contains('timed out')) {
      return 'Connection timeout. Please check your internet.';
    } else if (msg.contains('network') || msg.contains('internet')) {
      return 'Network error. Please check your connection.';
    } else if (msg.contains('500') || msg.contains('server')) {
      return 'Server error. Please try again later.';
    } else if (msg.contains('400') || msg.contains('bad request')) {
      return 'Invalid input. Please check your information and try again.';
    } else {
      return 'Registration failed: ${error.replaceAll('Exception: ', '')}';
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    try {
      final formattedPhone = PhoneUtils.formatPhoneNumber(
        _phoneController.text.trim(),
      );

      // Create registration request with all required fields
      final registerData = RegisterUserModel(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: formattedPhone,
        password: _passwordController.text.trim(),
        role: 'partner', // Default role as specified in the model
      );

      // Call register API
      final response = await _userService.registerUser(registerData);

      // Save tokens
      await _tokenService.saveTokens(response.token);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to home
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = _getUserFriendlyErrorMessage(e.toString());
        setState(() {
          _errorMessage = errorMsg;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ✅ Navigate to Privacy Policy
  void _navigateToPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 24),
                  _buildFormCard(isDark),
                  const SizedBox(height: 20),
                  _buildFooter(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign up to get started',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : AppTheme.kLightTextSub,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(bool isDark) {
    final isLoading = _userService.isLoading;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          width: 0.5,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name Field
            _buildLabel('Full Name', isDark),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fullNameController,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 15,
              ),
              onChanged: (_) {
                // Clear error when user types
                if (_errorMessage != null && mounted) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
              decoration: _buildInputDecoration(
                Icons.person_outline_rounded,
                'Enter your full name',
                isDark,
              ),
            ),
            const SizedBox(height: 16),

            // Email Field
            _buildLabel('Email Address', isDark),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 15,
              ),
              onChanged: (_) {
                // Clear error when user types
                if (_errorMessage != null && mounted) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email address';
                }
                // Email validation regex
                final emailRegex = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                );
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              decoration: _buildInputDecoration(
                Icons.email_outlined,
                'Enter your email address',
                isDark,
              ),
            ),
            const SizedBox(height: 16),

            // Phone Field
            _buildLabel('Phone Number', isDark),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 15,
              ),
              onChanged: (_) {
                // Clear error when user types
                if (_errorMessage != null && mounted) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (cleaned.length < 9) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
              decoration: _buildInputDecoration(
                Icons.phone_rounded,
                '+855 12 345 678',
                isDark,
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            _buildLabel('Password', isDark),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 15,
              ),
              onChanged: (_) {
                // Clear error when user types
                if (_errorMessage != null && mounted) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                // Optional: Add password strength validation
                if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
                  return 'Password must contain at least one letter and one number';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Min 6 characters with letter and number',
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppTheme.kAccent,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password Field
            _buildLabel('Confirm Password', isDark),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 15,
              ),
              onChanged: (_) {
                // Clear error when user types
                if (_errorMessage != null && mounted) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return "Passwords don't match";
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Re-enter your password',
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.check_circle_outline_rounded,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                ),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  ),
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppTheme.kAccent,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Terms and Conditions with clickable links
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) =>
                        setState(() => _agreeToTerms = value ?? false),
                    activeColor: AppTheme.kAccent,
                    checkColor: const Color(0xFF0A1828),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                        fontSize: 12,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: _navigateToPrivacyPolicy,
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                color: AppTheme.kAccent,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Create Account Button
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.kAccent,
                  foregroundColor: const Color(0xFF0A1828),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: isDark
                      ? Colors.grey[800]
                      : Colors.grey[300],
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Color(0xFF0A1828),
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        color: isDark ? Colors.white : AppTheme.kLightText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    IconData icon,
    String hint,
    bool isDark,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
      ),
      filled: true,
      fillColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.kAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: TextStyle(
            color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: AppTheme.kAccent,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
