import 'dart:developer';
import 'dart:io';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hunch_analyitcs/analytics.dart';
import 'package:hunch_analyitcs/locator.dart';
import 'package:hunch_analyitcs/widgets/feedback_bottomsheet.dart';

class ClevertapManager {
  static List<String> ignoreEvents = ['first_cast_vote'];
  static late CleverTapPlugin _clevertapPlugin;
  static String? cleverTapID = '';
  static final AnalyticsServices _analyticsServices =
      locator.get<AnalyticsServices>();

  static Future<void> init() async {
    activateCleverTapFlutterPluginHandlers();
    CleverTapPlugin.setDebugLevel(-1);
    CleverTapPlugin.createNotificationChannel(
        "hunch_ct", "hunch CT channel", "hunch CT channel", 4, true);
    CleverTapPlugin.initializeInbox();
    CleverTapPlugin.enableDeviceNetworkInfoReporting(true);

    cleverTapID = await CleverTapPlugin.getCleverTapID();
    FirebaseAnalytics.instance
        .setUserProperty(name: "ct_objectId", value: cleverTapID);
  }

  static void registerForPush() {
    if (Platform.isIOS) {
      CleverTapPlugin.registerForPush(); //only for iOS
    }
  }

  static void activateCleverTapFlutterPluginHandlers() {
    _clevertapPlugin = CleverTapPlugin();
    _clevertapPlugin
        .setCleverTapProfileDidInitializeHandler(profileDidInitialize);
    _clevertapPlugin
        .setCleverTapDisplayUnitsLoadedHandler(onDisplayUnitsLoaded);
  }

  static Future<void> profileDidInitialize() async {
    // var clevertapId = CleverTapPlugin.getCleverTapID();
    // // log("........Clevertap Initialise $clevertapId");
  }

  static Future<void> onDisplayUnitsLoaded(List<dynamic>? displayUnits) async {
    try {
      String displayType = "";
      Map<Object?, Object?> params = {};
      displayUnits?.forEach((element) {
        if (element["custom_kv"]["type"].toString().isNotEmpty) {
          displayType = element["custom_kv"]["type"];
          if (displayType == 'ai_comment_final') {
            params.addAll(element['custom_kv']);
          }
        }
      });
      nativeDisplayAction(displayType, params: params);
    } catch (err) {
      log("CT $err");
    }
  }

  static nativeDisplayAction(displayType,
      {Map<Object?, Object?> params = const {}}) async {
    final context = _analyticsServices.context;
    switch (displayType) {
      case "on_5th_vote":
        feedbackBottomsheet(
          context,
          OptionType.onBackButton,
          nativeDisplayType: displayType,
        );
        break;
      case "on_15th_vote":
        feedbackBottomsheet(
          context,
          OptionType.onFifthVote,
          nativeDisplayType: displayType,
        );
        break;
      case "on_2nd_launch":
        feedbackBottomsheet(
          context,
          OptionType.onSecondAppLaunch,
          nativeDisplayType: displayType,
        );
        break;
      case "on_2nd_launch_2":
        feedbackBottomsheet(
          context,
          OptionType.onMorethanOneAppLaunch,
          nativeDisplayType: displayType,
        );
        break;
      case "on_1st_chat_feedback":
        feedbackBottomsheet(
          context,
          OptionType.onFirstChatCompletion,
          nativeDisplayType: displayType,
        );

        break;
      default:
        break;
    }
  }

  static Future<void> registerUser(profile) async {
    print("Clevertap register");
    CleverTapPlugin.onUserLogin(profile);
  }

  static Future<void> setUserProperty(profile) async {
    try {
      CleverTapPlugin.profileSet(profile);
    } catch (err) {
      log("[Clevertap] err: $profile");
    }
  }

  static Future<void> incrementUserProperty(key, value) async {
    // log("[Clevertap]: $profile");
    CleverTapPlugin.profileIncrementValue(key, value);
  }

  static Future<void> setPushToken(token) async {
    if (Platform.isAndroid) {
      CleverTapPlugin.setPushToken(token);
    }
  }

  static Future<void> sendEvent(event, params) async {
    if (ignoreEvents.contains(event) == false) {
      try {
        params = params ?? <String, dynamic>{};

        params = <String, dynamic>{...params};
        // log("Clevertap params $params");
        CleverTapPlugin.recordEvent(event, params);
      } catch (err) {
        log("[Clevertap] err: $err");
      }
    }
  }
}
