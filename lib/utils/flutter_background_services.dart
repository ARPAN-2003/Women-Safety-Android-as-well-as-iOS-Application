import 'dart:async';
import 'dart:ui';
import 'package:background_location/background_location.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shake/shake.dart';
import 'package:telephony/telephony.dart';
import 'package:vibration/vibration.dart';
import 'package:women_safety_app/db/db_services.dart';
import 'package:women_safety_app/model/contactsm.dart';

sendMessage(String messageBody) async {
  List<TContact> contactList = await DatabaseHelper().getContactList();
  if (contactList.isEmpty) {
    Fluttertoast.showToast(msg: "No numbers exist. Please add a Number first");
  }
  else {
    for (var i = 0 ; i < contactList.length ; i++) {
      Telephony.backgroundInstance.sendSms(to: contactList[i].number, message: messageBody).then((value) {
        Fluttertoast.showToast(msg: "Messages sent");
      });
    }
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  AndroidNotificationChannel channel = AndroidNotificationChannel("Women Safety App ID", "Foreground Service", description: "It is used for important notification", importance: Importance.low);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  await service.configure(iosConfiguration: IosConfiguration(), androidConfiguration: AndroidConfiguration(onStart: onStart, isForegroundMode: true, autoStart: true, notificationChannelId: "Women Safety App ID", initialNotificationTitle: "Foreground Service", initialNotificationContent: "Initializing", foregroundServiceNotificationId: 888));
  service.startService();
}

@pragma('vm-entry-point')
void onStart(ServiceInstance service) async {
  Location? clocation;
  DartPluginRegistrant.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  await BackgroundLocation.setAndroidNotification(
    title: "Location tracking is running in the background!",
    message: "You can turn it off from settings menu inside the app",
    icon: '@mipmap/ic_logo'
  );

  BackgroundLocation.startLocationService(distanceFilter: 20);

  BackgroundLocation.getLocationUpdates((location) {
    clocation = location;
  });

  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      // await Geolocator.getCurrentPosition(
      //     desiredAccuracy: LocationAccuracy.high,
      //     forceAndroidLocationManager: true
      // ).then((Position position) {
      //   print("bg location: ${position.latitude}");
      // }).catchError((e) {
      //   Fluttertoast.showToast(msg: e.toString());
      // });
      ShakeDetector.autoStart(
          shakeThresholdGravity: 7,
          shakeSlopTimeMS: 500,
          shakeCountResetTime: 3000,
          minimumShakeCount: 1,
          onPhoneShake: () async {
            if (await Vibration.hasVibrator() ?? false) {
              print("Test 2");
              if (await Vibration.hasCustomVibrationsSupport() ?? false) {
                print("Test 3");
                Vibration.vibrate(duration: 1000);
              }
              else {
                print("Test 4");
                Vibration.vibrate();
                await Future.delayed(Duration(milliseconds: 500));
                Vibration.vibrate();
              }
              print("Test 5");
            }
            String messageBody = "https://www.google.com/maps/search/?api=1&query=${clocation!.latitude}%2C${clocation!.longitude}";
            sendMessage(messageBody);
          });
      flutterLocalNotificationsPlugin.show(
          888, "Women Safety App",
          clocation == null ? "Please enable the location to use the app" : "Shake feature enabled ${clocation!.latitude}",
          NotificationDetails(android: AndroidNotificationDetails("Women Safety App ID", "Foreground Service", channelDescription: "It is used for important notification", icon: 'ic_bg_service_small', ongoing: true)));
    }
  }
}
