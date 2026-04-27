import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player_app/app.dart';
import 'package:music_player_app/core/di/injection.dart';
import 'package:music_player_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,);

    // On web, Firestore persistence is managed via IndexedDB automatically;
    // applying Settings with persistenceEnabled on web can throw on some SDK
    // versions, so guard it.
    if (!kIsWeb) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }

    if (!kDebugMode) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    await Hive.initFlutter();
    await Hive.openBox<String>('queue_snapshot');

    await configureDependencies();
  } catch (e, stack) {
    // Show the error inside Flutter so it's visible in the browser.
    runApp(_ErrorApp(message: e.toString(), stack: stack.toString()));
    return;
  }

  runApp(const MusicPlayerApp());
}

class _ErrorApp extends StatelessWidget {
  const _ErrorApp({required this.message, required this.stack});
  final String message;
  final String stack;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[50],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Startup error',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,),),
              const SizedBox(height: 12),
              SelectableText(message,
                  style: const TextStyle(fontFamily: 'monospace'),),
              const SizedBox(height: 12),
              SelectableText(stack,
                  style: const TextStyle(
                      fontFamily: 'monospace', fontSize: 11,),),
            ],
          ),
        ),
      ),
    );
  }
}
