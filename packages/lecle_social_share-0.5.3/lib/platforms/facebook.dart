import 'package:flutter/services.dart';
import 'package:lecle_social_share/lecle_social_share.dart';
import 'package:lecle_social_share/models/models.dart';

class FacebookShare {
  /// Method channel to invoke method for the [FacebookShare] features
  final MethodChannel _channel = const MethodChannel('lecle_social_share');

  /// Share local file (video or image) to Facebook method. This method is merged from
  /// [shareVideoToFacebook] and [sharePhotoToFacebook] methods.
  ///
  /// The method required a local video file path ([filePath]) and
  /// a custom file provider path ([fileProviderPath] => use on Android platform) to access the local file.
  /// Besides, you can provide a [dstPath] (Android platform) to add a custom save folder path to cache the local file,
  /// and there are some other properties [pageId], [peopleIds], [hashtag], etc.
  ///
  /// Only [AssetType.video] and [AssetType.image] are supported.
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> shareFileToFacebook({
    required AssetType fileType,
    required String? filePath,
    required String fileProviderPath,
    String? dstPath,
    String? pageId,
    String? ref,
    List<String>? peopleIds,
    String? placeId,
    String? hashtag,
    String? contentUrl,
    String? contentTitle,
    String? contentDescription,
    String? previewImagePath,
  }) async {
    assert(
      fileType == AssetType.video || fileType == AssetType.image,
      "Only video and image types are supported",
    );

    return _channel.invokeMethod(
      'shareFileFacebook',
      {
        'fileType': fileType.name,
        'filePath': filePath,
        'dstPath': dstPath,
        'fileProviderPath': fileProviderPath,
        'pageId': pageId,
        'ref': ref,
        'peopleIds': peopleIds,
        'placeId': placeId,
        'hashtag': hashtag,
        'contentUrl': contentUrl,
        'contentTitle': contentTitle,
        'contentDescription': contentDescription,
        'previewImagePath': previewImagePath,
      },
    );
  }

  /// Share a content to your Facebook feed method. You can provide a link ([link]) of the content you want to share
  ///
  /// There are some other properties [pageId], [peopleIds], [hashtag], etc.
  /// The properties [linkCaption], [linkName], [linkDescription], [mediaSource], [picture], and [toId]
  /// are available on Android platform
  ///
  /// [quote] property is use for iOS platform.
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> shareFeedContentToFacebook({
    String? link,
    String? pageId,
    String? ref,
    List<String>? peopleIds,
    String? placeId,
    String? hashtag,
    String? quote,
    String? linkCaption,
    String? linkName,
    String? linkDescription,
    String? mediaSource,
    String? picture,
    String? toId,
  }) async {
    return _channel.invokeMethod(
      'shareFeedContentFacebook',
      <String, dynamic>{
        'link': link,
        'pageId': pageId,
        'ref': ref,
        'peopleIds': peopleIds,
        'placeId': placeId,
        'hashtag': hashtag,
        'linkCaption': linkCaption,
        'linkName': linkName,
        'linkDescription': linkDescription,
        'mediaSource': mediaSource,
        'picture': picture,
        'toId': toId,
        'quote': quote,
      },
    );
  }

  /// Share a link content to your Facebook feed method. You can provide a link of the content
  /// you want to share using [contentUrl] property.
  ///
  /// There are some other properties [pageId], [peopleIds], [hashtag], etc.
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> shareLinkContentToFacebook({
    String? contentUrl,
    String? pageId,
    String? ref,
    List<String>? peopleIds,
    String? placeId,
    String? hashtag,
    String? quote,
  }) async {
    if (contentUrl != null && !Uri.parse(contentUrl).isAbsolute) {
      return 'This is an invalid URL!';
    }

    return _channel.invokeMethod(
      'shareLinkContentFacebook',
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

  /// Share local images and videos to Facebook method. The method required the local video ([videoUrls]) and image ([imageUrls]) file paths
  /// and your custom file provider path [fileProviderPath] (use on Android platform) to access the local file.
  ///
  /// Besides, you can provide a [dstPath] (Android platform) to add the custom save folder path to cache the local file,
  /// and there are some other properties [pageId], [peopleIds], [hashtag], etc.
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> shareMediaContentFileToFacebook({
    required String fileProviderPath,
    List<String?>? videoUrls,
    List<String?>? imageUrls,
    String? dstPath,
    String? pageId,
    String? ref,
    List<String>? peopleIds,
    String? placeId,
    String? hashtag,
    String? contentUrl,
  }) async {
    assert(
      imageUrls != null || videoUrls != null,
      "Please provide at least one video list or one image list",
    );

    return _channel.invokeMethod(
      'shareMediaContentFileFacebook',
      <String, dynamic>{
        'dstPath': dstPath,
        'fileProviderPath': fileProviderPath,
        'pageId': pageId,
        'ref': ref,
        'peopleIds': peopleIds,
        'placeId': placeId,
        'hashtag': hashtag,
        'contentUrl': contentUrl,
        'imageUrls': imageUrls,
        'videoUrls': videoUrls,
      },
    );
  }

  /// Share local file to Facebook story method. The method required the local image ([imagePath]) file path,
  /// your Facebook app id ([appId]) and your custom file provider path ([fileProviderPath])
  /// to access the local file on Android platform.
  ///
  /// Besides, you can provide a [dstPath] to add the custom save folder path to cache the local file.
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> shareBackgroundAssetFileToFacebookStory({
    required String? filePath,
    required String appId,
    required String fileProviderPath,
    required AssetType fileType,
    String? dstPath,
  }) async {
    assert(
      fileType == AssetType.video || fileType == AssetType.image,
      "Only video and image types are supported",
    );

    return _channel.invokeMethod(
      'shareBackgroundAssetFileFacebookStory',
      {
        'fileType': fileType.name,
        'filePath': filePath,
        'appId': appId,
        'fileProviderPath': fileProviderPath,
        'dstPath': dstPath,
      },
    );
  }

  /// Share local sticker image to Facebook story method. The method required the local sticker image ([stickerPath]) file path,
  /// your Facebook app id ([appId]) and your custom file provider path ([fileProviderPath])
  /// to access the local file on Android platform.
  ///
  /// Besides, you can provide a [dstPath] to add the custom save folder path to cache the local file,
  /// the sticker top and bottom colors [stickerTopBgColors], [stickerBottomBgColors] (dedault color is #222222)
  ///
  /// **NOTE: On Android platform only a single color can be use for top and bottom of the sticker so the plugin will get the first color of the list on Android platform**
  ///
  /// Example with color:
  /// ``` dart
  /// LecleSocialShare.shareStickerAssetToFacebookStory(
  ///   appId: 'your_facebook_app_id',
  ///   stickerPath: 'your_image_path',
  ///   stickerTopBgColors: ['#33FF33'],
  ///   stickerBottomBgColors: ['#FF00FF'],
  ///   dstPath: 'your_custom_save_folder_path',
  ///   fileProviderPath: 'your_custom_fileProvider_path',
  /// )
  /// ```
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> shareStickerAssetToFacebookStory({
    required String appId,
    required String fileProviderPath,
    required String? stickerPath,
    String? dstPath,
    List<String>? stickerTopBgColors,
    List<String>? stickerBottomBgColors,
  }) async {
    return _channel.invokeMethod(
      'shareStickerAssetFacebookStory',
      <String, dynamic>{
        'appId': appId,
        'fileProviderPath': fileProviderPath,
        'stickerPath': stickerPath,
        'dstPath': dstPath,
        'stickerTopBgColors': stickerTopBgColors,
        'stickerBottomBgColors': stickerBottomBgColors,
      },
    );
  }

  /// Share local image bitmap to Facebook story method using [ShareStoryContent] class from Facebook share SDK.
  ///
  /// However, [ShareStoryContent] class is not working now so please use
  /// [shareBackgroundAssetFileToFacebookStory] or [shareStickerAssetToFacebookStory]
  /// methods instead.
  ///
  /// The method required the local image ([imagePath]) file path, and your custom file provider path ([fileProviderPath])
  /// to access the local file.
  ///
  /// Besides, you can provide a [dstPath] to add the custom save folder path to cache the local file
  /// and some other properties
  ///
  /// [videoBackgroundAssetPath], [photoBackgroundAssetPath] to set the background asset for the image [imagePath] file (video or photo)
  ///
  /// [stickerPath] to set the sticker asset for the [imagePath] file
  ///
  /// [backgroundColorList] the colors can be define the same format in
  /// [shareStickerAssetToFacebookStory] method example ([#33FF33]), etc.
  ///
  /// Working on: Android platform.
  Future<dynamic> shareBitmapImageBackgroundAssetToFacebookStory({
    required String fileProviderPath,
    required String? imagePath,
    String? dstPath,
    String? pageId,
    String? ref,
    List<String>? peopleIds,
    String? placeId,
    String? hashtag,
    String? contentUrl,
    String? attributionLink,
    List<String>? backgroundColorList,
    String? videoBackgroundAssetPath,
    String? photoBackgroundAssetPath,
    String? stickerPath,
  }) async {
    return _channel.invokeMethod(
      'shareBitmapImageBackgroundAssetFacebookStory',
      <String, dynamic>{
        'imagePath': imagePath,
        'fileProviderPath': fileProviderPath,
        'dstPath': dstPath,
        'hashtag': hashtag,
        'pageId': pageId,
        'ref': ref,
        'peopleIds': peopleIds,
        'placeId': placeId,
        'contentUrl': contentUrl,
        'attributionLink': attributionLink,
        'backgroundColorList': backgroundColorList,
        'videoBackgroundAssetPath': videoBackgroundAssetPath,
        'photoBackgroundAssetPath': photoBackgroundAssetPath,
        'stickerPath': stickerPath,
      },
    );
  }

  /// Share local image to Facebook story method using [ShareStoryContent] class from Facebook share SDK.
  ///
  /// However, [ShareStoryContent] class is not working now so please use
  /// [shareBackgroundAssetFileToFacebookStory] or [shareStickerAssetToFacebookStory]
  /// methods instead.
  ///
  /// The method required the local image ([photoBackgroundAssetPath]) file path, and your custom
  /// file provider path ([fileProviderPath]) to access the local file.
  ///
  /// Besides, you can provide a [dstPath] to add the custom save folder path to cache the local file
  /// and some other properties
  ///
  /// [stickerPath] to set the sticker asset for the image [photoBackgroundAssetPath] file
  ///
  /// [backgroundColorList] the colors can be define the same format in
  /// [shareStickerAssetToFacebookStory] method example ([#33FF33]), etc.
  ///
  /// Working on: Android platform.
  Future<dynamic> shareImageBackgroundAssetContentToFacebookStory({
    required String fileProviderPath,
    required String? photoBackgroundAssetPath,
    String? dstPath,
    String? pageId,
    String? ref,
    List<String>? peopleIds,
    String? placeId,
    String? hashtag,
    String? contentUrl,
    String? attributionLink,
    List<String>? backgroundColorList,
    String? stickerPath,
  }) async {
    return _channel.invokeMethod(
      'shareImageBackgroundAssetContentFacebookStory',
      <String, dynamic>{
        'dstPath': dstPath,
        'fileProviderPath': fileProviderPath,
        'hashtag': hashtag,
        'pageId': pageId,
        'ref': ref,
        'peopleIds': peopleIds,
        'placeId': placeId,
        'contentUrl': contentUrl,
        'attributionLink': attributionLink,
        'backgroundColorList': backgroundColorList,
        'photoBackgroundAssetPath': photoBackgroundAssetPath,
        'stickerPath': stickerPath,
      },
    );
  }

  /// Share local video to Facebook story method using [ShareStoryContent] class from Facebook share SDK.
  /// However, [ShareStoryContent] class is not working now so please use
  /// [shareBackgroundAssetFileToFacebookStory] method instead.
  ///
  /// The method required the local video ([videoBackgroundAssetPath]) file path, and your custom
  /// file provider path ([fileProviderPath]) to access the local file.
  /// Besides, you can provide a [dstPath] to add the custom save folder path to cache the local file.
  ///
  /// **Some other properties:**
  ///
  /// + [stickerPath] to set the sticker asset for the video [videoBackgroundAssetPath] file
  ///
  /// + [backgroundColorList] the colors can be define the same format in
  /// [shareStickerAssetToFacebookStory] method example ([#33FF33]), etc.
  ///
  /// Working on: Android platform.
  Future<dynamic> shareVideoBackgroundAssetContentToFacebookStory({
    required String fileProviderPath,
    required String? videoBackgroundAssetPath,
    String? dstPath,
    String? pageId,
    String? ref,
    List<String>? peopleIds,
    String? placeId,
    String? hashtag,
    String? contentUrl,
    String? attributionLink,
    List<String>? backgroundColorList,
    String? stickerPath,
  }) async {
    return _channel.invokeMethod(
      'shareVideoBackgroundAssetContentFacebookStory',
      <String, dynamic>{
        'dstPath': dstPath,
        'fileProviderPath': fileProviderPath,
        'hashtag': hashtag,
        'pageId': pageId,
        'ref': ref,
        'peopleIds': peopleIds,
        'placeId': placeId,
        'contentUrl': contentUrl,
        'attributionLink': attributionLink,
        'backgroundColorList': backgroundColorList,
        'videoBackgroundAssetPath': videoBackgroundAssetPath,
        'stickerPath': stickerPath,
      },
    );
  }

  /// Share local video to Facebook reels method.
  ///
  /// The method required a local video ([filePath]) file path,
  /// a Facebook app id ([appId]), and a custom file provider path ([fileProviderPath] => use on Android platform)
  /// to access the local file.
  ///
  /// Besides, you can provide a [dstPath] to add a custom save folder path to cache the local file,
  /// sticker's top and bottom colors ([stickerTopBgColor], [stickerBottomBgColor]) =>
  /// Default color is **#222222**, and [stickerPath] to set the sticker asset for the video file.
  ///
  /// **Example with color:**
  /// ``` dart
  /// LecleSocialShare.shareVideoToFacebookReelsAndroid(
  ///   appId: 'your_facebook_app_id',
  ///   filePath: 'your_image_file_path',
  ///   stickerTopBgColor: '#33FF33',
  ///   stickerBottomBgColor: '#FF00FF',
  ///   dstPath: 'your_custom_save_folder_path',
  ///   fileProviderPath: 'your_custom_fileProvider_path',
  ///   stickerPath: 'your_sticker_file_path'
  /// )
  /// ```
  ///
  /// Working on: Android platform.
  Future<dynamic> shareVideoToFacebookReels({
    required String? filePath,
    required String appId,
    required String fileProviderPath,
    String? dstPath,
    String? stickerPath,
    String? stickerTopBgColor,
    String? stickerBottomBgColor,
  }) async {
    return _channel.invokeMethod(
      'shareVideoFacebookReels',
      <String, dynamic>{
        'filePath': filePath,
        'stickerPath': stickerPath,
        'appId': appId,
        'fileProviderPath': fileProviderPath,
        'dstPath': dstPath,
        'stickerTopBgColor': stickerTopBgColor,
        'stickerBottomBgColor': stickerBottomBgColor,
      },
    );
  }

  /// Share multiple local stickers and images to Facebook story on iOS platform method.
  ///
  /// The method required the list of the local image and sticker paths ([photoBackgroundAssetPaths], [stickerAssetPaths])
  /// and your Facebook app id ([appId])
  ///
  /// Besides, you can provide the sticker top and bottom colors [backgroundTopColor], [backgroundBottomColor]
  /// (dedault color is #222222)
  ///
  /// Example with color:
  /// ``` dart
  /// LecleSocialShare.shareBackgroundImageAndStickerToFacebookStoryiOS(
  ///   appId: 'your_facebook_app_id',
  ///   photoBackgroundAssetPaths: ['your_image_paths'],
  ///   stickerAssetPaths: ['your_sticker_paths'],
  ///   backgroundTopColor: '#33FF33',
  ///   backgroundBottomColor: '#FF00FF',
  /// )
  /// ```
  ///
  /// Working on: iOS platform.
  Future<dynamic> shareBackgroundImageAndStickerToFacebookStoryiOS({
    required String appId,
    required List<String?>? photoBackgroundAssetPaths,
    required List<String?>? stickerAssetPaths,
    List<String>? backgroundTopColor,
    List<String>? backgroundBottomColor,
  }) async {
    return _channel.invokeMethod(
      'shareBackgroundImageAndStickerFacebookStoryiOS',
      <String, dynamic>{
        'appId': appId,
        'photoBackgroundAssetPaths': photoBackgroundAssetPaths,
        'stickerAssetPaths': stickerAssetPaths,
        'backgroundTopColor': backgroundTopColor,
        'backgroundBottomColor': backgroundBottomColor,
      },
    );
  }

  /// Share a Camera Effect to Facebook method.
  /// You have to provide data for [cameraEffectTextures] or [cameraEffectArguments] property to use this method.
  ///
  /// You can read the comment for the properties in the [CameraEffectTextures] and [CameraEffectArguments] classes
  /// to know what are their properties use for.
  ///
  /// For more information about Camera Effect platform of Facebook, you can follow this
  /// [link](https://developers.facebook.com/blog/post/2017/04/18/Introducing-Camera-Effects-Platform/).
  ///
  /// Working on: Android and iOS platforms.
  Future<dynamic> shareCameraEffectToFacebook({
    CameraEffectTextures? cameraEffectTextures,
    CameraEffectArguments? cameraEffectArguments,
    String? effectId,
    String? contentUrl,
    String? pageId,
    List<String>? peopleIds,
    String? placeId,
    String? ref,
    String? hashtag,
  }) async {
    assert(cameraEffectArguments != null || cameraEffectTextures != null);

    return _channel.invokeMethod(
      'shareCameraEffectToFacebook',
      <String, dynamic>{
        'cameraEffectTextures': cameraEffectTextures?.toJson(),
        'cameraEffectArguments': cameraEffectArguments?.toJson(),
        'effectId': effectId,
        'contentUrl': contentUrl,
        'pageId': pageId,
        'peopleIds': peopleIds,
        'placeId': placeId,
        'ref': ref,
        'hashtag': hashtag,
      },
    );
  }
}
