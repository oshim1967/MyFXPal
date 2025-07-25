import 'package:flutter/material.dart';
import 'package:my_currency_exchanger/exchanger_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_currency_exchanger/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мой Валютчик',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExchangerScreen(),
    );
  }
}
