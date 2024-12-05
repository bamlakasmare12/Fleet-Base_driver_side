import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {'title': 'Notification 1', 'body': 'This is the first notification'},
    {'title': 'Notification 2', 'body': 'This is the second notification'},
    // Add more notifications here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(notifications[index]['title']!),
              subtitle: Text(notifications[index]['body']!),
              leading: Icon(Icons.notifications),
            ),
          );
        },
      ),
    );
  }
}
