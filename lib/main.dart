import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hirfy/firebase_options.dart';
import 'package:hirfy/services/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wpnbutywzgfjhkhzjhho.supabase.co',
    publishableKey: 'sb_publishable_064lYOkcs59TdleB4u9crA_cCM_vAkz',
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
await GoogleSignIn.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      home: AuthGate()
    );
  }
}