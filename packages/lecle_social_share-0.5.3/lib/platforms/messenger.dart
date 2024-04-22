import 'package:flutter/services.dart';
import 'package:lecle_social_share/lecle_social_share.dart';

class MessengerShare {
  /// Method channel to invoke method for the [MessengerShare] features
  final MethodChannel _channel = const MethodChannel('lecle_social_share');

  /// Share local file (video or image) to Messenger method.
  ///
  /// The method required a local video file path ([filePath]),
  /// a custom file provider path ([fileProviderPath]) (use on Android platform) and a [fileType] that you want to share.
  /// Besides, you can provide the [dstPath] (use on Android platform) to add a custom save folder path to cache the local file.
  ///
  /// Only [AssetType.video] and [AssetType.image] are supported.
  ///
  /// iOS properties:  [pageId], [peopleIds], [hashtag], etc.
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> shareFileToMessenger({
    required String? filePath,
    required String fileProviderPath,
    required AssetType fileType,
    String? dstPath,
    String? pageId,
    String? ref,
    List<String>? peopleIds,
    String? placeId,
    String? hashtag,
    String? contentUrl,
    String? previewImagePath,
  }) async {
    assert(
      fileType == AssetType.video || fileType == AssetType.image,
      "Only video and image types are supported",
    );

    return _channel.invokeMethod(
      'shareFileMessenger',
      {
        'fileType': fileType.name,
        'filePath': filePath,
        'fileProviderPath': fileProviderPath,
        'dstPath': dstPath,
        'pageId': pageId,
        'ref': ref,
        'peopleIds': peopleIds,
        'placeId': placeId,
        'hashtag': hashtag,
        'contentUrl': contentUrl,
        'previewImagePath': previewImagePath,
      },
    );
  }

  /// Send text message (on Android) and link content (on iOS) to Messenger method.
  /// The method required a [message] string.
  ///
  /// There are some other properties for iOS: [pageId], [peopleIds], [hashtag], etc.
  ///
  /// **NOTE: On iOS a message can only be a link due to Facebook's policy.**
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> sendMessageToMessenger({
    required String message,
    String? pageId,
    String? ref,
    List<String>? peopleIds,
    String? placeId,
    String? hashtag,
    String? quote,
  }) async {
    return _channel.invokeMethod(
      'sendMessageMessenger',
      <String, dynamic>{
        'message': message,
        'pageId': pageId,
        'ref': ref,
        'peopleIds': peopleIds,
        'placeId': placeId,
        'hashtag': hashtag,
        'quote': quote,
      },
    );
  }

  /// Share a link content to Messenger method. You can provide a link of the content
  /// you want to share using [contentUrl] property.
  ///
  /// This method will call the [ShareLinkContent] class from Facebook's SDK to share the link instead of Android Intent
  /// like [sendMessageToMessenger] method. You can use this method or [sendMessageToMessenger] method to share the link you want to Messenger.
  ///
  /// There are some other properties: [pageId], [peopleIds], [hashtag], etc.
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> shareLinkContentToMessenger({
    required String contentUrl,
    String? pageId,
    String? ref,
    List<String>? peopleIds,
    String? placeId,
    String? hashtag,
    String? quote,
  }) async {
    return _channel.invokeMethod(
      'shareLinkContentMessenger',
      <String, dynamic>{
        'pageId': pageId,
        'ref': ref,
        'peopleIds': peopleIds,
        'placeId': placeId,
        'hashtag': hashtag,
        'contentUrl': contentUrl,
        'quote': quote,
      },
    );
  }
}
