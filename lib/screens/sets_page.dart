import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sport_timer/training_data/current_training_data.dart';
import 'package:sport_timer/training_data/exercises_list.dart';

import '../training_data/sets_list.dart';
import '../training_data/training_data.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'training_page.dart';

class SetsPage extends StatefulWidget {
  const SetsPage({ Key? key, required CurrentTrainingData? currentTrainingData, required User user})
    : _currentTrainingData = currentTrainingData, _user = user,
      super(key: key);

  final CurrentTrainingData? _currentTrainingData;
  final User _user;

  @override
  _SetsPageState createState() => _SetsPageState();
}

class _SetsPageState extends State<SetsPage> {
  late User _user;
  CurrentTrainingData? _currentTrainingData;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  late StreamSubscription _setsStream;
  PanelController panelController = PanelController();

  List<TrainingData> sets = [];
  List<Map<String, int>> exercises = [];
  late int currentSet;
  bool isPanelOpened = false;

  @override
  void initState() {
    super.initState();
    _user = widget._user;
    _currentTrainingData = widget._currentTrainingData;

    _setsStream = _database.child(_user.uid).child("sets").onValue.listen((event) {
      if (event.snapshot.value != null) {
        sets.clear();
        event.snapshot.value.forEach((key, value) {
          final Map<String, int> exercises = {};
          value.forEach((key, value) {
            value.forEach((key, value) {
              if (value is int) {
                exercises[key.toString()] = value;
              }
            });
          });
          final List sortedExercisesList = exercises.keys.toList();
          sortedExercisesList.sort();
          final Map<String, int> sortedExercisesMap = {};
          for (var i = 0; i < sortedExercisesList.length; i++) {
            sortedExercisesMap[sortedExercisesList[i].toString()] = exercises[sortedExercisesList[i].toString()]!;
          }
          final TrainingData set = createTrainingData(key, sortedExercisesMap);
          setState(() {
            sets.add(set);
          });
        });
      } else {
        setState(() {
          sets = [];
        });
      }
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    
    sets.clear();

    _setsStream.cancel();
  }

  void onOrder (Map<String, int> exercises) {
    setState(() {
      sets[currentSet].exercises = exercises;
    });
    _database.child(_user.uid).child("sets").child(sets[currentSet].name).child("exercises").set(exercises);
  }

  void setExercises (TrainingData set) {
    set.exercises.forEach((key, value) {
      final Map<String, int> _exercise = {key : value};
      setState(() {
        exercises.add(_exercise);
      });
    });
    panelController.open();
    setState(() {
      isPanelOpened = true;
    });
  }

  // ignore: use_setters_to_change_properties
  void setCurrentSet (int _currentSet) {
    currentSet = _currentSet;
  }

  Route _routeToHomePageScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomePage(currentTrainingData: _currentTrainingData ,user: _user),
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
      pageBuilder: (context, animation, secondaryAnimation) => TrainingPage(currentTrainingData: _currentTrainingData, user: _user),
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
        ]
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: const Text("Set Timer"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacement(_routeToHomePageScreen());
                }
              )
            ),
            Card(
              child: ListTile(
                title: const Text("My Sets"),
                selected: true,
                onTap: () {
                  
                }
              )
            )
          ]
        )
      ),
      body: SlidingUpPanel(
        controller: panelController,
        backdropEnabled: true,
        onPanelClosed: (){
          setState(() {
            exercises.clear();
            isPanelOpened = false;
          });
        },
        header: isPanelOpened == true
          ? SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Text(
                      sets[currentSet].name,
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).primaryColor
                      )
                    )
                  )
                ),
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          panelController.close();
                          isPanelOpened = false;
                          _database.child(_user.uid).child("sets").child(sets[currentSet].name).remove();
                        },
                        icon: const Icon(Icons.delete_outlined)
                      ),
                      IconButton(
                        onPressed: () {
                          _currentTrainingData!.exercises = sets[currentSet].exercises;
                          Navigator.of(context).pushReplacement(_routeToTrainingPageScreen());
                        },
                        icon: const Icon(Icons.play_arrow_outlined)
                      )
                    ]
                  )
                )
              ]
            )
          )
          : null,
        panel: Padding(
          padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
          child: ExercisesList(exercises, onOrder),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0)
        ),
        body: Column(
          children: [
            Expanded(child: SetsList(sets, setExercises, setCurrentSet))
          ]
        ),
        minHeight: 0,
      )
    );
  }
}
