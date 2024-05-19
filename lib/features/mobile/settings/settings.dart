import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saive/app/color.dart';
import 'package:saive/router/route_names.dart';
import 'package:saive/service/auth_service.dart';
import 'package:saive/service/report.dart';
import 'package:saive/service/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? nameController;
  String? phoneController;

  String? contct1Controller;
  String? contct2Controller;

  String? statusController;

  final formKey = GlobalKey<FormState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final service = SettingsService();

  @override
  void initState() {
    fetchAll();
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   fetchAll();
  //   super.didChangeDependencies();
  // }

  Future<void> fetchAll() async {
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

    void save() {
      if (nameController == null) {
        Report().showToast(msg: 'Name is Required', isError: true);
      } else if (phoneController == null) {
        Report().showToast(msg: 'Phone is Required', isError: true);
      } else if (contct1Controller == null) {
        Report().showToast(msg: 'Contact 1 is Required', isError: true);
      } else if (contct2Controller == null) {
        Report().showToast(msg: 'Contact 2 is Required', isError: true);
      } else {
        log(nameController.toString());
        SettingsService().saveProfile(
          fullName: nameController!.trim(),
          phone: phoneController!.trim(),
          contct1: contct1Controller!.trim(),
          contct2: contct2Controller!.trim(),
          status: statusController,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Preference',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              /**
                About User
               */
              _SectionWrap(
                sectionTitle: 'About me *',
                child: Column(
                  children: [
                    TextFormField(
                      controller: TextEditingController(text: nameController),
                      onChanged: (value) {
                        nameController = value;
                      },
                      decoration: const InputDecoration(
                        label: Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        hintText: 'Joe Brymo',
                      ),
                    ),
                    const SizedBox.square(dimension: 10),
                    TextFormField(
                      controller: TextEditingController(text: phoneController),
                      onChanged: (value) {
                        phoneController = value;
                      },
                      decoration: const InputDecoration(
                        label: Text(
                          'Phone Number',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox.square(dimension: 20),

              /**
                User Contacts
              */
              _SectionWrap(
                sectionTitle: 'Contacts *',
                child: Column(
                  children: [
                    TextFormField(
                      controller:
                          TextEditingController(text: contct1Controller),
                      onChanged: (value) {
                        contct1Controller = value;
                      },
                      decoration: const InputDecoration(
                        label: Text(
                          'Contact 1',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        hintText: 'Dad: 090123455676',
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'required';
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox.square(dimension: 10),
                    TextFormField(
                      controller:
                          TextEditingController(text: contct2Controller),
                      onChanged: (value) {
                        contct2Controller = value;
                      },
                      decoration: const InputDecoration(
                          label: Text(
                            'Contact 2',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          hintText: 'Joe: 090123455676'),
                      validator: (value) {
                        if (value == null) {
                          return 'required';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox.square(dimension: 20),

              /**
                User Contacts
              */
              _SectionWrap(
                sectionTitle:
                    'About plans, be it part plans, guests or anything about your day (optional)',
                child: Column(
                  children: [
                    TextFormField(
                      controller: TextEditingController(text: statusController),
                      onChanged: (value) {
                        statusController = value;
                      },
                      decoration: const InputDecoration(
                        label: Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox.square(dimension: 20),

              /**
                save
              */
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    save();
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: const Text('Save Profile'),
                ),
              ),
              const SizedBox.square(dimension: 70),

              /**
                log out 
               */
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: size.width / 1.3,
                  child: ElevatedButton(
                    onPressed: () {
                      AuthService().signOut(context).then((value) {
                        context.pushReplacementNamed(NamedRoutes.signIn.name);
                      });
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
              )
            ],
          ),
        ),
      )),
    );
  }
}

class _SectionWrap extends StatelessWidget {
  const _SectionWrap({
    required this.sectionTitle,
    required this.child,
  });
  final Widget child;
  final String sectionTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox.square(dimension: 10),
          child,
        ],
      ),
    );
  }
}
