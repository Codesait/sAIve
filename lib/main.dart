import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:saive/app/app.dart';
import 'package:saive/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  /// The `Gemini.init(apiKey: 'AIzaSyDXdAnT9HIadltwU8nJ8y37Ls1bqwKCNxc');` line in the code is
  /// initializing the Gemini SDK with a specific API key.
  Gemini.init(apiKey: 'AIzaSyDXdAnT9HIadltwU8nJ8y37Ls1bqwKCNxc');

  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
