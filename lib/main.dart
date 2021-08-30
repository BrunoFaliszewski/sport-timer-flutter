import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'themes.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      themeCollection: ThemeCollection(
        themes: {
          Themes.blue: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: const TextTheme(
              bodyText2: TextStyle(color: Colors.black87)
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(
                color: Colors.black87
              ),
              textTheme: TextTheme(
                headline6: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w500
                )
              )
            )
          ),
          Themes.red: ThemeData(
            primarySwatch: Colors.red,
            textTheme: const TextTheme(
              bodyText2: TextStyle(color: Colors.black87)
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(
                color: Colors.black87
              ),
              textTheme: TextTheme(
                headline6: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w500
                )
              )
            )
          ),
          Themes.green: ThemeData(
            primarySwatch: Colors.green,
            textTheme: const TextTheme(
              bodyText2: TextStyle(color: Colors.black87)
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(
                color: Colors.black87
              ),
              textTheme: TextTheme(
                headline6: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w500
                )
              )
            )
          ),
          Themes.yellow: ThemeData(
            primarySwatch: Colors.yellow,
            textTheme: const TextTheme(
              bodyText2: TextStyle(color: Colors.black87)
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(
                color: Colors.black87
              ),
              textTheme: TextTheme(
                headline6: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w500
                )
              )
            )
          ),
          Themes.pink: ThemeData(
            primarySwatch: Colors.pink,
            textTheme: const TextTheme(
              bodyText2: TextStyle(color: Colors.black87)
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(
                color: Colors.black87
              ),
              textTheme: TextTheme(
                headline6: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w500
                )
              )
            )
          ),
          Themes.purple: ThemeData(
            primarySwatch: Colors.purple,
            textTheme: const TextTheme(
              bodyText2: TextStyle(color: Colors.black87)
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(
                color: Colors.black87
              ),
              textTheme: TextTheme(
                headline6: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w500
                )
              )
            )
          )
        }
      ),
      builder: (context, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sport Timer',
          home: const LoginPage(),
          theme: theme
        );
      }
    );
  }
}
