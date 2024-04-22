import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:hunch_analyitcs/analytics.dart';
import 'package:hunch_analyitcs/constants/constant.dart';
import 'package:hunch_analyitcs/locator.dart';
import 'package:permission_handler/permission_handler.dart';

class AwsPinpointService {
  final AnalyticsServices _analyticsServices = locator.get<AnalyticsServices>();

  static Future<void> configureAmplify() async {
    try {
      final analyticsPlugin = AmplifyAnalyticsPinpoint();
      final authPlugin = AmplifyAuthCognito();
      await Amplify.addPlugins([analyticsPlugin, authPlugin]);
      await Amplify.configure(amplifyconfig);
      await Amplify.Analytics.enable();
    } catch (err) {
      safePrint(
        'amplify : $err',
      );
    }
  }

  static Future<void> sendAnalyticsEvent(
      String eventName, Map<dynamic, dynamic> properties) async {
    AnalyticsEvent event = AnalyticsEvent(eventName);
    try {
      createCustomProperties(event.customProperties, properties);
      await Amplify.Analytics.recordEvent(event: event);
      await Amplify.Analytics.flushEvents();
      print(
          "amplify record sent: $eventName:${event.customProperties.attributes}");
    } catch (err) {
      print("amplify err: $err");
    }
  }

  Future<void> identifyUser(Map<dynamic, dynamic> user) async {
    var status = await Permission.notification.status;
    var customProperties = createCustomProperties(CustomProperties(), {
      "isNotificationEnabled": status.isDenied ? false : true,
      "username": user["username"],
    });

    final analyticsUserProfile = UserProfile(
        name: user["userUid"],
        email: user["email"],
        customProperties: customProperties);

    await Amplify.Analytics.identifyUser(
      userId: user["userUid"],
      userProfile: analyticsUserProfile,
    );

    await _analyticsServices.activateEndpoint(user["userUid"]);
    print("amplify user registered");
  }

  static Future<void> updateUserIdentifier(dynamic user) async {
    try {
      var customProperties = createCustomProperties(CustomProperties(), {
        "lastTriggerTimestamp":
            (DateTime.now().millisecondsSinceEpoch / 1000).floor()
      });

      final analyticsUserProfile = UserProfile(
        name: user.userUid,
        email: user.email,
        customProperties: customProperties,
      );

      await Amplify.Analytics.identifyUser(
        userId: user.userUid!,
        userProfile: analyticsUserProfile,
      );
    } catch (e) {
      print(e);
    }
  }

  static createCustomProperties(
      CustomProperties customProperties, Map<dynamic, dynamic> properties) {
    for (var key in properties.keys) {
      if (properties[key].runtimeType == String) {
        customProperties.addStringProperty(key, properties[key]);
      }
      if (properties[key].runtimeType == int) {
        customProperties.addIntProperty(key, properties[key]);
      }
      if (properties[key].runtimeType == double) {
        customProperties.addDoubleProperty(key, properties[key]);
      }
      if (properties[key].runtimeType == bool) {
        customProperties.addBoolProperty(key, properties[key]);
      }
    }
    return customProperties;
  }
}
