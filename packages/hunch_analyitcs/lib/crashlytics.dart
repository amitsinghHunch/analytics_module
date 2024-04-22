import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsManager {
  static FirebaseCrashlytics? firebaseCrashlytics;

  static Future<void> init() async {
    // log("Crashlytics Init");
    if(!FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
         await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(true);
    }
    // if (kDebugMode) {
    //   // Force disable Crashlytics collection while doing every day development.
    //   // Temporarily toggle this to true if you want to test crash reporting in your app.
    //   await FirebaseCrashlytics.instance
    //       .setCrashlyticsCollectionEnabled(false);
    // } else {
    //   if(!FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
    //      await FirebaseCrashlytics.instance
    //       .setCrashlyticsCollectionEnabled(true);
    //   }
    // }
  }

  static Future<void> senderror(error, stack, reason, bool? fatal) async{
      fatal ??= true;
     await FirebaseCrashlytics.instance.recordError(error, stack, reason:reason, fatal: fatal);
  } 

  static Future<void> setUXCamUrl(sessionUrl) async{
    await FirebaseCrashlytics.instance.setCustomKey("UXCam: Session Recording link", sessionUrl);
  }

  static Future<void> setUser(userId) async{
   await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  static Future<void> logEvent(event) async {
    try {
      
    } catch (err) {
      log("err", error: err);
    }
  }
}
