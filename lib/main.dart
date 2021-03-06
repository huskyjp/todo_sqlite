import 'package:flutter/material.dart';
import 'package:todo_sqlite/screens/todo_list_screen.dart';
import 'package:todo_sqlite/screens/top_title.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App with Flutter ListView',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ToDoListScreen(),
    );
  }
}
