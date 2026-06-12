import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_input_field.dart';

class LoginPage extends StatefulWidget {
  final bool autoLogin;
  final String? initialEmail;
  final String? initialPassword;
  final int successInitialTab;

  const LoginPage({
    super.key,
    this.autoLogin = false,
    this.initialEmail,
    this.initialPassword,
    this.successInitialTab = 0,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail ?? '';
    _passwordController.text = widget.initialPassword ?? '';

    if (widget.autoLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onLogin());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력해 주세요.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(email, password);

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(
        context,
        AppRouter.main,
        arguments: widget.successInitialTab,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? '로그인에 실패했습니다.')),
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
                    Text(AppStrings.loginTitle,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    Text(AppStrings.loginSubtitle,
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
                      hint: AppStrings.password,
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 40),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        final isLoading = auth.status == AuthStatus.loading;
                        return GestureDetector(
                          onTap: isLoading ? null : _onLogin,
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
                                : Text(AppStrings.login,
                                    style: AppTextStyles.body
                                        .copyWith(color: Colors.white)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.signup),
                        child: Text('Sign up instead',
                            style: AppTextStyles.body.copyWith(
                                color: AppColors.textMuted,
                                decoration: TextDecoration.underline)),
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
