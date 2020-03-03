

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _toDoController = TextEditingController();
  List _toDoList = [];

  Map<String, dynamic> _lastRemoved = Map();
  int _lastRemovedPos;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _readData().then((data){
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();

      newToDo["title"] = _toDoController.text;
      newToDo["ok"] = false;

      _toDoList.add(newToDo);
      _toDoController.text = "";

      _saveData();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(

        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent)
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                )
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
                //onRefresh: _refresh(),
                child: ListView(
                  children: <Widget>[

                  ],
                ),)
          )
        ],
      ),
    );
  }

  Widget buildItem(context, index){
     return Dismissible(
       key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
       background: Container(
         color: Colors.red,
         child: Align(
           alignment: Alignment(-0.9, 0),
           child: Icon(Icons.delete, color: Colors.white,),
         )
       ),
       direction: DismissDirection.startToEnd,
       child: CheckboxListTile(
         title: Text(_toDoList[index]["title"]),
         value: _toDoList[index]["ok"],
         secondary: CircleAvatar(
           child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
         ),
         onChanged: (clicked){
           setState(() {
             _toDoList[index]["ok"] = clicked;
             _saveData();
           });
         },
       ),
       onDismissed: (direction) {
         setState(() {
           _lastRemoved = _toDoList[index];
           _lastRemovedPos = index;
           _toDoList.removeAt(index);

           _saveData();

           final snackbar = SnackBar(
             content: Text("Tarefa \"${_lastRemoved["title"]}\" removida!"),
             action: SnackBarAction(
                 label: "Desfazer",
                 onPressed: () {
                   setState(() {
                     _toDoList.insert(_lastRemovedPos, _lastRemoved);
                     _saveData();
                   });
                 }),
             duration: Duration(seconds: 2),
           );

           Scaffold.of(context).showSnackBar(snackbar);

         });
       },
     );
  }

  /*
  */

  Future<Null> refresh() async {

    return null;
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);

    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();

    } catch (e) {
      return null;
    }

  }


}
