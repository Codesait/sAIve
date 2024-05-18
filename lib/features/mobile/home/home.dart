// ignore_for_file: slash_for_doc_comments

import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saive/router/route_names.dart';
import 'package:saive/service/auth_service.dart';
import 'package:saive/service/location.dart';
import 'package:saive/service/report.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final firebaseAuth = AuthService().firebaseAuth;

  final formKey = GlobalKey<FormState>();

  Map<dynamic, dynamic> _report = {};

  /**
    report entry controllers
   */
  TextEditingController? titleController;
  TextEditingController? descController;

  /// `User` object from the Firebase authentication system
  /// or it can be `null` if no user is currently authenticated.
  User? user;

  final reportService = Report();
  final locationService = EQLocationService();

  Future<void> initDash() async {
    /**
      get user first
     */
    await checkForCurrentUser();

    //* start fetching report made by
    //* existing user

    await fetchReportByUser(user!.email!);
  }

  Future<void> fetchReportByUser(String user) async {
    BotToast.showLoading();
    try {
      // Create a query to fetch reports where 'user' field matches userId
      reportService.databaseReference.orderByChild('user').equalTo(user)
        ..onValue.listen((event) {
          final querySnapshot = event.snapshot;

          ///* cast the `value` property of the
          ///* `querySnapshot` object to a `Map<dynamic, dynamic>` type.
          if (querySnapshot.value != null) {
            BotToast.closeAllLoading();
            Map<dynamic, dynamic> credentialsMap =
                querySnapshot.value as Map<dynamic, dynamic>;

            credentialsMap.forEach((key, value) {
              setState(() {
                _report = {
                  'id': key,
                  ...value['data'],
                };
              });
            });

            log('My CRED $_report');
          }
        })
        ..onChildChanged.listen((event) {
          final updatedSnapshot = event.snapshot;

          ///* cast the `value` property of the
          ///* `querySnapshot` object to a `Map<dynamic, dynamic>` type.
          if (updatedSnapshot.value != null) {
            Map<dynamic, dynamic> credentialsMap =
                updatedSnapshot.value as Map<dynamic, dynamic>;

            credentialsMap.forEach((key, value) {
              setState(() {
                _report = {
                  'id': key,
                  ...value['data'],
                };
              });
            });

            log('My CRED $_report');
          }
        });
    } catch (e) {
      BotToast.closeAllLoading();
      log('FETCH REPORT BY USER ERROR: ${e.toString()}');
      rethrow; // Rethrow the error for handling in the UI
    }
  }

  @override
  void initState() {
    titleController = TextEditingController();
    descController = TextEditingController();
    initDash();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    locationService.handleLocationPermission(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      onPopInvoked: (didPop) {
        context.pushReplacementNamed(NamedRoutes.splash.name);
      },
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () {
              return initDash();
            },
            child: SingleChildScrollView(
              child: SizedBox(
                height: size.height,
                width: size.width,
                child: user != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _UserWidget(userDetails: user!),
                          ),
                          Expanded(
                            flex: 7,
                            child: _PanicWidget(
                              myReport: _report,
                            ),
                          )
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.blue,
          child: const Icon(Icons.report),
        ),
      ),
    );
  }

  Future<dynamic> checkForCurrentUser() async {
    BotToast.showLoading();
    try {
      firebaseAuth.authStateChanges().listen(
        (account) {
          if (account != null) {
            setState(() {
              user = account;
            });

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
}

class _UserWidget extends StatelessWidget {
  const _UserWidget({
    required this.userDetails,
  });
  final User userDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CachedNetworkImage(
              imageUrl: userDetails.photoURL ?? '',
              height: 10,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(.2),
                child: const Icon(Icons.person),
              ),
            ),
          ),
        ),
        const SizedBox.square(
          dimension: 10,
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: userDetails.email),
            ],
          ),
          style: GoogleFonts.poppins(
              color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox.square(dimension: 10),
        SizedBox(
          width: 130,
          child: ElevatedButton(
            onPressed: () {
              AuthService().signOut(context).then((value) {
                context.pushReplacementNamed(NamedRoutes.signIn.name);
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Logout ',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        const SizedBox.square(dimension: 10),
      ],
    );
  }
}

class _PanicWidget extends StatefulWidget {
  const _PanicWidget({required this.myReport});
  final Map<dynamic, dynamic> myReport;

  @override
  State<_PanicWidget> createState() => _PanicWidgetState();
}

class _PanicWidgetState extends State<_PanicWidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final myReportStats = widget.myReport;

    String locationTimeline() {
      if (myReportStats['reportStatus'] == 'IN_TROUBLE' &&
          _currentAddress != null) {
        return 'Last location: ${_currentAddress!}';
      } else if (myReportStats['reportStatus'] == 'IN_TROUBLE' &&
          _currentAddress == null) {
        return 'Last location: ${myReportStats['address']!}';
      } else {
        return '';
      }
    }

    return Container(
      width: size.width,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 10,
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Spacer(),
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: myReportStats['reportStatus'] != 'IN_TROUBLE'
                  ? Colors.amber
                  : Colors.green,
            ),
            child: IconButton(
              onPressed: () {
                if (myReportStats['reportStatus'] == 'IN_TROUBLE') {
                  startOrStoplocationPing(
                    reportId: myReportStats['id'],
                    status: 'SAFE',
                  );
                } else {
                  startOrStoplocationPing(
                    reportId: myReportStats['id'],
                    status: 'IN_TROUBLE',
                  );
                }
              },
              color: Colors.white,
              icon: const Icon(Icons.location_disabled),
            ),
          ),
          const SizedBox.square(dimension: 20),
          Text(
            myReportStats['reportStatus'] == 'IN_TROUBLE'
                ? 'PANIC ON'
                : 'PANIC OFF',
            style: GoogleFonts.aBeeZee(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox.square(dimension: 20),
          Visibility(
            visible: (_currentAddress != null),
            child: Text(
              locationTimeline(),
              style: GoogleFonts.aBeeZee(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }

  final reportService = Report();
  final locationService = EQLocationService();

  String? _currentAddress;
  Position? _currentPosition;

  Future<void> startOrStoplocationPing({
    required String reportId,
    required String status,
  }) async {
    try {
      await locationService.getCurrentPosition(context).then((value) {
        setState(() {
          _currentPosition = value;
        });
      });

      BotToast.showLoading();
      //*use positions to get address
      await locationService
          .getAddressFromLatLng(_currentPosition!)
          .then((value) {
        final placemarks = value as List<Placemark>;

        Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              '${place.street}, ${place.subLocality} ${place.subAdministrativeArea}, ${place.postalCode}';
        });
      });

      //* then submit
      await reportService.updateReport(
        reportId: reportId,
        longitude: _currentPosition!.longitude.toString(),
        latitude: _currentPosition!.latitude.toString(),
        address: _currentAddress,
        status: status,
      );
    } catch (e) {
      log(e.toString());
    } finally {
      BotToast.closeAllLoading();
    }
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {Key? key,
      required this.controller,
      this.hintText,
      this.prefix,
      this.suffixIcon,
      this.labelText,
      this.validator,
      this.obscureText,
      this.readOnly = false,
      this.autoFocus = false,
      this.inputType,
      this.maxLines = 1,
      this.maxLength,
      this.focusNode,
      this.onChange,
      this.fillColor,
      this.onTap,
      this.prefixColor,
      this.fontSize})
      : super(key: key);
  final TextEditingController controller;
  final String? hintText;
  final Widget? prefix;
  final Widget? suffixIcon;
  final String? labelText;
  final FormFieldValidator<String>? validator;
  final bool? obscureText;
  final TextInputType? inputType;
  final bool readOnly;
  final bool autoFocus;
  final int? maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final void Function()? onTap;
  final Function(String? val)? onChange;
  final Color? fillColor;
  final Color? prefixColor;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      readOnly: readOnly,
      autofocus: autoFocus,
      onChanged: onChange,
      maxLines: maxLines,
      maxLength: maxLength,
      focusNode: focusNode,
      obscureText: obscureText ?? false,
      onTap: onTap,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(fontSize: fontSize ?? 14),
      keyboardType: inputType,
      cursorColor: Colors.grey,
      decoration: InputDecoration(
          hintStyle: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey, fontSize: fontSize ?? 14),
          counterStyle: const TextStyle(
              color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
          hintText: hintText,
          prefixIcon: prefix,
          prefixIconColor: prefixColor ??
              MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.focused)
                    ? Colors.black
                    : const Color(0xFF9E9E9E),
              ),
          suffixIcon: suffixIcon,
          suffixIconColor: MaterialStateColor.resolveWith(
            (states) => states.contains(MaterialState.focused)
                ? Colors.black
                : const Color(0xFF9E9E9E),
          ),
          labelText: labelText,
          labelStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 15),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.purple.withOpacity(.5), width: 1.0),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: readOnly || maxLength != null
                ? BorderSide.none
                : const BorderSide(color: Colors.purple, width: 2.0),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          filled: true,
          fillColor: fillColor ?? Colors.white),
    );
  }
}
