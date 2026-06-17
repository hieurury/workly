import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/work_provider.dart';
import 'widgets/common/app_scaffold.dart';
import 'screens/onboarding/onboarding_screen.dart';

/// Root widget cua ung dung Workly.
/// Lang nghe ThemeProvider de phan ung voi thay doi giao dien.
class WorklyApp extends StatelessWidget {
  const WorklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Workly',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          locale: const Locale('vi', 'VN'),
          home: const AppRouter(),
        );
      },
    );
  }
}

/// Router chinh quyet dinh hien thi man hinh nao sau splash.
/// - Dang tai: SplashScreen
/// - Lan dau dung: OnboardingScreen
/// - Da co tai khoan: MainShell
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final userProvider = context.read<UserProvider>();
    final workProvider = context.read<WorkProvider>();

    // Tai du lieu song song de giam thoi gian cho
    await Future.wait([
      userProvider.initialize(),
      workProvider.initialize(),
    ]);

    // Kiem tra va reset streak neu can
    await userProvider.checkAndResetStreak();

    // Nạp trước đường dẫn ảnh
    await userProvider.resolveImagePaths();

    if (mounted) {
      setState(() => _isInitializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const SplashScreen();
    }

    final userProvider = context.watch<UserProvider>();

    if (userProvider.isFirstLaunch) {
      return const OnboardingScreen();
    }

    return const MainShell();
  }
}

/// Man hinh splash hien thi khi app dang khoi tao.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotsController;
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) {
            setState(() {
              _dotCount = _dotCount >= 3 ? 1 : _dotCount + 1;
            });
            _dotsController.reset();
            _dotsController.forward();
          }
        }
      });
    _dotsController.forward();
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFF5F5F5) : const Color(0xFF0A0A0A);
    final subColor = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF5A5A5A);

    final dots = '.' * _dotCount;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ten app
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 24 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                'Workly',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Slogan
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                'Khong co viec gi kho,\nchi so ban mat streak.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: subColor,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Animated dots loading indicator
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) => Opacity(opacity: value, child: child),
              child: _DotsLoader(color: subColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget hien thi 3 dot nhay dong bo
class _DotsLoader extends StatefulWidget {
  final Color color;
  const _DotsLoader({required this.color});

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) ctrl.repeat(reverse: true);
      });
      return ctrl;
    });

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0.0, end: -8.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, _) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, _animations[i].value),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
