// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saive/router/route_names.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  factory SettingsService() => _instance ??= SettingsService._();

  SettingsService._();

  static SettingsService? _instance;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static String nameCollKey = 'fullName';
  static String phoneCollKey = 'phoneNumber';
  static String contct1CollKey = 'contct1';
  static String contct2CollKey = 'contct2';
  static String statusCollKey = 'status';

  Future<void> saveProfile({
    required String fullName,
    required String phone,
    required String contct1,
    required String contct2,
    String? status,
  }) async {
    final prefs = await _prefs;
    BotToast.showLoading();
    try {
      prefs
        ..setString(nameCollKey, fullName)
        ..setString(phoneCollKey, phone)
        ..setString(contct1CollKey, contct1)
        ..setString(contct2CollKey, contct2)
        ..setString(statusCollKey, status ?? 'null');
    } catch (e) {
      log(e.toString());
    } finally {
      final prefs = await _prefs;
      String? fn = prefs.getString(nameCollKey);

      log('name: $fn');
      Timer(const Duration(milliseconds: 1500), () {
        BotToast.closeAllLoading();
      });
    }
  }

  Future<String?> getName() async {
    final prefs = await _prefs;
    String? data = prefs.getString(nameCollKey);
    return data;
  }

  Future<String?> getPhone() async {
    final prefs = await _prefs;
    String? data = prefs.getString(phoneCollKey);
    return data;
  }

  Future<String?> getContct1() async {
    final prefs = await _prefs;
    return prefs.getString(contct1CollKey);
  }

  Future<String?> getContct2() async {
    final prefs = await _prefs;
    return prefs.getString(contct2CollKey);
  }

  Future<String?> getStatus() async {
    final prefs = await _prefs;
    return prefs.getString(statusCollKey);
  }

  Future<void> modPrefPrompt(BuildContext context) async {
    final prefs = await _prefs;
    String? fn = prefs.getString(nameCollKey);
    log(fn.toString());

    if (fn == null) {
      showModalBottomSheet(
        context: context,
        builder: (cntxt) => Container(
          height: 300,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_rounded,
                size: 20,
                color: Colors.red,
              ),
              const SizedBox.square(dimension: 20),
              const Text(
                'Update your profile as this will be useful during emergencies',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox.square(dimension: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    context
                      ..pop()
                      ..pushNamed(NamedRoutes.settings.name);
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text('continue'),
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}
