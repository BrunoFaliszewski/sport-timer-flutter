import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ExercisesList extends StatefulWidget {
  final List<Map<String, int>> exercises;
  final Function onOrderCallback;

  const ExercisesList(this.exercises, this.onOrderCallback);

  @override
  _ExercisesListState createState() => _ExercisesListState();
}

class _ExercisesListState extends State<ExercisesList> {
  final Map<String, int> _exercises = {};

  @override
  Widget build(BuildContext context) {
    widget.exercises.sort(
      (a, b) => a.keys.elementAt(0).compareTo(b.keys.elementAt(0))
    );
    return ReorderableListView.builder(
      physics: const ClampingScrollPhysics(), 
      shrinkWrap: true,
      itemCount: widget.exercises.length,
      itemBuilder: (context, index) {
        final Map<String, int> exercise = widget.exercises[index];
        return Card(
          key: Key("$index"),
          child: ListTile(
            title: Text(exercise.keys.elementAt(0).substring(4)),
            subtitle: Text("${exercise.values.elementAt(0)} seconds"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      widget.exercises.removeAt(index);
                      _exercises.clear();
                      for (int index = 0; index < widget.exercises.length; index++) {
                        _exercises["${index.toString().padLeft(4, "0")}${widget.exercises[index].keys.elementAt(0).substring(4)}"] = widget.exercises[index].values.elementAt(0);
                      }
                    });
                    widget.onOrderCallback(_exercises);
                  },
                  icon: const Icon(Icons.delete_outline)
                ),
                const Icon(Icons.drag_handle)
              ]
            ),
            onTap: () {

            }
          )
        );
      },
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final Map<String, int> item = widget.exercises.removeAt(oldIndex);
          widget.exercises.insert(newIndex, item);
          _exercises.clear();
          for (int index = 0; index < widget.exercises.length; index++) {
            _exercises["${index.toString().padLeft(4, "0")}${widget.exercises[index].keys.elementAt(0).substring(4)}"] = widget.exercises[index].values.elementAt(0);
          }
          widget.exercises.clear();
          for (var i = 0; i < _exercises.length; i++) {
            widget.exercises.add({_exercises.keys.elementAt(i) : _exercises.values.elementAt(i)});
          }
        });
        widget.onOrderCallback(_exercises);
      }
    );
  }
}