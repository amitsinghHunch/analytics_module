package vn.lecle.lecle_social_share.platforms

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import androidx.core.content.FileProvider
import com.facebook.CallbackManager
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.share.Sharer
import com.facebook.share.model.ShareHashtag
import com.facebook.share.model.ShareLinkContent
import com.facebook.share.widget.MessageDialog
import io.flutter.plugin.common.MethodChannel
import vn.lecle.lecle_social_share.services.FileService
import vn.lecle.lecle_social_share.services.StoreService
import java.io.File

const val MESSENGER_PACKAGE = "com.facebook.orca"

object MessengerSocialMediaShare {
    fun shareFileToMessenger(
        context: Activity,
        flutterResult: MethodChannel.Result,
        fileType: String,
        filePath: String?,
        dstPath: String?,
        fileProviderPath: String,
    ) {
        filePath?.let {
            val hasPackage = StoreService.isPackageInstalled(context, MESSENGER_PACKAGE)
            if (!hasPackage) {
                flutterResult.success(false)
                StoreService.openAppOnStore(context, MESSENGER_PACKAGE)
            } else {
                val file = File(filePath)
                val storagePath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    context.getExternalFilesDir(dstPath ?: Environment.DIRECTORY_DOCUMENTS)?.absolutePath ?: ""
                } else {
                    Environment.getExternalStorageDirectory().absolutePath + (dstPath ?: "")
                }

                val publicFile = FileService.exportFile(
                    file,
                    File(storagePath)
                )

                // Define file asset URI
                val backgroundAssetUri: Uri?
                if (publicFile != null) {
                    backgroundAssetUri = FileProvider.getUriForFile(
                        context, context.packageName + fileProviderPath,
                        publicFile
                    )
                } else {
                    flutterResult.success(false)
                    return
                }

                if (backgroundAssetUri != null) {
                    val intent = Intent(Intent.ACTION_SEND)
                    intent.type = FileService.resolveFileType(fileType)
                    intent.putExtra(Intent.EXTRA_STREAM, backgroundAssetUri)
                    intent.flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
                    intent.setPackage(MESSENGER_PACKAGE)

                    // Instantiate activity and verify it will resolve implicit intent
                    if (context.packageManager.resolveActivity(intent, 0) != null) {
                        context.startActivity(intent, null)
                    } else {
                        flutterResult.success(false)
                    }
                } else {
                    flutterResult.success(false)
                    return
                }
            }
        }
    }

    fun sendMessageToMessenger(
        context: Activity,
        flutterResult: MethodChannel.Result,
        message: String,
    ) {
        val hasPackage = StoreService.isPackageInstalled(context, MESSENGER_PACKAGE)
        if (!hasPackage) {
            flutterResult.success(false)
            StoreService.openAppOnStore(context, MESSENGER_PACKAGE)
        } else {
            val sendIntent = Intent(Intent.ACTION_SEND)
            sendIntent.putExtra(
                Intent.EXTRA_TEXT,
                message,
            )
            sendIntent.type = "text/plain"
            sendIntent.setPackage(MESSENGER_PACKAGE)
            try {
                context.startActivity(sendIntent, null)
            } catch (ex: ActivityNotFoundException) {
                flutterResult.error(
                    "FLUTTER_ERROR_RESULT",
                    ex.message,
                    ex
                )
            }
        }
    }

    fun shareLinkContentToMessenger(
        context: Activity,
        flutterResult: MethodChannel.Result,
        pageId: String?,
        ref: String?,
        peopleIds: List<String>?,
        placeId: String?,
        hashtag: String?,
        contentUrl: String,
        quote: String?,
    ) {
        val hasPackage = StoreService.isPackageInstalled(context, MESSENGER_PACKAGE)
        if (!hasPackage) {
            flutterResult.success(false)
            StoreService.openAppOnStore(context, MESSENGER_PACKAGE)
        } else {
            val messageDialog = MessageDialog(context)
            val callbackManager = CallbackManager.Factory.create()
            val ht = ShareHashtag.Builder().setHashtag(hashtag).build()
            val content: ShareLinkContent =
                ShareLinkContent.Builder()
                    .setPageId(pageId)
                    .setRef(ref)
                    .setPeopleIds(peopleIds)
                    .setPlaceId(placeId)
                    .setShareHashtag(ht)
                    .setQuote(quote)
                    .setContentUrl(Uri.parse(contentUrl))
                    .build()

            messageDialog.registerCallback(
                callbackManager,
                object : FacebookCallback<Sharer.Result> {
                    override fun onSuccess(result: Sharer.Result) {
                        flutterResult.success(true)
                    }

                    override fun onCancel() {
                        flutterResult.success(false)
                    }

                    override fun onError(error: FacebookException) {
                        flutterResult.error(
                            "FB_SHARE_DIALOG_ERROR",
                            error.localizedMessage,
                            error.stackTrace
                        )
                    }
                },
            )

            if (MessageDialog.canShow(ShareLinkContent::class.java)) {
                messageDialog.show(content)
            } else {
                flutterResult.success(false)
            }
        }
    }
}