import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:women_safety_app/utils/constants.dart';

class MessageTextField extends StatefulWidget {
  final String currentId;
  final String friendId;
  const MessageTextField({super.key, required this.currentId, required this.friendId});

  @override
  State<MessageTextField> createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  TextEditingController _controller = TextEditingController();
  Position? _currentPosition;
  String? _currentAddress;
  String? message;
  File? imageFile;
  LocationPermission? permission;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();
    await _picker.pickImage(source: ImageSource.gallery).then((XFile? xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future getImageFromCamera() async {
    ImagePicker _picker = ImagePicker();
    await _picker.pickImage(source: ImageSource.camera).then((XFile? xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;
    var ref = FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile!);
    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();
      await sendMessage(imageUrl, 'img');
    }
  }

  Future _getCurrentLocation() async {
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      Fluttertoast.showToast(msg: "Location Permissions are denied");
      if(permission == LocationPermission.deniedForever){
        Fluttertoast.showToast(msg: "Location Permissions are permanently denied");
      }
    }
    Geolocator.getCurrentPosition(
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

  sendMessage(String message, String type) async {
    await FirebaseFirestore.instance.collection('users').doc(widget.currentId).collection('messages').doc(widget.friendId).collection('chats').add({
      'senderId': widget.currentId,
      'receiverId': widget.friendId,
      'message': message,
      'type': type,
      'date': DateTime.now()
    });
    await FirebaseFirestore.instance.collection('users').doc(widget.friendId).collection('messages').doc(widget.currentId).collection('chats').add({
      'senderId': widget.currentId,
      'receiverId': widget.friendId,
      'message': message,
      'type': type,
      'date': DateTime.now()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                cursorColor: primaryColor,
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type your message here',
                  fillColor: Colors.grey[100],
                  filled: true,
                  prefixIcon: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) => bottomsheet());
                      },
                      icon: Icon(Icons.add_box_rounded, color: primaryColor))
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                  onTap: () async {
                    message = _controller.text;
                    sendMessage(message!, 'text');
                    _controller.clear();
                  },
                  child: Icon(Icons.send_rounded, color: primaryColor, size: 30)),
            )
          ],
        ),
      ),
    );
  }

  bottomsheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            chatIcons(Icons.location_pin, "Location", () async {
              await _getCurrentLocation();
              Future.delayed(Duration(seconds: 2), (){
                message = "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude}%2C${_currentPosition!.longitude}. $_currentAddress";
                sendMessage(message!, 'link');
              });
            }),
            chatIcons(Icons.camera_alt_rounded, "Camera", () async {
              await getImageFromCamera();
            }),
            chatIcons(Icons.insert_photo_rounded, "Gallery", () async {
              await getImage();
            })
          ],
        ),
      ),
    );
  }

  chatIcons(IconData icons, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: primaryColor,
            child: Icon(icons),
          ),
          Text("$title")
        ],
      ),
    );
  }
}
