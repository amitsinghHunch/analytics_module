import 'dart:developer';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

class GaManager {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebasePerformance performance = FirebasePerformance.instance;

  static late Trace trace;

  static Future<void> init() async {
    // log("GA Init");
  }

  static Future<void> performanceNewTrace(name) async {
    trace = performance.newTrace(name);
    await trace.start();
  }

  static Future<void> performancSetMetric(String name, int value) async {
    trace.setMetric(name, value);
  }

  static Future<void> performanceSetAttribute(String name, String value) async {
    trace.putAttribute(name, value);
  }

  static Future<void> performanceStopTrace(event, params) async {
    await trace.stop();
  }

  static Future<void> registerUser(distinctId) async {
    await FirebaseAnalytics.instance.setUserId(id: distinctId);
  }

  static Future<void> onDeviceConversion(
      String email, String phoneNumber) async {
    if (Platform.isAndroid) {
      return;
    }
    if (phoneNumber != "" && email.contains("-")) {
      await FirebaseAnalytics.instance
          .initiateOnDeviceConversionMeasurementWithPhoneNumber(phoneNumber);
    } else if (email != "") {
      await FirebaseAnalytics.instance
          .initiateOnDeviceConversionMeasurementWithEmailAddress(email);
    }
  }

  static Future<void> setUserProperty(key, value) async {
    // log("GA: User Property $key, $value");
    await FirebaseAnalytics.instance
        .setUserProperty(name: key, value: value.toString());
  }

  static Future<void> sendEvent(event, params) async {
    // log("GA: $event: $params");
    try {
      switch (event) {
        case "15th_cast_vote":
          event = "fifteenth_cast_vote";
          break;
        case "5th_cast_vote":
          event = "fifth_cast_vote";
          break;
        case "10th_cast_vote":
          event = "tenth_cast_vote";
          break;
        case "2nd_cast_vote":
          event = "second_cast_vote";
          break;
      }
      if (params != null) {
        await FirebaseAnalytics.instance.logEvent(
          name: event,
          parameters: <String, dynamic>{...params},
        );
      } else {
        await FirebaseAnalytics.instance.logEvent(name: event);
      }
    } catch (err) {
      log("GA: $err");
    }
  }
}
