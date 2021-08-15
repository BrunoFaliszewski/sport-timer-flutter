import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import '../dialogs/add_dialog.dart';
import '../dialogs/save_dialog.dart';
import '../training_data/current_training_data.dart';
import '../training_data/training_data.dart';
import 'profile_page.dart';
import 'training_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _setsReference = FirebaseDatabase.instance.reference().child("sets");

  int _numberOfSets = 0;
  int _workMinutes = 0;
  int _workSeconds = 0;
  int _restMinutes = 0;
  int _restSeconds = 0;
  String exerciseText = "";
  String setName = "";
  late User _user;

  int exerciseIndex = 0;

  List sets = [];

  CurrentTrainingData currentTrainingData = CurrentTrainingData();

  @override
  void initState() {
    _user = widget._user;

    super.initState();
  }

  void addClicked() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AddDialog(addTimes);
      },
    );
  }

  void saveClicked() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SaveDialog(saveTimes);
      }
    );
  }
  

  void saveTimes(String setName) {
    this.setName = setName;
    final exercises = currentTrainingData.exercises;
    final set = Set(this.setName, exercises);

    _setsReference.child(this.setName).set(set.toJson());

    setState(() {
      sets.add(set);
      // ignore: avoid_print
      print(sets);
    });
  }

  void addTimes(String exerciseText) {
    this.exerciseText = exerciseText;

    if (_numberOfSets > 0 && _workMinutes * 60 + _workSeconds > 0 || _restMinutes * 60 + _restSeconds > 0) {
      if (currentTrainingData.exercises.isEmpty == true) {
        exerciseIndex = 0;
      }
      for (var i = 0; i < _numberOfSets; i++) {
        if (_workMinutes * 60 + _workSeconds > 0) {
          if (this.exerciseText == "") {
            currentTrainingData.addExercise("${exerciseIndex}Work", _workMinutes * 60 + _workSeconds);
            exerciseIndex++;
          } else {
            currentTrainingData.addExercise("$exerciseIndex${this.exerciseText}", _workMinutes * 60 + _workSeconds);
            exerciseIndex++;
          }
        }

        if (_restMinutes * 60 + _restSeconds > 0) {
          currentTrainingData.addExercise("${exerciseIndex}Rest", _restMinutes * 60 + _restSeconds);
          exerciseIndex++;
        }
      }
      // ignore: avoid_print
      print(currentTrainingData.exercises);
    }
  }

  Route _routeToProfilePageScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(user: _user),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
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

  Route _routeToTrainingPageScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => TrainingPage(currentTrainingData: currentTrainingData, user: _user,),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
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
        actions: [
          if (_user.photoURL != null) IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(_routeToProfilePageScreen());
            },
            icon: ClipOval(
              child: Image.network(_user.photoURL!),
            )
          ) else IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(_routeToProfilePageScreen());
            },
            icon: const Icon(Icons.person)
          )
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ListView(
          children: [
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Text(
                    "Sets",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                NumberPicker(
                  value: _numberOfSets,
                  minValue: 0,
                  maxValue: 100,
                  axis: Axis.horizontal,
                  onChanged: (value) => setState(() => _numberOfSets = value),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black26),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Text(
                    "Work",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text(
                          "Minutes",
                          style: TextStyle(fontSize: 12),
                        ),
                        NumberPicker(
                          value: _workMinutes,
                          minValue: 0,
                          maxValue: 100,
                          onChanged: (value) => setState(() => _workMinutes = value),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Text(
                        ":",
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    Column(
                      children: [
                        const Text(
                          "Seconds",
                          style: TextStyle(fontSize: 12),
                        ),
                        NumberPicker(
                          value: _workSeconds,
                          minValue: 0,
                          maxValue: 60,
                          onChanged: (value) => setState(() => _workSeconds = value),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Text(
                    "Rest",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text(
                          "Minutes",
                          style: TextStyle(fontSize: 12),
                        ),
                        NumberPicker(
                          value: _restMinutes,
                          minValue: 0,
                          maxValue: 100,
                          onChanged: (value) => setState(() => _restMinutes = value),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Text(
                        ":",
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    Column(
                      children: [
                        const Text(
                          "Seconds",
                          style: TextStyle(fontSize: 12),
                        ),
                        NumberPicker(
                          value: _restSeconds,
                          minValue: 0,
                          maxValue: 60,
                          onChanged: (value) => setState(() => _restSeconds = value),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: saveClicked,
                      child: const Text(
                        "Save"
                      ),
                    ),
                    OutlinedButton(
                      onPressed: currentTrainingData.reset,
                      child: const Text(
                        "Reset"
                      ),
                    ),
                    OutlinedButton(
                      onPressed: addClicked,
                      child: const Text(
                        "Add"
                      ),
                    ),
                  ],
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(_routeToTrainingPageScreen());
                  },
                  child: const Text(
                    "Start"
                  ),
                ),
              ],
            )
          ],
        )
      ),
    );
  }
}