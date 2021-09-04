import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:sport_timer/training_data/exercises_list.dart';

import '../dialogs/add_dialog.dart';
import '../dialogs/save_dialog.dart';
import '../training_data/current_training_data.dart';
import '../training_data/training_data.dart';
import 'profile_page.dart';
import 'sets_page.dart';
import 'training_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required User user, CurrentTrainingData? currentTrainingData})
      : _user = user, _currentTrainingData = currentTrainingData,
        super(key: key);

  final User _user;
  final CurrentTrainingData? _currentTrainingData;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  int _numberOfSets = 0;
  int _workMinutes = 0;
  int _workSeconds = 0;
  int _restMinutes = 0;
  int _restSeconds = 0;
  String exerciseText = "";
  String setName = "";
  late User _user;

  int exerciseIndex = 0;
  List<Map<String, int>> exercises = [];

  CurrentTrainingData? _currentTrainingData = CurrentTrainingData();

  @override
  void initState() {
    _user = widget._user;

    if (widget._currentTrainingData != null) {
      setState(() {
        _currentTrainingData = widget._currentTrainingData;
        exercises.clear();
        for (var i = 0; i < _currentTrainingData!.exercises.length; i++) {
          final Map<String, int> _exercise = {_currentTrainingData!.exercises.keys.elementAt(i) : _currentTrainingData!.exercises.values.elementAt(i)};
          exercises.add(_exercise);
        }
      });
    }

    super.initState();
  }

  // ignore: use_setters_to_change_properties
  void onOrder(Map<String, int> exercises) {
    _currentTrainingData!.exercises = exercises;
  }

  void saveTimes(String setName) {
    this.setName = setName;
    final exercises = _currentTrainingData!.exercises;
    final set = TrainingData(this.setName, exercises);

    _database.child(_user.uid).child("sets").child(setName).set(set.toJson());
  }

  void addTimes(String exerciseText) {
    this.exerciseText = exerciseText;

    if (_numberOfSets > 0 && _workMinutes * 60 + _workSeconds > 0 || _restMinutes * 60 + _restSeconds > 0) {
      if (_currentTrainingData!.exercises.isEmpty == true) {
        exerciseIndex = 0;
      }
      for (var i = 0; i < _numberOfSets; i++) {
        if (_workMinutes * 60 + _workSeconds > 0) {
          if (this.exerciseText == "") {
            _currentTrainingData!.addExercise("${exerciseIndex.toString().padLeft(4, "0")}Work", _workMinutes * 60 + _workSeconds);
            final Map<String, int> _exercise = {"${exerciseIndex.toString().padLeft(4, "0")}Work" : _workMinutes * 60 + _workSeconds};
            setState(() {
              exercises.add(_exercise);
            });
            exerciseIndex++;
          } else {
            _currentTrainingData!.addExercise("${exerciseIndex.toString().padLeft(4, "0")}${this.exerciseText}", _workMinutes * 60 + _workSeconds);
            final Map<String, int> _exercise = {"${exerciseIndex.toString().padLeft(4, "0")}${this.exerciseText}" : _workMinutes * 60 + _workSeconds};
            setState(() {
              exercises.add(_exercise);
            });
            exerciseIndex++;
          }
        }

        if (_restMinutes * 60 + _restSeconds > 0) {
          _currentTrainingData!.addExercise("${exerciseIndex.toString().padLeft(4, "0")}Rest", _restMinutes * 60 + _restSeconds);
          final Map<String, int> _exercise = {"${exerciseIndex.toString().padLeft(4, "0")}Rest" : _restMinutes * 60 + _restSeconds};
          setState(() {
            exercises.add(_exercise);
          });
          exerciseIndex++;
        }
      }
    }
  }

  Route _routeToProfilePageScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(currentTrainingData: _currentTrainingData ,user: _user),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        final end = Offset.zero;
        final curve = Curves.ease;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      }
    );
  }

  Route _routeToTrainingPageScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => TrainingPage(currentTrainingData: _currentTrainingData, user: _user,),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        final end = Offset.zero;
        final curve = Curves.ease;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      }
    );
  }

  Route _routeToSetsPageScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SetsPage(currentTrainingData: _currentTrainingData ,user: _user),
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
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return SaveDialog(saveTimes);
                }
              );
            },
            icon: const Icon(Icons.save_outlined)
          ),
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
      drawer: Drawer(
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: const Text("Set Timer"),
                selected: true,
                onTap: () {

                }
              )
            ),
            Card(
              child: ListTile(
                title: const Text("My Sets"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacement(_routeToSetsPageScreen());
                }
              )
            )
          ]
        )
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
        child: FloatingActionButton(
          onPressed: () {
            if (_currentTrainingData!.exercises.isNotEmpty) {
              Navigator.of(context).pushReplacement(_routeToTrainingPageScreen());
            }
          },
          child: const Icon(Icons.play_arrow),
        )
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(
              height: 10,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  width: 350,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black45
                    ),
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Text(
                          "Sets",
                          style: TextStyle(fontSize: 25),
                        )
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
                        )
                      )
                    ]
                  )
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  width: 350,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black45
                    ),
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Text(
                          "Work",
                          style: TextStyle(fontSize: 25),
                        )
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
                                )
                              )
                            ]
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                            child: Text(
                              ":",
                              style: TextStyle(fontSize: 25),
                            )
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
                                maxValue: 59,
                                onChanged: (value) => setState(() => _workSeconds = value),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black26),
                                )
                              )
                            ]
                          )
                        ]
                      )
                    ]
                  )
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  width: 350,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black45
                    ),
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Text(
                          "Rest",
                          style: TextStyle(fontSize: 25),
                        )
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
                                )
                              )
                            ]
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                            child: Text(
                              ":",
                              style: TextStyle(fontSize: 25),
                            )
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
                                maxValue: 59,
                                onChanged: (value) => setState(() => _restSeconds = value),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black26),
                                )
                              )
                            ]
                          )
                        ]
                      )
                    ]
                  )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 60,
                      padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                      child: OutlinedButton(
                        onPressed: () {
                          _currentTrainingData!.reset();
                          setState(() {
                            exercises.clear();
                          });
                        },
                        child: const Text(
                          "Reset",
                          style: TextStyle(
                            fontSize: 20
                          )
                        )
                      )
                    ),
                    Container(
                      width: 150,
                      height: 60,
                      padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                      child: OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AddDialog(addTimes);
                            }
                          );
                        },
                        child: const Text(
                          "Add",
                          style: TextStyle(
                            fontSize: 20
                          )
                        )
                      ),
                    )
                  ]
                ),
                ExercisesList(exercises, onOrder)
              ]
            )
          ]
        )
      )
    );
  }
}
