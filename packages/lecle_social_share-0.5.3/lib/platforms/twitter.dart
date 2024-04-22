import 'package:flutter/services.dart';
import 'package:lecle_social_share/lecle_social_share.dart';

class TwitterShare {
  /// Method channel to invoke method for the [TwitterShare] features
  final MethodChannel _channel = const MethodChannel('lecle_social_share');

  /// Create a Twitter tweet on Twitter app method.
  ///
  /// The method required a [title] for the Tweet.
  ///
  /// Besides, you can attach an url using [attachedUrl] property, add hashtags for the Tweet using [hashtags] property,
  /// add accounts related to the content of the shared URI [related] property and attribute the source of a Tweet to a Twitter username
  /// using [via] property.
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> createTwitterTweet({
    required String title,
    String? attachedUrl,
    List<String>? hashtags,
    String? via,
    List<String>? related,
  }) async {
    return _channel.invokeMethod(
      'createTwitterTweet',
      <String, dynamic>{
        'title': title,
        'attachedUrl': attachedUrl,
        'hashtags': hashtags,
        'via': via,
        'related': related,
      },
    );
  }

  /// Share local file to Twitter platform.
  ///
  /// The method required a local video file path ([filePath]),
  /// a custom file provider path ([fileProviderPath] => use on Android platform) and a [fileType] that you want to share.
  /// Besides, you can provide a [dstPath] (use on Android platform) to add a custom save folder path to cache the local file,
  /// [title] to set the message when sharing the file on Android and iOS platforms, etc.
  ///
  /// Only [AssetType.video] and [AssetType.image] are supported.
  ///
  /// **NOTE: If your app support iOS platform please provide the consumer [iOSConsumerKey] and secret key [iOSSecretKey]**
  /// **of your app on [Twitter developer page](https://developer.twitter.com/en/apps)**
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> shareFileToTwitter({
    required String? filePath,
    required String fileProviderPath,
    required AssetType fileType,
    String? dstPath,
    String? iOSConsumerKey,
    String? iOSSecretKey,
    String? title,
  }) async {
    assert(
      fileType == AssetType.video || fileType == AssetType.image,
      "Only video and image types are supported",
    );

    return _channel.invokeMethod(
      'shareFileTwitter',
      <String, dynamic>{
        'filePath': filePath,
        'fileProviderPath': fileProviderPath,
        'dstPath': dstPath,
        'fileType': fileType.name,
        'iOSConsumerKey': iOSConsumerKey,
        'iOSSecretKey': iOSSecretKey,
        'title': title,
      },
    );
  }
}
