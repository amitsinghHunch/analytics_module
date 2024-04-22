import 'dart:developer';

import 'package:flutter_config_plus/flutter_config_plus.dart';
import 'package:hunch_analyitcs/analytics.dart';
import 'package:hunch_analyitcs/locator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  OneSignal oneSignal = OneSignal();
  static final String onesignalKey = FlutterConfigPlus.get('ONESIGNAL_KEY');
  final AnalyticsServices _analyticsServices = locator.get<AnalyticsServices>();

  OneSignalService() {
    init();
    observeEvents();
  }

  void init() {
    //Remove this method to stop OneSignal Debugging
    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setAppId(onesignalKey);

    // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    // OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    //   log("OneSignal Accepted permission: $accepted");
    // });
  }

  void observeEvents() {
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent event) {
      // Will be called whenever a notification is received in foreground
      // Display Notification, pass null param for not displaying the notification
      event.complete(event.notification);

      _analyticsServices.getUnreadNotificationsCountAndChatParameters(true);
      // UserService.getUnreadNotificationsCountAndChatParameters(isCheck: true);
    });
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      /// adding listable service to listen clicks
      // _deeplinkService.deeplinkListener();
      // _deeplinkService.redirectDeepLink(_deeplinkService.redirectLink,
      //     GlobalNavigatorService.rootNavigatorKey.currentContext!);
      // Will be called whenever a notification is opened/button pressed.
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      // Will be called whenever the permission changes
      // (ie. user taps Allow on the permission prompt in iOS)
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      // Will be called whenever the subscription changes
      // (ie. user gets registered with OneSignal and gets a user ID)
    });

    OneSignal.shared.setEmailSubscriptionObserver(
        (OSEmailSubscriptionStateChanges emailChanges) {
      // Will be called whenever then user's email subscription changes
      // (ie. OneSignal.setEmail(email) is called and the user gets registered
    });
  }

  void setUser(userId) {
    // log("OneSignal Service: user $userId");
    // Setting External User Id with Callback Available in SDK Version 3.9.3+
    OneSignal.shared.setExternalUserId(userId).then((results) {
      log(results.toString());
    }).catchError((error) {
      log(error.toString());
    });
    disablePush(false);
  }

  void disablePush(flag) {
    OneSignal.shared.disablePush(flag);
  }

  void setTags(key, value) {
    OneSignal.shared.sendTag("category", "sports").then((response) {
      print("Successfully sent tags with response: $response");
    }).catchError((error) {
      print("Encountered an error sending tags: $error");
    });

    // OneSignal.shared.sendTags({"test_key_1" : "test_value_1", "test_key_2" : "test_value_2"})
  }
}
