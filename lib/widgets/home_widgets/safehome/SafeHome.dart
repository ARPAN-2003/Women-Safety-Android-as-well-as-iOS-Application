import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:women_safety_app/db/db_services.dart';
import 'package:women_safety_app/model/contactsm.dart';

class SafeHome extends StatefulWidget {
  const SafeHome({super.key});

  @override
  State<SafeHome> createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
  Position? _currentPosition;
  String? _currentAddress;
  LocationPermission? permission;

  // _getPermission() async => await [Permission.sms].request();
  _isPermissionGranted() async => await Permission.sms.status.isGranted;
  _sendSMS(String phoneNumber, String message, {int? simSlot}) async {
    SmsStatus result = await BackgroundSms.sendMessage(phoneNumber: phoneNumber, message: message, simSlot: 1);
    if (result == SmsStatus.sent) {
      Fluttertoast.showToast(msg: "Sent");
    }
    else {
      Fluttertoast.showToast(msg: "Failed");
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location services are disabled. Please enable the services")));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location permissions are denied")));
        return false;
      }
    }
    if(permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location permissions are permanently denied, We cannot request permissions")));
      return false;
    }
    return true;
  }

  _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if(!hasPermission) return;

    // permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   Fluttertoast.showToast(msg: "Location Permissions are denied");
    //   permission = await Geolocator.requestPermission();
    //   if(permission == LocationPermission.deniedForever){
    //     Fluttertoast.showToast(msg: "Location Permissions are permanently denied");
    //   }
    // }
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true
    ).then((Position position) {
      setState(() {
        _currentPosition = position;
        print(_currentPosition!.latitude);
        _getAddressFromLatLong();
      });
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  _getAddressFromLatLong() async {
    try{
      List<Placemark> placeMarks = await placemarkFromCoordinates(_currentPosition!.latitude, _currentPosition!.longitude);
      Placemark place = placeMarks[0];
      setState(() {
        _currentAddress = "${place.locality}, ${place.street}, ${place.postalCode}";
      });
    }
    catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    // _getPermission();
    _getCurrentLocation();
  }

  showModelSafeHome(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.4,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Send Your Current Location Immediately to your Emergency Contacts", style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
                SizedBox(height: 15),
                if(_currentPosition != null) Text(_currentAddress!),
                PrimaryButton(title: "Get LOCATION", onPressed: () {_getCurrentLocation();}),
                SizedBox(height: 14),
                PrimaryButton(title: "Send ALERT", onPressed: () async {
                  String recipients = "";
                  List<TContact> contactList = await DatabaseHelper().getContactList();
                  print(contactList.length);
                  if (contactList.isEmpty) {
                    Fluttertoast.showToast(msg: "Emergency Contact List is empty now");
                  }
                  else {
                    String messageBody = "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude}%2C${_currentPosition!.longitude}. $_currentAddress";
                    if (await _isPermissionGranted()) {
                      contactList.forEach((element) {
                        _sendSMS("${element.number}",
                            "I am in trouble. Please reach me out at - $messageBody");
                      });
                    }
                    else {
                      Fluttertoast.showToast(msg: "Something went wrong");
                    }
                  }
                })
              ],
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {
        showModelSafeHome(context),
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 180,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(),
          child: Row(
            children: [
              Expanded(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text("Send Location"),
                        subtitle: Text("Share Location"),
                  ),
                ],
              )),
              ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/route.jpg')
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  // const PrimaryButton({super.key});
  final String title;
  final Function onPressed;
  bool loading;
  PrimaryButton({required this.title, required this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.5,
      child: ElevatedButton(
        onPressed: () {
          onPressed();
        },
        child: Text(title, style: TextStyle(fontSize: 17)),
        style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFF8B4C5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))
      )
    );
  }
}
