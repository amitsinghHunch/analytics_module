import 'dart:developer';
import 'dart:io';
import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_attribution.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:adjust_sdk/adjust_event_failure.dart';
import 'package:adjust_sdk/adjust_event_success.dart';
import 'package:adjust_sdk/adjust_session_failure.dart';
import 'package:adjust_sdk/adjust_session_success.dart';
import 'package:datadog_flutter_plugin/datadog_flutter_plugin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config_plus/flutter_config_plus.dart';
import 'package:hunch_analyitcs/analytics.dart';
import 'package:hunch_analyitcs/locator.dart';
import 'package:hunch_analyitcs/mixpanel.dart';

class AdjustManager {
  static Adjust? adjust;
  static AdjustConfig? config;
  static AdjustAttribution? attribution;
  static final adjustDeeplink = ValueNotifier<String>("");
  static bool attStatus = false;
  static final String adjustToken = FlutterConfigPlus.get('ADJUST_TOKEN');
  final AnalyticsServices _analyticsServices = locator.get<AnalyticsServices>();

  Future<void> init() async {
    AdjustConfig config =
        AdjustConfig(adjustToken, AdjustEnvironment.production);
    config.logLevel = AdjustLogLevel.verbose;
    // config.delayStart = 5.5;
    await addSessionParameter();
    advanceSettings(config);
    // Start SDK.
    Adjust.start(config);

    config.defaultTracker;
    if (Platform.isIOS) {
      Adjust.checkForNewAttStatus();
    }

    try {
      var attribution = await Adjust.getAttribution();
      attributionFuntion(attribution);
    } catch (err) {
      log("Adjust: $err");
    }
  }

  // static void adjustAdidValue(String adid) async {
  //   // TokenStorage.adjustAdid = adid;
  // }

  void advanceSettings(config) async {
    // config.attributionCallback = (AdjustAttribution attributionChangedData) {
    //   print('Adjust: Attribution changed! $attributionChangedData');
    //   attribution = attributionChangedData;
    //   // if (FirebaseAuth.instance.currentUser != null) {
    //   attributionFuntion(attributionChangedData);
    //   // }
    // };

    config.sessionSuccessCallback = (AdjustSessionSuccess sessionSuccessData) {
      if (sessionSuccessData.message != null) {
        // log('[Adjust]: Message: ${sessionSuccessData.message!}');
      }
      if (sessionSuccessData.timestamp != null) {
        // log('[Adjust]: Timestamp: ${sessionSuccessData.timestamp!}');
      }
      if (sessionSuccessData.adid != null) {
        MixpanelManager.setUserProperty(
            "adjust_adid_internal", sessionSuccessData.adid.toString());
        _analyticsServices.adjustAdidValue(sessionSuccessData.adid.toString());
      }
      if (sessionSuccessData.jsonResponse != null) {
        // log('[Adjust]: JSON response: ${sessionSuccessData.jsonResponse!}');
      }
    };

    config.sessionFailureCallback = (AdjustSessionFailure sessionFailureData) {
      // log('[Adjust]: Session tracking failure!');

      if (sessionFailureData.message != null) {
        // log('[Adjust]: Message:  ${sessionFailureData.message!}');
      }
      if (sessionFailureData.timestamp != null) {
        // log('[Adjust]: Timestamp:  ${sessionFailureData.timestamp!}');
      }
      if (sessionFailureData.adid != null) {
        // log('[Adjust]: Adid:  ${sessionFailureData.adid!}');
      }
      if (sessionFailureData.willRetry != null) {
        // log('[Adjust]: Will retry:  ${sessionFailureData.willRetry.toString()}');
      }
      if (sessionFailureData.jsonResponse != null) {
        // log('[Adjust]: JSON response:  ${sessionFailureData.jsonResponse!}');
      }
    };

    config.eventSuccessCallback = (AdjustEventSuccess eventSuccessData) {
      // log('[Adjust]: Event tracking success!');

      if (eventSuccessData.eventToken != null) {
        // log('[Adjust]: Event token:  ${eventSuccessData.eventToken!}');
      }
      if (eventSuccessData.message != null) {
        // log('[Adjust]: Message:  ${eventSuccessData.message!}');
      }
      if (eventSuccessData.timestamp != null) {
        // log('[Adjust]: Timestamp:  ${eventSuccessData.timestamp!}');
      }
      if (eventSuccessData.adid != null) {
        // log('[Adjust]: Adid:  ${eventSuccessData.adid!}');
      }
      if (eventSuccessData.callbackId != null) {
        // log('[Adjust]: Callback ID:  ${eventSuccessData.callbackId!}');
      }
      if (eventSuccessData.jsonResponse != null) {
        // log('[Adjust]: JSON response:  ${eventSuccessData.jsonResponse!}');
      }
    };

    config.eventFailureCallback = (AdjustEventFailure eventFailureData) {
      // log('[Adjust]: Event tracking failure!');
      // ignore: prefer_typing_uninitialized_variables
      var params;
      if (eventFailureData.eventToken != null) {
        params["event_token"] = eventFailureData.eventToken;
        // log('[Adjust]: Event token: ${eventFailureData.eventToken!}');
      }
      if (eventFailureData.message != null) {
        params["message"] = eventFailureData.message.toString();
        // log('[Adjust]: Message: ${eventFailureData.message!}');
      }
      if (eventFailureData.timestamp != null) {
        params["timestamp"] = eventFailureData.timestamp.toString();
        // log('[Adjust]: Timestamp: ${eventFailureData.timestamp!}');
      }
      if (eventFailureData.adid != null) {
        params["adid"] = eventFailureData.adid.toString();
        // log('[Adjust]: Adid: ${eventFailureData.adid!}');
      }
      if (eventFailureData.callbackId != null) {
        // log('[Adjust]: Callback ID: ${eventFailureData.callbackId!}');
      }
      if (eventFailureData.willRetry != null) {
        params["willRetry"] = eventFailureData.willRetry.toString();
        // log('[Adjust]: Will retry: ${eventFailureData.willRetry.toString()}');
      }
      if (eventFailureData.jsonResponse != null) {
        // log('[Adjust]: JSON response: ${eventFailureData.jsonResponse!}');
      }
      MixpanelManager.sendEvent("adjust_event_failure", params);
    };

    config.deferredDeeplinkCallback = (String? uri) {
      print('Adjust: Received deferred deeplink 2:  ${uri!}');
      DatadogSdk.instance.logs?.info("Adjust Deeplink: $uri");
      MixpanelManager.sendEvent("adjust_deferred_linkk", uri);
      adjustDeeplink.value = uri;
    };

    config.conversionValueUpdatedCallback = (num? conversionValue) {
      // log('[Adjust]: Received conversion value update:  ${conversionValue!.toString()}');
    };

    requestTrackingAuth();
  }

  static Future<void> requestTrackingAuth() async {
    // Ask for tracking consent.
    if (Platform.isIOS) {
      Adjust.requestTrackingAuthorizationWithCompletionHandler().then(
        (status) {
          // log('[Adjust]: Authorization status update!');
          switch (status) {
            case 0:
              log('[Adjust]: Authorization status update: ATTrackingManagerAuthorizationStatusNotDetermined');
              break;
            case 1:
              log('[Adjust]: Authorization status update: ATTrackingManagerAuthorizationStatusRestricted');
              break;
            case 2:
              log('[Adjust]: Authorization status update: ATTrackingManagerAuthorizationStatusDenied');
              break;
            case 3:
              log('[Adjust]: Authorization status update: ATTrackingManagerAuthorizationStatusAuthorized');
              attStatus = true;
              break;
            default:
              log('[Adjust]: Unknown authorization status: $status');
              break; // Handle any other unexpected values
          }
        },
      );
    }
  }

  void attributionFuntion(attribution) {
    if (attribution.trackerToken != null) {
      print("Adjust trackerToken ${attribution.trackerToken}");
    }
    if (attribution.trackerName != null) {
      print("Adjust trackerName ${attribution.trackerName}");
    }
    if (attribution.campaign != null) {
      print("Adjust campaign ${attribution.campaign}");
    }
    if (attribution.network != null) {
      print("Adjust network ${attribution.network}");
    }
    if (attribution.creative != null) {
      print("Adjust creative ${attribution.creative}");
    }
    if (attribution.adgroup != null) {
      print("Adjust adgroup ${attribution.adgroup}");
    }
    if (attribution.clickLabel != null) {
      print("Adjust clickLabel ${attribution.clickLabel}");
    }
    if (attribution.adid != null) {
      print("Adjust Adid ${attribution.adid}");

      _analyticsServices.adjustAdidValue(attribution.adid.toString());
    }
  }

  static Future<void> addSessionParameter() async {
    try {
      String? distinctId = await MixpanelManager.getDistinctId();
      if (distinctId != null && distinctId.isNotEmpty) {
        Adjust.addSessionPartnerParameter('mixpanel_uuid', distinctId);
      }
    } catch (err) {
      log("Mixpanel $err");
    }
  }

  static Future<void> setPushToken(String token) async {
    if (token.isNotEmpty) Adjust.setPushToken(token);
  }

  Future<void> sendEvent(event, params) async {
    try {
      dynamic keyEvent = '';

      if (keyEvent != null && keyEvent.isNotEmpty) {
        AdjustEvent adjustEvent = AdjustEvent(keyEvent);
        String email = _analyticsServices.tokenStorageEmail;

        if (event == "complete_registration" || event == "15th_cast_vote") {
          Adjust.removeSessionPartnerParameter("mixpanel_uuid");
          params.forEach((key, value) {
            if (key != "email") {
              adjustEvent.addCallbackParameter(key, value.toString());
            }
          });
          Adjust.trackEvent(adjustEvent);
          await addSessionParameter();
        } else {
          if (FirebaseAuth.instance.currentUser != null && email.isNotEmpty) {
            adjustEvent.addCallbackParameter("email", email);
          }

          if (Platform.isIOS) {
            adjustEvent.addPartnerParameter(
                "AdvertiserTrackingEnabled", attStatus.toString());
            adjustEvent.addCallbackParameter(
                "AdvertiserTrackingEnabled", attStatus.toString());
          }
          params.forEach((key, value) {
            if (key == "level_number") {
              adjustEvent.addPartnerParameter("level_number", value.toString());
            }
            adjustEvent.addCallbackParameter(key, value.toString());
          });
          // log("Adjust Event $event");
          Adjust.trackEvent(adjustEvent);

          // log("ADJUST $event");
        }
      }
    } catch (err) {
      log("Adjust err", error: err);
    }
  }
}
