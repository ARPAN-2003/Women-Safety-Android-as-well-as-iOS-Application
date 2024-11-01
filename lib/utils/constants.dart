import 'package:flutter/material.dart';

Color primaryColor = Color(0xFFFc3B77);

void goTo(BuildContext context, Widget nextScreen) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => nextScreen));
}

dialogueBox(BuildContext context, String text) {
  showDialog(context: context, builder: (context) => AlertDialog(title: Text(text)));
}

Widget progressIndicator(BuildContext context) {
  return Center(
    child: CircularProgressIndicator(
      color: Color(0xFFCC2029),
      backgroundColor: Color(0xFF531BF3),
      strokeWidth: 7,
    ),
  );
}
