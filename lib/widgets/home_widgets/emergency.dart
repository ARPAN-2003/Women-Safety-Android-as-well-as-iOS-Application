import 'package:flutter/cupertino.dart';
import 'package:women_safety_app/widgets/home_widgets/emergencies/AmbulanceEmergency.dart';
import 'package:women_safety_app/widgets/home_widgets/emergencies/ArmyEmergency.dart';
import 'package:women_safety_app/widgets/home_widgets/emergencies/FirebrigadeEmergency.dart';
import 'package:women_safety_app/widgets/home_widgets/emergencies/policeemergency.dart';

class Emergency extends StatelessWidget {
  const Emergency({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: ListView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          PoliceEmergency(),
          AmbulanceEmergency(),
          FirebrigadeEmergency(),
          ArmyEmergency(),
        ],
      ),
    );
  }
}
