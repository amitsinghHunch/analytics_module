package vn.lecle.lecle_social_share.platforms

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import androidx.core.content.FileProvider
import com.bytedance.sdk.open.tiktok.TikTokOpenApiFactory
import com.bytedance.sdk.open.tiktok.TikTokOpenConfig
import com.bytedance.sdk.open.tiktok.api.TikTokOpenApi
import com.bytedance.sdk.open.tiktok.base.*
import com.bytedance.sdk.open.tiktok.common.constants.ParamKeyConstants.TargetSceneType
import com.bytedance.sdk.open.tiktok.share.Share
import io.flutter.plugin.common.MethodChannel
import vn.lecle.lecle_social_share.services.FileService
import vn.lecle.lecle_social_share.services.StoreService
import java.io.File


const val TIKTOK_M_PACKAGE = "com.zhiliaoapp.musically"
const val TIKTOK_T_PACKAGE = "com.ss.android.ugc.trill"

object TikTokSocialMediaShare {
    fun shareFilesToTikTok(
        context: Activity,
        flutterResult: MethodChannel.Result,
//        clientKey: String,
        fileType: String,
        fileUrls: List<String?>?,
        fileProviderPath: String,
        dstPath: String?,
    ) {
        fileUrls?.let {
            val hasPackage = StoreService.isPackageInstalled(context, TIKTOK_T_PACKAGE)
            if (!hasPackage) {
                flutterResult.success(false)
                StoreService.openAppOnStore(context, TIKTOK_T_PACKAGE)
            } else {
//                TikTokOpenApiFactory.init(TikTokOpenConfig(clientKey))
                val shareFiles = ArrayList<Uri>()

                if (fileUrls.isNotEmpty()) {
                    for (fileUrl in fileUrls) {
                        val file = File(fileUrl ?: "")
                        val storagePath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            context.getExternalFilesDir(dstPath ?: Environment.DIRECTORY_DOCUMENTS)?.absolutePath ?: ""
                        } else {
                            Environment.getExternalStorageDirectory().absolutePath + (dstPath ?: "")
                        }

                        val publicFile = FileService.exportFile(
                            file,
                            File(storagePath)
                        )

                        var uri: Uri?
                        if (publicFile != null) {
                            uri = FileProvider.getUriForFile(
                                context, context.packageName + fileProviderPath,
                                publicFile
                            )

                            shareFiles.add(uri)

//                                context.grantUriPermission(
//                                    TIKTOK_M_PACKAGE,
//                                    uri, Intent.FLAG_GRANT_READ_URI_PERMISSION
//                                )
                            context.grantUriPermission(
                                TIKTOK_T_PACKAGE,
                                uri, Intent.FLAG_GRANT_READ_URI_PERMISSION
                            )
                        }
                    }

                    val shareIntent = Intent()
                    shareIntent.action = Intent.ACTION_SEND_MULTIPLE
                    shareIntent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, shareFiles)
                    shareIntent.type = FileService.resolveFileType(fileType)

                    context.startActivity(Intent.createChooser(shareIntent, "Share to"))
                } else {
                    flutterResult.success(false)
                }
            }
        }
    }

    fun shareFilesToTikTokTemp(
        context: Activity,
        flutterResult: MethodChannel.Result,
        clientKey: String,
        fileType: String,
        shareFormat: String,
        landedPageType: String,
        fileUrls: List<String?>?,
        fileProviderPath: String,
        dstPath: String?,
        hashtag: ArrayList<String>?,
    ) {
        fileUrls?.let {
            val hasPackage = StoreService.isPackageInstalled(context, TIKTOK_T_PACKAGE)
            if (!hasPackage) {
                flutterResult.success(false)
                StoreService.openAppOnStore(context, TIKTOK_T_PACKAGE)
            } else {
                TikTokOpenApiFactory.init(TikTokOpenConfig(clientKey))

                val tiktokOpenApi: TikTokOpenApi = TikTokOpenApiFactory.create(context)
                val request = Share.Request()
                val shareFiles: ArrayList<String> = ArrayList()
                val mediaContent = MediaContent()
                val imageObject = ImageObject()
                val videoObject = VideoObject()

                if (fileUrls.isNotEmpty()) {
                    for (fileUrl in fileUrls) {
                        val file = File(fileUrl ?: "")
                        val storagePath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            context.getExternalFilesDir(dstPath ?: Environment.DIRECTORY_DOCUMENTS)?.absolutePath ?: ""
                        } else {
                            Environment.getExternalStorageDirectory().absolutePath + (dstPath ?: "")
                        }

                        val publicFile = FileService.exportFile(
                            file,
                            File(storagePath)
                        )

                        var uri: Uri?
                        if (publicFile != null) {
                            uri = FileProvider.getUriForFile(
                                context, context.packageName + fileProviderPath,
                                publicFile
                            )

                            if (uri.path != null) {
                                shareFiles.add(uri.path!!)
                            }

//                                context.grantUriPermission(
//                                    TIKTOK_M_PACKAGE,
//                                    uri, Intent.FLAG_GRANT_READ_URI_PERMISSION
//                                )
                            context.grantUriPermission(
                                TIKTOK_T_PACKAGE,
                                uri, Intent.FLAG_GRANT_READ_URI_PERMISSION
                            )
                        }
                    }

                    if (fileType == "image") {
                        imageObject.mImagePaths = shareFiles
                        mediaContent.mMediaObject = imageObject
                    } else {
                        videoObject.mVideoPaths = shareFiles
                        mediaContent.mMediaObject = videoObject
                    }

                    request.mMediaContent = mediaContent
                    if (hashtag != null) {
                        request.mHashTagList = hashtag
                    }

                    request.mClientKey = clientKey

                    if (shareFormat == "normal") {
                        request.mShareFormat = Share.Format.DEFAULT
                    } else {
                        request.mShareFormat = Share.Format.GREEN_SCREEN
                    }

                    when (landedPageType) {
                        "clip" -> {
                            request.mTargetSceneType = TargetSceneType.LANDPAGE_SCENE_CUT
                        }
                        "edit" -> {
                            request.mTargetSceneType = TargetSceneType.LANDPAGE_SCENE_EDIT
                        }
                        else -> {
                            request.mTargetSceneType = TargetSceneType.LANDPAGE_SCENE_DEFAULT
                        }
                    }

                    tiktokOpenApi.share(request)
                    flutterResult.success(true)
                } else {
                    flutterResult.success(false)
                }
            }
        }
    }

    fun openTikTokUserPage(
        context: Activity,
        flutterResult: MethodChannel.Result,
        username: String,
    ) {
        val hasPackage = StoreService.isPackageInstalled(context, TIKTOK_T_PACKAGE)
        if (!hasPackage) {
            flutterResult.success(false)
            StoreService.openAppOnStore(context, TIKTOK_T_PACKAGE)
        } else {
            val viewIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.tiktok.com/$username"))
            viewIntent.setPackage(TIKTOK_T_PACKAGE)

            try {
                context.startActivity(viewIntent, null)
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