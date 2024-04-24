// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:saive/service/auth_service.dart';

class EQLocationService {
  factory EQLocationService() => _instance ??= EQLocationService._();

  EQLocationService._();
  static EQLocationService? _instance;

  Future<dynamic> getCurrentPosition(BuildContext context) async {
    AuthService().customLoader();
    try {
      final hasPermission = await handleLocationPermission(context);
      if (!hasPermission) return;
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).whenComplete(() => BotToast.closeAllLoading());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<dynamic> getAddressFromLatLng(Position position) async {
    try {
      return placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }
}
