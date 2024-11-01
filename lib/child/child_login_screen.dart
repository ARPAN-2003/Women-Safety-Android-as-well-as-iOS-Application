import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_safety_app/child/bottom_page.dart';
import 'package:women_safety_app/components/PrimaryButton.dart';
import 'package:women_safety_app/components/SecondaryButton.dart';
import 'package:women_safety_app/components/custom_textfield.dart';
import 'package:women_safety_app/child/register_child.dart';
import 'package:women_safety_app/db/share_pref.dart';
import 'package:women_safety_app/parent/parent_home_screen.dart';
import 'package:women_safety_app/parent/parent_register_screen.dart';
import 'package:women_safety_app/utils/constants.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // const LoginScreen({super.key});
  bool isPasswordShown = true;
  final _formkey = GlobalKey<FormState>();
  final _formdata = Map<String, Object>();
  bool isLoading = false;

  _onSubmit() async {
    _formkey.currentState!.save();
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _formdata['email'].toString(),
          password: _formdata['password'].toString()
      );

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      if(userCredential.user != null) {
        FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get().then((value) {
          if (mounted) {
            print("====> ${value['type']}");
            if (value['type'] == 'parent'){
              MySharedPreference.saveUserType('parent');
              goTo(context, ParentHomeScreen());
            }
            else {
              MySharedPreference.saveUserType('child');
              goTo(context, BottomPage());
            }
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      // print("123212321\n");
      // print(e);
      // print("\n123212321");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      // if (e.code == 'user-not-found') {
      //   dialogueBox(context, 'No user found for that email.');
      //   print('No user found for that email.');
      // } else if (e.code == 'wrong-password') {
      //   dialogueBox(context, 'Wrong password provided for that user.');
      //   print('Wrong password provided for that user.');
      // }

      if (e.code == 'invalid-credential') {
        dialogueBox(context, "Please enter valid credential");
        print('Invalid Credential');
      }
    }
    print(_formdata['email']);
    print(_formdata['password']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              isLoading ? progressIndicator(context)
              : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'USER LOGIN',
                            style: TextStyle(fontSize: 40, color: primaryColor, fontWeight: FontWeight.bold),
                          ),
                          Image.asset('assets/logo.png', height: 100, width: 100),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Form(
                        key: _formkey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomTextField(
                                hintText: 'Enter your email address',
                                textInputAction: TextInputAction.next,
                                keyboardtype: TextInputType.emailAddress,
                                prefix: Icon(Icons.email_rounded),
                                onsave: (email) {
                                  _formdata['email'] = email ?? "";
                                },
                                validate: (email) {
                                  if (email!.isEmpty || email.length<3 || !email.contains("@") || !email.contains(".com")) {
                                    return 'Please enter correct email';
                                  }
                                  // return null;
                                },
                            ),
                            CustomTextField(
                                hintText: 'Enter your password',
                                isPassword: isPasswordShown,
                                prefix: Icon(Icons.vpn_key_rounded),
                                validate: (password) {
                                  if (password!.isEmpty || password.length<7) {
                                    return 'Please Enter Correct Password';
                                  }
                                  return null;
                                },
                                onsave: (password) {
                                  _formdata['password'] = password ?? "";
                                },
                                suffix: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isPasswordShown = !isPasswordShown;
                                      });
                                    },
                                    icon: isPasswordShown ? Icon(Icons.visibility_off) : Icon(Icons.visibility)
                                ),
                            ),
                            PrimaryButton(
                                title: 'LOGIN',
                                onPressed: () {
                                  // progressIndicator(context);
                                  if (_formkey.currentState!.validate()) {
                                    _onSubmit();
                                  }
                                }
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Forgot Password?", style: TextStyle(fontSize: 18)),
                          SecondaryButton(title: 'Click here', onPressed: () {}),
                        ],
                      ),
                    ),
                    SecondaryButton(title: 'Register as Child', onPressed: () {
                      goTo(context, RegisterChildScreen());
                    }),
                    SecondaryButton(title: 'Register as Parent', onPressed: () {
                      goTo(context, RegisterParentScreen());
                    })
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
