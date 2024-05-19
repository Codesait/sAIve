// ignore_for_file: slash_for_doc_comments

import 'dart:developer';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saive/app/color.dart';
import 'package:saive/router/route_names.dart';
import 'package:saive/service/auth_service.dart';
import 'package:saive/service/location.dart';
import 'package:saive/service/report.dart';
import 'package:saive/service/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final settingService = SettingsService();

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
    initDash().whenComplete(
      () => settingService.modPrefPrompt(context),
    );

    fetchUserProfile();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    locationService.handleLocationPermission(context);
    super.didChangeDependencies();
  }

  String? nameController;
  String? phoneController;

  String? contct1Controller;
  String? contct2Controller;

  String? statusController;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> fetchUserProfile() async {
    final prefs = await _prefs;

    nameController = prefs.getString('fullName');
    phoneController = prefs.getString('phoneNumber');

    contct1Controller = prefs.getString('contct1');
    contct2Controller = prefs.getString('contct2');

    statusController = prefs.getString('status');
    setState(() {});

    log('name: $nameController');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      onPopInvoked: (didPop) {
        context.pushReplacementNamed(NamedRoutes.splash.name);
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                context.pushNamed(NamedRoutes.settings.name);
              },
              icon: const Icon(Icons.settings),
            )
          ],
        ),
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
                            flex: 2,
                            child: _UserWidget(userDetails: user!),
                          ),
                          Expanded(
                            flex: 8,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _PanicWidget(
                                    myReport: _report,
                                    name: nameController,
                                    phone: phoneController,
                                    contct1: contct1Controller,
                                    contct2: contct2Controller,
                                    lastStatus: statusController,
                                  ),
                                  _report['reportStatus'] == 'IN_TROUBLE'
                                      ? _AiWidget(
                                          name: nameController,
                                          location: _report['address'],
                                          lastStatus: statusController,
                                        )
                                      : const SizedBox()
                                ],
                              ),
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
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {},
        //   backgroundColor: Colors.blue,
        //   child: const Icon(Icons.report),
        // ),
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
              imageUrl: userDetails.photoURL ?? 'https://google.com',
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
      ],
    );
  }
}

class _PanicWidget extends StatefulWidget {
  const _PanicWidget(
      {required this.myReport,
      this.name,
      this.phone,
      this.contct1,
      this.contct2,
      this.lastStatus});
  final Map<dynamic, dynamic> myReport;
  final String? name;
  final String? phone;
  final String? contct1;
  final String? contct2;
  final String? lastStatus;

  @override
  State<_PanicWidget> createState() => _PanicWidgetState();
}

class _PanicWidgetState extends State<_PanicWidget> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
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
      height: 250,
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
              onPressed: () async {
                final prefs = await _prefs;
                String? fn = prefs.getString('fullName');

                if (fn != null) {
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
                } else {
                  // ignore: use_build_context_synchronously
                  SettingsService().modPrefPrompt(context);
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
        name: widget.name,
        phone: widget.phone,
        contct1: widget.contct1,
        contct2: widget.contct2,
        lastStatus: widget.lastStatus,
      );
    } catch (e) {
      log(e.toString());
    } finally {
      BotToast.closeAllLoading();
    }
  }
}

class _AiWidget extends StatefulWidget {
  const _AiWidget({this.name, this.location, this.lastStatus});
  final String? name;
  final String? location;
  final String? lastStatus;

  @override
  State<_AiWidget> createState() => __AiWidgetState();
}

class __AiWidgetState extends State<_AiWidget> {
  final gemini = Gemini.instance;

  String aiResponse = '';

  void runAi() {
    String prompt = 'In a well formatted and spaced out response'
        ' this user by the name ${widget.name} is in a panic emergency'
        'while they should be in school,'
        'in location: ${widget.location} and their last status was "${widget.lastStatus}".'
        'use this infomation to provide tips on what to do and escape the emergency in a calming'
        'response, Response should not be formal or be in form of a letter'
        'Always include the name,loaction in the response'
        'Also Mention that their live location has been share with quick responders';
    gemini.streamGenerateContent(prompt).listen((value) {
      setState(() {
        aiResponse += value.output!;
      });
    }).onError((e) {
      log('streamGenerateContent exception', error: e);
    });

    // gemini.streamGenerateContent(prompt).listen((event) {
    //   print(event.output);
    // }).onData((v) {
    //   setState(() {
    //     aiResponse = v.output!;
    //   });
    // });
  }

  @override
  void initState() {
    runAi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text.rich(
            TextSpan(text: 'sAIve Ai ', children: [
              TextSpan(
                  text: 'powered by Gemini',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber)),
            ]),
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox.square(dimension: 10),
          SizedBox(
            height: 230,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(aiResponse),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
