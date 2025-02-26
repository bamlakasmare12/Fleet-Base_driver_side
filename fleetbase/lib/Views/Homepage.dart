import 'dart:ui';
import '../Model/task_model.dart' as taskmodel;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../Services/Location_manager.dart';
import '../Services/route_service.dart';
import '../Services/task_handler.dart';
import '../Services/delivery_manager.dart';
import '../Model/Task.dart' as taskFile;
import '../Views/Menu.dart';
import '../Services/cache_manager.dart';
import '../Services/auth_service.dart';

import '../Services/gpsupdate.dart'; // New service for sending GPS updates

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final MapController mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final DeliveryHandler deliveryHandler = DeliveryHandler();
  final LocationHandler locationHandler = LocationHandler();
  final RouteHandler routeHandler = RouteHandler();
  final TaskHandler taskHandler = TaskHandler();
  final AuthService _authService = AuthService();
  final CacheManager cacheManager = CacheManager();
  final GpsUpdateService gpsUpdateService = GpsUpdateService();
  //final TaskModel taskmodel = TaskModel();
  // Initially, use an empty list for tasks.
  List<taskFile.Task> tasks = <taskFile.Task>[];
  List<taskmodel.TaskModel> tasked = <taskmodel.TaskModel>[];

  LatLng? _currentDestination = LatLng(0, 0);
  LatLng? _destination;
  LatLng? _Warehousedestination;
  List<LatLng> _route = [];
  bool _showSearch = false;
  bool _isLoading = false;
  String deliveryStatusId = '';
  taskFile.Task? acceptedTask;
  Timer? _deliveryTimer;
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Get the user ID from the auth service.

    // Get the current location once and move the map.
    locationHandler.getCurrentLocation().then((location) {
      if (location != null) {
        setState(() {
          _currentDestination = location.coordinates;
        });
        mapController.move(location.coordinates, 16);
      }
    });

    //Initialize continuous location updates.
    locationHandler.initializeLocation(
      onLocationUpdate: (newLocation) {
        // Wrap the callback body in an async closure.
        () async {
          setState(() {
            _currentDestination = newLocation;
            _isLoading = false;
          });
          // Get the delivery ID asynchronously (instead of using userId)
          String delId = await deliveryHandler.getdeliveryid();
          // Update the backend with the new location.
          await gpsUpdateService.updateLocation(delId);
          mapController.move(newLocation, 16);
        }();
      },
      mapController: mapController,
    );

    // Load fetched tasks from API into the bottom sheet.
    if (!_isLoading) {
      await loadDeliveries();
    }
    startDeliveryTimer();
  }

 void startDeliveryTimer() {
  _deliveryTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
    try {
      final fetchedTasks = await taskHandler.fetchDeliveries();
      final fetchedWarehouses = await taskHandler.fetchWarehouses();
      setState(() {
        tasks = fetchedTasks;
        tasked = fetchedWarehouses.cast<taskmodel.TaskModel>();
      });
    } catch (e) {
      print('Background refresh error: $e');
    }
  });
}

  // This function fetches the deliveries and assigns them to the tasks list.
  Future<void> loadDeliveries() async {
    setState(() => _isLoading = true);
    try {
      final fetchedTasks = await taskHandler.fetchDeliveries();
      final fetchedWarehouses = await taskHandler.fetchWarehouses();
      setState(() {
        tasks = fetchedTasks;
        tasked = fetchedWarehouses.cast<taskmodel.TaskModel>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching deliveries: $e');
    }
  }

  String? displayUserName() {
    return _authService.getUserName();
  }

  Future<void> _fetchCoordinates(String location) async {
    try {
      LatLng? fetchedDestination =
          await routeHandler.fetchCoordinates(location);
      if (fetchedDestination != null) {
        setState(() {
          _destination = fetchedDestination;
        });
        if (_currentDestination != null && _destination != null) {
          List<LatLng> newRoute = await routeHandler.getRoute(
            current: _currentDestination!,
            destination: _destination!,
          );
          setState(() {
            _route = newRoute;
          });
          mapController.move(_destination!, 14);
        }
      } else {
        _showError('Location not found. Please try another search.');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _WareHouseCoordinates(String location) async {
    try {
      LatLng? fetchedDestination =
          await routeHandler.fetchCoordinates(location);
      if (fetchedDestination != null) {
        setState(() {
          _destination = fetchedDestination;
        });
        if (_currentDestination != null && _destination != null) {
          List<LatLng> newRoute = await routeHandler.getRoute(
            current: _currentDestination!,
            destination: _destination!,
          );
          setState(() {
            _route = newRoute;
          });
          mapController.move(_destination!, 14);
        }
      } else {
        _showError('Location not found. Please try another search.');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
    });
  }

  void finishTask() {
    taskHandler.finishTask(
      currentLocation: _currentDestination,
      destination: _destination,
      onFinished: () {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Task finished successfully."),
            backgroundColor: Colors.green,
          ),
        );
      },
      onError: _showError,
    );
  }

  bool checkTask() {
    taskHandler.checkTask(
      currentLocation: _currentDestination,
      destination: _Warehousedestination,
      onFinished: () {
        setState(() {});
        return true;
      },
      onError: _showError,
    );
    return false;
  }

  Future<void> routeToAcceptedTask() async {
    await taskHandler.routeToAcceptedTask(
      fetchCoordinatesCallback: _fetchCoordinates,
      onError: _showError,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  _toggleSearch();
                  if (value.trim().isNotEmpty) {
                    _fetchCoordinates(value.trim());
                  }
                },
              )
            : Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            const AssetImage('Assets/logo/default_profile.png'),
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Welcome ${displayUserName()}',
                      style: const TextStyle(color: Colors.black)),
                ],
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Menu(acceptedTask: acceptedTask),
                ),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () async {
          final currentExtent = _sheetController.size;
          final targetExtent = currentExtent <= 0.14 ? 0.4 : 0.14;
          await _sheetController.animateTo(
            targetExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              width: screenwidth,
              height: screenheight * 0.9,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: _currentDestination ?? const LatLng(0, 0),
                  initialZoom: 5,
                  minZoom: 0,
                  maxZoom: 100,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  if (_destination != null)
                    MarkerLayer(markers: [
                      Marker(
                        point: _destination!,
                        width: 80,
                        height: 80,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.location_pin),
                          color: Colors.green,
                          iconSize: 40,
                        ),
                      ),
                    ]),
                  MarkerLayer(markers: [
                    Marker(
                      point: _currentDestination!,
                      width: 80,
                      height: 80,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.location_pin),
                        color: Colors.red,
                        iconSize: 40,
                      ),
                    ),
                  ]),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _route,
                        color: Colors.green,
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  // QR code scanner functionality
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.white,
                  elevation: 10,
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.black),
              ),
            ),
            Positioned(
              top: 70,
              right: 20,
              child: ElevatedButton(
                onPressed: routeToAcceptedTask,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.white,
                  elevation: 10,
                ),
                child: const Icon(Icons.route, color: Colors.black),
              ),
            ),
            Positioned(
              top: 130,
              right: 20,
              child: ElevatedButton(
                onPressed: finishTask,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.white,
                  elevation: 10,
                ),
                child: const Icon(Icons.stop, color: Colors.black),
              ),
            ),
            Positioned.fill(
              child: Column(
                children: [
                  SizedBox(
                      height:
                          MediaQuery.of(context).padding.top + kToolbarHeight),
                  Expanded(
                    child: DraggableScrollableSheet(
                      controller: _sheetController,
                      initialChildSize: 0.14,
                      minChildSize: 0.1,
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
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: Offset(0, -3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final currentExtent = _sheetController.size;
                                final targetExtent =
                                    currentExtent <= 0.14 ? 0.4 : 0.14;
                                await _sheetController.animateTo(
                                  targetExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                width: 100,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                height: 5,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                              ),
                            ),
                            const Text(
                              "Upcoming Tasks",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Expanded(
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : tasks.isEmpty
                                      ? const Center(
                                          child: Text("No tasks available"))
                                      : ListView.builder(
                                          controller: scrollController,
                                          itemCount: tasks.length,
                                          itemBuilder: (context, index) =>
                                              buildTask(
                                                  tasks[index], tasked[index]),
                                        ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTask(taskFile.Task task, taskmodel.TaskModel taskeds) => ListTile(
        title: Text(
          "Created by: ${task.createdBy}",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "instruction: ${task.deliveryInstructions}\n location: ${task.destinationLongitude} ${task.destinationLatitude}\n WareHouse: ${taskeds.name}",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            // Highlight only if this task's ID matches the accepted one.
            backgroundColor:
                (acceptedTask != null && acceptedTask!.id == task.id)
                    ? Colors.green
                    : null,
          ),
          onPressed: () async {
            // If no task is currently accepted, accept this one.
            _Warehousedestination =
                LatLng(taskeds.longitude, taskeds.latitude) as LatLng?;

            if (acceptedTask == null && checkTask()) {
              setState(() {
                acceptedTask = taskHandler.acceptedTask = task;
              });
              await _fetchCoordinates(
                  "${task.destinationLongitude},${task.destinationLatitude}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Task '${task.id}' accepted."),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (acceptedTask!.id == task.id) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Task '${task.id}' is already accepted."),
                  backgroundColor: Colors.orange,
                ),
              );
            } else if (checkTask() == false) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "you need to be at the warehouse to accept the task ."),
                  backgroundColor: Colors.orange,
                ),
              );
            } else {
              // Show a pop-up message if a different task is accepted.
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Task Already Accepted"),
                  content: const Text(
                      "You must finish your current task before accepting another."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            }
          },
          child: Text(
            (acceptedTask != null && acceptedTask!.id == task.id)
                ? "Accepted"
                : "Accept",
          ),
        ),
        onTap: () {
          // _fetchCoordinates("${taskeds.longitude},${taskeds.latitude}");
          _fetchCoordinates(taskeds.name);
        },
      );
}
