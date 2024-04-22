package vn.lecle.lecle_social_share.platforms

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.net.Uri
import android.os.Build
import android.os.Environment
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodChannel
import vn.lecle.lecle_social_share.services.FileService
import vn.lecle.lecle_social_share.services.StoreService
import java.io.File

const val INSTAGRAM_PACKAGE = "com.instagram.android"
const val INSTAGRAM_REQUEST_CODE = 1234

object InstagramSocialMediaShare {
    fun shareFileToInstagram(
        context: Activity,
        flutterResult: MethodChannel.Result,
        fileType: String,
        filePath: String?,
        dstPath: String?,
        fileProviderPath: String,
    ) {
        filePath?.let {
            val hasPackage = StoreService.isPackageInstalled(context, INSTAGRAM_PACKAGE)
            if (!hasPackage) {
                flutterResult.success(false)
                StoreService.openAppOnStore(context, INSTAGRAM_PACKAGE)
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

                val uri: Uri?
                if (publicFile != null) {
                    uri = FileProvider.getUriForFile(
                        context, context.packageName + fileProviderPath,
                        publicFile
                    )
                } else {
                    flutterResult.success(false)
                    return
                }

                val share = Intent(Intent.ACTION_SEND)
                share.type = FileService.resolveFileType(fileType)
                share.putExtra(Intent.EXTRA_STREAM, uri)
                share.setPackage(INSTAGRAM_PACKAGE)
                share.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

                val chooser = Intent.createChooser(share, "Share to")
                val resInfoList: List<ResolveInfo> =
                    context.packageManager.queryIntentActivities(
                        chooser,
                        PackageManager.MATCH_DEFAULT_ONLY
                    )

                for (resolveInfo in resInfoList) {
                    val packageName: String = resolveInfo.activityInfo.packageName
                    context.grantUriPermission(
                        packageName,
                        uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION
                    )
                }

                context.startActivityForResult(chooser, INSTAGRAM_REQUEST_CODE)
                flutterResult.success(true)
            }
        }
    }

    fun sendMessageToInstagram(
        context: Activity,
        flutterResult: MethodChannel.Result,
        message: String,
    ) {
        val hasPackage = StoreService.isPackageInstalled(context, INSTAGRAM_PACKAGE)
        if (!hasPackage) {
            flutterResult.success(false)
            StoreService.openAppOnStore(context, INSTAGRAM_PACKAGE)
        } else {
            val sendIntent = Intent(Intent.ACTION_SEND)
            sendIntent.putExtra(
                Intent.EXTRA_TEXT,
                message,
            )
            sendIntent.type = "text/plain"
            sendIntent.setPackage(INSTAGRAM_PACKAGE)
            try {
                context.startActivity(sendIntent, null)
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