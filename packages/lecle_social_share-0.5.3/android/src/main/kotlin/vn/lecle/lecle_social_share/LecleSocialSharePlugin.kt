package vn.lecle.lecle_social_share

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import vn.lecle.lecle_social_share.platforms.*

/** LecleSocialSharePlugin */
class LecleSocialSharePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var activity: Activity

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "lecle_social_share")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val arguments = call.arguments as Map<*, *>

        when (call.method) {
            "shareFileFacebook" -> {
                shareFileToFacebook(arguments, result)
            }
            "shareFeedContentFacebook" -> {
                shareFeedContentToFacebook(arguments, result)
            }
            "shareLinkContentFacebook" -> {
                shareLinkContentToFacebook(arguments, result)
            }
            "shareMediaContentFileFacebook" -> {
                shareMediaContentFileToFacebook(arguments, result)
            }
            "shareCameraEffectToFacebook" -> {
                shareCameraEffectToFacebook(arguments, result)
            }
            "shareBackgroundAssetFileFacebookStory" -> {
                shareBackgroundAssetFileToFacebookStory(arguments, result)
            }
            "shareStickerAssetFacebookStory" -> {
                shareStickerAssetToFacebookStory(arguments, result)
            }
            "shareBitmapImageBackgroundAssetFacebookStory" -> {
                shareBitmapImageBackgroundAssetToFacebookStory(arguments, result)
            }
            "shareImageBackgroundAssetContentFacebookStory" -> {
                shareImageBackgroundAssetContentToFacebookStory(arguments, result)
            }
            "shareVideoBackgroundAssetContentFacebookStory" -> {
                shareVideoBackgroundAssetContentToFacebookStory(arguments, result)
            }
            "shareVideoFacebookReels" -> {
                shareVideoToFacebookReels(arguments, result)
            }
            "shareFileInsta" -> {
                shareFileToInstagram(arguments, result)
            }
            "sendMessageInsta" -> {
                sendMessageToInstagram(arguments, result)
            }
            "shareFileMessenger" -> {
                shareFileToMessenger(arguments, result)
            }
            "sendMessageMessenger" -> {
                sendMessageToMessenger(arguments, result)
            }
            "shareLinkContentMessenger" -> {
                shareLinkContentToMessenger(arguments, result)
            }
            "shareFileTelegram" -> {
                shareFileToTelegram(arguments, result)
            }
            "sendMessageTelegram" -> {
                sendMessageToTelegram(arguments, result)
            }
            "openTelegramDirectMessage" -> {
                openTelegramDirectMessage(arguments, result)
            }
            "openTelegramChannelViaShareLink" -> {
                openTelegramChannelViaShareLink(arguments, result)
            }
            "shareFileWhatsApp" -> {
                shareFileToWhatsApp(arguments, result)
            }
            "sendMessageWhatsApp" -> {
                sendMessageToWhatsApp(arguments, result)
            }
            "createTwitterTweet" -> {
                createTwitterTweet(arguments, result)
            }
            "shareFileTwitter" -> {
                shareFileToTwitter(arguments, result)
            }
            "shareFilesTikTok" -> {
                shareFilesToTikTok(arguments, result)
            }
            "openTikTokUserPage" -> {
                openTikTokUserPage(arguments, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }

    private fun shareFileToFacebook(arguments: Map<*, *>, result: Result) {
        val fileType = arguments["fileType"] as String

        if (fileType == "video") {
            shareVideoToFacebook(arguments, result)
        } else {
            sharePhotoToFacebook(arguments, result)
        }
    }

    private fun shareVideoToFacebook(arguments: Map<*, *>, result: Result) {
        val filePath: String? = arguments["filePath"] as? String
        val dstPath: String? = arguments["dstPath"] as? String
        val fileProviderPath: String = arguments["fileProviderPath"] as String
        val pageId: String? = arguments["pageId"] as? String
        val ref: String? = arguments["ref"] as? String
        val peopleIds: List<String>? = arguments["peopleIds"] as? List<String>
        val placeId: String? = arguments["placeId"] as? String
        val hashtag: String? = arguments["hashtag"] as? String
        val contentTitle: String? = arguments["contentTitle"] as? String
        val contentDescription: String? = arguments["contentDescription"] as? String
        val contentUrl: String? = arguments["contentUrl"] as? String
        val previewImagePath: String? = arguments["previewImagePath"] as? String

        FacebookSocialMediaShare.shareVideoToFacebook(
            activity,
            result,
            filePath,
            fileProviderPath,
            dstPath,
            pageId,
            ref,
            peopleIds,
            placeId,
            hashtag,
            contentUrl,
            previewImagePath,
            contentTitle,
            contentDescription,
        )
    }

    private fun sharePhotoToFacebook(arguments: Map<*, *>, result: Result) {
        val filePath: String? = arguments["filePath"] as? String
        val dstPath: String? = arguments["dstPath"] as? String
        val fileProviderPath: String = arguments["fileProviderPath"] as String
        val pageId: String? = arguments["pageId"] as? String
        val ref: String? = arguments["ref"] as? String
        val peopleIds: List<String>? = arguments["peopleIds"] as? List<String>
        val placeId: String? = arguments["placeId"] as? String
        val hashtag: String? = arguments["hashtag"] as? String
        val contentUrl: String? = arguments["contentUrl"] as? String

        FacebookSocialMediaShare.sharePhotoToFacebook(
            activity,
            result,
            filePath,
            fileProviderPath,
            dstPath,
            pageId,
            ref,
            peopleIds,
            placeId,
            hashtag,
            contentUrl,
        )
    }

    private fun shareFeedContentToFacebook(arguments: Map<*, *>, result: Result) {
        val link: String? = arguments["link"] as? String
        val pageId: String? = arguments["pageId"] as? String
        val ref: String? = arguments["ref"] as? String
        val peopleIds: List<String>? = arguments["peopleIds"] as? List<String>
        val placeId: String? = arguments["placeId"] as? String
        val hashtag: String? = arguments["hashtag"] as? String
        val linkCaption: String? = arguments["linkCaption"] as? String
        val linkName: String? = arguments["linkName"] as? String
        val linkDescription: String? = arguments["linkDescription"] as? String
        val mediaSource: String? = arguments["mediaSource"] as? String
        val picture: String? = arguments["picture"] as? String
        val toId: String? = arguments["toId"] as? String

        FacebookSocialMediaShare.shareFeedContentToFacebook(
            activity,
            result,
            link,
            pageId,
            ref,
            peopleIds,
            placeId,
            hashtag,
            linkCaption,
            linkName,
            linkDescription,
            mediaSource,
            picture,
            toId,
        )
    }

    private fun shareLinkContentToFacebook(arguments: Map<*, *>, result: Result) {
        val pageId: String? = arguments["pageId"] as? String
        val ref: String? = arguments["ref"] as? String
        val peopleIds: List<String>? = arguments["peopleIds"] as? List<String>
        val placeId: String? = arguments["placeId"] as? String
        val hashtag: String? = arguments["hashtag"] as? String
        val contentUrl: String = arguments["contentUrl"] as String
        val quote: String? = arguments["quote"] as? String

        FacebookSocialMediaShare.shareLinkContentToFacebook(
            activity,
            result,
            pageId,
            ref,
            peopleIds,
            placeId,
            hashtag,
            contentUrl,
            quote,
        )
    }

    private fun shareMediaContentFileToFacebook(arguments: Map<*, *>, result: Result) {
        val fileProviderPath: String = arguments["fileProviderPath"] as String
        val pageId: String? = arguments["pageId"] as? String
        val ref: String? = arguments["ref"] as? String
        val peopleIds: List<String>? = arguments["peopleIds"] as? List<String>
        val placeId: String? = arguments["placeId"] as? String
        val hashtag: String? = arguments["hashtag"] as? String
        val contentUrl: String? = arguments["contentUrl"] as? String
        val imageUrls: List<String?>? = arguments["imageUrls"] as? List<String?>
        val videoUrls: List<String?>? = arguments["videoUrls"] as? List<String?>
        val dstPath: String? = arguments["dstPath"] as? String

        FacebookSocialMediaShare.shareMediaContentFileToFacebook(
            activity,
            result,
            fileProviderPath,
            pageId,
            ref,
            peopleIds,
            placeId,
            hashtag,
            contentUrl,
            imageUrls,
            videoUrls,
            dstPath,
        )
    }

    private fun shareCameraEffectToFacebook(arguments: Map<*, *>, result: Result) {
        val cameraEffectTextures = arguments["cameraEffectTextures"] as? Map<*, *>
        val cameraTexturesKey = if (cameraEffectTextures != null) cameraEffectTextures["textureKey"] as String else ""
        val cameraTexturesUrl = if (cameraEffectTextures != null) cameraEffectTextures["textureUrl"] as? String else null

        val cameraEffectArguments = arguments["cameraEffectArguments"] as? Map<*, *>
        val cameraArgumentsKey = if (cameraEffectArguments != null) cameraEffectArguments["argumentKey"] as String else ""
        val cameraArgumentsValue = if (cameraEffectArguments != null) cameraEffectArguments["argumentValue"] as? String else null
        val cameraArgumentsArray = if (cameraEffectArguments != null) cameraEffectArguments["argumentList"] as? Array<String> else null

        val effectId = arguments["effectId"] as? String
        val contentUrl = arguments["contentUrl"] as? String
        val pageId = arguments["pageId"] as? String
        val peopleIds: List<String>? = arguments["peopleIds"] as? List<String>
        val ref: String? = arguments["ref"] as? String
        val placeId: String? = arguments["placeId"] as? String
        val hashtag: String? = arguments["hashtag"] as? String

        FacebookSocialMediaShare.shareCameraEffectToFacebook(
            activity,
            result,
            cameraTexturesKey,
            cameraTexturesUrl,
            cameraArgumentsKey,
            cameraArgumentsValue,
            cameraArgumentsArray,
            effectId,
            contentUrl,
            pageId,
            peopleIds,
            placeId,
            ref,
            hashtag,
        )
    }

    private fun shareBackgroundAssetFileToFacebookStory(arguments: Map<*, *>, result: Result) {
        val filePath = arguments["filePath"] as? String
        val appId = arguments["appId"] as String
        val dstPath = arguments["dstPath"] as? String
        val fileProviderPath = arguments["fileProviderPath"] as String
        val fileType = arguments["fileType"] as String

        FacebookSocialMediaShare.shareBackgroundAssetFileToFacebookStory(
            activity,
            result,
            fileType,
            filePath,
            appId,
            dstPath,
            fileProviderPath
        )
    }

    private fun shareStickerAssetToFacebookStory(arguments: Map<*, *>, result: Result) {
        val stickerPath = arguments["stickerPath"] as? String
        val appId = arguments["appId"] as String
        val fileProviderPath: String = arguments["fileProviderPath"] as String
        val dstPath: String? = arguments["dstPath"] as? String
        val stickerTopBgColors = arguments["stickerTopBgColors"] as? List<*>
        val stickerBottomBgColors = arguments["stickerBottomBgColors"] as? List<*>

        FacebookSocialMediaShare.shareStickerAssetToFacebookStory(
            activity,
            result,
            appId,
            fileProviderPath,
            stickerPath,
            dstPath,
            stickerTopBgColors?.get(0) as? String,
            stickerBottomBgColors?.get(0) as? String,
        )
    }

    private fun shareBitmapImageBackgroundAssetToFacebookStory(arguments: Map<*, *>, result: Result) {
        val imagePath: String? = arguments["imagePath"] as? String
        val dstPath: String? = arguments["dstPath"] as? String
        val fileProviderPath: String = arguments["fileProviderPath"] as String
        val hashtag: String? = arguments["hashtag"] as? String
        val pageId: String? = arguments["pageId"] as? String
        val ref: String? = arguments["ref"] as? String
        val peopleIds: List<String>? = arguments["peopleIds"] as? List<String>
        val placeId: String? = arguments["placeId"] as? String?
        val contentUrl: String? = arguments["contentUrl"] as? String
        val attributionLink: String? = arguments["attributionLink"] as? String
        val backgroundColorList: List<String>? = arguments["peopleIds"] as? List<String>
        val videoBackgroundAssetPath: String? = arguments["videoBackgroundAssetPath"] as? String
        val photoBackgroundAssetPath: String? = arguments["photoBackgroundAssetPath"] as? String
        val stickerPath: String? = arguments["stickerPath"] as? String

        FacebookSocialMediaShare.shareBitmapImageBackgroundAssetToFacebookStory(
            activity,
            result,
            imagePath,
            dstPath,
            fileProviderPath,
            pageId,
            ref,
            peopleIds,
            placeId,
            hashtag,
            contentUrl,
            attributionLink,
            backgroundColorList,
            videoBackgroundAssetPath,
            photoBackgroundAssetPath,
            stickerPath,
        )
    }

    private fun shareImageBackgroundAssetContentToFacebookStory(arguments: Map<*, *>, result: Result) {
        val fileProviderPath: String = arguments["fileProviderPath"] as String
        val hashtag: String? = arguments["hashtag"] as? String
        val pageId: String? = arguments["pageId"] as? String
        val ref: String? = arguments["ref"] as? String
        val peopleIds: List<String>? = arguments["peopleIds"] as? List<String>
        val placeId: String? = arguments["placeId"] as? String?
        val dstPath: String? = arguments["dstPath"] as? String
        val contentUrl: String? = arguments["contentUrl"] as? String
        val attributionLink: String? = arguments["attributionLink"] as? String
        val backgroundColorList: List<String>? = arguments["peopleIds"] as? List<String>
        val photoBackgroundAssetPath: String? = arguments["photoBackgroundAssetPath"] as? String
        val stickerPath: String? = arguments["stickerPath"] as? String

        FacebookSocialMediaShare.shareImageBackgroundAssetContentToFacebookStory(
            activity,
            result,
            dstPath,
            fileProviderPath,
            pageId,
            ref,
            peopleIds,
            placeId,
            hashtag,
            contentUrl,
            attributionLink,
            backgroundColorList,
            photoBackgroundAssetPath,
            stickerPath,
        )
    }

    private fun shareVideoBackgroundAssetContentToFacebookStory(arguments: Map<*, *>, result: Result) {
        val fileProviderPath: String = arguments["fileProviderPath"] as String
        val hashtag: String? = arguments["hashtag"] as? String
        val pageId: String? = arguments["pageId"] as? String
        val ref: String? = arguments["ref"] as? String
        val peopleIds: List<String>? = arguments["peopleIds"] as? List<String>
        val placeId: String? = arguments["placeId"] as? String?
        val dstPath: String? = arguments["dstPath"] as? String
        val contentUrl: String? = arguments["contentUrl"] as? String
        val attributionLink: String? = arguments["attributionLink"] as? String
        val backgroundColorList: List<String>? = arguments["peopleIds"] as? List<String>
        val videoBackgroundAssetPath: String? = arguments["videoBackgroundAssetPath"] as? String
        val stickerPath: String? = arguments["stickerPath"] as? String

        FacebookSocialMediaShare.shareVideoBackgroundAssetContentToFacebookStory(
            activity,
            result,
            dstPath,
            fileProviderPath,
            pageId,
            ref,
            peopleIds,
            placeId,
            hashtag,
            contentUrl,
            attributionLink,
            backgroundColorList,
            videoBackgroundAssetPath,
            stickerPath,
        )
    }

    private fun shareVideoToFacebookReels(arguments: Map<*, *>, result: Result) {
        val filePath: String? = arguments["filePath"] as? String
        val stickerPath: String? = arguments["stickerPath"] as? String
        val appId = arguments["appId"] as String
        val fileProviderPath: String = arguments["fileProviderPath"] as String
        val dstPath: String? = arguments["dstPath"] as? String
        val stickerTopBgColor: String? = arguments["stickerTopBgColor"] as? String
        val stickerBottomBgColor: String? = arguments["stickerBottomBgColor"] as? String

        FacebookSocialMediaShare.shareVideoToFacebookReels(
            activity,
            result,
            filePath,
            stickerPath,
            appId,
            fileProviderPath,
            dstPath,
            stickerTopBgColor,
            stickerBottomBgColor,
        )
    }

    private fun shareFileToInstagram(arguments: Map<*, *>, result: Result) {
        val fileType: String = arguments["fileType"] as String
        val filePath: String? = arguments["filePath"] as? String
        val dstPath: String? = arguments["dstPath"] as? String
        val fileProviderPath: String = arguments["fileProviderPath"] as String

        InstagramSocialMediaShare.shareFileToInstagram(activity, result, fileType, filePath, dstPath, fileProviderPath)
    }

    private fun sendMessageToInstagram(arguments: Map<*, *>, result: Result) {
        val message = arguments["message"] as String

        InstagramSocialMediaShare.sendMessageToInstagram(activity, result, message)
    }

    private fun shareFileToMessenger(arguments: Map<*, *>, result: Result) {
        val fileType = arguments["fileType"] as String
        val filePath = arguments["filePath"] as? String
        val dstPath = arguments["dstPath"] as? String
        val fileProviderPath = arguments["fileProviderPath"] as String

        MessengerSocialMediaShare.shareFileToMessenger(activity, result, fileType, filePath, dstPath, fileProviderPath)
    }

    private fun sendMessageToMessenger(arguments: Map<*, *>, result: Result) {
        val message = arguments["message"] as String

        MessengerSocialMediaShare.sendMessageToMessenger(activity, result, message)
    }

    private fun shareLinkContentToMessenger(arguments: Map<*, *>, result: Result) {
        val pageId: String? = arguments["pageId"] as? String
        val ref: String? = arguments["ref"] as? String
        val peopleIds: List<String>? = arguments["peopleIds"] as? List<String>
        val placeId: String? = arguments["placeId"] as? String
        val hashtag: String? = arguments["hashtag"] as? String
        val contentUrl: String = arguments["contentUrl"] as String
        val quote: String? = arguments["quote"] as? String

        MessengerSocialMediaShare.shareLinkContentToMessenger(
            activity,
            result,
            pageId,
            ref,
            peopleIds,
            placeId,
            hashtag,
            contentUrl,
            quote,
        )
    }

    private fun shareFileToTelegram(arguments: Map<*, *>, result: Result) {
        val filePath = arguments["filePath"] as? String
        val dstPath = arguments["dstPath"] as? String
        val fileProviderPath = arguments["fileProviderPath"] as String
        val fileType = arguments["fileType"] as String
        val message = arguments["message"] as? String

        TelegramSocialMediaShare.shareFileToTelegram(activity, result, filePath, dstPath, fileProviderPath, fileType, message)
    }

    private fun sendMessageToTelegram(arguments: Map<*, *>, result: Result) {
        val message = arguments["message"] as String

        TelegramSocialMediaShare.sendMessageToTelegram(activity, result, message)
    }

    private fun openTelegramDirectMessage(arguments: Map<*, *>, result: Result) {
        val username = arguments["username"] as String

        TelegramSocialMediaShare.openTelegramDirectMessage(activity, result, username)
    }

    private fun openTelegramChannelViaShareLink(arguments: Map<*, *>, result: Result) {
        val inviteLink = arguments["inviteLink"] as String

        TelegramSocialMediaShare.openTelegramChannelViaShareLink(activity, result, inviteLink)
    }

    private fun shareFileToWhatsApp(arguments: Map<*, *>, result: Result) {
        val filePath = arguments["filePath"] as? String
        val fileProviderPath: String = arguments["fileProviderPath"] as String
        val fileType = arguments["fileType"] as String
        val dstPath = arguments["dstPath"] as? String
        val message = arguments["message"] as? String

        WhatsAppSocialMediaShare.shareFileToWhatsApp(
            activity,
            result,
            filePath,
            dstPath,
            fileProviderPath,
            fileType,
            message,
        )
    }

    private fun sendMessageToWhatsApp(arguments: Map<*, *>, result: Result) {
        val message = arguments["message"] as String
        val phoneNumber = arguments["phoneNumber"] as? String

        WhatsAppSocialMediaShare.sendMessageToWhatsApp(
            activity,
            result,
            message,
            phoneNumber
        )
    }

    private fun createTwitterTweet(arguments: Map<*, *>, result: Result) {
        val title = arguments["title"] as String
        val attachedUrl = arguments["attachedUrl"] as? String
        val hashtags = arguments["hashtags"] as? List<String>
        val via = arguments["via"] as? String
        val related = arguments["related"] as? List<String>

        TwitterSocialMediaShare.createTwitterTweet(activity, result, title, attachedUrl, hashtags, via, related)
    }

    private fun shareFileToTwitter(arguments: Map<*, *>, result: Result) {
        val filePath = arguments["filePath"] as? String
        val dstPath = arguments["dstPath"] as? String
        val fileProviderPath = arguments["fileProviderPath"] as String
        val fileType = arguments["fileType"] as String
        val title = arguments["title"] as? String

        TwitterSocialMediaShare.shareFileToTwitter(activity, result, filePath, dstPath, fileProviderPath, fileType, title)
    }

    private fun shareFilesToTikTok(arguments: Map<*, *>, result: Result) {
        val fileUrls = arguments["fileUrls"] as? ArrayList<String?>
        val fileType = arguments["fileType"] as String
        val dstPath = arguments["dstPath"] as? String
        val fileProviderPath = arguments["fileProviderPath"] as String
//        val clientKey = arguments["clientKey"] as String

        TikTokSocialMediaShare.shareFilesToTikTok(
            activity,
            result,
//            clientKey,
            fileType,
            fileUrls,
            fileProviderPath,
            dstPath,
        )
    }

    private fun openTikTokUserPage(arguments: Map<*, *>, result: Result) {
        val username = arguments["username"] as String

        TikTokSocialMediaShare.openTikTokUserPage(activity, result, username)
    }
}
