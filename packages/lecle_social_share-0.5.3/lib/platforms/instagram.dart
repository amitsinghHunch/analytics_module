import 'package:flutter/services.dart';
import 'package:lecle_social_share/lecle_social_share.dart';

class InstagramShare {
  /// Method channel to invoke method for the [InstagramShare] features
  final MethodChannel _channel = const MethodChannel('lecle_social_share');

  /// Share local file (video or image) to Instagram platform.
  ///
  /// The method required a local video file path ([filePath]),
  /// a custom file provider path ([fileProviderPath] => use on Android platform) and a [fileType] that you want to share.
  /// Besides, you can provide a [dstPath] (use on Android platform) to add a custom save folder path to cache the local file.
  ///
  /// Only [AssetType.video] and [AssetType.image] are supported.
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> shareFileToInstagram({
    required AssetType fileType,
    required String? filePath,
    required String fileProviderPath,
    String? dstPath,
  }) async {
    assert(
      fileType == AssetType.video || fileType == AssetType.image,
      "Only video and image types are supported",
    );

    return _channel.invokeMethod(
      'shareFileInsta',
      {
        'filePath': filePath,
        'fileProviderPath': fileProviderPath,
        'dstPath': dstPath,
        'fileType': fileType.name,
      },
    );
  }

  /// Send text message to Instagram method.
  /// The method required a [message] string.
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> sendMessageToInstagram({
    required String message,
  }) async {
    return _channel.invokeMethod(
      'sendMessageInsta',
      {
        'message': message,
      },
    );
  }
}
