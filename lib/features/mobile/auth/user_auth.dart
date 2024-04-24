// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saive/app/color.dart';
import 'package:saive/router/route_names.dart';
import 'package:saive/service/auth_service.dart';
import 'package:saive/service/report.dart';

class UserAuth extends StatefulWidget {
  const UserAuth({super.key});

  @override
  State<UserAuth> createState() => _UserAuthState();
}

class _UserAuthState extends State<UserAuth> {
  bool isLogin = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController? emailController;
  TextEditingController? passwordController;

  @override
  void initState() {
    isLogin = true;
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isLogin ? Colors.green : Colors.amber,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: size.height,
            width: size.width,
            padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 40),
            child: Column(
              children: [
                //back btn
                _BackBtn(key: Key('auth_screen_key')),

                // registration flow
                Container(
                  height: size.height / 1.5,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          isLogin ? 'Sign In' : 'Sign Up',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Text inputs
                        SizedBox.square(dimension: 20),
                        TextFormField(
                          controller: emailController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'required';
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Email Address',
                            prefixIcon: Icon(Icons.person_2_outlined),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        SizedBox.square(dimension: 20),
                        TextFormField(
                          controller: passwordController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'required';
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.key_off_outlined),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        SizedBox.square(dimension: 50),

                        // Auth Button
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              /// The code snippet `if (isLogin) { signIn(); } else { signUp(); }` is checking
                              /// the value of the `isLogin` variable to determine whether the user is trying
                              /// to sign in or sign up.

                              if (isLogin) {
                                signIn();
                              } else {
                                signUp();
                              }
                            }
                          },
                          child: const Text(
                            'Proceed',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox.square(dimension: 50),

                        // select Auth mode (Sign up or Sign In)
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                                text: isLogin
                                    ? 'Not Registerd ? '
                                    : 'Already registered ? '),
                            WidgetSpan(
                              child: InkWell(
                                onTap: () {
                                  if (isLogin) {
                                    setState(() => isLogin = false);
                                  } else {
                                    setState(() => isLogin = true);
                                  }
                                },
                                child: Text(
                                  isLogin ? 'Register' : 'Login',
                                  style: TextStyle(
                                    color: isLogin
                                        ? Colors.white
                                        : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signIn() {
    AuthService()
        .signIn(
      context,
      email: emailController!.text.trim(),
      password: passwordController!.text.trim(),
    )
        .then((value) {
      if (value.toString().contains('UserCredential')) {
        context.pushReplacementNamed(NamedRoutes.homePage.name);
      }

      if (kDebugMode) {
        log('SIGN IN VALUE: $value');
      }
    }).whenComplete(() {
      BotToast.closeAllLoading();
    });
  }

  void signUp() {
    AuthService()
        .signUp(context,
            email: emailController!.text.trim(),
            password: passwordController!.text.trim())
        .then((value) {
      if (value.toString().contains('UserCredential')) {
        Report().createReport(
          user: emailController!.text.trim(),
          longitude: '',
          latitude: '',
          address: '',
        );
        GoRouter.of(context).pushReplacementNamed(NamedRoutes.homePage.name);
      }
      if (kDebugMode) {
        log('SIGN IN VALUE: $value');
      }
    }).whenComplete(() {
      BotToast.closeAllLoading();
    });
  }
}

class _BackBtn extends StatelessWidget {
  const _BackBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back,
          ),
        )
      ],
    );
  }
}
