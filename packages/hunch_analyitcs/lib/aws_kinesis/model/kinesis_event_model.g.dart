// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kinesis_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KinesisEventModel _$KinesisEventModelFromJson(Map<String, dynamic> json) =>
    KinesisEventModel(
      event: json['event'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      targetEntityType: json['targetEntityType'] as String,
      targetEntityId: json['targetEntityId'] as String,
    );

Map<String, dynamic> _$KinesisEventModelToJson(KinesisEventModel instance) =>
    <String, dynamic>{
      'event': instance.event,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'targetEntityType': instance.targetEntityType,
      'targetEntityId': instance.targetEntityId,
    };
