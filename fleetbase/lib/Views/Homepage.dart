import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import '../Model/task_model.dart' as taskmodel;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../Services/Location_manager.dart';
import '../Services/route_service.dart';
import '../Services/task_handler.dart';
import '../Services/delivery_manager.dart';
import '../Model/Task.dart' as taskFile;
import '../Views/Menu.dart';
import '../Services/cache_manager.dart';
import '../Services/auth_service.dart';
import '../Services/camera_service.dart';
import '../Services/gpsupdate.dart'; // New service for sending GPS updates
import '../Services/supabase_storage.dart';

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
  final CameraService cameraService = CameraService();

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
  List<taskmodel.TaskModel> _selectedWarehouses = [];
  LatLng? _currentDestination = LatLng(0, 0);
  LatLng? _destination;
  List<LatLng> _selectedWarehouseCoordinates = [];
  List<String> warehousenames = [];
  List<LatLng> _route = [];
  bool _showSearch = false;
  bool _isLoading = false;
  String deliveryStatusId = '';
  taskFile.Task? acceptedTask;
  Timer? _deliveryTimer;

  static const double _markerSize = 40.0;
  static const double _currentLocationSize = 40.0;
  static const Color _taskColor = Colors.blue;
  static const Color _warehouseColor = Colors.orange;
  bool _isLocationLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initializes the app by getting the user ID, getting the current location once, and starting continuous location updates.
  /// It also loads the fetched tasks from the API into the bottom sheet and starts the delivery timer.

  Future<void> _initializeApp() async {
    // Get the user ID from the auth service.
    setState(() => _isLocationLoaded = true);

    // Get the current location once and move the map.
    final location = await locationHandler.getCurrentLocation();
    if (location != null && mounted) {
      setState(() {
        _currentDestination = location.coordinates;
        _isLocationLoaded = true; // Location obtained
      });
      mapController.move(location.coordinates, 16);
    }

    if (mounted) {
      // Initialize continuous location updates.
      locationHandler.initializeLocation(
        onLocationUpdate: (newLocation) {
          // Wrap the callback body in an async closure.
          () async {
            setState(() {
              _currentDestination = newLocation;
              _isLoading = false;
            });
            // Get the delivery ID asynchronously (instead of using userId)
            if (acceptedTask != null) {
              int delId = acceptedTask!.id;
              // Update the backend with the new location.
              await gpsUpdateService.updateLocation(delId);
              mapController.move(newLocation, 16);
            }
          }();
        },
        mapController: mapController,
      );

      // Start a timer to update the current location every 3 seconds.
      Timer.periodic(const Duration(seconds: 3), (timer) async {
        final location = await locationHandler.getCurrentLocation();
        if (location != null) {
          setState(() {
            _currentDestination = location.coordinates;
          });
          mapController.move(location.coordinates, 16);

          // Update the backend with the new location if there is an active task.
          if (acceptedTask != null) {
            int delId = acceptedTask!.id;
            await gpsUpdateService.updateLocation(delId);
          }
        }
      });

      // Load fetched tasks from API into the bottom sheet.
      if (!_isLoading) {
        await loadDeliveries();
      }
      startDeliveryTimer();
    }
  }

  void startDeliveryTimer() {
    _deliveryTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final fetchedTasks = await taskHandler.fetchDeliveries();
        setState(() {
          tasks = fetchedTasks;
        });

        // Check the status of each task and update _destination and acceptedTask if in transit
        bool foundInTransit = false;
        for (var task in fetchedTasks) {
          if (task.status == "In Transit") {
            // Assuming "In Transit" represents 'in transit'
            setState(() async {
              _destination = LatLng(task.destinationLatitude ?? 0.0,
                  task.destinationLongitude ?? 0.0);
              _route = await routeHandler.getRoute(
                  current: _currentDestination!, destination: _destination!);
              acceptedTask = task;
            });
            foundInTransit = true;
            break; // Exit the loop once we find a task in transit
          }
        }

        // If no task is in transit, clear the acceptedTask and route
        if (!foundInTransit) {
          setState(() {
            acceptedTask = null;
            _destination = null;
            _route = [];
          });
        }
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
      setState(() {
        tasks = fetchedTasks;
        _isLoading = false;
      });

      // Check the status of each task and update _destination and acceptedTask if in transit
      for (var task in fetchedTasks) {
        if (task.status == "In Transit") {
          // Assuming 2 represents 'in transit'
          setState(() async {
            _destination = LatLng(task.destinationLatitude ?? 0.0,
                task.destinationLongitude ?? 0.0);
            acceptedTask = task;
            _route = await routeHandler.getRoute(
                current: _currentDestination!, destination: _destination!);
          });
          break; // Exit the loop once we find a task in transit
        }
      }
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

  // Modify _WareHouseCoordinates to simply move to the given location without drawing a route.

  // This function fetches warehouses for a task, extracts their coordinates,
// and stores both the full warehouse data and their LatLng coordinates.
  Future<void> loadWarehouseCoordinatesFromTask(int taskId) async {
    try {
      // Fetch warehouses associated with the task.
      final warehouses = await taskHandler.fetchWarehouses(taskId);

      // Clear previous data (if needed).
      _selectedWarehouses.clear();
      _selectedWarehouseCoordinates.clear();

      print("warehouses length: ${warehouses.length}");

      // Loop through each warehouse.
      for (int i = 0; i < warehouses.length; i++) {
        // Create a LatLng instance using the warehouse's latitude and longitude.
        LatLng coordinate =
            LatLng(warehouses[i].latitude, warehouses[i].longitude);
        print("warehouse coordinate: $coordinate");

        // Add the full warehouse object and its coordinate to their respective lists.
        _selectedWarehouses.add(warehouses[i]);
        _selectedWarehouseCoordinates.add(coordinate);
      }

      // Update the UI.
      setState(() {});
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

  void finishTask() async {
    try {
      // Step 1: Take picture
      final Uint8List? image = await cameraService.takePicture();
      if (image == null) return;

      // Step 2: Upload to Supabase
      setState(() => _isLoading = true);
      final supabaseStorage = SupabaseStorage();
      final String? imageUrl = await supabaseStorage.uploadDeliveryProof(image);

      if (imageUrl == null) {
        throw Exception('Failed to get image URL');
      }

      // Step 3: Complete the task with image URL
      taskHandler.finishTask(
        currentLocation: _currentDestination,
        destination: _destination,
        imageUrl: imageUrl, // Add this parameter to your finishTask method
        onFinished: () {
          setState(() {
            acceptedTask = null;
            _destination = null;
            _route = [];
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Task finished successfully with photo!"),
              backgroundColor: Colors.green,
            ),
          );
        },
        onError: (error) {
          setState(() => _isLoading = false);
          _showError(error.toString());
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to capture/upload photo: ${e.toString()}');
    }
  }

  Future<void> routeToAcceptedTask() async {
    await taskHandler.routeToAcceptedTask(
      fetchCoordinatesCallback: _fetchCoordinates,
      onError: _showError,
    );
  }

  void _showDelayDialog(BuildContext context, taskFile.Task task) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Delay Task"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Delay Reason',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a reason';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (reasonController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a delay reason'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      final notes = reasonController.text.trim();
                      await taskHandler.delayTask(
                        task.id,
                        notes,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text("Task delayed: ${reasonController.text}"),
                          backgroundColor: Colors.blue,
                        ),
                      );
                      setState(() {
                        acceptedTask = null;
                        _destination = null;
                        _route = [];
                      });
                    } catch (e) {
                      _showError("Failed to delay task: ${e.toString()}");
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Menu(acceptedTask: acceptedTask),
              ),
            ),
          ),
        ],
      ),
      body:_isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
        onTap: () async {
          final currentExtent = _sheetController.size;
          final targetExtent = currentExtent <= 0.2 ? 0.4 : 0.2;
          await _sheetController.animateTo(
            targetExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
          if (_isLocationLoaded) // Only build map when location is ready

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
                  initialCenter: _currentDestination!,
                  initialZoom: 3,
                  minZoom: 3,
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
                        child: Column(
                          children: [
                            Text(
                              "My Location",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ],
                        )),
                  ]),
                  // Added MarkerLayer for displaying multiple warehouse markers.
                  MarkerLayer(
                    markers: _selectedWarehouses
                        .map((warehouse) => Marker(
                              point: LatLng(
                                  warehouse.latitude, warehouse.longitude),
                              width: 80,
                              height: 80,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    warehouse.name,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.warehouse,
                                    color: Colors.blue,
                                    size: 40,
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),

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
              top: 80,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  if (acceptedTask != null && _destination != null) {
                    //  Directly use pre-cached destination
                    mapController.move(_destination!, 14);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No delivery is in route"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
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
              top: 140,
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
                      initialChildSize: 0.20,
                      minChildSize: 0.2,
                      maxChildSize: 0.80,
                      builder: (context, scrollController) => Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45,
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
                                    currentExtent <= 0.2 ? 0.8 : 0.2;
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
                                          // FIX: Use the smaller length to avoid out-of-range errors.
                                          itemCount: tasks.length,
                                          itemBuilder: (context, index) =>
                                              buildTask(tasks[index]),
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

  Widget buildTask(taskFile.Task task) => ListTile(
        title: Text(
          "Order id: ${task.orderId}",
          style: const TextStyle(
              fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Instruction: ${task.deliveryInstructions}\nStatus: ${task.status}\nLocation: ${task.destinationAddress} ",
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        onTap: () async {
          print("task id: ${task.orderId} delivery id ${task.id} on tap");
          try {
            final fetchedWarehouses =
                await taskHandler.fetchWarehouses(task.id);

            setState(() {
              _selectedWarehouses = fetchedWarehouses;
            });

            if (_selectedWarehouses.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (_currentDestination == null) return;

                final warehousePoints = _selectedWarehouses
                    .map((w) => LatLng(w.latitude, w.longitude))
                    .toList();

                // Combine with current location for better context
                final allPoints = [...warehousePoints, _currentDestination!];

                if (_selectedWarehouses.length == 1) {
                  // Single warehouse: Set zoom level explicitly
                  mapController.move(
                    warehousePoints.first,
                    14, // Optimal zoom level for single location
                  );
                } else {
                  // Multiple warehouses: Fit to bounds
                  final bounds = LatLngBounds.fromPoints(allPoints);
                  mapController.fitCamera(
                    CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(100),
                    ),
                  );
                }
              });
            }
          } catch (e) {
            print('Error handling warehouse tap: $e');
          }
        },
        trailing: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 200.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (acceptedTask?.id == task.id)
                      ? Colors.orange
                      : Colors.grey, // Grey out if not accepted
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () {
                  if (acceptedTask == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please accept the task first"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  } else if (acceptedTask!.id != task.id) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("only tasked accepted can be delayed."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  _showDelayDialog(context, task);
                },
                child: Text(
                  "Delay",
                  style: TextStyle(
                    fontSize: 14,
                    color: (acceptedTask?.id == task.id)
                        ? Colors.white
                        : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (acceptedTask != null && acceptedTask!.id == task.id)
                          ? Colors.green
                          : null,
                ),
                onPressed: () async {
                  if (acceptedTask == null) {
                    setState(() {
                      acceptedTask = taskHandler.acceptedTask = task;
                      taskHandler.updateDeliveryStatus(task.id);
                      // 🔥 Directly set destination from task coordinates
                      _destination = LatLng(
                        task.destinationLatitude ?? 0.0,
                        task.destinationLongitude ?? 0.0,
                      );
                    });

                    // Generate route after setting destination
                    if (_currentDestination != null && _destination != null) {
                      List<LatLng> newRoute = await routeHandler.getRoute(
                        current: _currentDestination!,
                        destination: _destination!,
                      );
                      setState(() {
                        _route = newRoute;
                      });
                      mapController.move(_destination!, 14); // Recenter map
                    }

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
                  } else {
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
            ],
          ),
        ),
      );
}
