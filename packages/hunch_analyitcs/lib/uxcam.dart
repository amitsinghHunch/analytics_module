import 'dart:convert';
import 'dart:developer';

import 'package:flutter_config_plus/flutter_config_plus.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:system_info_plus/system_info_plus.dart';

class UXCamManager {
  static late FlutterUxcam flutterUxcam;
  static bool isUxCamAllowed = false;
  static final String uxcamKey = FlutterConfigPlus.get('UXCAM_KEY');

  static Future<void> checkForUxCam() async {
    try {
      int? ramSize = await SystemInfoPlus.physicalMemory;
      if (ramSize! <= 0) {
        return;
      }

      if ((ramSize / 1024) > 4) {
        isUxCamAllowed = true;
      } else {
        isUxCamAllowed = false;
      }
    } catch (err) {
      log("UxCam: $err");
    }
  }

  static Future<void> init() async {
    await checkForUxCam();

    if (!isUxCamAllowed) {
      return;
    }

    log("UXCAM init");
    FlutterUxcam
        .optIntoSchematicRecordings(); // Confirm that you have user permission for screen recording
    FlutterUxConfig config = FlutterUxConfig(
        userAppKey: uxcamKey, enableAutomaticScreenNameTagging: true);
    FlutterUxcam.startWithConfiguration(config);
  }

  static Future<void> setIdentity(userId) async {
    if (!isUxCamAllowed) {
      return;
    }

    await FlutterUxcam.setUserIdentity(userId);
  }

  static Future<void> setUserProperty(key, value) async {
    if (!isUxCamAllowed) {
      return;
    }

    value = value.toString();
    try {
      FlutterUxcam.setUserProperty(key, value);
    } catch (err) {
      log("UxCam: $err");
    }
  }

  static Future getSessionUrl() async {
    if (!isUxCamAllowed) {
      return;
    }

    var url = await FlutterUxcam.urlForCurrentSession();
    return url;
  }

  static Future pauseScreenRecording() async {
    if (!isUxCamAllowed) {
      return;
    }

    await FlutterUxcam.pauseScreenRecording();
    await FlutterUxcam.allowShortBreakForAnotherApp(true);
  }

  static Future resumeScreenRecording() async {
    if (!isUxCamAllowed) {
      return;
    }

    await FlutterUxcam.resumeScreenRecording();
    await FlutterUxcam.allowShortBreakForAnotherApp(false);
  }

  static Future tagScreenName(screenName) async {
    if (!isUxCamAllowed) {
      return;
    }

    await FlutterUxcam.tagScreenName(screenName);
  }

  static Future<void> sendEvent(event, params) async {
    if (!isUxCamAllowed) {
      return;
    }

    try {
      if (params == null) {
        await FlutterUxcam.logEvent(event);
      } else {
        params = json.decode(json.encode(params)) as Map<String, dynamic>;
        if (params.length > 20) {
          // Remove excess properties
          params = Map<String, dynamic>.fromEntries(params.entries.take(20));
        }

        await FlutterUxcam.logEventWithProperties(event, params);
      }
    } catch (err) {
      log("UXCam err", error: err);
    }
  }

  static Future<void> stopSession() async {
    UXCamManager.isUxCamAllowed = false;
    await FlutterUxcam.stopSessionAndUploadData();
  }

  static Future<void> startSession() async {
    UXCamManager.isUxCamAllowed = true;
    await FlutterUxcam.startNewSession();
  }
}
