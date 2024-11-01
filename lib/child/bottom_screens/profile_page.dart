import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:women_safety_app/child/bottom_page.dart';
import 'package:women_safety_app/child/child_login_screen.dart';
import 'package:women_safety_app/components/PrimaryButton.dart';
import 'package:women_safety_app/components/custom_textfield.dart';
import 'package:women_safety_app/utils/constants.dart';

class CheckUserStatusBeforeChatOnProfile extends StatelessWidget {
  const CheckUserStatusBeforeChatOnProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        else {
          if (snapshot.hasData) {
            return ProfilePage();
          }
          else {
            Fluttertoast.showToast(msg: 'please login first');
            return LoginScreen();
          }
        }
      },
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameC = TextEditingController();
  TextEditingController parentEmailC = TextEditingController();
  TextEditingController childEmailC = TextEditingController();
  TextEditingController phoneC = TextEditingController();

  final key = GlobalKey<FormState>();
  String? id;
  String? profilePic;
  String? downloadURL;
  bool isSaving = false;

  getData() async {
    await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get().then((value) {
      setState(() {
        nameC.text = value.docs.first['name'];
        childEmailC.text = value.docs.first['childEmail'];
        parentEmailC.text = value.docs.first['parentEmail'];
        phoneC.text = value.docs.first['phone'];
        id = value.docs.first.id;
        profilePic = value.docs.first['profilePic'];
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isSaving == true ? Center(child: CircularProgressIndicator(backgroundColor: primaryColor))
      : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Center(
              child: Form(
                key: key,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Update Your Profile", style: TextStyle(fontSize: 25)),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () async {
                          final XFile? pickImage = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
                          if (pickImage != null) {
                            setState(() {
                              profilePic = pickImage.path;
                            });
                          }
                        },
                        child: Container(
                          child: profilePic == null ? CircleAvatar(
                              radius: 80, backgroundColor: Colors.deepPurple,
                              child: Center(child: Image.asset('assets/add_pic.png', height: 80, width: 80))
                          )
                          : profilePic!.contains('http') ? CircleAvatar(
                              radius: 80, backgroundColor: Colors.deepPurple,
                              backgroundImage: NetworkImage(profilePic!),
                          )
                          : CircleAvatar(
                              radius: 80, backgroundColor: Colors.deepPurple,
                              backgroundImage: FileImage(File(profilePic!))
                          ),
                        ),
                      ),
                      CustomTextField(
                          controller: nameC,
                          hintText: nameC.text,
                          validate: (v) {
                            if (v!.isEmpty) {
                              return "Please enter your updated name";
                            }
                            return null;
                          }
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                          controller: childEmailC,
                          hintText: "Child Email",
                          readOnly: true,
                          validate: (v) {
                            if (v!.isEmpty) {
                              return "Please enter your updated email";
                            }
                            return null;
                          }
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                          controller: parentEmailC,
                          hintText: "Parent Email",
                          readOnly: true,
                          validate: (v) {
                            if (v!.isEmpty) {
                              return "Please enter your updated parent email";
                            }
                            return null;
                          }
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                          controller: phoneC,
                          hintText: "Phone Number",
                          readOnly: true,
                          validate: (v) {
                            if (v!.isEmpty) {
                              return "Please enter your updated phone number";
                            }
                            return null;
                          }
                      ),
                      SizedBox(height: 25),
                      PrimaryButton(title: "UPDATE", onPressed: () async {
                        if (key.currentState!.validate()) {
                          SystemChannels.textInput.invokeMethod('TextInput.hide');
                          profilePic == null ? Fluttertoast.showToast(msg: "Please Select Profile Picture")
                          : update();
                        }
                        // await FirebaseFirestore.instance.collection('users').doc(id).update({'name': nameC.text}).then((value) => Fluttertoast.showToast(msg: 'Name updated successfully'));
                      })
                ],
              ))
          ),
        ),
      ),
    );
  }
  Future<String?> uploadImage(String filePath) async {
    try {
      final fileName = Uuid().v4();
      final Reference fbStorage = FirebaseStorage.instance.ref('profile').child(fileName);
      final UploadTask uploadTask = fbStorage.putFile(File(filePath));
      await uploadTask.then((p0) async {
        downloadURL = await fbStorage.getDownloadURL();
      });
      return downloadURL;
    }
    catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  update() async {
    setState(() {
      isSaving = true;
    });
    uploadImage(profilePic!).then((value) {
      Map<String, dynamic> data = {
        'name': nameC.text,
        'profilePic': downloadURL
      };
      FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(data);
      setState(() {
        isSaving = false;
        goTo(context, BottomPage());
      });
    });
  }
}
