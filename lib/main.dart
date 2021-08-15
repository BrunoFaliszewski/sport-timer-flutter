import 'package:flutter/material.dart';
import 'screens/login_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sport Timer',
        home: const LoginPage(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      );
  }
}
