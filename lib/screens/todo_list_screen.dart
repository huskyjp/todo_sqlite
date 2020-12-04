import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_sqlite/helpers/database_helper.dart';
import 'package:todo_sqlite/models/task_model.dart';
import 'package:todo_sqlite/screens/add_tasks_screen.dart';

class ToDoListScreen extends StatefulWidget {
  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  Future<List<Task>> _taskList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() async {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
    List list = await _taskList;
    _listKey.currentState.insertItem(list.length - 1);
  }

  _deleteTaskList(String title) async {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
    List list = await _taskList;
    print(title);
    _listKey.currentState.removeItem(list.indexOf(title, 1),
        (context, animation) {
      return SizedBox.shrink();
    });
  }

  _buildTasks<Widget>(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 25.0,
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 18.0,
                decoration: task.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Text(
              '${_dateFormatter.format(task.date)} ・ ${task.priority}',
              style: TextStyle(
                fontSize: 15.0,
                decoration: task.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            trailing: Checkbox(
              onChanged: (value) {
                setState(() {
                  task.status = value ? 1 : 0;
                  DatabaseHelper.instance.updateTask(task);
                  _updateTaskList();
                });
              },
              activeColor: Theme.of(context).primaryColor,
              value: task.status == 1 ? true : false,
            ),
            onLongPress: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddTasksScreen(
                  task: task,
                  updateTaskList: _updateTaskList,
                  deleteTaskList: _deleteTaskList,
                ),
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// button in the right bottom
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add_circle_outline),
        // push to scrren where task is added
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTasksScreen(
              updateTaskList: _updateTaskList,
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _taskList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // If snapshot has data (user added tasks)
          final int completedTaskCount = snapshot.data
              .where((Task task) => task.status == 1)
              .toList()
              .length;

          return AnimatedList(
            padding: EdgeInsets.symmetric(
              vertical: 80.0,
            ),
            key: _listKey,
            initialItemCount: 1 + snapshot.data.length,
            itemBuilder:
                (BuildContext context, int index, Animation<double> animation) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Have A Nice Day!',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        '$completedTaskCount of ${snapshot.data.length}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                );
              }

              Tween<Offset> _offset =
                  Tween(begin: Offset(1, 0), end: Offset(0, 0));

              return SlideTransition(
                child: _buildTasks(snapshot.data[index - 1]),
                position: animation.drive(_offset),
              );
            },
          );
        },
      ),
    );
  }
}
