import 'package:flutter/services.dart';
import 'package:lecle_social_share/lecle_social_share.dart';

class TikTokShare {
  /// Method channel to invoke method for the [TwitterShare] features
  final MethodChannel _channel = const MethodChannel('lecle_social_share');

  /// Share local files (videos or images) to TikTok method.
  ///
  /// The method required a list of local file paths ([fileUrls]) and
  /// a custom file provider path ([fileProviderPath] => use on Android platform) to access the local file.
  /// Besides, you can provide a [dstPath] (Android platform) to add a custom save folder path to cache the local file,
  /// and there are some other properties [shareFormat], [landedPageType], [hashtag], etc.
  ///
  /// Only [AssetType.video] and [AssetType.image] are supported.
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> shareFilesToTikTok({
    required List<String?>? fileUrls,
    required String fileProviderPath,
    required AssetType fileType,
    String? dstPath,
    TikTokShareFormatType shareFormat = TikTokShareFormatType.normal,
    TikTokLandedPageType landedPageType = TikTokLandedPageType.clip,
    List<String>? hashtag,
    // String? clientKey,
    // String? clientSecret,
  }) async {
    assert(
      fileType == AssetType.video || fileType == AssetType.image,
      "Only video and image types are supported",
    );

    return _channel.invokeMethod(
      'shareFilesTikTok',
      {
        'fileUrls': fileUrls,
        'fileProviderPath': fileProviderPath,
        'fileType': fileType.name,
        'dstPath': dstPath,
        'shareFormat': shareFormat.name,
        'landedPageType': landedPageType.name,
        'hashtag': hashtag,
        // 'clientKey': clientKey,
        // 'clientSecret': clientSecret,
      },
    );
  }

  /// Open a user page on TikTok app method.
  /// The method required a [username] that you want to open their TikTok page.
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> openTikTokUserPage({
    required String username,
  }) async {
    if (username.contains('@')) {
      username = username.replaceAll('@', '');
    }

    return _channel.invokeMethod(
      'openTikTokUserPage',
      {
        'username': '@$username',
      },
    );
  }
}
