import 'dart:convert';
import 'dart:developer';
import 'package:intercom_flutter/intercom_flutter.dart';

class IntercomManager {
  Intercom? intercom;

  static Future<void> init({
    required String appId,
    required String iosApiKey,
    required String androidApiKey,
  }) async {
    await Intercom.instance.initialize(
      appId,
      iosApiKey: iosApiKey,
      androidApiKey: androidApiKey,
    );
    await Intercom.instance.loginUnidentifiedUser();
  }

  static Future<void> registerUser(email) async {
    await Intercom.instance.loginIdentifiedUser(email: email);
  }

  static Future<void> setUserProperty(key, value) async {
    if (key == "username") {
      await Intercom.instance.updateUser(name: value);
    } else if (key == "email") {
      await Intercom.instance.updateUser(email: value);
    } else {
      await Intercom.instance.updateUser(customAttributes: {key: value});
    }
  }

  static Future<void> sendEvent(event, params) async {
    try {
      if (params == null) {
        Intercom.instance.logEvent(event);
      } else {
        params = json.decode(json.encode(params)) as Map<String, dynamic>;
        // log("$event $params: Intercom Events");
        Intercom.instance.logEvent(event, params);
      }
    } catch (err) {
      log("err $err");
    }
  }

  static Future<void> openIntercom() async {
    await Intercom.instance.displayMessenger();
  }
}
