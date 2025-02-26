
import 'package:flutter/material.dart';
import 'package:fleetbase/Model/history_model.dart';
import '../Services/history_manager.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final HistoryManager historyManager = HistoryManager();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: historyManager.loadHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } 
          else {
            final data = snapshot.data ?? [];
            final historyList = data
                .map((element) => HistoryModel.fromJson(element))
                .toList();

            return ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final item = historyList[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(item.created_by),
                    subtitle: Text(
                      'Started At: ${item.started_at}\nDestination to:- ${item.destinationName} \nfinished delivery at: ${item.deliverd_at}'
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}