import 'dart:ui';
import 'package:flutter/material.dart';
import '../Views/Menu.dart';
import '../Model/Task.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});
  final String name = 'Bamlak';
  final Task task = Task(
    title: 'Task 1',
    description: 'Description of Task 1',
    date: '2023-07-01',
    time: '12:00',
    location: 'Location 1',
  );

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      AssetImage('Assets/logo/default_profile.png'),
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('Welcome $name', style: const TextStyle(color: Colors.black)),
          ],
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Menu()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            width: screenwidth,
            height: screenheight * 0.9,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                image: AssetImage('Assets/logo/demo_map.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.2,
            minChildSize: 0.06,
            maxChildSize: 0.4,
            builder: (context, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(1),
                    child: Text(
                      "Upcoming Tasks",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return buildTask(task);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTask(Task task) => ListTile(
        title: Text(
          task.title,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(task.description),
        onTap: () {
          print("Task pressed");
        },
      );
}
