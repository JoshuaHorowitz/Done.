import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:duration_picker/duration_picker.dart';

// ignore: must_be_immutable
class ToDoTile extends StatefulWidget {
  final String taskName;
  final bool taskCompleted;
  Color mainColor;
  String timeLeft = "00:00:00";
  Function(bool?)? onChanged;
  Function(BuildContext)? deleteFunction;
  Function(Color?)? onMainColorChanged;
  Function(String?)? onTimeLeftChanged;
  int index;

  ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
    required this.mainColor,
    required this.onMainColorChanged,
    required this.timeLeft,
    required this.onTimeLeftChanged,
    required this.index,
  });

  @override
  State<ToDoTile> createState() => _ToDoTileState();
}

class _ToDoTileState extends State<ToDoTile> {
  Color? _tempMainColor;
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void showColorDialog() {
      showDialog(
          context: context,
          builder: (context) {
            return SizedBox(
                height: 50,
                child: Scaffold(
                    body: Column(
                  children: [
                    MaterialColorPicker(
                        selectedColor: widget.mainColor,
                        allowShades: false,
                        onMainColorChange: (color) =>
                            {setState(() => _tempMainColor = color)}),
                    Row(
                      children: [
                        TextButton(
                          child: const Text("Choose"),
                          onPressed: () {
                            setState(
                                () => {widget.mainColor = _tempMainColor!});
                            widget.onMainColorChanged!(widget.mainColor);
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    )
                  ],
                )));
          });
    }

    return SizedBox(
      height: 150,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Slidable(
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: widget.deleteFunction,
                icon: Icons.delete,
                backgroundColor: Colors.red.shade300,
                borderRadius: BorderRadius.circular(12),
              )
            ],
          ),
          child: ReorderableDelayedDragStartListener(
              index: widget.index,
              child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                  decoration: BoxDecoration(
                      color: widget.mainColor,
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          widget.mainColor,
                          widget.mainColor.withOpacity(0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // checkbox
                          Checkbox(
                            value: widget.taskCompleted,
                            onChanged: widget.onChanged,
                            activeColor: Colors.black,
                          ),

                          // task name
                          Flexible(
                              child: Text(
                            widget.taskName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              decoration: widget.taskCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          )),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: TextButton(
                              onPressed: () async {
                                int timeLeft = 30;
                                try {
                                  timeLeft =
                                      int.parse(widget.timeLeft.split(":")[1]);
                                } catch (error) {
                                  print(error);
                                  timeLeft = 30;
                                }
                                var result = await showDurationPicker(
                                    context: context,
                                    initialTime: Duration(minutes: timeLeft));
                                setState(() => widget.timeLeft =
                                    result.toString().substring(0, 7));
                                widget.onTimeLeftChanged!(
                                    result.toString().substring(0, 7));
                              },
                              child: Text(
                                widget.timeLeft,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showColorDialog();
                            },
                            icon: const Icon(Icons.color_lens),
                            color: Colors.white,
                          ),
                        ],
                      )
                    ],
                  ))),
        ),
      ),
    );
  }
}
