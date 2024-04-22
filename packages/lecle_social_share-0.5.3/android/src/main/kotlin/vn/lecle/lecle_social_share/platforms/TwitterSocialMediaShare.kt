package vn.lecle.lecle_social_share.platforms

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodChannel
import vn.lecle.lecle_social_share.services.FileService
import vn.lecle.lecle_social_share.services.StoreService
import java.io.File

const val TWITTER_PACKAGE = "com.twitter.android"

object TwitterSocialMediaShare {
    fun createTwitterTweet(
        context: Activity,
        flutterResult: MethodChannel.Result,
        title: String,
        attachedUrl: String?,
        hashtags: List<String>?,
        via: String?,
        related: List<String>?
    ) {
        val hasPackage = StoreService.isPackageInstalled(context, TWITTER_PACKAGE)
        if (!hasPackage) {
            flutterResult.success(false)
            StoreService.openAppOnStore(context, TWITTER_PACKAGE)
        } else {
            lateinit var sendIntent: Intent
            var urlString = "https://twitter.com/intent/tweet?text=$title"

            if (attachedUrl != null) {
                urlString += "&url=$attachedUrl"
            }
            if (via != null) {
                urlString += "&via=$via"
            }
            if (hashtags != null) {
                val ht = hashtags.joinToString(",")
                urlString += "&hashtags=$ht"
            }
            if (related != null) {
                val re = related.joinToString(",")
                urlString += "&related=$re"
            }

            if (attachedUrl != null || hashtags != null || via != null || related != null) {
                val uri = Uri.parse(urlString)
                sendIntent = Intent(Intent.ACTION_VIEW, uri)
            } else {
                sendIntent = Intent(Intent.ACTION_SEND)
                sendIntent.putExtra(
                    Intent.EXTRA_TEXT,
                    title,
                )
                sendIntent.type = "text/plain"
            }

            sendIntent.setPackage(TWITTER_PACKAGE)
            try {
                context.startActivity(sendIntent)
                flutterResult.success(true)
            } catch (ex: ActivityNotFoundException) {
                flutterResult.error(
                    "FLUTTER_ERROR_RESULT",
                    ex.message,
                    ex
                )
            }
        }
    }

    fun shareFileToTwitter(
        context: Activity,
        flutterResult: MethodChannel.Result,
        filePath: String?,
        dstPath: String?,
        fileProviderPath: String,
        fileType: String,
        title: String?,
    ) {
        filePath?.let {
            val hasPackage = StoreService.isPackageInstalled(context, TWITTER_PACKAGE)
            if (!hasPackage) {
                flutterResult.success(false)
                StoreService.openAppOnStore(context, TWITTER_PACKAGE)
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

                // Define video asset URI
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

                    if (title != null && title.isNotEmpty()) {
                        intent.putExtra(Intent.EXTRA_TEXT, title)
                    }

                    intent.flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
                    intent.setPackage(TWITTER_PACKAGE)

                    // Instantiate activity and verify it will resolve implicit intent
                    if (context.packageManager.resolveActivity(intent, 0) != null) {
                        ContextCompat.startActivity(context, intent, null)
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
}