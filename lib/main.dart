import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('darkMode') ?? false;
  runApp(MyApp(isDark: isDark));
}

class MyApp extends StatefulWidget {
  final bool isDark;
  const MyApp({super.key, required this.isDark});

  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late bool _isDark;
  bool get isDark => _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
    _updateSystemUI();
  }

  void toggleTheme() async {
    setState(() => _isDark = !_isDark);
    _updateSystemUI();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', _isDark);
  }

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      _isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Al-Quran Digital',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: const MainScreen(),
    );
  }
}
