import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;

const headerTextStyle = TextStyle(
  fontSize: 24.0,
  fontFamily: 'Teachers',
);
const paraTextStyle = TextStyle(
  fontSize: 16.0,
  fontFamily: 'Teachers',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo Tagging Camera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  loc.Location location = loc.Location();
  loc.LocationData? locationData;
  late bool isLocationEnabled;
  late loc.PermissionStatus permissionGranted;
  List<Placemark> locationAddr = [];

  @override
  void initState() {
    checkLocationService();
    super.initState();
  }

  void checkLocationService() async {
    isLocationEnabled = await location.serviceEnabled();
    if (!isLocationEnabled) {
      isLocationEnabled = await location.requestService();
      if (!isLocationEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    if (locationData != null) {
      locationAddr = await placemarkFromCoordinates(
        locationData!.latitude!,
        locationData!.longitude!,
      );
    }
  }

  void updateDateTime(DateTime date, TimeOfDay time) {
    setState(() {
      selectedDate = date;
      selectedTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gps photo tagger",
          style: headerTextStyle,
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: (selectedIndex == 0)
              ? EditPage(
                  selectedDate: selectedDate,
                  selectedTime: selectedTime,
                  updateDateTime: updateDateTime,
                  locationData: locationData,
                  locationAddr: locationAddr)
              : CameraPage()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_outlined),
            activeIcon: Icon(Icons.edit),
            label: "Edit",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: "Edit",
          ),
        ],
      ),
    );
  }
}

class EditPage extends StatefulWidget {
  const EditPage({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.updateDateTime,
    required this.locationData,
    required this.locationAddr,
  });

  final Function(DateTime, TimeOfDay) updateDateTime;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final loc.LocationData? locationData;
  final List<Placemark> locationAddr;

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  void changeDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        widget.updateDateTime(date, widget.selectedTime);
      });
    }
  }

  void changeTime() async {
    TimeOfDay? time = await showTimePicker(
        context: context, initialTime: widget.selectedTime);
    if (time != null) {
      setState(() {
        widget.updateDateTime(widget.selectedDate, time);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Placemark? place =
        (widget.locationAddr.isNotEmpty) ? widget.locationAddr[0] : null;
    return Center(
      child: Column(
        spacing: 16.0,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => changeDateTime(),
            child: Container(
              width: 200.0,
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                border: Border.all(width: 2.0, color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                spacing: 16.0,
                children: [
                  Icon(
                    Icons.edit_calendar,
                    color: Colors.blueAccent,
                    size: 32.0,
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    DateFormat.yMd().format(widget.selectedDate),
                    style: headerTextStyle,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => changeTime(),
            child: Container(
              width: 200.0,
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                border: Border.all(width: 2.0, color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                spacing: 16.0,
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.blueAccent,
                    size: 32.0,
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    widget.selectedTime.format(context),
                    style: headerTextStyle,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 32.0,
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              border: Border.all(width: 2.0, color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16.0,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.blueAccent,
                  size: 32.0,
                ),
                Expanded(
                  child: Text(
                    "Lat: ${widget.locationData?.latitude}\nLon: ${widget.locationData?.longitude}\nAddr: ${(place != null) ? "${place.name} ${place.street} ${place.administrativeArea} ${place.subAdministrativeArea} ${place.administrativeArea} ${place.country} ${place.postalCode}" : "Error while fetching address"}",
                    softWrap: true,
                    style: paraTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
