import 'package:flutter/material.dart';
import '../Model/Task.dart'; // Adjust the import as needed

class HistoryPage extends StatelessWidget {
  // Using the dummy deliveryHistory data
  final List<Task> history = '' as List<Task>;

  HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final task = history[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.history),
              title: Text(task.createdBy),
              subtitle: Text('${task.startedAt} - ${task.deliveryInstructions}'),
            ),
          );
        },
      ),
    );
  }
}
