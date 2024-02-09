import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController taskNameController=TextEditingController();
  TextEditingController descriptionController=TextEditingController();
  TextEditingController dueDateController=TextEditingController();
  List<Task> tasks = [];

  int selectedIndex=-1;

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
            TextField(
              controller: taskNameController,
              decoration: const InputDecoration(
                  hintText: 'Task Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ))),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ))),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: dueDateController,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: InputDecoration(
                  hintText: 'Date',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ))),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {
                  String taskName=taskNameController.text.trim();
                  String description=descriptionController.text.trim();
                  String dueDate=dueDateController.text.trim();
                  if(taskName.isNotEmpty && description.isNotEmpty && dueDate.isNotEmpty){
                    setState(() {
                      tasks.add(Task(taskName: taskName, description: description, dueDate: dueDate));
                    });
                  }
                }, child: const Text("Add")),
                ElevatedButton(onPressed: () {
                  String taskName=taskNameController.text.trim();
                  String description=descriptionController.text.trim();
                  String dueDate=dueDateController.text.trim();
                  if(taskName.isNotEmpty && description.isNotEmpty && dueDate.isNotEmpty){
                    setState(() {
                      taskNameController.text='';
                      descriptionController.text='';
                      dueDateController.text='';
                      tasks[selectedIndex].taskName = taskName;
                      tasks[selectedIndex].description=description;
                      tasks[selectedIndex].dueDate=dueDate;
                      selectedIndex=-1;
                    });
                  }
                }, child: const Text("Update")),
              ],
            ),
            SizedBox(height: 5),
            tasks.isEmpty ?const Text('No Task Are Added Yet' , style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent),)
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
          width: 70,
            child: Row(
              children: [
                InkWell(
                  onTap: (){
                    taskNameController.text=tasks[index].taskName;
                    descriptionController.text=tasks[index].description;
                    dueDateController.text=tasks[index].dueDate;
                    setState(() {
                      selectedIndex=index;
                    });
                  },
                  child:
                      Icon(Icons.edit),
                  ),
                InkWell(
                  onTap: (){
                    setState(() {
                      tasks.removeAt(index);
                    });
                  },
                  child:
                  Icon(Icons.delete),
                ),
              ],
            ),

            ),
          ),

    );
  }
}

class Task {
  String taskName;
  String description;
  String dueDate;

  Task({required this.taskName, required this.description, required this.dueDate});
}
