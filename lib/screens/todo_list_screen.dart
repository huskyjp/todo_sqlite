import 'package:flutter/material.dart';
import 'package:todo_sqlite/helpers/database_helper.dart';
import 'package:todo_sqlite/models/task_model.dart';
import 'package:todo_sqlite/screens/add_tasks_screen.dart';

class ToDoListScreen extends StatefulWidget {
  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  Future<List<Task>> _taskList;

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

  _buildTasks<Widget>(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 25.0,
      ),
      child: Column(
        children: [
          ListTile(
            title: Text('Task Title'),
            subtitle: Text("NOW"),
            trailing: Checkbox(
              onChanged: (value) {
                setState(() {
                  value = true;
                });
              },
              activeColor: Theme.of(context).primaryColor,
              value: false,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add_circle_outline),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTasksScreen(),
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

          final int completedTaskCount = snapshot.data
              .where((Task task) => task.status == 1)
              .toList()
              .length;

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: 80.0,
            ),
            itemCount: 1 + snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
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
                        'My New Tasks!',
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
              return _buildTasks(snapshot.data[index - 1]);
            },
          );
        },
      ),
    );
  }
}
