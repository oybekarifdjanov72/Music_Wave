import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog(BuildContext parentContext) {
    final resetController = TextEditingController(text: emailController.text);
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Reset Password',
            style: GoogleFonts.workSans(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email address and we will send you a password reset link.',
                style: GoogleFonts.workSans(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Enter your email',
                controller: resetController,
                prefixIcon: CupertinoIcons.mail,
                validator: Validators.email,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: GoogleFonts.workSans(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyanAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (resetController.text.trim().isNotEmpty) {
                  parentContext.read<AuthCubit>().forgotPassword(email: resetController.text.trim());
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(
                'Send Link',
                style: GoogleFonts.workSans(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const isDark = true;
    final themeColor = AppColors.instance.getTextPrimary(isDark);
    final bgColor = AppColors.instance.getBackground(isDark);
    final containerColor = AppColors.instance.getCardBackground(isDark);

    return BlocProvider(
      create: (_) => AuthCubit(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: bgColor,
          elevation: 0,
          title: Text.rich(
            TextSpan(
              style: GoogleFonts.workSans(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: 'Neon ',
                  style: TextStyle(
                    color: themeColor,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: themeColor.withValues(alpha: 0.8),
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                TextSpan(
                  text: 'Wave',
                  style: TextStyle(
                    color: AppColors.cyanAccent,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: AppColors.cyanAccent.withValues(alpha: 0.8),
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: bgColor,
        body: BlocConsumer<AuthCubit, AuthState>(
          listenWhen: (previous, current) {
            return previous.runtimeType != current.runtimeType;
          },
          listener: (context, state) {
            if (state is AuthError) {
              toastification.show(
                context: context,
                type: ToastificationType.error,
                title: Text(
                  state.message,
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.redAccent,
                  ),
                ),
                autoCloseDuration: const Duration(seconds: 4),
              );
            } else if (state is AuthLoaded) {
              toastification.show(
                context: context,
                type: ToastificationType.success,
                title: Text(
                  'Successfully authorized',
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.greenAccent,
                  ),
                ),
                autoCloseDuration: const Duration(seconds: 3),
              );
              Navigator.of(context).pushNamedAndRemoveUntil(
                RouteNames.splash,
                (_) => false,
              );
            } else if (state is AuthPasswordResetSuccess) {
              toastification.show(
                context: context,
                type: ToastificationType.success,
                title: Text(
                  'Password reset email sent!',
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.greenAccent,
                  ),
                ),
                autoCloseDuration: const Duration(seconds: 4),
              );
            }
          },
          builder: (context, state) {
            return Form(
              key: formKey,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          'Welcome back!',
                          style: GoogleFonts.workSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: themeColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Log into your account',
                          style: GoogleFonts.workSans(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: containerColor,
                            border: Border.all(
                              color: AppColors.cyanAccent.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              CustomTextField(
                                hintText: 'Enter your email',
                                labelText: 'Email',
                                controller: emailController,
                                validator: Validators.email,
                                isPassword: false,
                                prefixIcon: CupertinoIcons.mail,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                hintText: 'Enter your password',
                                labelText: 'Password',
                                controller: passwordController,
                                validator: Validators.password,
                                isPassword: true,
                                prefixIcon: CupertinoIcons.lock,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => _showForgotPasswordDialog(context),
                                  child: Text(
                                    'Forgot Password?',
                                    style: GoogleFonts.workSans(
                                      color: AppColors.cyanAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              state is AuthLoading
                                  ? const CupertinoActivityIndicator(
                                      radius: 16,
                                      color: AppColors.cyanAccent,
                                    )
                                  : AppButton(
                                      onTap: () {
                                        if (!formKey.currentState!.validate()) {
                                          return;
                                        }
                                        context.read<AuthCubit>().signIn(
                                          email: emailController.text.trim(),
                                          password: passwordController.text,
                                        );
                                      },
                                      text: 'Sign In',
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Or continue with',
                          style: GoogleFonts.workSans(
                            fontSize: 16,
                            color: AppColors.instance.gray,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Spacer(),
                            OutlinedButton(
                              onPressed: () {
                                context.read<AuthCubit>().signInWithGoogle();
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: containerColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: themeColor.withValues(alpha: 0.15),
                                  ),
                                ),
                                fixedSize: const Size(160, 60),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.account_circle_outlined,
                                    size: 24,
                                    color: AppColors.cyanAccent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Google',
                                    style: GoogleFonts.workSans(
                                      color: themeColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: () {
                                toastification.show(
                                  context: context,
                                  type: ToastificationType.info,
                                  title: Text(
                                    'Facebook login is currently disabled',
                                    style: GoogleFonts.workSans(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  autoCloseDuration: const Duration(seconds: 2),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: containerColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: themeColor.withValues(alpha: 0.15),
                                  ),
                                ),
                                fixedSize: const Size(160, 60),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.facebook,
                                    size: 24,
                                    color: Colors.blueAccent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Facebook',
                                    style: GoogleFonts.workSans(
                                      color: themeColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(RouteNames.signUp);
                            },
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Don't have an account? ",
                                    style: GoogleFonts.workSans(
                                      color: AppColors.instance.gray,
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: GoogleFonts.workSans(
                                      color: AppColors.cyanAccent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
