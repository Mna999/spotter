import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/input_converter/input_validator.dart';
import 'package:spotter/core/route/routing.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:spotter/features/auth/presentation/screens/onBoarding_screen.dart';
import 'package:spotter/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:spotter/features/auth/presentation/widgets/spotter_title.dart';
import 'package:spotter/features/auth/presentation/widgets/text_form_title.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isObscure = true;
  bool isAgreed = false;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final AuthBloc authBloc = context.read<AuthBloc>();
    return Scaffold(
      appBar: AppBar(title: const SpotterTitle()),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError)
            SnackBarBuilder.showSnackBar(context, state.message, true, cs);

          if (state is Authenticated && !state.verificationEmailSent) {
            authBloc.add(
              VerificationEmailRequested(userAccount: state.userAccount),
            );
          }

          if (state is Authenticated && state.verificationEmailSent) {
            SnackBarBuilder.showSnackBar(
              context,
              'A verification link has been sent to your email. Please check your inbox to verify your account.',
              false,
              cs,
            );

            Routing.routeReplacement(const OnboardingScreen(), context);
          }
        },
        builder: (context, state) {
          isLoading = state is AuthLoading;
          return Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constraints) => Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Create Account',
                          style: text.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormTitle(text: text, cs: cs, title: 'FULL NAME'),
                      const SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        controller: nameController,
                        validator: InputValidator.validateName,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline_rounded),

                          hintText: 'Karim Fouad',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormTitle(text: text, cs: cs, title: 'EMAIL ADDRESS'),
                      const SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        validator: (value) {
                          return InputValidator.validateEmail(value);
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.mail_outline_rounded),

                          hintText: 'karim.fouad@example.com',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormTitle(text: text, cs: cs, title: 'PASSWORD'),
                      const SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: isObscure,
                        validator: (value) {
                          return InputValidator.validatePassword(value);
                        },
                        controller: passwordController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () {
                              isObscure = !isObscure;
                              setState(() {});
                            },
                            icon: Icon(
                              isObscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off,
                            ),
                          ),
                          hintText: '•••••••••••••••',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormTitle(
                        text: text,
                        cs: cs,
                        title: 'CONFIRM PASSWORD',
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: isObscure,
                        validator: (value) {
                          if (value != passwordController.text)
                            return 'Passwords Don\'t Match';
                          return null;
                        },
                        controller: confirmPasswordController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock_clock_rounded),
                          hintText: '•••••••••••••••',
                        ),
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        value: isAgreed,
                        onChanged: (value) {
                          isAgreed = value ?? false;
                          setState(() {});
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: Text.rich(
                          TextSpan(
                            text: 'I agree to the ',
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: cs.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: ' and Privacy Policy.'),
                            ],
                          ),
                          style: text.bodySmall!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      SizedBox(
                        width: constraints.maxWidth,
                        child: FilledButton.icon(
                          onPressed: isAgreed && !isLoading
                              ? () {
                                  if (formKey.currentState!.validate() &&
                                      isAgreed) {
                                    authBloc.add(
                                      SignUpSubmitted(
                                        signUpParams: SignUpParams(
                                          email: emailController.text.trim(),
                                          password: passwordController.text,
                                          name: nameController.text.trim(),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          label: const Text(
                            'Create Account',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          icon: const Icon(Icons.arrow_forward_outlined),
                          iconAlignment: IconAlignment.end,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: text.bodyMedium!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: !isLoading
                                ? () {
                                    Routing.routeReplacement(
                                      const SignInScreen(),
                                      context,
                                    );
                                  }
                                : null,
                            child: Text(
                              'Sign In',
                              style: text.labelLarge!.copyWith(
                                color: cs.primary,
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
          );
        },
      ),
    );
  }
}
