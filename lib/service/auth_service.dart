// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthService {
  final firebaseAuth = FirebaseAuth.instance;

  get user => firebaseAuth.currentUser;

  User? _appUser;
  User? get appUser => _appUser;

  void showSnackbarMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, right: 20, left: 20),
      ),
    );
  }

  //SIGN UP METHOD
  Future signUp(BuildContext context,
      {required String email, required String password}) async {
    BotToast.showLoading();
    try {
      return await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      showSnackbarMessage(context, e.message!, isError: true);
      return e.message;
    }
  }

  //SIGN IN METHOD
  Future signIn(BuildContext context,
      {required String email, required String password}) async {
    BotToast.showLoading();
    try {
      return await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      showSnackbarMessage(context, e.message!, isError: true);
      return e.message;
    }
  }

  void onError(FirebaseAuthException e, BuildContext context) {
    if (e.code == 'invalid-email') {
      showSnackbarMessage(context, 'Invalid Email');
      if (kDebugMode) {
        print('Firebase Authentication Exception: ${e.code}/////////////');
      }
    } else if (e.code == 'user-not-found') {
      showSnackbarMessage(context, 'User not found for this Email');
      if (kDebugMode) {
        print('Firebase Authentication Exception: ${e.code}/////////////');
      }
    } else if (e.code == 'wrong-password') {
      showSnackbarMessage(context, 'Wrong Password');
      if (kDebugMode) {
        print('Firebase Authentication Exception: ${e.code}/////////////');
      }
    }
  }

  //SIGN OUT METHOD
  Future signOut(BuildContext context) async {
    try {
      return await firebaseAuth.signOut();
    } catch (e) {
      if (kDebugMode) {
        log('signout error: $e');
      }
    }
    
    
    
  }

  Future<void> checkForCurrentUser() async {
    BotToast.showLoading();
    try {
      firebaseAuth.authStateChanges().listen(
        (account) {
          if (account != null) {
            _appUser = account;

            BotToast.closeAllLoading();

            if (kDebugMode) {
              print('USER SIGNED IN $user');
            }
          }
        },
        onDone: () {
          if (kDebugMode) {
            print('CHECKING FOR EXISTING USER DONE');
          }
          BotToast.closeAllLoading();
        },
        onError: (e) {
          if (kDebugMode) {
            print('SIGN IN ERROR: $e');
          }
          BotToast.closeAllLoading();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error $e');
      }
      BotToast.closeAllLoading();
    }
  }

  void customLoader() {
    BotToast.showCustomLoading(toastBuilder: (_) {
      return Container(
        height: 130,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Text('...getting location data'),
          ],
        ),
      );
    });
  }
}
