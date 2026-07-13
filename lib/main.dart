import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:molen_king_application/providers/auth_provider.dart';
import 'package:molen_king_application/repositories/auth_repository.dart';
import 'package:molen_king_application/services/auth_service.dart';
import 'package:molen_king_application/services/profile_service.dart';
import 'package:molen_king_application/providers/stock_provider.dart';
import 'package:molen_king_application/repositories/stock_repository.dart';
import 'package:molen_king_application/services/stock_service.dart';
import 'package:molen_king_application/providers/attendance_provider.dart';
import 'package:molen_king_application/repositories/attendance_repository.dart';
import 'package:molen_king_application/services/attendance_service.dart';
import 'package:molen_king_application/providers/expense_provider.dart';
import 'package:molen_king_application/repositories/expense_repository.dart';
import 'package:molen_king_application/services/expense_service.dart';
import 'package:molen_king_application/providers/report_provider.dart';
import 'package:molen_king_application/repositories/report_repository.dart';
import 'package:molen_king_application/services/report_service.dart';
import 'services/supabase_config.dart';
import 'views/auth/login_view.dart';
import 'views/shared/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase jika kredensial telah dikonfigurasi
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      debugPrint("Berhasil menginisialisasi Supabase Client.");
    } catch (e) {
      debugPrint(
        "Gagal menginisialisasi Supabase: $e. Aplikasi akan berjalan di Mode Simulasi.",
      );
    }
  } else {
    debugPrint(
      "Kredensial Supabase kosong. Aplikasi berjalan dalam Mode Simulasi Hibrida.",
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            repository: AuthRepository(
              authService: AuthService(),
              profileService: ProfileService(),
            ),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => StockProvider(
            repository: StockRepository(service: StockService()),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(
            repository: AttendanceRepository(service: AttendanceService()),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(
            repository: ExpenseRepository(service: ExpenseService()),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => ReportProvider(
            repository: ReportRepository(service: ReportService()),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Molen King',
      debugShowCheckedModeBanner: false,
      // Mengonfigurasi tema global berbasis Premium Artisan
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.royalHoneyGold,
          primary: AppColors.royalHoneyGold,
          secondary: AppColors.goldenCaramel,
          background: AppColors.ivoryCream,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Menggunakan font bawaan Flutter yang bersih
        appBarTheme: const AppBarTheme(
          color: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: AppColors.royalHoneyGold,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
      home: const LoginView(),
    );
  }
}
