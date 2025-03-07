import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gpscam/main.dart';
import 'package:location/location.dart' as loc;
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:latlong2/latlong.dart';

class CameraPage extends StatelessWidget {
  CameraPage({
    super.key,
    required this.cameraController,
    required this.takePicture,
    required this.locationData,
    required this.locationAddr,
    required this.selectedDate,
    required this.selectedTime,
    required this.screenshotController,
  });

  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final CameraController cameraController;
  final ScreenshotController screenshotController;
  final Function takePicture;
  final loc.LocationData? locationData;
  final List<Placemark> locationAddr;
  final MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    Placemark? place;
    if (locationAddr.isNotEmpty) {
      place = locationAddr[0];
    }
    final geoTagCountry = (locationAddr.isNotEmpty)
        ? "${place?.administrativeArea}, ${place?.country}, ${place?.postalCode}"
        : "Null";
    final geoTagCoordinates =
        "Lat: ${locationData?.latitude}, Lon: ${locationData?.longitude}";
    final geoTagLocation = (locationAddr.isNotEmpty)
        ? "${place?.name}, ${place?.subLocality}, ${place?.locality}, ${place?.administrativeArea}, ${place?.subAdministrativeArea}, ${place?.administrativeArea}-${place?.country} ${place?.postalCode}."
        : "Null";
    final geoTagDateTime = "${DateFormat.yMd().add_jm().format(
          DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          ),
        )} ${((selectedDate.timeZoneOffset.isNegative) ? "" : "+") + selectedDate.timeZoneOffset.inHours.toString()}:${selectedDate.timeZoneOffset.inMinutes % 60} ${selectedDate.timeZoneName}";

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Screenshot(
          controller: screenshotController,
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              CameraPreview(
                cameraController,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 24.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(160),
                    backgroundBlendMode: BlendMode.multiply,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Flex(
                    direction: Axis.horizontal,
                    spacing: 8.0,
                    children: [
                      Container(
                        height: 120.0,
                        width: 120.0,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ),
                        ),
                        child: FlutterMap(
                          options: MapOptions(
                            initialZoom: 12.0,
                            initialCenter: LatLng(
                              locationData?.latitude ?? 19.183,
                              locationData?.longitude ?? 72.862,
                            ),
                          ),
                          mapController: mapController,
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://stamen-tiles.a.ssl.fastly.net/terrain/{z}/{x}/{y}.jpg',
                              fallbackUrl:
                                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: ['a', 'b', 'c'],
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              geoTagCountry,
                              softWrap: true,
                              textAlign: TextAlign.start,
                              style: headerTextStyle.copyWith(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ),
                            Text(
                              geoTagCoordinates,
                              softWrap: true,
                              textAlign: TextAlign.start,
                              style: paraTextStyle.copyWith(
                                color: Colors.white,
                                fontSize: 10.0,
                              ),
                            ),
                            Text(
                              geoTagDateTime,
                              softWrap: true,
                              textAlign: TextAlign.start,
                              style: paraTextStyle.copyWith(
                                color: Colors.white,
                                fontSize: 10.0,
                              ),
                            ),
                            Text(
                              geoTagLocation,
                              softWrap: true,
                              textAlign: TextAlign.start,
                              style: paraTextStyle.copyWith(
                                color: Colors.white,
                                fontSize: 10.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton.outlined(
          splashColor: Colors.blueAccent,
          padding: EdgeInsets.all(2.0),
          onPressed: () => takePicture(),
          icon: Icon(
            Icons.circle,
            size: 48.0,
            color: Colors.blueAccent,
          ),
        )
      ],
    );
  }
}
