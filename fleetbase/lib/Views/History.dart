import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final List<Map<String, String>> history = [
    {'date': '2024-01-01', 'event': 'Started using the app'},
    {'date': '2024-03-15', 'event': 'Completed the first task'},
    // Add more history events here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(history[index]['event']!),
              subtitle: Text(history[index]['date']!),
              leading: Icon(Icons.history),
            ),
          );
        },
      ),
    );
  }
}
