import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/request_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/ipo_provider.dart';
import 'providers/corporate_action_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/report_provider.dart';
import 'providers/portfolio_provider.dart';
import 'providers/reminder_provider.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BrokerAssistApp());
}

class BrokerAssistApp extends StatelessWidget {
  const BrokerAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => IpoProvider()),
        ChangeNotifierProvider(create: (_) => CorporateActionProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: MaterialApp(
        title: 'BrokerAssist',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const RootDecider(),
      ),
    );
  }
}

class RootDecider extends StatelessWidget {
  const RootDecider({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (!auth.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (auth.isLoggedIn) {
      return const HomeScreen();
    }
    return const LoginScreen();
  }
}
