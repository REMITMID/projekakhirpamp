import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:projekakhirpamp/features/dashboard/presentation/pages/main_navigation_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/reservation/presentation/providers/reservation_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/member/presentation/providers/member_provider.dart';
import 'features/category_rack/presentation/providers/category_rack_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => CategoryRackProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return MaterialApp(
      title: 'PerpusKu - Reservasi Buku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: authProvider.currentUser == null
          ? const LoginPage()
          : const MainNavigationPage(),
    );
  }
}
