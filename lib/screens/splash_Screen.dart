import 'dart:async';
import 'package:flutter/material.dart';
import 'package:test/sharedPrefrenceMethods/SharedPrefrenceMethods.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  late Animation<double> _descFade;
  late Animation<Offset> _descSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Title animations
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(curve: Curves.easeOut, parent: _controller),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(curve: Curves.easeIn, parent: _controller),
    );

    // Description animations
    _descFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _descSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // CHECK LOGIN + NAVIGATE
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3)); // splash wait

    final prefs = SharedPreferenceMethods();
    bool isLoggedIn = await prefs.getUserLogin(); // check SharedPreferences

    print("aaaaaaaaa SplashScreen: isLoggedIn = $isLoggedIn");

    if (mounted) {
      if (isLoggedIn) {
        print("aaaaaaaaa SplashScreen: navigating to HomeScreen");
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        print("aaaaaaaaa SplashScreen: navigating to LoginScreen");
        Navigator.pushReplacementNamed(context, "/login");
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: _fade.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: const Icon(Icons.wechat_outlined, size: 100),
                  ),
                ),
                Opacity(
                  opacity: _fade.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: const Text(
                      "Bi lang",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SlideTransition(
                  position: _descSlide,
                  child: Opacity(
                    opacity: _descFade.value,
                    child: const Text(
                      "break the language barrier",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
