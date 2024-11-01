import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:women_safety_app/db/db_services.dart';
import 'package:women_safety_app/model/contactsm.dart';
import 'package:women_safety_app/widgets/home_widgets/CustomCarouel.dart';
import 'package:women_safety_app/widgets/home_widgets/custom_appBar.dart';
import 'package:women_safety_app/widgets/home_widgets/emergency.dart';
import 'package:women_safety_app/widgets/home_widgets/safehome/SafeHome.dart';
import 'package:women_safety_app/widgets/live_safe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // const HomeScreen({super.key});
  int qIndex = 0;
  Position? _currentPosition;
  String? _currentAddress;
  LocationPermission? permission;

  _getPermission() async => await [Permission.sms].request();
  _isPermissionGranted() async => await Permission.sms.status.isGranted;

  // _sendSMS(String phoneNumber, String message, {int? simSlot}) async {
  //   SmsStatus result = await BackgroundSms.sendMessage(phoneNumber: phoneNumber, message: message, simSlot: 1);
  //   if (result == SmsStatus.sent) {
  //     Fluttertoast.showToast(msg: "Sent");
  //   }
  //   else {
  //     Fluttertoast.showToast(msg: "Failed");
  //   }
  // }

  String _currentCity = "";
  checkLocationPermission() async {
    bool permissionGranted = await _requestLocationPermission();
    setState(() {
      _locationPermissionGranted = permissionGranted;
    });

    if (_locationPermissionGranted) {
      _getCurrentCity();
    }
  }

  void _getCurrentCity() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          _currentCity = placemark.locality ?? "Unknown";
        });
        print(_currentCity);
      }
    } catch (e) {
      print("Error getting current city: $e");
    }
  }

  bool _locationPermissionGranted = false;
  Future<bool> _requestLocationPermission() async {
    var status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print("Current Location: $position");
      _getCurrentAddress();
      // Handle the obtained location as needed
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  String currentCity = "";

  _getCurrentAddress() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(_currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = "${place.locality}, ${place.street}, ${place.postalCode}";
        print(_currentAddress);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  // _getAddressFromLatLong() async {
  //   try{
  //     List<Placemark> placeMarks = await placemarkFromCoordinates(_currentPosition!.latitude, _currentPosition!.longitude);
  //     Placemark place = placeMarks[0];
  //     setState(() {
  //       _currentAddress = "${place.locality}, ${place.street}, ${place.postalCode}";
  //     });
  //   }
  //   catch (e) {
  //     Fluttertoast.showToast(msg: e.toString());
  //   }
  // }

  getAndSendSms() async {
    List<TContact> contactList = await DatabaseHelper().getContactList();
    String messageBody = "https://maps.google.com/?daddr=${_currentPosition!.latitude},${_currentPosition!.longitude}";
    if (await _isPermissionGranted()) {
      contactList.forEach((element) {
        // _sendSMS("${element.number}", "I am in trouble. Please reach me out at $messageBody");
      });
    }
    else {
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  getRandomQuote() {
    Random random = Random();
    setState(() {
      qIndex = random.nextInt(6);
    });
  }

  @override
  void initState() {
    getRandomQuote();
    super.initState();
    _getPermission();
    // _getCurrentLocation();

    /// Shake Feature ///
    // To close: detector.stopListening();
    // ShakeDetector.waitForStart() waits for user to call detector.startListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 10,
                child: Container(
                  color: Colors.grey.shade100,
                ),
              ),
              SizedBox(height: 5),
              CustomAppBar(
                  quoteIndex: qIndex,
                  onTap: () {
                    getRandomQuote();
                  }),
              SizedBox(height: 5),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  child: Icon(Icons.flight_takeoff_outlined),
                                  backgroundColor: Colors.grey.shade300,
                                ),
                                SizedBox(width: 5),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _locationPermissionGranted == false ? Text("Turn on location services.", style: TextStyle(fontWeight: FontWeight.bold))
                                    : Text("Location enabled"),
                                    SizedBox(height: 5),
                                    _currentCity.isEmpty ? Text("Please enable locations for a better experiences", maxLines: 2, style: TextStyle())
                                    : Text("Current City $_currentCity"),
                                    SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: _locationPermissionGranted == true ? SizedBox()
                                      : MaterialButton(
                                        onPressed: () async {
                                          checkLocationPermission();
                                        },
                                        color: Colors.grey.shade100,
                                        shape: StadiumBorder(),
                                        child: Text("Enable location", style: TextStyle(color: Colors.black)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Explore your power",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomCarouel(),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Incase of emergency dial me",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Emergency(),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Explore LiveSafe",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    LiveSafe(),
                    SafeHome(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 10,
//                 child: Container(color: Colors.grey.shade100),
//               ),
//               SizedBox(height: 5),
//               CustomAppBar(
//                 quoteIndex: qIndex,
//                 onTap: () {
//                   getRandomQuote();
//                 }
//               ),
//               Expanded(
//                 child: ListView(
//                   shrinkWrap: true,
//                   children: [
//                     SizedBox(height: 10),
//                     CustomCarouel(),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text("Emergency",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
//                     ),
//                     Emergency(),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text("Explore LiveSafe",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
//                     ),
//                     LiveSafe(),
//                     SafeHome(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
