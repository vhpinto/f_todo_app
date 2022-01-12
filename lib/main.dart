import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ToDo {
  ToDo({required this.name, required this.checked});

  final String name;
  bool checked;

  ToDo.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        checked = json['checked'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'checked': checked,
      };
}

class ToDoItem extends StatelessWidget {
  ToDoItem({
    required this.toDo,
    required this.onToDoChanged,
    required this.deleteTask,
  }) : super(key: ObjectKey(toDo));

  final ToDo toDo;
  final Function onToDoChanged;
  final Function deleteTask;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onToDoChanged(toDo);
      },
      leading: (toDo.checked)
          ? const Icon(Icons.task_sharp)
          : const Icon(Icons.task_outlined),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          deleteTask(toDo);
        },
      ),
      title: Text(toDo.name),
    );
  }
}

class ToDoList extends StatefulWidget {
  const ToDoList({Key? key}) : super(key: key);

  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final TextEditingController _toDoController = TextEditingController();
  List<ToDo> _toDos = [];

  @override
  void initState() {
    super.initState();
    _createFile();
    _readData().then((data) {
      List<dynamic> _jsonList = json.decode(data);
      setState(() {
        _toDos = _jsonList.map((json) => ToDo.fromJson(json)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To Do List',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: _toDos.map((ToDo toDo) {
          return ToDoItem(
            toDo: toDo,
            onToDoChanged: _toDoChangeHandler,
            deleteTask: _deleteTaskHandler,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _displayDialog(),
          tooltip: 'Add item',
          child: const Icon(Icons.add)),
    );
  }

  Future<File> _createFile() async {
    final directory = await getApplicationDocumentsDirectory();
    bool fileExists = await directory.exists();
    if (!fileExists) {
      File file = File("${directory.path}/data.json");
      return file.create();
    }
    return _getFile();
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<String> _readData() async {
    final file = await _getFile();
    return file.readAsString();
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDos);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  void _toDoChangeHandler(ToDo toDo) {
    setState(() {
      toDo.checked = !toDo.checked;
      _saveData();
    });
  }

  void _deleteTaskHandler(ToDo toDo) {
    setState(() {
      _toDos.remove(toDo);
      _saveData();
    });
  }

  void _addToDoItem(String name) {
    setState(() {
      ToDo _toDo = ToDo(name: name, checked: false);
      if (_toDo.name != "") {
        _toDos.add(_toDo);
        _toDoController.clear();
        _saveData();
      }
    });
  }

  Future<void> _displayDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add a new to do item: '),
            content: TextField(
              controller: _toDoController,
              decoration:
                  const InputDecoration(hintText: 'Type new to do title: '),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _addToDoItem(_toDoController.text);
                  },
                  child: const Text('Add'))
            ],
          );
        });
  }
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'To Do list',
      home: ToDoList(),
    );
  }
}

void main() => runApp(const ToDoApp());
