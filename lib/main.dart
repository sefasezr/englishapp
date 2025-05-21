import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurs/screens/auth/giris_yap.dart';
import 'package:kurs/screens/auth/register.dart';
import 'package:kurs/screens/auth/login.dart';
import 'package:kurs/screens/chat_screen.dart';
import 'package:kurs/services/import_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //await ImportService.importWordsFromJson();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sparky',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF87CEEB),
      ),
      // İlk açılış sayfası olarak login sayfasını ayarladık
      initialRoute: '/login',
      routes: {
        //'/': (context) => const MainMenu(),
        '/login': (context) => const Giris(),
        '/register': (context) => const KayitOl(),
        '/giris_yap': (context) => const GirisYap(),
        '/chat': (context) => ChatScreen(),
        //'/main_menu': (context) => const MainMenu(),
        //'/profile': (context) => const ProfilSayfasi(),
      },
    );
  }
}
