import 'dart:async';
import 'package:design_system_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(
      const Duration(seconds: 3),
      () => context.go('/demographics'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_rect.png', height: 200),
            const SizedBox(height: 20),
            const Text(
              "Laboratório de Pesquisa Aplicada a Neurovisão",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Prof. Hugo de Paula, Ph. D.",
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }
}
