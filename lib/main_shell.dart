import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter/core/route/routing.dart';
import 'package:spotter/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:spotter/features/auth/presentation/screens/profile_screen.dart';
import 'package:spotter/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:spotter/features/workouts/presentation/screens/workout_list_screen.dart';
import 'package:spotter/home_screen.dart';

/// Root navigation shell for the signed-in app.
///
/// Keeps the three top-level destinations alive in an [IndexedStack] so the
/// workout dashboard keeps its scroll position and loaded data while the user
/// moves between tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  late final AnimationController _tabTransition = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
    value: 1,
  );
  late final Animation<double> _tabOpacity = _tabTransition.drive(
    CurveTween(curve: Curves.easeOutCubic),
  );
  late final Animation<Offset> _tabOffset = _tabTransition.drive(
    Tween<Offset>(
      begin: const Offset(0, 0.015),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic)),
  );

  @override
  void dispose() {
    _tabTransition.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    _tabTransition.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UnAuthenticated) {
          Routing.routeReplacement(const SignInScreen(), context);
        }
      },
      child: Scaffold(
        body: FadeTransition(
          opacity: _tabOpacity,
          child: SlideTransition(
            position: _tabOffset,
            child: IndexedStack(
              index: _index,
              children: [
                HomeScreen(onOpenWorkouts: () => _select(1)),
                const WorkoutListScreen(),
                const ProfileScreen(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center),
              label: 'Workouts',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
