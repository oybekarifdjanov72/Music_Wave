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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: themeColor),
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
                  'Successfully created account',
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
                        const SizedBox(height: 30),
                        Text(
                          'Create an account',
                          style: GoogleFonts.workSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: themeColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Join Neon Wave today',
                          style: GoogleFonts.workSans(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
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
                                hintText: 'Enter your full name',
                                labelText: 'Full Name',
                                controller: fullNameController,
                                validator: Validators.fullName,
                                prefixIcon: CupertinoIcons.person,
                              ),
                              const SizedBox(height: 16),
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
                              const SizedBox(height: 16),
                              CustomTextField(
                                hintText: 'Confirm your password',
                                labelText: 'Confirm Password',
                                controller: confirmPasswordController,
                                validator: (v) => Validators.confirmPassword(
                                  v,
                                  passwordController.text,
                                ),
                                isPassword: true,
                                prefixIcon: CupertinoIcons.lock_shield,
                              ),
                              const SizedBox(height: 24),
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
                                        context.read<AuthCubit>().signUp(
                                          email: emailController.text.trim(),
                                          password: passwordController.text,
                                          fullName: fullNameController.text.trim(),
                                        );
                                      },
                                      text: 'Sign Up',
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Or continue with',
                          style: GoogleFonts.workSans(
                            fontSize: 16,
                            color: AppColors.instance.gray,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: TextButton(
                            onPressed: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              } else {
                                Navigator.of(context).pushReplacementNamed(RouteNames.login);
                              }
                            },
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: GoogleFonts.workSans(
                                      color: AppColors.instance.gray,
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Sign In',
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
