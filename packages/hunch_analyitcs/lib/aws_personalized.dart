import 'dart:developer';
import 'package:aws_personalize_events_api/personalize-events-2018-03-22.dart';
import 'package:datadog_flutter_plugin/datadog_flutter_plugin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_config_plus/flutter_config_plus.dart';
import 'package:hunch_analyitcs/analytics.dart';
import 'package:hunch_analyitcs/impression_track.dart';
import 'package:hunch_analyitcs/locator.dart';

// ignore: non_constant_identifier_names
Map<String, double> EVENT_WEIGHT_VALUE = {
  "like_comment": 2,
  "add_comment": 6,
  "poll_view": 0.5,
  "poll_expand": 1.5,
  "fake_poll": 0
};

// ignore: non_constant_identifier_names
// List<String> IMPRESSION_EVENT = ["cast_vote", "poll_expand"];

class AwsPersonalizeService {
  static List<Map<String, dynamic>> eventStack = [];

  static late PersonalizeEvents personalizeEventsClient;
  static late String sessionId;

  final AnalyticsServices _analyticsServices = locator.get<AnalyticsServices>();

  static Future<void> personalizeSetup({
    required String region,
  }) async {
    final String awsAccessKey = FlutterConfigPlus.get('AWS_ACCESS_KEY');
    final String awsSecretKey = FlutterConfigPlus.get('AWS_SECRET_KEY');

    personalizeEventsClient = PersonalizeEvents(
      region: region,
      // Replace with your region ID
      credentials: AwsClientCredentials(
        accessKey: awsAccessKey,
        secretKey: awsSecretKey,
      ),
      // endpointUrl:
      //     'https://personalize-events.your-region-id.amazonaws.com',
    );
    sessionId = DateTime.now().microsecondsSinceEpoch.toString();
  }

  Future<void> sendEvent(event, params, {doReset = true}) async {
    final String awsFakePollId = FlutterConfigPlus.get('AWS_FAKE_POLL_ID');
    try {
      // For impression tracking
      if (event == "poll_view") {
        ImpressionTrack.push(params["poll_id"]);
        if (ImpressionTrack.impressionItemList.length == 10) {
          event = "fake_poll";
          params["poll_id"] = awsFakePollId;
        }
      }

      if (event == "cast_vote") ImpressionTrack.stash();

      String email = _analyticsServices.tokenStorageEmail;
      String awsTrakingId = _analyticsServices.getAwsTrakingId;

      if (EVENT_WEIGHT_VALUE[event] != null &&
          FirebaseAuth.instance.currentUser != null &&
          email.isNotEmpty) {
        String itemId = params["poll_id"] ?? params["id"];
        double eventValue = EVENT_WEIGHT_VALUE[event]!.toDouble();

        List<String> impressionList = event == "poll_view"
            ? []
            : ImpressionTrack.impressionItemList
                .where((element) => element != itemId)
                .toList();
        // print("AWS: ${RemoteConfigService.awsTrakingId}");
        await personalizeEventsClient.putEvents(
            trackingId: awsTrakingId,
            sessionId: "session-$sessionId",
            eventList: [
              Event(
                  itemId: itemId,
                  eventType: event,
                  sentAt: DateTime.now(),
                  eventValue: eventValue,
                  impression: impressionList.isNotEmpty ? impressionList : null,
                  recommendationId:
                      params["recommendationId"].toString().isNotEmpty
                          ? params["recommendationId"]
                          : null),
            ],
            userId: email);

        if (event != "poll_view") {
          DatadogSdk.instance.logs
              ?.info("AWS Personalised event: $impressionList");
          ImpressionTrack.stash();
        }
        DatadogSdk.instance.logs
            ?.info("AWS record event done $awsTrakingId = $itemId");

        if (doReset) {
          await resendEvents();
          eventStack.clear();
        }
      }
    } catch (err) {
      eventStack.add({
        "event": event,
        "params": params,
      });

      // Limit the stack to a maximum of 10 events.
      if (eventStack.length > 10) {
        eventStack.removeAt(0); // Remove the oldest event.
      }

      log("AWS record event $err");
      DatadogSdk.instance.logs?.info("AWS record event: $err");
    }
  }

  Future<void> resendEvents() async {
    for (final eventItem in eventStack) {
      final event = eventItem["event"];
      final params = eventItem["params"];
      await sendEvent(event, params, doReset: false);
    }
  }
}
