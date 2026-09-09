import 'package:material_ui/material_ui.dart';
import 'package:gep/router/app_navigation.dart';
import 'package:gep/router/app_routes.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/view/widgets/app_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: const Offset(0, -0.1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        AppNavigation.pushReplacement(context, AppRoutes.kDashboardRoute);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppScaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SlideTransition(
                position: _animation,
                child: Image.asset(
                  fit: BoxFit.cover,
                  isDark ? AppIcons.gepLogoDark : AppIcons.gepLogoLight,
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.5,
                ),
              ),
            ),
          ),
          const Text("Version 1.0.0"),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
