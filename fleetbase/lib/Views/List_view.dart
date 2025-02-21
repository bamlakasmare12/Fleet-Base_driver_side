// list_items_page.dart
import 'package:flutter/material.dart';

class ListItemsPage extends StatelessWidget {
  final List<String> items;

  const ListItemsPage({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Items')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.list),
              title: Text(item),
            ),
          );
        },
      ),
    );
  }
}
