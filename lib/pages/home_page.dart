// ignore_for_file: unnecessary_brace_in_string_interps
import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todoflutter/util/hero_route.dart';
import '../data/database.dart';
import '../util/dialog_box.dart';
import '../util/todo_tile.dart';
import 'package:just_audio/just_audio.dart';
import 'package:duration_picker/duration_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // reference the hive box
  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();
  String currTimeLeft = '00:00:00';
  Timer? countDownTimer;
  final player = AudioPlayer();
  String warningTime = '00:05:00';

  @override
  void initState() {
    // if this is the 1st time ever openin the app, then create default data
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      // there already exists data
      db.loadData();
      getCurrListTime(0);
    }
    super.initState();
  }

  // text controller
  final _controller = TextEditingController();

  // checkbox was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDataBase();
  }

  //Main color was changed
  void mainColorChanged(Color? value, int index) {
    setState((() {
      db.toDoList[index][2] = value;
    }));
    db.updateDataBase();
  }

  void onTimeLeftChanged(String? value, int index) {
    setState((() {
      db.toDoList[index][3] = value;
    }));
    db.updateDataBase();
    getCurrListTime(0);
  }

  // save new task
  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false, Colors.grey[400], "00:00:00"]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  // create a new task
  void createNewTask() async {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  // delete task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase();
    getCurrListTime(0);
  }

  void getCurrListTime(int? secondsToDecrement) {
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    for (var element in db.toDoList) {
      int parsedHours = int.parse(element[3].split(":")[0]);
      hours += parsedHours;
      int parsedMinutes = int.parse(element[3].split(":")[1]);
      minutes += parsedMinutes;
      int parsedSeconds = int.parse(element[3].split(":")[2]);
      seconds += parsedSeconds;
    }
    double hoursInMinutes = minutes % 60;
    int hoursInMinutesVal = (minutes / 60).floor();
    hours += hoursInMinutesVal;
    if (secondsToDecrement! > 0) {
      seconds -= secondsToDecrement;
      if (seconds < 0) {
        seconds = 60 - seconds.abs();
      }
      minutes -= 1;
      if (minutes < 0) {
        minutes = 60 - minutes.abs();
        if (hours > 0) {
          hours -= 1;
        }
      }
    }
    var newHoursInMinutes = hoursInMinutes.toInt();
    hours = hours.toInt();
    minutes = minutes.toInt();
    seconds = seconds.toInt();
    String hoursString = hours > 0
        ? hours < 10
            ? '0$hours'
            : '$hours'
        : '00';
    String minutesString = newHoursInMinutes > 0
        ? minutes < 10
            ? '0$newHoursInMinutes'
            : '$newHoursInMinutes'.substring(0, 2)
        : '00';
    String secondsString = seconds > 0
        ? seconds < 10
            ? '0$seconds'
            : '$seconds'
        : '00';
    setState(() {
      currTimeLeft = "$hoursString:$minutesString:${secondsString}";
    });
  }

  decrementCurrListTimeByVal(int? secondsToDecrement) async {
    int hours = 0;
    int minutes = 0;
    int seconds = 0;

    int parsedHours = int.parse(currTimeLeft.split(":")[0]);
    hours += parsedHours;
    int parsedMinutes = int.parse(currTimeLeft.split(":")[1]);
    minutes += parsedMinutes;
    int parsedSeconds = int.parse(currTimeLeft.split(":")[2]);
    seconds += parsedSeconds;

    int hoursInMinutesVal = (minutes / 60).floor();
    hours += hoursInMinutesVal;
    if (secondsToDecrement! > 0) {
      seconds -= secondsToDecrement;
      if (seconds < 0) {
        seconds = 60 - seconds.abs();
        minutes = minutes - 1;
      }

      if (minutes < 0) {
        minutes = 60 - minutes.abs();
        if (hours > 0) {
          hours = hours - 1;
        }
      }
    }
    double hoursInMinutes = minutes % 60;
    var newHoursInMinutes = hoursInMinutes.toInt();
    minutes = minutes.toInt();
    seconds = seconds.toInt();
    String hoursString = hours > 0
        ? hours < 10
            ? '0$hours'
            : '$hours'
        : '00';
    String minutesString = newHoursInMinutes > 0
        ? minutes < 10
            ? '0$newHoursInMinutes'
            : '$newHoursInMinutes'.substring(0, 2)
        : '00';
    String secondsString = seconds > 0
        ? seconds < 10
            ? '0$seconds'
            : '$seconds'
        : '00';
    setState(() {
      currTimeLeft = "$hoursString:$minutesString:${secondsString}";
    });
    String trueWarningTime =
        this.warningTime.length < 8 ? "0" + this.warningTime : this.warningTime;
    log(trueWarningTime);
    if (currTimeLeft == trueWarningTime.toString()) {
      try {
        await player.setUrl(
            'https://www.applesaucekids.com/sound%20effects/ASK%20Wind%20Chime.wav');
        await player.setClip(
            start: Duration(seconds: 2), end: Duration(seconds: 7));
        await player.play();
      } catch (error) {
        print(error);
      }
    } else if (currTimeLeft == "00:00:00") {
      try {
        pauseCountDown();
        await player.setUrl(
            'https://www.applesaucekids.com/sound%20effects/ASK%20Wind%20Chime.wav');
        await player.setClip(
            start: Duration(seconds: 12), end: Duration(seconds: 15));
        await player.play();
      } catch (error) {
        print(error);
      }
    }
  }

  decrementFirstDBRecord(int? secondsToDecrement, int indexOfToDoList) async {
    int hours = 0;
    int minutes = 0;
    int seconds = 0;

    int parsedHours = int.parse(db.toDoList[indexOfToDoList][3].split(":")[0]);
    hours += parsedHours;
    int parsedMinutes =
        int.parse(db.toDoList[indexOfToDoList][3].split(":")[1]);
    minutes += parsedMinutes;
    int parsedSeconds =
        int.parse(db.toDoList[indexOfToDoList][3].split(":")[2]);
    seconds += parsedSeconds;

    int hoursInMinutesVal = (minutes / 60).floor();
    hours += hoursInMinutesVal;
    if (secondsToDecrement! > 0) {
      seconds -= secondsToDecrement;
      if (seconds < 0) {
        seconds = 60 - seconds.abs();
        minutes = minutes - 1;
      }

      if (minutes < 0) {
        minutes = 60 - minutes.abs();
        if (hours > 0) {
          hours = hours - 1;
        }
      }
    }
    double hoursInMinutes = minutes % 60;
    var newHoursInMinutes = hoursInMinutes.toInt();
    minutes = minutes.toInt();
    seconds = seconds.toInt();
    String hoursString = hours > 0
        ? hours < 10
            ? '0$hours'
            : '$hours'
        : '00';
    String minutesString = newHoursInMinutes > 0
        ? minutes < 10
            ? '0$newHoursInMinutes'
            : '$newHoursInMinutes'.substring(0, 2)
        : '00';
    String secondsString = seconds > 0
        ? seconds < 10
            ? '0$seconds'
            : '$seconds'
        : '00';

    db.toDoList[indexOfToDoList][3] =
        "$hoursString:$minutesString:${secondsString}";
    db.updateDataBase();
    String trueWarningTime =
        this.warningTime.length < 8 ? "0" + this.warningTime : this.warningTime;
    log(trueWarningTime);
    if ("$hoursString:$minutesString:${secondsString}" == trueWarningTime) {
      try {
        await player.setUrl(
            'https://www.applesaucekids.com/sound%20effects/ASK%20Wind%20Chime.wav');
        await player.setClip(
            start: Duration(seconds: 2), end: Duration(seconds: 7));
        player.play();
      } catch (error) {
        print(error);
      }
    } else if ("$hoursString:$minutesString:${secondsString}" == "00:00:00") {
      db.toDoList[indexOfToDoList][1] = true;
      try {
        await player.setUrl(
            'https://www.applesaucekids.com/sound%20effects/ASK%20Wind%20Chime.wav');
        await player.setClip(
            start: Duration(seconds: 12), end: Duration(seconds: 15));
        await player.play();
      } catch (error) {
        print(error);
      }
    }
  }

  void startCountDown() {
    if (countDownTimer == null || !countDownTimer!.isActive) {
      countDownTimer =
          Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (currTimeLeft != "00:00:00") {
          decrementCurrListTimeByVal(1);
          var toDoListElem = 0;
          for (var i = 0; i < db.toDoList.length; i++) {
            if (db.toDoList[i][3] != "00:00:00") {
              toDoListElem = i;
              break;
            }
          }
          if (db.toDoList[toDoListElem][3] != "00:00:00") {
            decrementFirstDBRecord(1, toDoListElem);
          }
        } else {
          timer.cancel();
        }
      });
    }
  }

  void pauseCountDown() {
    countDownTimer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: createNewTask,
          child: Icon(Icons.add),
          backgroundColor: Colors.grey[200],
        ),
        body: Stack(
          children: [
            Row(children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(HeroDialogRoute(builder: (context) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Hero(
                          tag: 'add-todo-hero',
                          // createRectTween: (begin, end) {
                          //   return CustomRectTween(begin: begin, end: end);
                          // },
                          child: Material(
                            color: Colors.grey,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Set your warning time:'),
                                    const Divider(
                                      color: Colors.black,
                                      thickness: 1,
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        int timeLeft = 30;
                                        try {
                                          timeLeft = int.parse(
                                              this.warningTime.split(":")[1]);
                                        } catch (error) {
                                          print(error);
                                          timeLeft = 30;
                                        }
                                        var result = await showDurationPicker(
                                            context: context,
                                            initialTime:
                                                Duration(minutes: timeLeft));
                                        setState(() => this.warningTime =
                                            result.toString().substring(0, 7));
                                      },
                                      icon: Icon(Icons.timer),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }));
                },
                child: Hero(
                    tag: 'add-todo-hero',
                    // createRectTween: (begin, end) {
                    //   return CustomRectTween(begin: begin, end: end);
                    // },
                    child: Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: const Icon(
                        Icons.settings,
                        size: 32,
                      ),
                    )),
              ),
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[200]),
                  height: 60,
                  margin: const EdgeInsets.all(40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {
                            startCountDown();
                          },
                          icon: Icon(Icons.play_arrow)),
                      Text(currTimeLeft,
                          style: TextStyle(fontSize: 36, color: Colors.black)),
                      IconButton(
                          onPressed: () {
                            pauseCountDown();
                          },
                          icon: Icon(Icons.pause_circle_filled)),
                    ],
                  )),
            ]),
            Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: ReorderableListView.builder(
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  final item = db.toDoList.removeAt(oldIndex);
                  db.toDoList.insert(newIndex, item);
                },
                itemCount: db.toDoList.length,
                itemBuilder: (context, index) {
                  return ToDoTile(
                      index: index,
                      key: ValueKey('item$index'),
                      taskName: db.toDoList[index][0],
                      taskCompleted: db.toDoList[index][1],
                      mainColor: db.toDoList[index][2],
                      onChanged: (value) => checkBoxChanged(value, index),
                      onMainColorChanged: (value) =>
                          mainColorChanged(value, index),
                      onTimeLeftChanged: (value) =>
                          onTimeLeftChanged(value, index),
                      timeLeft: db.toDoList[index][3],
                      deleteFunction: (p0) => deleteTask(index));
                },
              ),
            ),
          ],
        ));
  }
}
