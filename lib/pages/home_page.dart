import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';

class HomePage extends StatefulWidget {
  HomePage();
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight, _deviceWidth;

  String? _newTaskContent;
  Box? _box;

  _HomePageState();
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * 0.15,
        title: const Text('Taskly'),
        backgroundColor: Colors.red,
        centerTitle: true,
        titleTextStyle: const TextStyle(
            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      body: _taskView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _taskView() {
    return FutureBuilder(
      future: Hive.openBox('tasks'),
      builder: (BuildContext _context, AsyncSnapshot _snapShot) {
        if (_snapShot.hasData) {
          _box = _snapShot.data;
          return _taskList();
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _taskList() {
    List tasks = _box!.values.toList();
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext _context, int _index) {
        var task = Task.fromMap(tasks[_index]);
        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
              decoration: task.done ? TextDecoration.lineThrough : null,
              color: task.done ? Colors.grey : Colors.black,
            ),
          ),
          subtitle: Text(
            task.timestamp.toString(),
          ),
          trailing: Checkbox(
            value: task.done,
            onChanged: (value) {
              task.done = value!;
              _box!.putAt(_index, task.toMap());
              setState(() {});
            },
            activeColor: Colors.green,
          ),
          onTap: () async {
            _showEditForm(context, task, _index);
          },
          onLongPress: () {
            _box!.deleteAt(_index);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopUp,
      backgroundColor: Colors.red,
      child: const Icon(Icons.add),
    );
  }

  void _displayTaskPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        return AlertDialog(
          title: const Text("Add New Task"),
          content: TextField(
            onSubmitted: (_value) {
              if (_newTaskContent != null) {
                var _task = Task(
                    content: _newTaskContent!,
                    timestamp: DateTime.now(),
                    done: false);
                _box?.add(_task.toMap());
                setState(() {
                  _newTaskContent = null;
                  Navigator.pop(_context);
                });
              }
            },
            onChanged: (_value) {
              setState(() {
                _newTaskContent = _value;
              });
            },
          ),
        );
      },
    );
  }

  void _showEditForm(BuildContext context, Task task, int index) {
    TextEditingController _controller =
        TextEditingController(text: task.content);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Enter new task content'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Tutup dialog tanpa menyimpan perubahan
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String editedContent = _controller.text;
                // Perbarui data tugas di penyimpanan lokal Hive
                task.content = editedContent;
                _box!.putAt(index, task.toMap());
                setState(() {});
                Navigator.of(context)
                    .pop(); // Tutup dialog setelah menyimpan perubahan
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
