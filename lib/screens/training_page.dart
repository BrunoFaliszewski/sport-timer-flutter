import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../training_data/current_training_data.dart';
import 'home_page.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({ Key? key, required CurrentTrainingData currentTrainingData, required User user})
    : _currentTrainingData = currentTrainingData, _user = user,
      super(key: key);

  final CurrentTrainingData _currentTrainingData;
  final User _user;

  @override
  _TrainingPageState createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  late CurrentTrainingData _currentTrainingData;
  late User _user;
  Timer? timer;

  String exercise = "";
  String time = "";
  int i = 0;
  int j = 0;

  void updateTime() {
    if (i < _currentTrainingData.exercises.length) {
      setState(() {
        time = j.toString();
      });

      j--;

      if (j == 0) {
        if (i + 1 < _currentTrainingData.exercises.length) {
          i++;
          j = _currentTrainingData.exercises.values.elementAt(i);
        } else {
          time = "Finish";
          i++;
        }
      }
    }
  }

  @override
  void initState() {
    _currentTrainingData = widget._currentTrainingData;
    _user = widget._user;
    j = _currentTrainingData.exercises.values.elementAt(0);

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => updateTime());

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  Route _routeToHomePageScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomePage(user: _user),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(exercise),
            Text(time),
          ],
        ),
      )
    );
  }
}

// for (var i = 0; i < _currentTrainingData.exercises.length; i++) {
//       setState(() {
//         exercise = _currentTrainingData.exercises.keys.elementAt(i);
//       });

//       for (var j = _currentTrainingData.exercises.values.elementAt(i); j > 0; j--) {
//         await Future.delayed(const Duration(seconds: 1));

//         setState(() {
//           time = j.toString();
//         });
//       }
//     }