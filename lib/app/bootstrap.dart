import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:farm2fork_mobile/firebase_options.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase powers authentication (Google + email/password) and, later, FCM.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
