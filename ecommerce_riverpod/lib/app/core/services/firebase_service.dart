import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../../firebase_options.dart';

class FirebaseService {
  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('[FirebaseService] Error initializing Firebase: $e');
    }
  }
}
