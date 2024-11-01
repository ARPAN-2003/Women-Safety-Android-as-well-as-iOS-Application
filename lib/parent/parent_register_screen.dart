import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:women_safety_app/components/PrimaryButton.dart';
import 'package:women_safety_app/components/SecondaryButton.dart';
import 'package:women_safety_app/components/custom_textfield.dart';
import 'package:women_safety_app/child/child_login_screen.dart';
import 'package:women_safety_app/model/user_model.dart';
import 'package:women_safety_app/utils/constants.dart';

class RegisterParentScreen extends StatefulWidget {
  @override
  State<RegisterParentScreen> createState() => _RegisterParentScreenState();
}

class _RegisterParentScreenState extends State<RegisterParentScreen> {
  // const RegisterParentScreen({super.key});
  bool isPasswordShown = true;
  bool isConfirmPasswordShown = true;

  final _formkey = GlobalKey<FormState>();
  final _formdata = Map<String, Object>();
  bool isLoading = false;

  _onSubmit() async {
    _formkey.currentState!.save();
    if(_formdata['password'] != _formdata['confirm_password']) {
      dialogueBox(context, 'Your entered password and confirm password should be equal');
    }
    else {
      progressIndicator(context);
      try {
        setState(() {
          isLoading = true;
        });
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _formdata['email'].toString(),
            password: _formdata['password'].toString()
        );
        if(userCredential.user != null) {
          final v = userCredential.user!.uid;
          DocumentReference<Map<String, dynamic>> db = FirebaseFirestore.instance.collection('users').doc(v);
          final user = UserModel(
              id: v,
              name: _formdata['name'].toString(),
              phone: _formdata['phone'].toString(),
              childEmail: _formdata['child_email'].toString(),
              parentEmail: _formdata['email'].toString(),
              type: 'parent'
          );
          final jsonData = user.toJson();
          await db.set(jsonData).whenComplete(() {
            goTo(context, LoginScreen());
            setState(() {
              isLoading = false;
            });
          });
          // goTo(context, LoginScreen());
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
        });
        if (e.code == 'weak-password') {
          dialogueBox(context, 'The password provided is too weak.');
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          dialogueBox(context, 'The account already exists for that email.');
          print('The account already exists for that email.');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        dialogueBox(context, e.toString());
        // print(e);
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                            'REGISTER AS PARENT',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 40, color: primaryColor, fontWeight: FontWeight.bold),
                          ),
                          Image.asset('assets/logo.png', height: 100, width: 100),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: Form(
                        key: _formkey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomTextField(
                              hintText: 'Enter your name',
                              textInputAction: TextInputAction.next,
                              keyboardtype: TextInputType.name,
                              prefix: Icon(Icons.person_rounded),
                              onsave: (name) {
                                _formdata['name'] = name ?? "";
                              },
                              validate: (name) {
                                if (name!.isEmpty || name.length<3) {
                                  return 'Please enter correct name';
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText: 'Enter your phone number',
                              textInputAction: TextInputAction.next,
                              keyboardtype: TextInputType.phone,
                              prefix: Icon(Icons.phone_rounded),
                              onsave: (phone) {
                                _formdata['phone'] = phone ?? "";
                              },
                              validate: (phone) {
                                if (phone!.isEmpty || phone.length<10) {
                                  return 'Please Enter Correct Phone Number';
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              hintText: 'Enter your email address',
                              textInputAction: TextInputAction.next,
                              keyboardtype: TextInputType.emailAddress,
                              prefix: Icon(Icons.email_rounded),
                              validate: (email) {
                                if (email!.isEmpty || email.length<3 || !email.contains("@") || !email.contains(".com")) {
                                  return 'Please Enter Correct Email';
                                }
                                // return null;
                              },
                              onsave: (email) {
                                _formdata['email'] = email ?? "";
                              },
                            ),
                            CustomTextField(
                              hintText: 'Enter your child\'s email address',
                              textInputAction: TextInputAction.next,
                              keyboardtype: TextInputType.emailAddress,
                              prefix: Icon(Icons.email_rounded),
                              validate: (email) {
                                if (email!.isEmpty || email.length<3 || !email.contains("@") || !email.contains(".com")) {
                                  return 'Please Enter Correct Email';
                                }
                                // return null;
                              },
                              onsave: (child_email) {
                                _formdata['child_email'] = child_email ?? "";
                              },
                            ),
                            CustomTextField(
                              hintText: 'Enter new password',
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
                            CustomTextField(
                              hintText: 'Enter confirm password',
                              isPassword: isConfirmPasswordShown,
                              prefix: Icon(Icons.vpn_key_rounded),
                              validate: (password) {
                                if (password!.isEmpty || password.length<7) {
                                  return 'Please Enter Correct Password';
                                }
                                return null;
                              },
                              onsave: (password) {
                                _formdata['confirm_password'] = password ?? "";
                              },
                              suffix: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isConfirmPasswordShown = !isConfirmPasswordShown;
                                    });
                                  },
                                  icon: isConfirmPasswordShown ? Icon(Icons.visibility_off) : Icon(Icons.visibility)
                              ),
                            ),
                            PrimaryButton(title: 'REGISTER', onPressed: () {
                              if (_formkey.currentState!.validate()) {
                                _onSubmit();
                              }
                            }),
                          ],
                        ),
                      ),
                    ),
                    SecondaryButton(title: 'Login into your account', onPressed: () {
                      goTo(context, LoginScreen());
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
