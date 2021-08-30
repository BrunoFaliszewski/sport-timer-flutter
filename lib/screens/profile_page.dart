import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sport_timer/training_data/current_training_data.dart';

import '../dialogs/theme_dialog.dart';
import 'home_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required CurrentTrainingData? currentTrainingData, required User user})
      : _currentTrainingData = currentTrainingData, _user = user,
        super(key: key);

  final CurrentTrainingData? _currentTrainingData;
  final User _user;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _user;
  CurrentTrainingData? _currentTrainingData;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  late StreamSubscription _soundStream;

  bool isSound = true;
  late int theme;

  @override
  void initState() {
    _user = widget._user;
    _currentTrainingData = widget._currentTrainingData;

    _soundStream = _database.child(_user.uid).child("sound").onValue.listen((event) {
      if (event.snapshot.value != null) {
        if (event.snapshot.value == "true") {
          setState(() {
            isSound = true;
          });
        } else {
          setState(() {
            isSound = false;
          });
        }
      } else {
        _database.child(_user.uid).child("sound").set("true");
        setState(() {
          isSound = true;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _soundStream.cancel();
  }

  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        final end = Offset.zero;
        final curve = Curves.ease;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route _routeToHomePageScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomePage(currentTrainingData: _currentTrainingData ,user: _user),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
        final end = Offset.zero;
        final curve = Curves.ease;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sport Timer"),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(_routeToHomePageScreen());
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ListView(
          children: [
            Card(
              child: ListTile(
                trailing: Switch(
                  value: isSound,
                  onChanged: (value) {
                    _database.child(_user.uid).child("sound").set(value.toString());
                  }
                ),
                title: Text(
                  "Sound",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                )
              )
            ),
            Card(
              child: ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const ThemeDialog();
                    }
                  );
                },
                title: Text(
                  "Theme",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                )
              )
            ),
            Card(
              child: ListTile(
                onTap: () async {
                  await signOut();
                  Navigator.of(context).pushReplacement(_routeToSignInScreen());
                },
                title: Text(
                  "Sign Out",
                  style: TextStyle(color: Theme.of(context).primaryColor)
                )
              )
            )
          ]
        )
      )
    );
  }
}
