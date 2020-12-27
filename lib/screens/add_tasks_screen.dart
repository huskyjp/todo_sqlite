import 'package:flutter/material.dart';
// format calendar date instead single string
import 'package:intl/intl.dart';
import 'package:todo_sqlite/helpers/database_helper.dart';
import 'package:todo_sqlite/models/task_model.dart';

class AddTasksScreen extends StatefulWidget {
  final Task task;
  final Function updateTaskList;
  final Function deleteTaskList;

  AddTasksScreen({this.task, this.updateTaskList, this.deleteTaskList});

  @override
  _AddTasksScreenState createState() => _AddTasksScreenState();
}

class _AddTasksScreenState extends State<AddTasksScreen> {
  // validate user input
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _priority;
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();

  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  // avoid case use selected today's task
  void initState() {
    super.initState();
    _dateController.text = _dateFormatter.format(_date);

    // initial setting if user tap task list
    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _priority = widget.task.priority;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _handleDatePicker() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      // controll text field number depends on calendar tap
      _dateController.text = _dateFormatter.format(date);
    }
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('$_title, $_date, $_priority');

      // TODO: Insert the task to the user database

      Task task = Task(title: _title, date: _date, priority: _priority);
      if (widget.task == null) {
        task.status = 0;
        DatabaseHelper.instance.insertTask(task);
      } else {
        task.id = widget.task.id;
        task.status = widget.task.status;
        DatabaseHelper.instance.updateTask(task);
      }

      // TODO: Update the list screen UI
      widget.updateTaskList();

      Navigator.pop(context);
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteTask(widget.task.id);
    // call back
    print(widget.task.)
    widget.deleteTaskList(widget.task.title);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 80.0,
            ),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        size: 30.0,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      widget.task == null ? 'Add Task' : 'Update Task',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // text field for user routine
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                            ),
                            child: TextFormField(
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Your Routine',
                                labelStyle: TextStyle(fontSize: 18.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              validator: (input) => input.trim().isEmpty
                                  ? 'Please enter your routine here!'
                                  : null,
                              onSaved: (input) => _title = input,
                              initialValue: _title,
                            ),
                          ),
                          // Calendar field
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                            ),
                            child: TextFormField(
                              readOnly: true,
                              controller: _dateController,
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                              onTap: _handleDatePicker,
                              decoration: InputDecoration(
                                labelText: 'Date',
                                labelStyle: TextStyle(fontSize: 18.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                          // Priority Field
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                            ),
                            child: DropdownButtonFormField(
                              isDense: true,
                              icon: Icon(Icons.arrow_drop_down_circle),
                              iconSize: 22.0,
                              iconEnabledColor: Theme.of(context).primaryColor,
                              items: _priorities.map(
                                (String priority) {
                                  return DropdownMenuItem(
                                    value: priority,
                                    child: Text(
                                      priority,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  );
                                  // TODO: Add Timer field and pass that value to Timer Screen
                                },
                              ).toList(),
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Priority',
                                labelStyle: TextStyle(fontSize: 18.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              validator: (input) => _priority == null
                                  ? 'Please select a prority level'
                                  : null,
                              onSaved: (input) => _priority = input,
                              onChanged: (value) {
                                setState(() {
                                  _priority = value;
                                });
                              },
                              value: _priority,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 20.0,
                            ),
                            height: 60.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: FlatButton(
                              child: Text(
                                widget.task == null ? 'Add' : 'update',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                              onPressed: _submit,
                            ),
                          ),
                          widget.task != null
                              ? Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 20.0,
                                  ),
                                  height: 60.0,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: FlatButton(
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                    onPressed: _delete,
                                  ),
                                )
                              : SizedBox.shrink()
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
