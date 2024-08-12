import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hivefinal/pages/multi_step_form.dart';
import 'home/welcome_page.dart';
import 'login/login_page.dart';
import 'models/hive_models/document.dart';
import 'models/hive_models/user.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(DocumentAdapter());

  // Open boxes
  await Hive.openBox<User>('userBox');
  await Hive.openBox<Document>('documentBox');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Multi-Step Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MultiStepForm(),
        '/welcome': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),

      },
    );
  }
}
