import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class TodoItem {
  String title;
  bool isDone;
  String timestamp;

  TodoItem({required this.title, this.isDone = false, required this.timestamp});

  Map<String, dynamic> toJson() =>
      {'title': title, 'isDone': isDone, 'timestamp': timestamp};

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        title: json['title'],
        isDone: json['isDone'],
        timestamp: json['timestamp'],
      );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced ToDo',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: TodoHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoHomePage extends StatefulWidget {
  @override
  _TodoHomePageState createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  List<TodoItem> _todos = [];
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() async {
    prefs = await SharedPreferences.getInstance();
    String? todoString = prefs!.getString('todos');
    if (todoString != null) {
      setState(() {
        _todos = (jsonDecode(todoString) as List)
            .map((e) => TodoItem.fromJson(e))
            .toList();
      });
    }
  }

  void _saveTodos() {
    prefs?.setString(
        'todos', jsonEncode(_todos.map((e) => e.toJson()).toList()));
  }

  void _addTodo(String title) {
    String timestamp = DateTime.now().toString().split('.')[0];
    setState(() {
      _todos.add(TodoItem(title: title, timestamp: timestamp));
    });
    _saveTodos();
  }

  void _editTodo(int index, String newTitle) {
    setState(() {
      _todos[index].title = newTitle;
    });
    _saveTodos();
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
    });
    _saveTodos();
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTodos();
  }

  void _showAddDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Task"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _addTodo(controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text("Add"))
        ],
      ),
    );
  }

  void _showEditDialog(int index) {
    TextEditingController controller =
        TextEditingController(text: _todos[index].title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Task"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _editTodo(index, controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text("Save"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My ToDo List'),
        actions: [
          IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: () {
                setState(() {
                  _todos.clear();
                });
                _saveTodos();
              })
        ],
      ),
      body: _todos.isEmpty
          ? Center(child: Text("No tasks yet. Add one!"))
          : ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (_, index) {
                final todo = _todos[index];
                return ListTile(
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration:
                          todo.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text("Added: ${todo.timestamp}"),
                  leading: Checkbox(
                    value: todo.isDone,
                    onChanged: (_) => _toggleTodo(index),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTodo(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
