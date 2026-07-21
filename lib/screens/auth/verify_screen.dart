import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/core/theme.dart';
import 'package:flutter_application_1/features/Auth/firebase_otp_service.dart';
import 'package:flutter_application_1/features/Token/service/token_service.dart';
import 'package:flutter_application_1/features/User/Model/register_user_model.dart';
import 'package:flutter_application_1/features/User/Service/user_service.dart';
import 'package:flutter_application_1/routes/app_routes.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  static const int _otpLength = 6;
  static const int _resendCooldown = 60;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  int _secondsLeft = _resendCooldown;
  Timer? _timer;
  bool _isLoading = false;
  bool _isInitializing = true;

  // Registration data
  String _phoneNumber = '';
  String? _verificationId;
  RegisterUserModel? _userData;

  final _tokenService = getIt<TokenService>();
  final _userService = getIt<UserService>();
  final _firebaseOtpService = getIt<FirebaseOtpService>();

  @override
  void initState() {
    super.initState();
    debugPrint('🔵 VerifyScreen initState called');
    _startTimer();

    // Handle arguments after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleArguments();
    });
  }

  void _handleArguments() {
    debugPrint('🔵 Handling arguments in VerifyScreen');

    final route = ModalRoute.of(context);
    final args = route?.settings.arguments;

    if (args is Map<String, dynamic>) {
      final phone = args['phoneNumber'] as String? ?? '';
      final verificationId = args['verificationId'] as String?;
      final userData = args['userData'];

      debugPrint('📱 Phone: $phone');
      debugPrint('🔑 Verification ID: ${verificationId ?? 'null'}');
      debugPrint(
        '👤 User Data: ${userData is RegisterUserModel ? userData.fullName : 'null'}',
      );

      setState(() {
        _phoneNumber = phone;
        _verificationId = verificationId;
        if (userData is RegisterUserModel) {
          _userData = userData;
        }
        _isInitializing = false;
      });

      // Auto-focus on first OTP field after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _focusNodes[0].requestFocus();
        }
      });

      // If verificationId is null, send OTP automatically
      if (_verificationId == null && _phoneNumber.isNotEmpty) {
        debugPrint('🔄 No verification ID found, sending OTP...');
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _sendOtp();
          }
        });
      }
    } else if (args is RegisterUserModel) {
      debugPrint('👤 Received RegisterUserModel directly: ${args.fullName}');
      setState(() {
        _userData = args;
        _phoneNumber = args.phoneNumber;
        _isInitializing = false;
      });

      // Send OTP automatically
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _sendOtp();
        }
      });
    } else {
      debugPrint('⚠️ No valid arguments received');
      setState(() => _isInitializing = false);

      // Show error and navigate back
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showError('Invalid registration data. Please try again.');
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  void dispose() {
    debugPrint('🔵 VerifyScreen dispose');
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendCooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();
  bool get _isComplete => _otp.length == _otpLength;

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  void _onPaste(String pasted, int index) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    for (int i = 0; i < _otpLength && i < digits.length; i++) {
      _controllers[i].text = digits[i];
    }
    final next = (digits.length < _otpLength) ? digits.length : _otpLength - 1;
    _focusNodes[next].requestFocus();
    setState(() {});
  }

  void _clearFields() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  Future<void> _sendOtp() async {
    if (_phoneNumber.isEmpty) {
      debugPrint('⚠️ Cannot send OTP: Phone number is empty');
      return;
    }

    if (_isLoading) {
      debugPrint('⚠️ Already loading, skipping OTP send');
      return;
    }

    debugPrint('🔵 Sending OTP to: $_phoneNumber');
    setState(() => _isLoading = true);

    try {
      await _firebaseOtpService.sendOtp(
        phoneNumber: _phoneNumber,
        isResend: false,
        onCodeSent: (verificationId) {
          debugPrint(
            '✅ OTP sent successfully. Verification ID: $verificationId',
          );
          if (!mounted) return;

          setState(() {
            _isLoading = false;
            _verificationId = verificationId;
          });
          _startTimer();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onFailed: (FirebaseAuthException e) {
          debugPrint('❌ OTP send failed: ${e.code} - ${e.message}');
          if (!mounted) return;

          setState(() => _isLoading = false);
          _showError(e.message ?? 'Failed to send OTP (${e.code})');
        },
      );
    } catch (e) {
      debugPrint('❌ OTP send error: $e');
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  Future<void> _resendOtp() async {
    if (_secondsLeft > 0 || _isLoading) return;
    await _sendOtp();
  }

  Future<void> _verifyOtp() async {
    if (!_isComplete) {
      _showError('Please enter the complete OTP code');
      return;
    }

    if (_userData == null) {
      _showError('User registration data is missing');
      return;
    }

    if (_verificationId == null) {
      _showError('OTP session expired. Sending new code...');
      await _sendOtp();
      return;
    }

    debugPrint('🔵 Verifying OTP: $_otp');
    setState(() => _isLoading = true);

    try {
      // Step 1: Verify OTP with Firebase
      debugPrint('🔵 Calling Firebase verifyOtp...');
      User user = await _firebaseOtpService.verifyOtp(
        smsCode: _otp,
        verificationIdOverride: _verificationId,
      );
      debugPrint('✅ Firebase verification successful: ${user.uid}');

      // Step 2: Get Firebase token
      debugPrint('🔵 Getting Firebase token...');
      final firebaseToken = await user.getIdToken(true);
      if (firebaseToken == null) {
        throw Exception('Failed to get Firebase authentication token');
      }
      debugPrint('✅ Firebase token obtained');

      if (!mounted) return;

      // Step 3: Register user with backend
      debugPrint('🔵 Registering user with backend...');
      await _registerUserWithBackend(firebaseToken);
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase auth error: ${e.code} - ${e.message}');
      if (mounted) {
        String errorMessage = _getFirebaseErrorMessage(e);
        _showError(errorMessage);
        if (e.code == 'invalid-verification-code' ||
            e.code == 'session-expired') {
          _clearFields();
          // Resend OTP for expired session
          if (e.code == 'session-expired') {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                _sendOtp();
              }
            });
          }
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ General error: $e');
      if (mounted) {
        _showError('Verification failed: ${e.toString()}');
        _clearFields();
        setState(() => _isLoading = false);
      }
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please try again.';
      case 'session-expired':
        return 'OTP session expired. Sending new code...';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'missing-verification-id':
        return 'Session expired. Sending new code...';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Verification failed. Please try again.';
    }
  }

  Future<void> _registerUserWithBackend(String firebaseToken) async {
    try {
      final registerData = RegisterUserModel(
        fullName: _userData!.fullName,
        email: _userData!.email,
        phoneNumber: _userData!.phoneNumber,
        password: _userData!.password,
        role: _userData!.role,
      );

      debugPrint('📝 Registration data: ${registerData.toJson()}');

      // Register user with backend (with timeout)
      final response = await _userService
          .registerUser(registerData)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Registration timeout. Please try again.');
            },
          );

      debugPrint('✅ Backend registration successful');

      if (!mounted) return;

      // Save tokens
      debugPrint('🔵 Saving tokens...');
      await _tokenService.saveTokens(response.token);
      debugPrint('✅ Tokens saved');

      // Show success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created successfully! Welcome ${response.user.fullName}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      setState(() => _isLoading = false);

      // Navigate to home
      debugPrint('🔵 Navigating to home...');
      Navigator.pushNamedAndRemoveUntil(
        // ignore: use_build_context_synchronously
        context,
        AppRoutes.home,
        (route) => false,
      );
    } on TimeoutException catch (e) {
      debugPrint('❌ Registration timeout: $e');
      if (mounted) {
        _showError('Registration timeout. Please try again.');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Backend registration error: $e');
      if (mounted) {
        _showError('Failed to create account: ${e.toString()}');
        setState(() => _isLoading = false);
        await _handleRegistrationFailure();
      }
    }
  }

  Future<void> _handleRegistrationFailure() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
        debugPrint(
          '✅ Firebase user deleted due to backend registration failure',
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to clean up Firebase user: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayPhoneNumber = _phoneNumber.isNotEmpty
        ? _phoneNumber
        : _userData?.phoneNumber ?? '+855968877203';

    // Show loading while initializing
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.kAccent),
              const SizedBox(height: 20),
              Text(
                'Initializing...',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : AppTheme.kLightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(isDark, displayPhoneNumber),
                  const SizedBox(height: 32),
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

  Widget _buildHeader(bool isDark, String phoneNumber) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.kAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_add_rounded,
            color: AppTheme.kAccent,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Create Account',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the 6-digit code sent to verify your account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.kAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.kAccent.withValues(alpha: 0.2)),
          ),
          child: Text(
            phoneNumber,
            style: TextStyle(
              color: AppTheme.kAccent,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (_userData != null && _userData!.fullName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Welcome, ${_userData!.fullName}!',
              style: TextStyle(
                color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormCard(bool isDark) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOtpFields(isDark),
          const SizedBox(height: 20),
          _buildResendRow(isDark),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isComplete && !_isLoading && _verificationId != null)
                  ? _verifyOtp
                  : null,
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
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: _isLoading
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
                          _verificationId == null
                              ? 'Requesting OTP...'
                              : 'Verify & Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ),
                        if (_verificationId != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpFields(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (index) {
        final hasText = _controllers[index].text.isNotEmpty;
        return SizedBox(
          width: 44,
          height: 56,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _onKeyEvent(event, index),
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: _verificationId != null,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: hasText
                        ? AppTheme.kAccent
                        : (isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.kAccent,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: hasText
                    ? AppTheme.kAccent.withValues(alpha: 0.08)
                    : (isDark
                          ? AppTheme.kCardAlt.withValues(alpha: 0.4)
                          : AppTheme.kLightCardAlt.withValues(alpha: 0.4)),
              ),
              onChanged: (val) {
                if (val.length > 1) {
                  _controllers[index].text = val[0];
                  _onPaste(val, index);
                  return;
                }
                _onChanged(val, index);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResendRow(bool isDark) {
    final canResend = _secondsLeft == 0 && !_isLoading;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Didn\'t receive the code?',
          style: TextStyle(
            color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        canResend
            ? GestureDetector(
                onTap: _resendOtp,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.kAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Resend',
                    style: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            : Text(
                '${_secondsLeft}s',
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ],
    );
  }

  Widget _buildFooter(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(
            color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Navigator.pop(context),
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
