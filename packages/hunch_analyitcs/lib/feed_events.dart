import 'dart:developer';
import 'package:hunch_analyitcs/analytics.dart';
import 'package:hunch_analyitcs/aws_kinesis/aws_kinesis.dart';
import 'package:hunch_analyitcs/aws_kinesis/model/kinesis_event_model.dart';
import 'package:hunch_analyitcs/locator.dart';

//Todo:(Amit) AwsKinesisService..... will add

class FeedEventService {
  final AwsKinesisService _kinesisServices = AwsKinesisService();

  final AnalyticsServices _analyticsServices = locator.get<AnalyticsServices>();

  Future<void> sendEvent(
    event,
    params, {
    doReset = true,
  }) async {
    final userUid = _analyticsServices.currentUserUid;
    try {
      // For impression tracking
      if (event == "poll_view") {
        String userId = userUid, pollId = params["poll_id"];
        await _kinesisServices.pushDataToKinesis(
          KinesisEventModel(
            event: KinesisEvents.pollView.name,
            entityType: KinesisEntityType.user.name,
            entityId: userId,
            targetEntityType: KinesisEntityType.poll.name,
            targetEntityId: pollId,
          ),
        );
        log("Poll View Event Sent $pollId");
      }
    } catch (err) {
      log("FEED Events $err");
    }
  }
}
