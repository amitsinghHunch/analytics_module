import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer' as developer;

import 'package:aws_kinesis_api/kinesis-2013-12-02.dart';
import 'package:hunch_analyitcs/aws_kinesis/model/kinesis_event_model.dart';
import 'package:flutter_config_plus/flutter_config_plus.dart';

// Access KINESIS Service Via Locator
class AwsKinesisService {
  static late Kinesis kinesisClient;
  static final String awsRegion = FlutterConfigPlus.get('AWS_REGION');
  static final String awsAccessKey = FlutterConfigPlus.get('AWS_ACCESS_KEY');
  static final String awsSecretKey = FlutterConfigPlus.get('AWS_SECRET_KEY');
  static final String kinesisStreamName =
      FlutterConfigPlus.get('KINESIS_STREAM_NAME');

  // Initialize Kinesis Client
  AwsKinesisService() {
    init();
  }

  static Future<void> init() async {
    kinesisClient = Kinesis(
        region: awsRegion,
        credentials: AwsClientCredentials(
          accessKey: awsAccessKey,
          secretKey: awsSecretKey,
        ));
  }

  Future<void> pushDataToKinesis(KinesisEventModel payload) async {
    try {
      await kinesisClient.putRecord(
        data: Uint8List.fromList(jsonEncode(payload.toJson()).codeUnits),
        partitionKey: payload.event,
        streamName: kinesisStreamName,
      );
      developer.log("kinesis record sent");
    } catch (err) {
      developer.log("kinesis error $err");
    }
  }
}
