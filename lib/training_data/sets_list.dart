import 'package:flutter/material.dart';
import 'package:sport_timer/training_data/training_data.dart';

// ignore: must_be_immutable
class SetsList extends StatefulWidget {
  List<TrainingData> sets;
  final Function(TrainingData) setExercises;
  final Function(int) currentSet;

  SetsList(this.sets, this.setExercises, this.currentSet);

  @override
  _SetsListState createState() => _SetsListState();
}

class _SetsListState extends State<SetsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.sets.length,
      itemBuilder: (context, index) {
        final TrainingData set = widget.sets[index];
        return Card(
          child: ListTile(
            title: Text(
              set.name,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onTap: () {
              widget.setExercises(set);
              widget.currentSet(index);
            }
          )
        );
      }
    );
  }
}