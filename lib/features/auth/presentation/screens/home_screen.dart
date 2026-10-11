import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/route/routing.dart';
import 'package:spotter/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:spotter/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:spotter/features/auth/presentation/widgets/spotter_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final AuthBloc authBloc = context.read<AuthBloc>();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const SpotterTitle(),
          leading: IconButton(
            onPressed: () {
              authBloc.add(SignOutRequested());
              Routing.routeReplacement(const SignInScreen(), context);
            },
            icon: const Icon(Icons.logout),
          ),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return Center(
                child: Text(
                  state.userAccount.displayName,
                  style: text.headlineLarge,
                ),
              );
            }
            if (state is AuthError) {
              return Center(child: Text(state.message));
            }
            if (state is AuthLoading)
              return const Center(child: Text('Loading'));

            return const Center(child: Text('unknown'));
          },
        ),
      ),
    );
  }
}
