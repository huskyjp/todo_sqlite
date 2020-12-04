import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_sqlite/models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();

  static Database _db;
  // only create one database for the app
  DatabaseHelper._instance();

  String tasksTable = 'task_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  // db: call from getTaskMapList function
  // create new database if _db is null
  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    // if exists
    return _db;
  }

  // _initDb: call from get db
  // create new database
  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + '/todo_list.db';
    final todoListDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDb;
  }

  // create actual database
  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $tasksTable($colId INTEGER PRIMARY KEY, $colTitle TEXT, $colDate TEXT, $colPriority TEXT, $colStatus INTEGER)',
    );
  }

  // getTaskMapList: call db function and create database as map
  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(tasksTable);
    return result;
  }

  // getTaskList: call getTaskMapList then convert it into list
  // Query function! （これを今から検索するよ）
  Future<List<Task>> getTaskList() async {
    // get task list from database
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    final List<Task> taskList = [];
    // convert map of tasklist to list of taskList
    // get each element by forEach from taskMapList then add into taskList
    taskMapList.forEach((taskMap) {
      taskList.add(Task.fromMap(taskMap));
    });
    taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    return taskList;
  }

// Create Database
// 👇👆
// Add, Update, Delete Database

  // Add a task to database from [task_model]
  Future<int> insertTask(Task task) async {
    Database db = await this.db;
    final int result = await db.insert(tasksTable, task.toMap());
    return result;
  }

  // update individual task from [task_model]
  Future<int> updateTask(Task task) async {
    Database db = await this.db;
    final int result = await db.update(
      tasksTable,
      task.toMap(),
      where: '$colId = ?',
      whereArgs: [task.id],
    );
    return result;
  }

  // delete individual task from [task_model]
  Future<int> deleteTask(int id) async {
    Database db = await this.db;
    final int result = await db.delete(
      tasksTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }
}
