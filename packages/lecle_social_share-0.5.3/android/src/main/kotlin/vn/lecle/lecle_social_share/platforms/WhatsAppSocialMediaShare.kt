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

const val WHATSAPP_PACKAGE = "com.whatsapp"

object WhatsAppSocialMediaShare {
    fun shareFileToWhatsApp(
        context: Activity,
        flutterResult: MethodChannel.Result,
        filePath: String?,
        dstPath: String?,
        fileProviderPath: String,
        fileType: String,
        message: String?,
    ) {
        filePath?.let {
            val hasPackage = StoreService.isPackageInstalled(context, WHATSAPP_PACKAGE)
            if (!hasPackage) {
                flutterResult.success(false)
                StoreService.openAppOnStore(context, WHATSAPP_PACKAGE)
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

                    if (message != null && message.isNotEmpty()) {
                        intent.putExtra(Intent.EXTRA_TEXT, message)
                    }

                    intent.flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
                    intent.setPackage(WHATSAPP_PACKAGE)

                    // Instantiate activity and verify it will resolve implicit intent
                    if (context.packageManager.resolveActivity(intent, 0) != null) {
                        ContextCompat.startActivity(context, intent, null)
                        flutterResult.success(false)
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

    fun sendMessageToWhatsApp(
        context: Activity,
        flutterResult: MethodChannel.Result,
        message: String,
        phoneNumber: String?,
    ) {
        val hasPackage = StoreService.isPackageInstalled(context, WHATSAPP_PACKAGE)
        if (!hasPackage) {
            flutterResult.success(false)
            StoreService.openAppOnStore(context, WHATSAPP_PACKAGE)
        } else {
            lateinit var sendIntent: Intent

            if (phoneNumber != null) {
                val uri = Uri.parse("https://api.whatsapp.com/send?phone=$phoneNumber&text=$message")
                sendIntent = Intent(Intent.ACTION_VIEW, uri)
            } else {
                sendIntent = Intent(Intent.ACTION_SEND)
                sendIntent.putExtra(
                    Intent.EXTRA_TEXT,
                    message,
                )
                sendIntent.type = "text/plain"
            }

            sendIntent.setPackage(WHATSAPP_PACKAGE)
            flutterResult.success(true)
            try {
                ContextCompat.startActivity(context, sendIntent, null)
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
}