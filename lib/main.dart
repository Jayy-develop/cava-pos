import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/pos/presentation/bloc/cart_bloc.dart';
import 'features/pos/presentation/bloc/menu_bloc.dart';
import 'features/history/bloc/order_history_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/pos/presentation/screens/cava_main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CavaPosApp());
}

class CavaPosApp extends StatefulWidget {
  const CavaPosApp({super.key});

  @override
  State<CavaPosApp> createState() => _CavaPosAppState();
}

class _CavaPosAppState extends State<CavaPosApp> {
  ThemeMode _themeMode = ThemeMode.light; // Default Cerah (Light Mode)

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(),
        ),
        BlocProvider<MenuBloc>(
          create: (_) => MenuBloc(),
        ),
        BlocProvider<CartBloc>(
          create: (_) => CartBloc(),
        ),
        BlocProvider<OrderHistoryBloc>(
          create: (_) => OrderHistoryBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Cava Cafe POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: CavaMainShell(
          currentThemeMode: _themeMode,
          onToggleTheme: _toggleTheme,
        ),
      ),
    );
  }
}
