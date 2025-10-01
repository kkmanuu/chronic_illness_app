import 'package:chronic_illness_app/core/utils/validators.dart';
import 'package:chronic_illness_app/features/auth/services/auth_service.dart';
import 'package:chronic_illness_app/features/auth/screens/register_screen.dart';
import 'package:chronic_illness_app/features/auth/screens/forgot_password_screen.dart';
import 'package:chronic_illness_app/features/auth/widgets/app_name_text_widget.dart';
import 'package:chronic_illness_app/features/auth/widgets/titles_text_widget.dart';
import 'package:chronic_illness_app/features/auth/widgets/subtitle_text_widget.dart';
import 'package:chronic_illness_app/features/auth/widgets/google_button.dart';
import 'package:chronic_illness_app/features/home/root_screen.dart';
import 'package:chronic_illness_app/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _emailController, _passwordController;
  late final FocusNode _emailFocusNode, _passwordFocusNode;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final AuthService _authService = AuthService();

  late AnimationController _backgroundController;
  late AnimationController _formController;
  late AnimationController _headerController;
  late Animation<double> _backgroundAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<double> _headerFadeAnimation;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _setupAnimations();
    super.initState();
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _formController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.elasticOut,
    ));

    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeIn),
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeIn),
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _formController.dispose();
    _headerController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_backgroundAnimation.value * 2 * 3.14159),
              colors: [
                Colors.blue.shade600,
                Colors.purple.shade600,
                Colors.pink.shade500,
                Colors.blue.shade700,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 100 + (50 * _backgroundAnimation.value),
                left: 50 + (30 * _backgroundAnimation.value),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                top: 300 - (40 * _backgroundAnimation.value),
                right: 80 + (20 * _backgroundAnimation.value),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: 200 + (60 * _backgroundAnimation.value),
                left: 20 - (10 * _backgroundAnimation.value),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerFadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.health_and_safety,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chronic Illness Management',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your personal health companion',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w300,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    VoidCallback? onFieldSubmitted,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onFieldSubmitted: (_) => onFieldSubmitted?.call(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              prefixIcon,
              color: Colors.blue.shade600,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback? onPressed,
    required IconData icon,
    List<Color>? colors,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: colors ?? [Colors.blue.shade600, Colors.blue.shade700],
        ),
        boxShadow: [
          BoxShadow(
            color: (colors?.first ?? Colors.blue).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _loginFct() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    try {
      final userModel = await _authService.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final user = _authService.currentUser!;
      await _authService.reloadUser(user);

      if (!user.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Please verify your email before logging in.')),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Resend Email',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  await _authService.sendEmailVerification(user);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Verification email resent.'),
                        ],
                      ),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Failed to resend email: $e')),
                        ],
                      ),
                      backgroundColor: Colors.red.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
        return;
      }

      // Update AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loadCurrentUser();

      debugPrint('User logged in: ${userModel.toMap()}');
      debugPrint('Attempting to navigate to RootScreen (/root)');
      Navigator.pushNamedAndRemoveUntil(
        context,
        RootScreen.routeName,
        (route) => false,
      );
      debugPrint('Navigation to RootScreen initiated successfully');
    } catch (e, st) {
      debugPrint('Login error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Login failed: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _googleSignInFct() async {
    setState(() => isLoading = true);

    try {
      final userCred = await _authService.signInWithGoogle();
      if (userCred == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 12),
                Text('Google Sign-In canceled'),
              ],
            ),
            backgroundColor: Colors.grey.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      final user = userCred.user!;
      debugPrint('Google Sign-In: User UID: ${user.uid}, Email: ${user.email}');
      await _authService.reloadUser(user);

      final doc = await _authService.getUserFromFirestore(user.uid);

      if (!doc.exists || doc.data() == null) {
        debugPrint('Saving new Google user to Firestore');
        await _authService.saveUserToFirestore(user);
      }

      // Update AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loadCurrentUser();

      debugPrint('Attempting to navigate to RootScreen (/root) after Google sign-in');
      Navigator.pushNamedAndRemoveUntil(
        context,
        RootScreen.routeName,
        (route) => false,
      );
      debugPrint('Navigation to RootScreen after Google sign-in initiated successfully');
    } catch (e, st) {
      debugPrint('Google Sign-In error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Google Sign-In failed: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    SlideTransition(
                      position: _formSlideAnimation,
                      child: FadeTransition(
                        opacity: _formFadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome Back!',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sign in to continue your health journey',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                _buildStyledTextField(
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  hintText: 'Email address',
                                  prefixIcon: IconlyLight.message,
                                  validator: MyValidators.emailValidator,
                                  keyboardType: TextInputType.emailAddress,
                                  onFieldSubmitted: () =>
                                      FocusScope.of(context).requestFocus(_passwordFocusNode),
                                ),
                                _buildStyledTextField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  hintText: 'Password',
                                  prefixIcon: IconlyLight.lock,
                                  validator: MyValidators.passwordValidator,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: () => _loginFct(),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                        context, ForgotPasswordScreen.routeName),
                                    child: Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: Colors.blue.shade600,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildGradientButton(
                                  text: 'Login',
                                  icon: Icons.login,
                                  onPressed: isLoading ? null : _loginFct,
                                  isLoading: isLoading,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade300,
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade300,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: GoogleButton(
                                          onPressed: isLoading ? null : _googleSignInFct,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.grey.shade600,
                                              Colors.grey.shade700,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.3),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                RootScreen.routeName,
                                                (route) => false,
                                              ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: const Text(
                                            'Guest',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pushNamed(
                                          context, RegisterScreen.routeName),
                                      child: Text(
                                        'Sign up',
                                        style: TextStyle(
                                          color: Colors.blue.shade600,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
