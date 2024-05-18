import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Report {
  factory Report() => _instance ??= Report._();

  Report._();
  static Report? _instance;

  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref().child('users');

  Future<dynamic> createReport({
    required String user,
    required String longitude,
    required String latitude,
    String? address,
  }) async {
    BotToast.showLoading();
    try {
      await databaseReference.push().set({
        'user': user,
        'data': {
          'uniqueId': UniqueKey().toString() + UniqueKey().toString(),
          'longitude': longitude,
          'latitude': latitude,
          'address': address,
          'reportStatus': 'SAFE',
          'createdAt': DateTime.now().toString(),
        },
      }).then((value) {
        //BotToast.closeAllLoading();
        showToast(msg: 'Report Created');
      });
      return true; // Indicate success
    } catch (e) {
      //BotToast.closeAllLoading();
      showToast(msg: e.toString(), isError: true);
      log('CREATE REPORT ERROR ${e.toString()}');
      return e.toString(); // Return error message if any
    }
  }


  Future<dynamic> updateReport({
    required String reportId,
    required String longitude,
    required String latitude,
    required String status,
    String? address,
  }) async {
    BotToast.showLoading();
    try {
      await databaseReference.child(reportId).update({
        'data': {
          'longitude': longitude,
          'latitude': latitude,
          'address': address,
          'reportStatus': status,
          'createdAt': DateTime.now().toString(),
        },
      }).whenComplete(() {
        BotToast.closeAllLoading();
      });

      return true; // Indicate success
    } catch (e) {
      return e.toString(); // Return error message if any
    }
  }

  Future<dynamic> deleteReport(String reportId) async {
    try {
      await databaseReference.child(reportId).remove();
      return true; // Indicate success
    } catch (e) {
      return e.toString(); // Return error message if any
    }
  }

  void showToast({required String msg, bool isError = false}) {
    BotToast.showSimpleNotification(
      title: msg,
      backgroundColor: isError ? Colors.red : Colors.green,
      titleStyle: const TextStyle(
        color: Colors.white,
      ),
    );
  }

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
}
