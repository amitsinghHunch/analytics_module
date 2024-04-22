import 'package:json_annotation/json_annotation.dart';

part 'kinesis_event_model.g.dart';

@JsonSerializable()
class KinesisEventModel {
  final String event;
  final String entityType;
  final String entityId;
  final String targetEntityType;
  final String targetEntityId;

  KinesisEventModel({
    required this.event,
    required this.entityType,
    required this.entityId,
    required this.targetEntityType,
    required this.targetEntityId,
  });

  factory KinesisEventModel.fromJson(Map<String, dynamic> json) =>
      _$KinesisEventModelFromJson(json);

  Map<String, dynamic> toJson() => _$KinesisEventModelToJson(this);
}

enum KinesisEntityType { user, hotTake, poll }

enum KinesisEvents { hotTakeView, pollShare, pollView, pollViewCount }
