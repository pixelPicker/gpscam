import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gpscam/camera_page.dart';
import 'package:gpscam/edit_page.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

const headerTextStyle = TextStyle(
  fontSize: 24.0,
  fontFamily: 'Teachers',
  fontWeight: FontWeight.bold,
);
const paraTextStyle = TextStyle(
  fontSize: 16.0,
  fontFamily: 'Teachers',
);

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
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
  List<Placemark> locationAddr = [];

  late bool isLocationEnabled;
  late loc.PermissionStatus permissionGranted;

  late CameraController cameraController;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    checkLocationService();
    checkCameraStatus();
    cameraController = CameraController(_cameras[0], ResolutionPreset.max);
    cameraController.initialize().then((_) {
      if (!mounted) return;
    }).catchError((Object error) {
      if (error is CameraException) {
        switch (error.code) {
          case 'CameraAccessDenied':
            checkCameraStatus();
            break;
          default:
        }
      }
    });
    super.initState();
  }

  void takePicture() async {
    try {
      final image = await screenshotController.capture();
      if (image == null) throw Error();

      await Gal.putImageBytes(
        image,
        album: 'DCIM/Camera',
        name: 'img_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Captured Screenshot Successfully"),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error while capturing! $e")),
      );
    }
  }

  void checkCameraStatus() async {
    if (!kIsWeb) {
      final PermissionStatus storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        await Permission.storage.request();
      }
      final PermissionStatus cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        await Permission.camera.request();
      }
    }
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
    setState(() {});
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
              : CameraPage(
                  cameraController: cameraController,
                  takePicture: takePicture,
                  locationAddr: locationAddr,
                  locationData: locationData,
                  selectedDate: selectedDate,
                  selectedTime: selectedTime,
                  screenshotController: screenshotController,
                )),
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
