import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/input_converter/input_validator.dart';
import 'package:spotter/core/snack_bar_builder.dart';
import 'package:spotter/core/usecases/usecase.dart';
import 'package:spotter/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:spotter/features/auth/presentation/widgets/spotter_title.dart';
import 'package:spotter/features/auth/presentation/widgets/text_form_title.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final AuthBloc authBloc = context.read<AuthBloc>();
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError)
          SnackBarBuilder.showSnackBar(context, state.message, true, cs);
        if (state is UnAuthenticated)
          SnackBarBuilder.showSnackBar(
            context,
            'An email with the reset link was sent, check you inbox',
            false,
            cs,
          );
      },
      builder: (context, state) {
        bool isLoading = state is AuthLoading;
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const SpotterTitle(),
          ),
          body: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constraints) => Column(
                    children: [
                      const SizedBox(height: 10),
                      Text('Reset Password', style: text.headlineMedium),
                      const SizedBox(height: 10),
                      Text(
                        'Enter your email to receive recovery instructions.',
                        textAlign: TextAlign.center,
                        style: text.bodyMedium!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormTitle(
                        text: text,
                        cs: cs,
                        title: 'REGISTERED EMAIL',
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.alternate_email_rounded,
                            color: cs.primary,
                          ),
                          hintText: 'name@domain.com',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                        validator: (value) =>
                            InputValidator.validateEmail(value),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: constraints.maxWidth,
                        child: FilledButton(
                          onPressed: !isLoading
                              ? () {
                                  if (formKey.currentState!.validate())
                                    authBloc.add(
                                      PasswordResetRequested(
                                        resetParams: ResetParams(
                                          email: emailController.text.trim(),
                                        ),
                                      ),
                                    );
                                }
                              : null,
                          child: const Text(
                            'Send Reset Link',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.mark_email_read_outlined,
                                    size: 22,
                                    color: cs.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'If this email is registered, we sent a reset link.',
                                      style: text.bodyMedium!.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_outlined,
                                    size: 16,
                                    color: cs.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Check your inbox & spam',
                                      style: text.labelSmall!.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      OutlinedButton.icon(
                        onPressed: !isLoading
                            ? () {
                                Navigator.pop(context);
                              }
                            : null,
                        icon: const Icon(Icons.arrow_back_outlined, size: 18),
                        label: const Text('Return to Sign In'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: cs.surfaceContainerLow,
                          shape: const StadiumBorder(),
                          minimumSize: const Size(0, 44),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
