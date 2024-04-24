import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saive/app/color.dart';
import 'package:saive/router/route_names.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool authLoading = false;

  bool checkingUser = true;

  ///  instance of the`FirebaseAuth` class using the `instance` property.
  final firebaseAuth = FirebaseAuth.instance;

  /// `User` object from the Firebase authentication system
  /// or it can be `null` if no user is currently authenticated.
  User? user;

  //
  void checkForCurrentUser() {
    try {
      firebaseAuth.authStateChanges().listen(
        (account) {
          if (account != null) {
            setState(() {
              user = account;
            });
            /**
           * if user is already signed in, they will be nvigated 
           * to home screen after a two seconds delay
           */
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                checkingUser = false;
              });
              GoRouter.of(context).pushReplacementNamed(
                NamedRoutes.homePage.name,
              );
            });
          }
        },
        onError: (e) {
          if (kDebugMode) {
            print('SIGN IN ERROR: $e');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkForCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: AppColors.primary,
        body: Container(
          height: size.height,
          width: size.width,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: SingleChildScrollView(
            child: !checkingUser
                ? Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox.square(
                        dimension: 10,
                      ),
                      Text(
                        '...please wait',
                        style: GoogleFonts.poppins(color: Colors.white),
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // illustration

                      // about app
                      Text.rich(
                        TextSpan(children: [
                          const TextSpan(text: 'Beyond'),
                          TextSpan(
                            text: '\nPromoting ',
                            style: GoogleFonts.inter(
                              color: Colors.amber,
                            ),
                          ),
                          const TextSpan(text: 'Self-'),
                          TextSpan(
                            text: 'Defense',
                            style: GoogleFonts.inter(
                              color: Colors.greenAccent,
                            ),
                          ),
                        ]),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox.square(
                        dimension: 10,
                      ),

                      SizedBox(
                        width: 260,
                        child: Text(
                          'Create Instant real-time location pings',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox.square(
                        dimension: 40,
                      ),

                      ElevatedButton(
                        onPressed: () =>
                            context.pushNamed(NamedRoutes.userAuth.name),
                        child: const Text(
                          'Continue',
                          style: TextStyle(color: Colors.green),
                        ),
                      )
                    ],
                  ),
          ),
        ));
  }
}
