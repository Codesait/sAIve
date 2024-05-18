import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saive/router/route_names.dart';

class WebSplash extends StatefulWidget {
  const WebSplash({super.key});

  @override
  State<WebSplash> createState() => _WebSplashState();
}

class _WebSplashState extends State<WebSplash> {
  void initApp() {
    Future.delayed(const Duration(seconds: 3), () {
      GoRouter.of(context).pushReplacementNamed(NamedRoutes.dashboard.name);
    });
  }

  @override
  void initState() {
    initApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'sAIve'),
            TextSpan(
              text: '|Admin',
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )
          ]),
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color:  Colors.blue,
          ),
        ),
      ),
    );
  }
}
