import 'dart:convert';
import 'dart:developer';
import 'package:flutter_config_plus/flutter_config_plus.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelManager {
  static Mixpanel? mixpanel;

  static final String mixpanelToken = FlutterConfigPlus.get('MIXPANEL_TOKEN');

  static Future<void> init() async {
    try {
      mixpanel ??= await Mixpanel.init(mixpanelToken,
          optOutTrackingDefault: false, trackAutomaticEvents: true);
    } catch (err) {
      log("Analytics $err");
    }
  }

  static Future<String?> getDistinctId() async {
    try {
      var distinctId = await mixpanel?.getDistinctId();
      return distinctId;
    } catch (err) {
      log("err $err");
    }
    return null;
  }

  static Future<void> sendEvent(event, params) async {
    try {
      var distinctId = await mixpanel?.getDistinctId();
      if (params == null) {
        mixpanel?.track(event);
      } else {
        params = json.decode(json.encode(params)) as Map<String, dynamic>;
        log("$event $params: Mixpanel Distict Id: $distinctId");
        mixpanel?.track(event, properties: params);
      }
    } catch (err) {
      log("err $err");
    }
  }

  static Future<void> registerUser(distinctId) async {
    try {
      mixpanel?.identify(distinctId);
    } catch (err) {
      log("Mixpanel $err");
    }
  }

  static Future<void> setAliasUser(distinctId) async {
    String? currentDistinctId = await mixpanel?.getDistinctId();
    mixpanel?.alias(distinctId, currentDistinctId!);
  }

  static Future<void> incrementUserProperty(key, value) async {
    // log("user property $key, $value");
    mixpanel?.getPeople().increment(key, value);
  }

  static Future<void> incrementSuperProperty(key, value) async {
    var superProperty = await mixpanel?.getSuperProperties();
    if (superProperty!.containsKey(key)) {
      // log("increment super property $key");
      superProperty.forEach((pKey, pValue) {
        if (key == pKey) {
          setSuperProperty(key, (value + pValue));
        }
      });
    } else {
      log("increment set super property");
      setSuperProperty(key, 1);
    }
  }

  static Future<void> setUserProperty(key, value) async {
    if (key != "email") {
      mixpanel?.getPeople().set(key, value);
    }
  }

  static Future<void> setSuperProperty(key, value, {once = false}) async {
    if (once) {
      mixpanel?.registerSuperPropertiesOnce({key: value});
    } else {
      // log("superproperty $key, $value");
      mixpanel?.registerSuperProperties({key: value});
    }
  }

  static Future<void> reset() async {
    mixpanel?.reset();
    init();
    // mixpanel?.clearSuperProperties();
    // UUID.
  }
}
