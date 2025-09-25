import 'package:chronic_illness_app/config/assets_manager.dart';
import 'package:chronic_illness_app/core/utils/validators.dart';
import 'package:chronic_illness_app/features/auth/widgets/app_name_text_widget.dart';
import 'package:chronic_illness_app/features/auth/widgets/titles_text_widget.dart';
import 'package:chronic_illness_app/features/auth/widgets/subtitle_text_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
// Ensure that assets_manager.dart defines the AssetsManager class and forgotPassword asset.

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = '/forgot_password';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _forgetPassFCT() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() { isLoading = true; });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent to your email.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "An error occurred."), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const AppNameTextWidget(fontSize: 22),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 20),
              Image.asset(
                AssetsManager.forgotPassword,
                width: size.width * 0.6,
                height: size.width * 0.6,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 50),
              ),
              const SizedBox(height: 20),
              const TitlesTextWidget(label: 'Forgot Password', fontSize: 22),
              const SizedBox(height: 8),
              const SubtitleTextWidget(
                label: 'Enter your email to receive a password reset link',
                fontSize: 14,
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'youremail@email.com',
                    prefixIcon: Icon(IconlyLight.message),
                  ),
                  validator: MyValidators.emailValidator,
                  onFieldSubmitted: (_) => _forgetPassFCT(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(IconlyBold.send),
                  label: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Request Link', style: TextStyle(fontSize: 20)),
                  onPressed: isLoading ? null : _forgetPassFCT,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
