import 'package:flutter/services.dart';
import 'package:lecle_social_share/lecle_social_share.dart';

class WhatsAppShare {
  /// Method channel to invoke method for the [WhatsAppShare] features
  final MethodChannel _channel = const MethodChannel('lecle_social_share');

  /// Share local file to Telegram platform.
  ///
  /// The method required a local video file path ([filePath]),
  /// a custom file provider path ([fileProviderPath] => use on Android platform) and a [fileType] that you want to share.
  /// Besides, you can provide a [dstPath] (use on Android platform) to add a custom save folder path to cache the local file.
  ///
  /// **NOTE:**
  ///
  /// - Because it is not possible to open WhatsApp directly to share a file on iOS. So the plugin will use the
  /// [UIDocumentInteractionController] in Swift to share the file.
  /// - The [message] property will work only on Android platform because WhatsApp don't have any API
  /// that support to share file and text together on iOS.
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> shareFileToWhatsApp({
    required String? filePath,
    required String fileProviderPath,
    required AssetType fileType,
    String? dstPath,
    String? message,
  }) async {
    String type = AssetType.values[fileType.index].name;

    return _channel.invokeMethod(
      'shareFileWhatsApp',
      <String, dynamic>{
        'filePath': filePath,
        'fileProviderPath': fileProviderPath,
        'fileType': type,
        'dstPath': dstPath,
        'message': message,
      },
    );
  }

  /// Send text message to Telegram method.
  /// The method required a [message] string.
  ///
  /// Besides, you can give the phone number of the people you want to send to [phoneNumber] property
  /// (Android only)
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> sendMessageToWhatsApp({
    required String message,
    String? phoneNumber,
  }) async {
    return _channel.invokeMethod(
      'sendMessageWhatsApp',
      <String, dynamic>{
        'message': message,
        'phoneNumber': phoneNumber,
      },
    );
  }
}
