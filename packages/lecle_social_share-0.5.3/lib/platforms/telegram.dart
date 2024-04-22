import 'package:flutter/services.dart';
import 'package:lecle_social_share/lecle_social_share.dart';

class TelegramShare {
  /// Method channel to invoke method for the [TelegramShare] features
  final MethodChannel _channel = const MethodChannel('lecle_social_share');

  /// Send text message to Telegram method.
  /// The method required a [message] string.
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> sendMessageToTelegram({
    required String message,
  }) async {
    return _channel.invokeMethod(
      'sendMessageTelegram',
      <String, dynamic>{
        'message': message,
      },
    );
  }

  /// Open a direct message on Telegram app method.
  /// The method required a [username] that you want to send message
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> openTelegramDirectMessage({
    required String username,
  }) async {
    return _channel.invokeMethod(
      'openTelegramDirectMessage',
      <String, dynamic>{
        'username': username,
      },
    );
  }

  /// Open a channel on Telegram app method.
  /// The method required an [inviteLink] of the channel.
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> openTelegramChannelViaShareLink({
    required String inviteLink,
  }) async {
    return _channel.invokeMethod(
      'openTelegramChannelViaShareLink',
      <String, dynamic>{
        'inviteLink': inviteLink,
      },
    );
  }

  /// Share local file to Telegram platform.
  ///
  /// The method required a local video file path ([filePath]),
  /// a custom file provider path ([fileProviderPath] => use on Android platform) and a [fileType] that you want to share.
  /// Besides, you can provide a [dstPath] (use on Android platform) to add a custom save folder path to cache the local file.
  ///
  /// **NOTE: Because there is noway to send a file directly to Telegram on iOS so the method will call the**
  /// **[UIActivityViewController] class on iOS instead and user have to choose Telegram app to share the file.**
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> shareFileToTelegram({
    required String? filePath,
    required String fileProviderPath,
    required AssetType fileType,
    String? dstPath,
    String? message,
  }) async {
    return _channel.invokeMethod(
      'shareFileTelegram',
      <String, dynamic>{
        'filePath': filePath,
        'fileProviderPath': fileProviderPath,
        'dstPath': dstPath,
        'fileType': fileType.name,
        'message': message,
      },
    );
  }
}
