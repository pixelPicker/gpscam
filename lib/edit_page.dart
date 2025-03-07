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
                    style: paraTextStyle,
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => changeTime(),
            child: Container(
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
                    style: paraTextStyle,
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
                    "Lat: ${widget.locationData?.latitude}\nLon: ${widget.locationData?.longitude}\nAddr: ${(place != null) ? "${place.name} ${place.street} ${place.subLocality} ${place.administrativeArea} ${place.subAdministrativeArea} ${place.administrativeArea} ${place.country} ${place.postalCode}" : "Error while fetching address"}",
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
