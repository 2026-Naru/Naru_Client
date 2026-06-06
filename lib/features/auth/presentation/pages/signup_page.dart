import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_input_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 항목을 입력해 주세요.')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signup(email, username, password);

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRouter.main);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? '회원가입에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: IconButton(
                icon: const Icon(Icons.close, size: 20),
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 25, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.signupSubtitle,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    Text(AppStrings.signupTitle,
                        style: AppTextStyles.h2
                            .copyWith(color: AppColors.textDark)),
                    const SizedBox(height: 40),
                    AuthInputField(
                      hint: AppStrings.email,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 20),
                    AuthInputField(
                      hint: AppStrings.username,
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 32),
                    AuthInputField(
                      hint: AppStrings.password,
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 10),
                    AuthInputField(
                      hint: AppStrings.confirmPassword,
                      obscureText: true,
                      controller: _confirmController,
                    ),
                    const SizedBox(height: 40),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final isLoading =
                            auth.status == AuthStatus.loading;
                        return GestureDetector(
                          onTap: isLoading ? null : _onSignup,
                          child: Container(
                            height: 51,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.dark,
                              borderRadius: BorderRadius.circular(9000),
                            ),
                            alignment: Alignment.center,
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(AppStrings.signup,
                                    style: AppTextStyles.body
                                        .copyWith(color: Colors.white)),
                          ),
                        );
                      },
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
