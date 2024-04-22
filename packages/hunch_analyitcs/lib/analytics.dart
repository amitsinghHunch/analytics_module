import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:adjust_sdk/adjust.dart';
import 'package:datadog_flutter_plugin/datadog_flutter_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_config_plus/flutter_config_plus.dart';
import 'package:hunch_analyitcs/adjust.dart';
import 'package:hunch_analyitcs/aws_analytics.dart';
import 'package:hunch_analyitcs/aws_personalized.dart';
import 'package:hunch_analyitcs/clevertap.dart';
import 'package:hunch_analyitcs/crashlytics.dart';
import 'package:hunch_analyitcs/feed_events.dart';
import 'package:hunch_analyitcs/ga.dart';
import 'package:hunch_analyitcs/intercom.dart';
import 'package:hunch_analyitcs/locator.dart';
import 'package:hunch_analyitcs/mixpanel.dart';
import 'package:hunch_analyitcs/models/analytics-model.dart';
import 'package:hunch_analyitcs/one_signal.dart';
import 'package:hunch_analyitcs/utils/helpers_class.dart';
import 'package:hunch_analyitcs/uxcam.dart';
import 'package:package_info_plus/package_info_plus.dart';

const notEvokeProperty = ["updatedAt", "dp"];

class AnalyticsServices extends AnalyticsEvents {
  OneSignalService oneSignalService = locator.get<OneSignalService>();
  FeedEventService feedEventService = locator.get<FeedEventService>();

  AnalyticsProperty property = AnalyticsProperty();
  AnalyticsPropertyValue propertyValue = AnalyticsPropertyValue();
  bool isUserRegister = false;
  String currentRoute = "";
  String currentPage = "";
  String previousPage = "";
  String reportEvent = "";
  dynamic moderationParams;
  Set<String> impressionPoll3Sec = {};
  Set<String> impressionPoll1Sec = {};
  Set<String> impressionAd = {};
  bool isAskForPush = false;

  late BuildContext _context;

  BuildContext get context => _context;
  static final String env = FlutterConfigPlus.get('ENV');

  String? _firebaseToken;
  String? get firebaseToken => _firebaseToken;

  late String tokenStorageEmail;
  late bool isDarkTheme;
  late String currentUserUid;
  late String getAwsTrakingId;

  late void Function(String adid) adjustAdidValue;

  late void Function(bool isCheck) getUnreadNotificationsCountAndChatParameters;

  late Future<void> Function(dynamic userUid) activateEndpoint;

  AnalyticsServices(
    String? token, {
    required String email,
    required bool isNightMode,
    required String userUid,
    required String awsTrakingId,
    required void Function(String adid) adjustAdidValue,
    required void Function(bool isCheck)
        getUnreadNotificationsCountAndChatParameters,
    required void Function(String userUid) activateEndpoint,
  }) {
    init();

    _context = context;
    _firebaseToken = token;
    tokenStorageEmail = email;
    isDarkTheme = isNightMode;
    currentUserUid = userUid;
    getAwsTrakingId = awsTrakingId;
    initLocator(
      firebaseToken,
      email: tokenStorageEmail,
      isDarkTheme: isDarkTheme,
      userUid: currentUserUid,
      awsTrakingId: getAwsTrakingId,
      adjustAdidValue: adjustAdidValue,
      getUnreadNotificationsCountAndChatParameters:
          getUnreadNotificationsCountAndChatParameters,
      activateEndpoint: activateEndpoint,
    );
  }

  Future<void> init() async {
    try {
      AdjustManager().init();
      await MixpanelManager.init();

      requestTrackingAuth();
      ClevertapManager.init();
      UXCamManager.init();
      CrashlyticsManager.init();
      GaManager.init();
      AwsPinpointService.configureAmplify();

      if (Platform.isAndroid) {
        initFCMToken();
      }

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setUserProperty("env", env, isClevertap: true);
      setUserProperty(
          "app_version", (packageInfo.version + packageInfo.buildNumber),
          isClevertap: true);
    } catch (err) {
      log("Analytics error $err");
    }
  }

  Future<void> openIntercom() async {
    await IntercomManager.openIntercom();
  }

  Future<void> setScreenName(screenName) async {
    await UXCamManager.tagScreenName(screenName);
  }

  void initFCMToken() async {
    try {
      String? token = firebaseToken;
      // await FCMServices().getToken();
      log("FCM_IOS $token");
      if (token != null && token.isNotEmpty) {
        ClevertapManager.setPushToken(token);
        AdjustManager.setPushToken(token);
      }
    } catch (error) {
      log("Catch error in initFCMToken: $error");
    }
  }

  Future<void> registerUser(String userEmail) async {
    print("abc:: registerUser: $userEmail");
    // log("Set_User $userEmail");
    DatadogSdk.instance.setUserInfo(id: userEmail, email: userEmail);
    MixpanelManager.registerUser(userEmail);
    oneSignalService.setUser(userEmail);
    IntercomManager.registerUser(userEmail);
    ClevertapManager.registerUser({"Identity": userEmail, "Email": userEmail});
    AdjustManager.addSessionParameter();
    GaManager.registerUser(userEmail);
    CrashlyticsManager.setUser(userEmail);
    UXCamManager.setIdentity(userEmail);
    setUXCamUrl();
    MixpanelManager.setSuperProperty("email", userEmail);
    isUserRegister = true;
    if (Platform.isAndroid) {
      initFCMToken();
    }
  }

  Future<void> setProperty(user) async {
    // Identity & set user property
    String now = DateTime.now().toString();
    setUserProperty("last_active_date", now);
    if (!isUserRegister && user["email"] != null) {
      if (user["updatedAt"] != null) {
        incrementUserProperty("total_logins", 1.toDouble());
        incrementSuperProperty("total_logins", 1);
      } else {
        await setAliasUser(user["email"]);
        setUserProperty("total_logins", 1.toDouble());
        setSuperProperty("total_logins", 1);
      }
      try {
        await AwsPinpointService().identifyUser(user);
      } catch (err) {
        log("Amplify err $err");
      }
      print("abc:: registerUser: ${user["email"]}");
      await registerUser(user["email"]);
      onDeviceConversion(user["email"], user["phoneNumber"]);
      setSuperProperty("login_status", "Logged in");
      MixpanelManager.setUserProperty("\$email", user["email"]);
      if (user["entitlements"] != null) {
        MixpanelManager.setUserProperty("is_premium", true);
      } else {
        MixpanelManager.setUserProperty("is_premium", false);
      }
    }
    // ignore: prefer_typing_uninitialized_variables
    var age;
    user.forEach((key, value) {
      if (!notEvokeProperty.contains(key) &&
          value != null &&
          value is! Map<String, dynamic>) {
        try {
          String propertyKey = key;
          dynamic propertyValue = value;
          bool isClevertapKey = true;
          switch (key) {
            case "dob":
              if (value.isNotEmpty) {
                int age;
                if (value.toString().contains("-")) {
                  age = HelpersClass.calculateAge(DateTime.parse(value));
                } else {
                  DateTime currentDate = DateTime.now();
                  age = currentDate.year - int.parse(value);
                }
                propertyKey = "age";
                propertyValue = age.toString();
              }
              break;
            case "createdAt":
              var date =
                  DateTime.fromMillisecondsSinceEpoch(value * 1000).toString();
              propertyValue = date;
              setSuperProperty("first_signin_date", date, once: true);
              break;
            case "source":
              propertyKey = "usertype";
              propertyValue = value;
              break;
            case "city":
            case "country":
            case "region":
              String updatedKey = "db_$key";
              propertyKey = updatedKey;
              propertyValue = value;
              break;
            case "circleCount":
              String updatedKey = "no_of_circles_joined";
              propertyKey = updatedKey;
              propertyValue = value;
              break;
            case "isCircleOnboarded":
              String updatedKey = "is_circle_onboarded";
              propertyKey = updatedKey;
              propertyValue = value;
              break;
          }

          setUserProperty(propertyKey, propertyValue,
              isClevertap: isClevertapKey);
        } catch (err) {
          // print(
          //     "Error in setting user ${TokenStorage.email} property $key - $value: $err");
          DatadogSdk.instance.logs!.error(
              "Error in setting user $tokenStorageEmail property $key - $value: $err");
        }
      }
    });
    user["age"] = age;
    ClevertapManager.setUserProperty(user);
  }

  Future<void> onDeviceConversion(String email, String phoneNumber) async {
    GaManager.onDeviceConversion(email, phoneNumber);
  }

  Future<void> setUserProperty(String key, value, {isClevertap = false}) async {
    // Identity & set user property
    MixpanelManager.setUserProperty(key, value);
    GaManager.setUserProperty(key, value);
    UXCamManager.setUserProperty(key, value);
    IntercomManager.setUserProperty(key, value);
    if (isClevertap) {
      ClevertapManager.setUserProperty({key: value});
    }
  }

  Future<void> setUserObjProperty(var property) async {
    property
        .forEach((key, value) => {MixpanelManager.setUserProperty(key, value)});
  }

  Future<void> incrementUserProperty(String key, value) async {
    MixpanelManager.incrementUserProperty(key, value);
  }

  Future<void> incrementSuperProperty(String key, value) async {
    MixpanelManager.incrementSuperProperty(key, value);
    ClevertapManager.incrementUserProperty(key, value);
  }

  Future<void> incrementCTUserProperty(String key, value) async {
    ClevertapManager.incrementUserProperty(key, value);
  }

  Future<void> setSuperProperty(String key, value, {once = false}) async {
    // log("$key, $value");
    MixpanelManager.setSuperProperty(key, value, once: once);
  }

  Future<void> setAliasUser(String? distinctId) async {
    if (distinctId != null && distinctId.isNotEmpty) {
      await MixpanelManager.setAliasUser(distinctId);
    }
  }

  Future<void> setUXCamUrl() async {
    var sessionUrl = await UXCamManager.getSessionUrl();

    if (sessionUrl != null && sessionUrl != "") {
      GaManager.analytics
          .setUserProperty(name: "UXCam_Session_Link", value: sessionUrl);
      MixpanelManager.setUserProperty("uxcamUrl", sessionUrl);
      // GaManager.sendEvent(event, params);
      CrashlyticsManager.setUXCamUrl(sessionUrl);
    }
  }

  Future<void> track(String event, dynamic params) async {
    final darkTheme = isDarkTheme ? 'Dark' : 'Light';
    final darkThemeOS =
        SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? 'Dark'
            : 'Light';
    if (params != null) {
      params = {
        "current_page_name": property.current_page_name ?? "",
        "previous_page_name": property.previous_page_name ?? "",
        "current_mode": darkTheme,
        "os_mode": darkThemeOS,
        ...params
      };
    } else {
      params = {
        "current_page_name": property.current_page_name ?? "",
        "previous_page_name": property.previous_page_name ?? "",
        "current_mode": darkTheme,
        "os_mode": darkThemeOS
      };
    }
    MixpanelManager.sendEvent(event, params);
    ClevertapManager.sendEvent(event, params);
    AdjustManager().sendEvent(event, params);
    IntercomManager.sendEvent(event, params);
    UXCamManager.sendEvent(event, params);
    GaManager.sendEvent(event, params);
    AwsPersonalizeService().sendEvent(event, params);
    feedEventService.sendEvent(event, params);
    // AwsPinpointService.sendAnalyticsEvent(event, params);
  }

  Future<void> trackAiSuggestions(String event, dynamic params) async {
    AwsPinpointService.sendAnalyticsEvent(event, params);
  }

  Future<void> askForPush() async {
    ClevertapManager.registerForPush();
    oneSignalService.oneSignal
        .promptUserForPushNotificationPermission()
        .then((accepted) {
      isAskForPush = true;
      log("OneSignal Accepted permission: $accepted, $isAskForPush");
    });
  }

  Future<void> requestTrackingAuth() async {
    // Ask for tracking consent.
    if (Platform.isIOS) {
      Adjust.requestTrackingAuthorizationWithCompletionHandler().then((status) {
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
            break;
          default:
            log('[Adjust]: Authorization status update: DefaultState');
        }
        Timer(const Duration(seconds: 7), () => askForPush());
      });
    }
  }

  Future<void> logout() async {
    isUserRegister = false;
    // FCMServices().deleteToken();
    oneSignalService.disablePush(true);
    Timer(const Duration(seconds: 1), () => MixpanelManager.reset());
  }

  // Map<String?, dynamic> getPollAnalyticData(PollClass pollDetails) {
  //   try {
  //     var descriptionAdded = DescriptionAddedEventUtils.getDescriptionAdded(
  //         pollDetails.selectedMediaType ?? "");

  //     var obj = {
  //       property.poll_id: pollDetails.id,
  //       property.creator_username: pollDetails.creator!.username,
  //       property.question: pollDetails.question.substring(
  //           0,
  //           pollDetails.question.length > 255
  //               ? 255
  //               : pollDetails.question.length),
  //       // property.options: pollDetails.displayType == "text"
  //       //     ? pollDetails.options.map((e) => e.text).join(",")
  //       //     : "null",
  //       property.creator_type: pollDetails.createdFrom,
  //       property.tags: pollDetails.tags?.join(","),
  //       property.display_type: pollDetails.displayType,
  //       property.categories: pollDetails.categories?.join(","),
  //       property.poll_type: pollDetails.pollType ?? "",
  //       property.created_via: HelpersClass.createdViaCreatorType(
  //           pollDetails.creator!, pollDetails.createdAt),
  //       property.nsfwContent: pollDetails.nsfwContent,
  //       property.description_added: descriptionAdded,
  //       property.session_id: propertyValue.sessionId,
  //       property.refresh_id: propertyValue.refreshId,
  //       property.recommendationId: pollDetails.recommendationId,
  //       property.score: pollDetails.score,
  //       property.feed_type:
  //           propertyValue.feedType == "hot" ? "top" : propertyValue.feedType,
  //       property.model_type: pollDetails.modelType,
  //       property.campaign_id: pollDetails.campaignId,
  //       property.rank: pollDetails.rank,
  //       property.others_option_enabled: pollDetails.options.last.displayType ==
  //           DisplayType.textWithComment.value,
  //     };

  //     return obj;
  //   } catch (err) {
  //     debugPrint("$err");
  //     return {};
  //   }
  // }

  getMixpanelSuperProperty(key) async {
    var property = await MixpanelManager.mixpanel?.getSuperProperties();
    return property != null ? property[key] : null;
  }
}

enum DisplayType {
  text("text"),
  textWithComment("text_with_comment"),
  image("image"),
  gif("gif");

  final String value;

  const DisplayType(this.value);

  static DisplayType fromString(String value) {
    return DisplayType.values.firstWhere((e) => e.value == value);
  }
}
