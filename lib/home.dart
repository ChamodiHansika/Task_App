import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Task {
  int? id; // Add an ID field for database
  String taskName;
  String description;
  String dueDate;
  bool completed;

  Task({
    this.id,
    required this.taskName,
    required this.description,
    required this.dueDate,
    this.completed = false,
  });

  // Convert Task to a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskName': taskName,
      'description': description,
      'dueDate': dueDate,
      'completed': completed ? 1 : 0,
    };
  }

  // Construct a Task from a Map retrieved from the database
  Task.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    taskName = map['taskName'];
    description = map['description'];
    dueDate = map['dueDate'];
    completed = map['completed'] == 1;
  }
}

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'tasks';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'task_database.db');

    return openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            taskName TEXT,
            description TEXT,
            dueDate TEXT,
            completed INTEGER
          )
          ''',
        );
      },
    );
  }

  static Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      tableName,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteTask(Task task) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  static Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      tableName,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController taskNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();
  List<Task> tasks = [];

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    tasks = await DatabaseHelper.getTasks();
    setState(() {});
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dueDateController.text = picked.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Task List"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            TextFormField(
              controller: taskNameController,
              decoration: const InputDecoration(
                  hintText: 'Task Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  )),
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  )),
            ),
            SizedBox(height: 10.0),
            InkWell(
              onTap: () {
                _selectDueDate(context);
              },
              child: IgnorePointer(
                child: TextFormField(
                  controller: dueDateController,
                  decoration: InputDecoration(
                    hintText: 'Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    String taskName = taskNameController.text.trim();
                    String description = descriptionController.text.trim();
                    String dueDate = dueDateController.text.trim();
                    if (taskName.isNotEmpty &&
                        description.isNotEmpty &&
                        dueDate.isNotEmpty) {
                      Task newTask = Task(
                        taskName: taskName,
                        description: description,
                        dueDate: dueDate,
                      );
                      await DatabaseHelper.insertTask(newTask);
                      await _loadTasks();
                    }
                  },
                  child: const Text("Add"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String taskName = taskNameController.text.trim();
                    String description = descriptionController.text.trim();
                    String dueDate = dueDateController.text.trim();
                    if (taskName.isNotEmpty &&
                        description.isNotEmpty &&
                        dueDate.isNotEmpty) {
                      Task updatedTask = Task(
                        id: tasks[selectedIndex].id,
                        taskName: taskName,
                        description: description,
                        dueDate: dueDate,
                        completed: tasks[selectedIndex].completed,
                      );
                      await DatabaseHelper.updateTask(updatedTask);
                      await _loadTasks();
                    }
                  },
                  child: const Text("Update"),
                ),
              ],
            ),
            SizedBox(height: 5),
            tasks.isEmpty
                ? const Text(
              'No Task Are Added Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) => getRow(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getRow(int index) {
    return Card(
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Task: ${tasks[index].taskName}"),
            Text("Description: ${tasks[index].description}"),
            Text("Due Date: ${tasks[index].dueDate}"),
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  taskNameController.text = tasks[index].taskName;
                  descriptionController.text = tasks[index].description;
                  dueDateController.text = tasks[index].dueDate;
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Icon(Icons.edit),
              ),
              InkWell(
                onTap: () async {
                  await DatabaseHelper.deleteTask(tasks[index]);
                  await _loadTasks();
                },
                child: Icon(Icons.delete),
              ),
              Checkbox(
                value: tasks[index].completed,
                onChanged: (newValue) async {
                  setState(() {
                    tasks[index].completed = newValue!;
                  });
                  await DatabaseHelper.updateTask(tasks[index]);
                  await _loadTasks();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
