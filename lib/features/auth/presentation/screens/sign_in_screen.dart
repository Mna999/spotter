import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotter/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:spotter/features/auth/presentation/widgets/info_tile.dart';
import 'package:spotter/features/auth/presentation/widgets/text_form_title.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = context.read<AuthBloc>();
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {},

      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text('Sign In', style: text.headlineMedium)),
          body: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constraints) => Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: cs.primary, width: 0.5),
                            ),
                            child: Text(
                              'AI BIOTELEMETRY ACTIVE',
                              style: text.bodyMedium!.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: constraints.maxWidth * 0.25,

                        child: Image.asset(
                          './lib/core/assets/images/logo.png',
                          scale: 0.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Spotter', style: text.headlineLarge),
                      const SizedBox(height: 5),
                      Text(
                        'BE SPOT ON.',
                        style: text.labelMedium!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: InfoTile(
                              cs: cs,
                              text: text,
                              title: 'VISION ENGINE',
                              subtitle: 'Kinetic Tracking',
                              icon: Icons.motion_photos_on_outlined,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InfoTile(
                              cs: cs,
                              text: text,
                              icon: Icons.restaurant,
                              subtitle: 'Egyptian Nutrition',
                              title: 'LOCAL MACROS',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'AI-powered niomechanics coaching & Egyptian nutrition guidance, built for real progress',
                          textAlign: TextAlign.center,
                          style: text.bodyMedium!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormTitle(
                        text: text,
                        cs: cs,
                        title: 'EMAIL ADDRESS',
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                          hintText: 'karim.fouad@example.com',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormTitle(
                        text: text,
                        cs: cs,
                        title: 'PASSWORD',
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: isObscure,
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
                          hintText: 'karim.fouad@example.com',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {},
                          child: Text(
                            'Forgot Password?',

                            style: text.titleSmall!,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: constraints.maxWidth,
                        child: FilledButton.icon(
                          onPressed: () {},
                          label: const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'SIGN IN',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_forward_ios_outlined),
                          iconAlignment: IconAlignment.end,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR CONTINUE WITH',
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: constraints.maxWidth,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          label: const Text('  Continue With Google'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: cs.surfaceContainerLow,
                            disabledBackgroundColor: cs.surfaceContainerLow,
                            alignment: AlignmentDirectional.centerStart,
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: 16,
                            ),
                          ),
                          icon: FaIcon(
                            FontAwesomeIcons.google,
                            color: cs.secondaryFixedDim,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Don\'t have an account?',
                        style: text.bodyMedium!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: () {},
                        child: Text(
                          'Create Account >',
                          style: text.titleSmall!,
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
