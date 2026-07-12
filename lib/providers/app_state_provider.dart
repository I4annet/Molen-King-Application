// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../models/user_model.dart';
// import '../models/stock_model.dart';
// import '../models/transaction_model.dart';
// import '../models/expense_model.dart';
// import '../models/attendance_model.dart';
// import '../services/supabase_config.dart';

// class AppStateProvider extends ChangeNotifier {
//   bool _isInitializing = false;
//   bool _isSimulationMode = false;
//   bool _isLogginIn = false;
//   bool _isRegistering = false;
//   String? _errorMessage;

//   UserModel? _currentUser;
//   List<UserModel> _users = [];
//   List<TransactionModel> _transactions = [];
//   List<ExpenseModel> _expenses = [];
//   List<AttendanceModel> _attendanceLogs = [];

//   // Getters
//   bool get isInitializing => _isInitializing;
//   bool get isLogginIn => _isLogginIn;
//   bool get isRegistering => _isRegistering;
//   bool get isSimulationMode => _isSimulationMode;
//   String? get errorMessage => _errorMessage;
//   UserModel? get currentUser => _currentUser;
//   List<UserModel> get users => _users;
//   List<TransactionModel> get transactions => _transactions;
//   List<ExpenseModel> get expenses => _expenses;
//   List<AttendanceModel> get attendanceLogs => _attendanceLogs;

//   // Prices
//   final Map<String, double> molenPrices = {
//     'keju': 1000.0,
//     'ori': 1000.0,
//     'coklat': 1000.0,
//   };

//   AppStateProvider() {
//     _initialize();
//   }

//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }

//   Future<void> _initialize() async {
//     _setInitializing(true);
//     try {
//       await _loadFromSupabase();
//       _isSimulationMode = false;
//     } catch (e, st) {
//       debugPrint("Supabase initialization failed: $e");
//       debugPrintStack(stackTrace: st);

//       // Fallback to local storage simulation
//       try {
//         _isSimulationMode = true;
//         await _loadFromLocalStorage();
//       } catch (localE) {
//         debugPrint("Local storage fallback failed: $localE");
//         _isSimulationMode = false;
//       }
//     }
//     _setInitializing(false);
//   }

//   void _setInitializing(bool value) {
//     _isInitializing = value;
//     notifyListeners();
//   }

//   // --- LOCAL STORAGE SIMULATION ---
//   Future<void> _loadFromLocalStorage() async {
//     final prefs = await SharedPreferences.getInstance();

//     // Load users
//     final usersStr = prefs.getString('sim_users');
//     if (usersStr != null) {
//       final List<dynamic> decoded = jsonDecode(usersStr);
//       _users = decoded
//           .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } else {
//       // Default Admin and Cashier accounts for testing
//       _users = [
//         UserModel(
//           id: 'admin-id',
//           name: 'Paman Owner',
//           email: 'admin@molenking.com',
//           phone: '08123456789',
//           origin: 'Yogyakarta',
//           role: 'admin',
//         ),
//         UserModel(
//           id: 'cashier-id',
//           name: 'Budi Kasir',
//           email: 'kasir@molenking.com',
//           phone: '08987654321',
//           origin: 'Solo',
//           role: 'cashier',
//         ),
//       ];
//       await _saveUsersToLocal();
//     }

//     // Load currentUser if logged in
//     final currentUserStr = prefs.getString('sim_current_user');
//     if (currentUserStr != null) {
//       _currentUser = UserModel.fromJson(jsonDecode(currentUserStr));
//     }

//     // Load transactions
//     final txsStr = prefs.getString('sim_transactions');
//     if (txsStr != null) {
//       final List<dynamic> decoded = jsonDecode(txsStr);
//       _transactions = decoded.map((e) {
//         final map = e as Map<String, dynamic>;
//         final items = map['items'] as List<dynamic>?;
//         return TransactionModel.fromJson(map, items);
//       }).toList();
//     }

//     // Load expenses
//     final expStr = prefs.getString('sim_expenses');
//     if (expStr != null) {
//       final List<dynamic> decoded = jsonDecode(expStr);
//       _expenses = decoded
//           .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
//           .toList();
//     }

//     // Load attendance logs
//     final attStr = prefs.getString('sim_attendance');
//     if (attStr != null) {
//       final List<dynamic> decoded = jsonDecode(attStr);
//       _attendanceLogs = decoded
//           .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
//           .toList();
//     }
//     notifyListeners();
//   }

//   Future<void> _saveUsersToLocal() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = _users.map((e) => e.toJson()).toList();
//     await prefs.setString('sim_users', jsonEncode(data));
//   }

//   Future<void> _saveCurrentUserToLocal() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (_currentUser != null) {
//       await prefs.setString(
//         'sim_current_user',
//         jsonEncode(_currentUser!.toJson()),
//       );
//     } else {
//       await prefs.remove('sim_current_user');
//     }
//   }

//   Future<void> _saveTransactionsToLocal() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = _transactions.map((t) {
//       final json = t.toJson();
//       json['items'] = t.items.map((i) => i.toJson()).toList();
//       return json;
//     }).toList();
//     await prefs.setString('sim_transactions', jsonEncode(data));
//   }

//   Future<void> _saveExpensesToLocal() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = _expenses.map((e) => e.toJson()).toList();
//     await prefs.setString('sim_expenses', jsonEncode(data));
//   }

//   Future<void> _saveAttendanceToLocal() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = _attendanceLogs.map((e) => e.toJson()).toList();
//     await prefs.setString('sim_attendance', jsonEncode(data));
//   }

//   // --- SUPABASE DATA RETRIEVAL ---
//   Future<void> _loadFromSupabase() async {
//     final supabase = Supabase.instance.client;

//     // Check if auth session exists
//     final session = supabase.auth.currentSession;
//     if (session != null) {
//       final profileRes = await supabase
//           .from('profiles')
//           .select()
//           .eq('id', session.user.id)
//           .maybeSingle();
//       if (profileRes != null) {
//         _currentUser = UserModel.fromJson(profileRes);
//       }
//     }

//     // Load transactions and their items
//     final txsRes = await supabase
//         .from('transactions')
//         .select('*, transaction_items(*)')
//         .order('created_at', ascending: false);
//     _transactions = txsRes.map<TransactionModel>((tx) {
//       final items = tx['transaction_items'] as List<dynamic>?;
//       return TransactionModel.fromJson(tx, items);
//     }).toList();

//     // Load expenses
//     final expRes = await supabase
//         .from('expenses')
//         .select()
//         .order('created_at', ascending: false);
//     _expenses = expRes
//         .map<ExpenseModel>((e) => ExpenseModel.fromJson(e))
//         .toList();

//     // Load attendance logs
//     final attRes = await supabase
//         .from('attendance_logs')
//         .select()
//         .order('check_in_time', ascending: false);
//     _attendanceLogs = attRes
//         .map<AttendanceModel>((e) => AttendanceModel.fromJson(e))
//         .toList();

//     // Load profiles (for admin)
//     final profilesRes = await supabase.from('profiles').select();
//     _users = profilesRes.map<UserModel>((e) => UserModel.fromJson(e)).toList();

//     notifyListeners();
//   }

//   // --- AUTH OPERATIONS ---
//   Future<bool> register({
//     required String email,
//     required String password,
//     required String name,
//     required String phone,
//     required String origin,
//     required String role,
//   }) async {
//     _isRegistering = true;
//     notifyListeners();
//     _errorMessage = null;
//     try {
//       if (_isSimulationMode) {
//         // Simulasi Registrasi
//         final isExist = _users.any(
//           (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
//         );
//         if (isExist) {
//           throw 'Email sudah terdaftar.';
//         }
//         final newUser = UserModel(
//           id: 'user-${DateTime.now().millisecondsSinceEpoch}',
//           name: name,
//           email: email,
//           phone: phone,
//           origin: origin,
//           role: role,
//         );
//         _users.add(newUser);
//         await _saveUsersToLocal();
//         _currentUser = newUser;
//         await _saveCurrentUserToLocal();
//         _setInitializing(false);
//         return true;
//       } else {
//         // Supabase Registrasi
//         final supabase = Supabase.instance.client;
//         final AuthResponse res = await supabase.auth.signUp(
//           email: email,
//           password: password,
//         );

//         if (res.user == null) throw 'Registrasi gagal.';

//         // Buat profile di database
//         final newUser = UserModel(
//           id: res.user!.id,
//           name: name,
//           email: email,
//           phone: phone,
//           origin: origin,
//           role: role,
//         );

//         await supabase.from('profiles').insert(newUser.toJson());

//         _currentUser = newUser;
//         _users.add(newUser);
//         _setInitializing(false);
//         return true;
//       }
//     } catch (e) {
//       _errorMessage = e.toString().replaceAll('Exception: ', '');
//       _setInitializing(false);
//       return false;
//     }
//   }

//   Future<bool> login(String email, String password) async {
//     _isLogginIn = true;
//     notifyListeners();
//     _errorMessage = null;
//     try {
//       if (_isSimulationMode) {
//         // Simulasi Login
//         final user = _users.firstWhere(
//           (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
//           orElse: () => throw 'Email atau password salah.',
//         );
//         // Dalam simulasi, kita izinkan login langsung
//         _currentUser = user;
//         await _saveCurrentUserToLocal();
//         _isLogginIn = false;
//         notifyListeners();
//         return true;
//       } else {
//         // Supabase Login
//         final supabase = Supabase.instance.client;
//         final AuthResponse res = await supabase.auth.signInWithPassword(
//           email: email,
//           password: password,
//         );

//         if (res.user == null) throw 'Login gagal.';

//         // Load profile
//         final profileRes = await supabase
//             .from('profiles')
//             .select()
//             .eq('id', res.user!.id)
//             .maybeSingle();

//         if (profileRes == null) {
//           throw 'Profil pengguna tidak ditemukan.';
//         }

//         _currentUser = UserModel.fromJson(profileRes);
//         await _loadFromSupabase();
//         _isLogginIn = false;
//         notifyListeners();
//         return true;
//       }
//     } catch (e) {
//       _errorMessage = e.toString().replaceAll('Exception: ', '');
//       _isLogginIn = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<void> logout() async {
//     _setInitializing(true);
//     try {
//       if (!_isSimulationMode) {
//         await Supabase.instance.client.auth.signOut();
//       }
//       _currentUser = null;
//       if (_isSimulationMode) {
//         await _saveCurrentUserToLocal();
//       }
//     } catch (e) {
//       debugPrint("Gagal logout: $e");
//     }
//     _setInitializing(false);
//   }

//   // --- ATTENDANCE SYSTEM ---
//   Future<bool> checkIn(String status, String? reason) async {
//     if (_currentUser == null) return false;
//     _setInitializing(true);
//     try {
//       final now = DateTime.now();
//       final logId = 'att-${now.millisecondsSinceEpoch}';

//       final log = AttendanceModel(
//         id: _isSimulationMode ? logId : '',
//         userId: _currentUser!.id,
//         userName: _currentUser!.name,
//         date: now,
//         checkInTime: now,
//         status: status,
//         reason: reason,
//       );

//       _currentUser = _currentUser!.copyWith(
//         isActive: status == 'present',
//         lastCheckIn: now,
//         lastCheckOut: null,
//       );

//       if (_isSimulationMode) {
//         _attendanceLogs.insert(0, log);
//         // update user list status
//         final idx = _users.indexWhere((u) => u.id == _currentUser!.id);
//         if (idx != -1) _users[idx] = _currentUser!;

//         await _saveCurrentUserToLocal();
//         await _saveUsersToLocal();
//         await _saveAttendanceToLocal();
//       } else {
//         final supabase = Supabase.instance.client;

//         // Simpan log absensi
//         final logJson = log.toJson();
//         logJson.remove('id'); // Biar generate di db
//         await supabase.from('attendance_logs').insert(logJson);

//         // Update profile
//         await supabase
//             .from('profiles')
//             .update({
//               'is_active': status == 'present',
//               'last_check_in': now.toIso8601String(),
//               'last_check_out': null,
//             })
//             .eq('id', _currentUser!.id);

//         await _loadFromSupabase();
//       }
//       _setInitializing(false);
//       return true;
//     } catch (e) {
//       _errorMessage = e.toString();
//       _setInitializing(false);
//       return false;
//     }
//   }

//   Future<bool> checkOut() async {
//     if (_currentUser == null) return false;
//     _setInitializing(true);
//     try {
//       final now = DateTime.now();

//       _currentUser = _currentUser!.copyWith(isActive: false, lastCheckOut: now);

//       if (_isSimulationMode) {
//         // Update log terakhir yang belum checkout
//         final todayStr =
//             "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
//         final logIdx = _attendanceLogs.indexWhere(
//           (l) => l.userId == _currentUser!.id && l.checkOutTime == null,
//         );
//         if (logIdx != -1) {
//           final old = _attendanceLogs[logIdx];
//           _attendanceLogs[logIdx] = AttendanceModel(
//             id: old.id,
//             userId: old.userId,
//             userName: old.userName,
//             date: old.date,
//             checkInTime: old.checkInTime,
//             checkOutTime: now,
//             status: old.status,
//             reason: old.reason,
//           );
//         }

//         final idx = _users.indexWhere((u) => u.id == _currentUser!.id);
//         if (idx != -1) _users[idx] = _currentUser!;

//         await _saveCurrentUserToLocal();
//         await _saveUsersToLocal();
//         await _saveAttendanceToLocal();
//       } else {
//         final supabase = Supabase.instance.client;

//         // Cari log absensi hari ini yang check_out_time masih null
//         final lastLogRes = await supabase
//             .from('attendance_logs')
//             .select()
//             .eq('user_id', _currentUser!.id)
//             .isFilter('check_out_time', null)
//             .order('check_in_time', ascending: false)
//             .limit(1)
//             .maybeSingle();

//         if (lastLogRes != null) {
//           final logId = lastLogRes['id'] as String;
//           await supabase
//               .from('attendance_logs')
//               .update({'check_out_time': now.toIso8601String()})
//               .eq('id', logId);
//         }

//         // Update profile
//         await supabase
//             .from('profiles')
//             .update({
//               'is_active': false,
//               'last_check_out': now.toIso8601String(),
//             })
//             .eq('id', _currentUser!.id);

//         await _loadFromSupabase();
//       }
//       _setInitializing(false);
//       return true;
//     } catch (e) {
//       _errorMessage = e.toString();
//       _setInitializing(false);
//       return false;
//     }
//   }

//   // --- TRANSACTIONS ---
//   Future<bool> createTransaction(List<TransactionItem> items) async {
//     if (_currentUser == null) return false;
//     _setInitializing(true);
//     try {
//       // 1. Kurangi Stok terlebih dahulu (verifikasi stok cukup)
//       for (var item in items) {
//         final currentQty = _stocks[item.flavor] ?? 0;
//         if (currentQty < item.quantity) {
//           throw 'Stok rasa ${item.flavor.toUpperCase()} tidak mencukupi! Tersedia: $currentQty.';
//         }
//       }

//       final total = items.fold<double>(
//         0,
//         (sum, item) => sum + (item.price * item.quantity),
//       );
//       final now = DateTime.now();
//       final txId = 'tx-${now.millisecondsSinceEpoch}';

//       final tx = TransactionModel(
//         id: _isSimulationMode ? txId : '',
//         cashierId: _currentUser!.id,
//         cashierName: _currentUser!.name,
//         totalAmount: total,
//         createdAt: now,
//         items: items,
//       );

//       // Kurangi stok di memory
//       for (var item in items) {
//         _stocks[item.flavor] = (_stocks[item.flavor] ?? 0) - item.quantity;
//       }

//       if (_isSimulationMode) {
//         _transactions.insert(0, tx);
//         await _saveStocksToLocal();
//         await _saveTransactionsToLocal();
//       } else {
//         final supabase = Supabase.instance.client;

//         // Simpan Transaksi utama
//         final txRes = await supabase
//             .from('transactions')
//             .insert({
//               'cashier_id': _currentUser!.id,
//               'cashier_name': _currentUser!.name,
//               'total_amount': total,
//             })
//             .select()
//             .single();

//         final newTxId = txRes['id'] as String;

//         // Simpan Detail Item
//         for (var item in items) {
//           await supabase.from('transaction_items').insert({
//             'transaction_id': newTxId,
//             'flavor': item.flavor,
//             'quantity': item.quantity,
//             'price': item.price,
//           });

//           // Update Stok di DB
//           await supabase
//               .from('stocks')
//               .update({
//                 'quantity': _stocks[item.flavor] ?? 0,
//                 'last_updated': now.toIso8601String(),
//               })
//               .eq('flavor', item.flavor);
//         }

//         await _loadFromSupabase();
//       }

//       _setInitializing(false);
//       return true;
//     } catch (e) {
//       _errorMessage = e.toString().replaceAll('Exception: ', '');
//       _setInitializing(false);
//       return false;
//     }
//   }

//   // --- EXPENSES ---
//   Future<bool> addExpense(double amount, String description) async {
//     if (_currentUser == null) return false;
//     _setInitializing(true);
//     try {
//       final now = DateTime.now();
//       final expId = 'exp-${now.millisecondsSinceEpoch}';

//       final exp = ExpenseModel(
//         id: _isSimulationMode ? expId : '',
//         cashierId: _currentUser!.id,
//         cashierName: _currentUser!.name,
//         amount: amount,
//         description: description,
//         createdAt: now,
//       );

//       if (_isSimulationMode) {
//         _expenses.insert(0, exp);
//         await _saveExpensesToLocal();
//       } else {
//         final supabase = Supabase.instance.client;
//         await supabase.from('expenses').insert({
//           'cashier_id': _currentUser!.id,
//           'cashier_name': _currentUser!.name,
//           'amount': amount,
//           'description': description,
//         });
//         await _loadFromSupabase();
//       }

//       _setInitializing(false);
//       return true;
//     } catch (e) {
//       _errorMessage = e.toString();
//       _setInitializing(false);
//       return false;
//     }
//   }

//   // --- METRIC GETTERS FOR DASHBOARDS & REPORTS ---
//   int getMolenSoldQuantity(String flavor) {
//     int total = 0;
//     for (var tx in _transactions) {
//       for (var item in tx.items) {
//         if (item.flavor == flavor) {
//           total += item.quantity;
//         }
//       }
//     }
//     return total;
//   }

//   int getTotalMolenSold() {
//     int total = 0;
//     for (var tx in _transactions) {
//       for (var item in tx.items) {
//         total += item.quantity;
//       }
//     }
//     return total;
//   }

//   // Filter transactions by date range
//   List<TransactionModel> _getTransactionsInPeriod(
//     DateTime start,
//     DateTime end,
//   ) {
//     return _transactions.where((tx) {
//       return tx.createdAt.isAfter(start) && tx.createdAt.isBefore(end);
//     }).toList();
//   }

//   List<ExpenseModel> _getExpensesInPeriod(DateTime start, DateTime end) {
//     return _expenses.where((ex) {
//       return ex.createdAt.isAfter(start) && ex.createdAt.isBefore(end);
//     }).toList();
//   }

//   // Dashboard Stats
//   Map<String, double> getStatsForPeriod(String period) {
//     final now = DateTime.now();
//     DateTime start;

//     switch (period) {
//       case 'daily':
//         start = DateTime(now.year, now.month, now.day);
//         break;
//       case 'weekly':
//         start = now.subtract(Duration(days: now.weekday - 1));
//         start = DateTime(start.year, start.month, start.day);
//         break;
//       case 'monthly':
//         start = DateTime(now.year, now.month, 1);
//         break;
//       case 'yearly':
//         start = DateTime(now.year, 1, 1);
//         break;
//       default:
//         start = DateTime(now.year, now.month, now.day);
//     }

//     final end = now.add(const Duration(seconds: 1));
//     final txs = _getTransactionsInPeriod(start, end);
//     final exps = _getExpensesInPeriod(start, end);

//     double sales = txs.fold<double>(0, (sum, tx) => sum + tx.totalAmount);
//     double expensesTotal = exps.fold<double>(0, (sum, ex) => sum + ex.amount);
//     int itemsCount = 0;

//     for (var tx in txs) {
//       for (var item in tx.items) {
//         itemsCount += item.quantity;
//       }
//     }

//     return {
//       'revenue': sales,
//       'expenses': expensesTotal,
//       'profit': sales - expensesTotal,
//       'qty_sold': itemsCount.toDouble(),
//     };
//   }

//   // Chart data points helper
//   List<MapEntry<String, double>> getChartDataForPeriod(String period) {
//     final now = DateTime.now();
//     final List<MapEntry<String, double>> data = [];

//     if (period == 'daily') {
//       // 24 jam terakhir (kelompokkan per 2 jam atau jam tertentu)
//       for (int i = 6; i >= 0; i--) {
//         final time = now.subtract(Duration(hours: i * 2));
//         final start = time.subtract(const Duration(hours: 2));
//         final txs = _getTransactionsInPeriod(start, time);
//         final revenue = txs.fold<double>(0, (sum, tx) => sum + tx.totalAmount);
//         final label = "${time.hour.toString().padLeft(2, '0')}:00";
//         data.add(MapEntry(label, revenue));
//       }
//     } else if (period == 'weekly') {
//       // 7 hari terakhir (Senin - Minggu)
//       final List<String> days = [
//         'Sen',
//         'Sel',
//         'Rab',
//         'Kam',
//         'Jum',
//         'Sab',
//         'Min',
//       ];
//       final weekday = now.weekday; // 1 = Senin, 7 = Minggu
//       for (int i = 1; i <= 7; i++) {
//         final targetDate = now.subtract(Duration(days: weekday - i));
//         final start = DateTime(
//           targetDate.year,
//           targetDate.month,
//           targetDate.day,
//         );
//         final end = start.add(const Duration(days: 1));
//         final txs = _getTransactionsInPeriod(start, end);
//         final revenue = txs.fold<double>(0, (sum, tx) => sum + tx.totalAmount);
//         data.add(MapEntry(days[i - 1], revenue));
//       }
//     } else if (period == 'monthly') {
//       // 4 minggu terakhir
//       for (int i = 3; i >= 0; i--) {
//         final start = now.subtract(Duration(days: (i + 1) * 7));
//         final end = now.subtract(Duration(days: i * 7));
//         final txs = _getTransactionsInPeriod(start, end);
//         final revenue = txs.fold<double>(0, (sum, tx) => sum + tx.totalAmount);
//         data.add(MapEntry("Wk ${4 - i}", revenue));
//       }
//     } else if (period == 'yearly') {
//       // 12 bulan terakhir
//       final List<String> months = [
//         'Jan',
//         'Feb',
//         'Mar',
//         'Apr',
//         'Mei',
//         'Jun',
//         'Jul',
//         'Agu',
//         'Sep',
//         'Okt',
//         'Nov',
//         'Des',
//       ];
//       for (int i = 0; i < 12; i++) {
//         final monthIndex = (now.month - 11 + i) % 12;
//         final yearOffset = (now.month - 11 + i) <= 0 ? -1 : 0;
//         final targetYear = now.year + yearOffset;
//         final start = DateTime(targetYear, monthIndex + 1, 1);
//         final end = DateTime(
//           targetYear,
//           monthIndex + 2,
//           1,
//         ).subtract(const Duration(seconds: 1));

//         final txs = _getTransactionsInPeriod(start, end);
//         final revenue = txs.fold<double>(0, (sum, tx) => sum + tx.totalAmount);
//         data.add(MapEntry(months[monthIndex], revenue));
//       }
//     }

//     return data;
//   }
// }
