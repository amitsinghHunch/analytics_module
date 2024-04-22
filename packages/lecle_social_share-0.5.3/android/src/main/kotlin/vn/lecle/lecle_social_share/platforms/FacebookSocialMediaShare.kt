package vn.lecle.lecle_social_share.platforms

import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.ImageDecoder
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import com.facebook.CallbackManager
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.share.Sharer
import com.facebook.share.internal.ShareFeedContent
import com.facebook.share.model.*
import com.facebook.share.widget.ShareDialog
import io.flutter.plugin.common.MethodChannel
import vn.lecle.lecle_social_share.services.FileService
import vn.lecle.lecle_social_share.services.StoreService
import java.io.File

const val FACEBOOK_PACKAGE = "com.facebook.katana"

object FacebookSocialMediaShare {
    fun shareVideoToFacebook(
        context: Activity,
        flutterResult: MethodChannel.Result,
        filePath: String?,
        fileProviderPath: String,
        dstPath: String?,
        pageId: String?,
        ref: String?,
        peopleIds: List<String>?,
        placeId: String?,
        hashtag: String?,
        contentUrl: String?,
        previewImagePath: String?,
        contentTitle: String?,
        contentDescription: String?,
    ) {
        filePath?.let {
            val hasPackage = StoreService.isPackageInstalled(context, FACEBOOK_PACKAGE)
            if (!hasPackage) {
                flutterResult.success(false)
                StoreService.openAppOnStore(context, FACEBOOK_PACKAGE)
            } else {
                val previewImgFile: File?
                val previewImgPublicFile: File?
                val previewImgUri: Uri?
                var previewPhoto: SharePhoto? = null
                if (previewImagePath != null) {
                    previewImgFile = File(previewImagePath)
                    val storagePath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        context.getExternalFilesDir(dstPath ?: Environment.DIRECTORY_DOCUMENTS)?.absolutePath ?: ""
                    } else {
                        Environment.getExternalStorageDirectory().absolutePath + (dstPath ?: "")
                    }

                    previewImgPublicFile = FileService.exportFile(
                        previewImgFile,
                        File(storagePath)
                    )

                    if (previewImgPublicFile != null) {
                        previewImgUri = FileProvider.getUriForFile(
                            context, context.packageName + fileProviderPath,
                            previewImgPublicFile
                        )
                        previewPhoto = SharePhoto.Builder().setImageUrl(previewImgUri).build()
                    }
                }

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
                    return
                }

                val shareDialog = ShareDialog(context)
                val callbackManager = CallbackManager.Factory.create()
                val ht = ShareHashtag.Builder().setHashtag(hashtag).build()
                val video = ShareVideo.Builder().setLocalUrl(uri).build()

                val videoShareBuilder = ShareVideoContent.Builder()
                if (previewPhoto?.imageUrl != null) {
                    videoShareBuilder.setPreviewPhoto(previewPhoto)
                }

                val content: ShareVideoContent =
                    videoShareBuilder
                        .setVideo(video)
                        .setContentTitle(contentTitle)
                        .setContentDescription(contentDescription)
                        .setPageId(pageId)
                        .setRef(ref)
                        .setPeopleIds(peopleIds)
                        .setPlaceId(placeId)
                        .setShareHashtag(ht)
                        .setContentUrl(Uri.parse(contentUrl ?: ""))
                        .build()

                shareDialog.registerCallback(callbackManager,
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
                                error.stackTrace,
                            )
                        }
                    })

                if (ShareDialog.canShow(ShareVideoContent::class.java)) {
                    shareDialog.show(content)
                } else {
                    flutterResult.success(false)
                }
            }
        }
    }

    fun sharePhotoToFacebook(
        context: Activity,
        flutterResult: MethodChannel.Result,
        filePath: String?,
        fileProviderPath: String,
        dstPath: String?,
        pageId: String?,
        ref: String?,
        peopleIds: List<String>?,
        placeId: String?,
        hashtag: String?,
        contentUrl: String?,
    ) {
        filePath?.let {
            val hasPackage = StoreService.isPackageInstalled(context, FACEBOOK_PACKAGE)
            if (!hasPackage) {
                flutterResult.success(false)
                StoreService.openAppOnStore(context, FACEBOOK_PACKAGE)
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
                    return
                }

                val shareDialog = ShareDialog(context)
                val callbackManager = CallbackManager.Factory.create()
                val ht: ShareHashtag = ShareHashtag.Builder().setHashtag(hashtag).build()
                val photo = SharePhoto.Builder().setImageUrl(uri).build()
                val content: SharePhotoContent =
                    SharePhotoContent.Builder()
                        .setPhotos(listOf(photo))
                        .setPageId(pageId)
                        .setRef(ref)
                        .setPeopleIds(peopleIds)
                        .setPlaceId(placeId)
                        .setShareHashtag(ht)
                        .setContentUrl(Uri.parse(contentUrl ?: ""))
                        .build()

                shareDialog.registerCallback(callbackManager,
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
                    })

                if (ShareDialog.canShow(SharePhotoContent::class.java)) {
                    shareDialog.show(content)
                } else {
                    flutterResult.success(false)
                }
            }
        }
    }

    fun shareFeedContentToFacebook(
        context: Activity,
        flutterResult: MethodChannel.Result,
        link: String?,
        pageId: String?,
        ref: String?,
        peopleIds: List<String>?,
        placeId: String?,
        hashtag: String?,
        linkCaption: String?,
        linkName: String?,
        linkDescription: String?,
        mediaSource: String?,
        picture: String?,
        toId: String?,
    ) {
        val hasPackage = StoreService.isPackageInstalled(context, FACEBOOK_PACKAGE)
        if (!hasPackage) {
            flutterResult.success(false)
            StoreService.openAppOnStore(context, FACEBOOK_PACKAGE)
        } else {
            val shareDialog = ShareDialog(context)
            val callbackManager = CallbackManager.Factory.create()
            val ht = ShareHashtag.Builder().setHashtag(hashtag).build()
            val content: ShareFeedContent =
                ShareFeedContent.Builder()
                    .setLink(link)
                    .setPageId(pageId)
                    .setRef(ref)
                    .setPeopleIds(peopleIds)
                    .setPlaceId(placeId)
                    .setShareHashtag(ht)
                    .setLinkCaption(linkCaption)
                    .setLinkName(linkName)
                    .setLinkDescription(linkDescription)
                    .setMediaSource(mediaSource)
                    .setPicture(picture)
                    .setToId(toId)
                    .build()

            shareDialog.registerCallback(
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

            shareDialog.show(content)
        }
    }

    fun shareLinkContentToFacebook(
        context: Activity,
        flutterResult: MethodChannel.Result,
        pageId: String?,
        ref: String?,
        peopleIds: List<String>?,
        placeId: String?,
        hashtag: String?,
        contentUrl: String?,
        quote: String?,
    ) {
        val hasPackage = StoreService.isPackageInstalled(context, FACEBOOK_PACKAGE)
        if (!hasPackage) {
            flutterResult.success(false)
            StoreService.openAppOnStore(context, FACEBOOK_PACKAGE)
        } else {
            val shareDialog = ShareDialog(context)
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
                    .setContentUrl(Uri.parse(contentUrl ?: ""))
                    .build()
            shareDialog.registerCallback(
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

            if (ShareDialog.canShow(ShareLinkContent::class.java)) {
                shareDialog.show(content)
            } else {
                flutterResult.success(false)
            }
        }
    }

    fun shareMediaContentFileToFacebook(
        context: Activity,
        flutterResult: MethodChannel.Result,
        fileProviderPath: String?,
        pageId: String?,
        ref: String?,
        peopleIds: List<String>?,
        placeId: String?,
        hashtag: String?,
        contentUrl: String?,
        imageUrls: List<String?>?,
        videoUrls: List<String?>?,
        dstPath: String?,
    ) {
        val hasPackage = StoreService.isPackageInstalled(context, FACEBOOK_PACKAGE)
        if (!hasPackage) {
            flutterResult.success(false)
            StoreService.openAppOnStore(context, FACEBOOK_PACKAGE)
        } else {
            val photoList = mutableListOf<SharePhoto>()
            val videoList = mutableListOf<ShareVideo>()

            if (videoUrls != null && videoUrls.isNotEmpty()) {
                for (videoUrl in videoUrls) {
                    val file = File(videoUrl ?: "")
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

                        val video = ShareVideo.Builder().setLocalUrl(uri).build()
                        videoList.add(video)
                    }
                }
            }

            if (imageUrls != null && imageUrls.isNotEmpty()) {
                for (photo in imageUrls) {
                    val file = File(photo ?: "")
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

                        val p = SharePhoto.Builder().setImageUrl(uri).build()
                        photoList.add(p)
                    }
                }
            }


            if (photoList.isEmpty() && videoList.isEmpty()) {
                flutterResult.success(false)
                return
            }

            val shareList = mutableListOf<ShareMedia<*, *>>()
            shareList.addAll(videoList)
            shareList.addAll(photoList)

            val shareDialog = ShareDialog(context)
            val callbackManager = CallbackManager.Factory.create()
            val ht = ShareHashtag.Builder().setHashtag(hashtag).build()
            val content: ShareMediaContent =
                ShareMediaContent.Builder()
                    .setMedia(shareList)
                    .setPageId(pageId)
                    .setRef(ref)
                    .setPeopleIds(peopleIds)
                    .setPlaceId(placeId)
                    .setShareHashtag(ht)
                    .setContentUrl(Uri.parse(contentUrl ?: ""))
                    .build()
            shareDialog.registerCallback(
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

            if (ShareDialog.canShow(ShareMediaContent::class.java)) {
                shareDialog.show(content)
            } else {
                flutterResult.success(false)
            }
        }
    }

    fun shareBackgroundAssetFileToFacebookStory(
        context: Activity,
        flutterResult: MethodChannel.Result,
        fileType: String,
        filePath: String?,
        appId: String,
        dstPath: String?,
        fileProviderPath: String,
    ) {
        filePath?.let {
            val hasPackage = StoreService.isPackageInstalled(context, FACEBOOK_PACKAGE)
            if (!hasPackage) {
                flutterResult.success(false)
                StoreService.openAppOnStore(context, FACEBOOK_PACKAGE)
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

                // Define photo asset URI
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
                    // Instantiate implicit intent with ADD_TO_STORY action
                    val intent = Intent("com.facebook.stories.ADD_TO_STORY")
                    intent.setDataAndType(backgroundAssetUri, FileService.resolveFileType(fileType))
                    intent.flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
                    intent.putExtra("com.facebook.platform.extra.APPLICATION_ID", appId)

                    // Instantiate activity and verify it will resolve implicit intent
                    if (context.packageManager.resolveActivity(intent, 0) != null) {
                        context.startActivityForResult(intent, 0)
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

    fun shareStickerAssetToFacebookStory(
        context: Activity,
        flutterResult: MethodChannel.Result,
        appId: String,
        fileProviderPath: String,
        stickerPath: String?,
        dstPath: String?,
        stickerTopBgColor: String?,
        stickerBottomBgColor: String?,
    ) {
        stickerPath?.let {
            val hasPackage = StoreService.isPackageInstalled(context, FACEBOOK_PACKAGE)
            if (!hasPackage) {
                flutterResult.success(false)
                StoreService.openAppOnStore(context, FACEBOOK_PACKAGE)
            } else {
                val file = File(stickerPath)
                val storagePath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    context.getExternalFilesDir(dstPath ?: Environment.DIRECTORY_DOCUMENTS)?.absolutePath ?: ""
                } else {
                    Environment.getExternalStorageDirectory().absolutePath + (dstPath ?: "")
                }

                val publicFile = FileService.exportFile(
                    file,
                    File(storagePath)
                )

                // Define sticker asset URI
                val stickerAssetUri: Uri?
                if (publicFile != null) {
                    stickerAssetUri = FileProvider.getUriForFile(
                        context, context.packageName + fileProviderPath,
                        publicFile
                    )
                } else {
                    flutterResult.success(false)
                    return
                }

                // Instantiate implicit intent with ADD_TO_STORY action,
                // sticker asset and background colors
                val intent = Intent("com.facebook.stories.ADD_TO_STORY")
                intent.type = "image/*"
                intent.putExtra("com.facebook.platform.extra.APPLICATION_ID", appId)
                intent.putExtra("interactive_asset_uri", stickerAssetUri)

                if (stickerTopBgColor != null) {
                    intent.putExtra("top_background_color", stickerTopBgColor)
                }
                if (stickerBottomBgColor != null) {
                    intent.putExtra("bottom_background_color", stickerBottomBgColor)
                }

                context.grantUriPermission(
                    FACEBOOK_PACKAGE, stickerAssetUri, Intent.FLAG_GRANT_READ_URI_PERMISSION
                )
                if (context.packageManager.resolveActivity(intent, 0) != null) {
                    context.startActivityForResult(intent, 0)
                } else {
                    flutterResult.success(false)
                }
            }
        }
    }

    fun shareBitmapImageBackgroundAssetToFacebookStory(
        context: Activity,
        flutterResult: MethodChannel.Result,
        imagePath: String?,
        dstPath: String?,
        fileProviderPath: String,
        pageId: String?,
        ref: String?,
        peopleIds: List<String>?,
        placeId: String?,
        hashtag: String?,
        contentUrl: String?,
        attributionLink: String?,
        backgroundColorList: List<String>?,
        videoBackgroundAssetPath: String?,
        photoBackgroundAssetPath: String?,
        stickerPath: String?,
    ) {
        imagePath?.let {
            val hasPackage = StoreService.isPackageInstalled(context, FACEBOOK_PACKAGE)
            if (!hasPackage) {
                flutterResult.success(false)
                StoreService.openAppOnStore(context, FACEBOOK_PACKAGE)
            } else {
                val file = File(imagePath)
                val storagePath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    context.getExternalFilesDir(dstPath ?: Environment.DIRECTORY_DOCUMENTS)?.absolutePath ?: ""
                } else {
                    Environment.getExternalStorageDirectory().absolutePath + (dstPath ?: "")
                }

                val publicFile = FileService.exportFile(
                    file,
                    File(storagePath)
                )

                // Define sticker asset URI
                val imageAssetUri: Uri?
                if (publicFile != null) {
                    imageAssetUri = FileProvider.getUriForFile(
                        context, context.packageName + fileProviderPath,
                        publicFile
                    )
                } else {
                    flutterResult.success(false)
                    return
                }

                // Model an image background asset
                val image: Bitmap = if (Build.VERSION.SDK_INT <= 28) {
                    MediaStore.Images.Media.getBitmap(context.contentResolver, imageAssetUri)
                } else {
                    val source = ImageDecoder.createSource(context.contentResolver, imageAssetUri)
                    ImageDecoder.decodeBitmap(source)
                }

                val photo: SharePhoto = SharePhoto.Builder()
                    .setBitmap(image)
                    .build()

                var backgroundAssetUri: Uri? = null
                if (videoBackgroundAssetPath != null) {
                    val backgroundAssetFile = File(videoBackgroundAssetPath)
                    val videoPath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        context.getExternalFilesDir(dstPath ?: Environment.DIRECTORY_DOCUMENTS)?.absolutePath ?: ""
                    } else {
                        Environment.getExternalStorageDirectory().absolutePath + (dstPath ?: "")
                    }

                    val videoPublicFile = FileService.exportFile(
                        backgroundAssetFile,
                        File(videoPath)
                    )

                    if (videoPublicFile != null) {
                        backgroundAssetUri = FileProvider.getUriForFile(
                            context, context.packageName + fileProviderPath,
                            videoPublicFile
                        )
                    } else {
                        return
                    }
                }
                if (photoBackgroundAssetPath != null) {
                    val backgroundAssetFile = File(photoBackgroundAssetPath)
                    val photoPath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        context.getExternalFilesDir(dstPath ?: Environment.DIRECTORY_DOCUMENTS)?.absolutePath ?: ""
                    } else {
                        Environment.getExternalStorageDirectory().absolutePath + (dstPath ?: "")
                    }

                    val photoPublicFile = FileService.exportFile(
                        backgroundAssetFile,
                        File(photoPath)
                    )

                    if (photoPublicFile != null) {
                        backgroundAssetUri = FileProvider.getUriForFile(
                            context, context.packageName + fileProviderPath,
                            photoPublicFile
                        )
                    } else {
                        return
                    }
                }

                var videoAsset: ShareVideo? = null
                if (videoBackgroundAssetPath != null) {
                    videoAsset = ShareVideo.Builder().setLocalUrl(backgroundAssetUri).build()
                }

                var photoAsset: SharePhoto? = null
                if (photoBackgroundAssetPath != null) {
                    photoAsset = SharePhoto.Builder().setImageUrl(backgroundAssetUri).build()
                }

                val shareDialog = ShareDialog(context)
                val callbackManager = CallbackManager.Factory.create()
                val ht = ShareHashtag.Builder().setHashtag(hashtag).build()
                val storyContentBuilder = ShareStoryContent.Builder()

                if (videoBackgroundAssetPath != null) {
                    storyContentBuilder.setBackgroundAsset(videoAsset)
                }
                if (photoBackgroundAssetPath != null) {
                    storyContentBuilder.setBackgroundAsset(photoAsset)
                }

                var stickerAsset: SharePhoto? = null
                if (stickerPath != null) {
                    val stickerFile = File(stickerPath)
                    val stickerStoragePath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        context.getExternalFilesDir(dstPath ?: Environment.DIRECTORY_DOCUMENTS)?.absolutePath ?: ""
                    } else {
                        Environment.getExternalStorageDirectory().absolutePath + (dstPath ?: "")
                    }

                    val stickerPublicFile = FileService.exportFile(
                        stickerFile,
                        File(stickerStoragePath)
                    )

                    // Define sticker asset URI
                    val stickerImageAssetUri: Uri?
                    if (stickerPublicFile != null) {
                        stickerImageAssetUri = FileProvider.getUriForFile(
                            context, context.packageName + fileProviderPath,
                            stickerPublicFile
                        )
                    } else {
                        flutterResult.success(false)
                        return
                    }

                    stickerAsset = SharePhoto.Builder().setImageUrl(stickerImageAssetUri).build()
                }

                // Add to ShareStoryContent
                val content: ShareStoryContent = storyContentBuilder
                    .setBackgroundAsset(photo)
                    .setStickerAsset(stickerAsset)
                    .setShareHashtag(ht)
                    .setRef(ref)
                    .setPeopleIds(peopleIds)
                    .setPlaceId(placeId)
                    .setContentUrl(Uri.parse(contentUrl ?: ""))
                    .setPageId(pageId)
                    .setAttributionLink(attributionLink)
                    .setBackgroundColorList(backgroundColorList)
                    .build()

                shareDialog.registerCallback(
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

                if (ShareDialog.canShow(ShareStoryContent::class.java)) {
                    shareDialog.show(content)
                } else {
                    flutterResult.success(false)
                }
            }
        }
    }

    fun shareImageBackgroundAssetContentToFacebookStory(
        context: Activity,
        flutterResult: MethodChannel.Result,
        dstPath: String?,
        fileProviderPath: String,
        pageId: String?,
        ref: String?,
        peopleIds: List<String>?,
        placeId: String?,
        hashtag: String?,
        contentUrl: String?,
        attributionLink: String?,
        backgroundColorList: List<String>?,
        photoBackgroundAssetPath: String?,
        stickerPath: String?,
    ) {
        photoBackgroundAssetPath?.let {
            val hasPackage = StoreService.isPackageInstalled(context, FACEBOOK_PACKAGE)
            if (!hasPackage) {
                flutterResult.success(false)
                StoreService.openAppOnStore(context, FACEBOOK_PACKAGE)
            } else {
                val photo: SharePhoto?
                val file = File(photoBackgroundAssetPath)
                val storagePath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    context.getExternalFilesDir(dstPath ?: Environment.DIRECTORY_DOCUMENTS)?.absolutePath ?: ""
                } else {
                    Environment.getExternalStorageDirectory().absolutePath + (dstPath ?: "")
                }

                val publicFile = FileService.exportFile(
                    file,
                    File(storagePath)
                )

                // Define sticker asset URI
                val imageAssetUri: Uri?
                if (publicFile != null) {
                    imageAssetUri = FileProvider.getUriForFile(
                        context, context.packageName + fileProviderPath,
                        publicFile
                    )
                } else {
                    flutterResult.success(false)
                    return
                }

                photo = SharePhoto.Builder()
                    .setImageUrl(imageAssetUri)
                    .build()

                var stickerAsset: SharePhoto? = null
                if (stickerPath != null) {
                    val stickerFile = File(stickerPath)
                    val stickerStoragePath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        context.getExternalFilesDir(dstPath ?: Environment.DIRECTORY_DOCUMENTS)?.absolutePath ?: ""
                    } else {
                        Environment.getExternalStorageDirectory().absolutePath + (dstPath ?: "")
                    }

                    val stickerPublicFile = FileService.exportFile(
                        stickerFile,
                        File(stickerStoragePath)
                    )

                    // Define sticker asset URI
                    val stickerImageAssetUri: Uri?
                    if (stickerPublicFile != null) {
                        stickerImageAssetUri = FileProvider.getUriForFile(
                            context, context.packageName + fileProviderPath,
                            stickerPublicFile
                        )
                    } else {
                        flutterResult.success(false)
                        return
                    }

                    stickerAsset = SharePhoto.Builder().setImageUrl(stickerImageAssetUri).build()
                }

                val shareDialog = ShareDialog(context)
                val callbackManager = CallbackManager.Factory.create()
                val ht = ShareHashtag.Builder().setHashtag(hashtag).build()

                // Add to ShareStoryContent
                val content: ShareStoryContent = ShareStoryContent.Builder()
                    .setBackgroundAsset(photo)
                    .setStickerAsset(stickerAsset)
                    .setShareHashtag(ht)
                    .setRef(ref)
                    .setPeopleIds(peopleIds)
                    .setPlaceId(placeId)
                    .setContentUrl(Uri.parse(contentUrl ?: ""))
                    .setPageId(pageId)
                    .setAttributionLink(attributionLink)
                    .setBackgroundColorList(backgroundColorList)
                    .build()

                shareDialog.registerCallback(
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

                if (ShareDialog.canShow(ShareStoryContent::class.java)) {
                    shareDialog.show(content)
                } else {
                    flutterResult.success(false)
                }
            }
        }
    }

    fun shareVideoBackgroundAssetContentToFacebookStory(
        context: Activity,
        flutterResult: MethodChannel.Result,
        dstPath: String?,
        fileProviderPath: String,
        pageId: String?,
        ref: String?,
        peopleIds: List<String>?,
        placeId: String?,
        hashtag: String?,
        contentUrl: String?,
        attributionLink: String?,
        backgroundColorList: List<String>?,
        videoBackgroundAssetPath: String?,
        stickerPath: String?,
    ) {
        videoBackgroundAssetPath?.let {
            val hasPackage = StoreService.isPackageInstalled(context, FACEBOOK_PACKAGE)
            if (!hasPackage) {
                flutterResult.success(false)
                StoreService.openAppOnStore(context, FACEBOOK_PACKAGE)
            } else {
                val video: ShareVideo?
                val file = File(videoBackgroundAssetPath)
                val storagePath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    context.getExternalFilesDir(dstPath ?: Environment.DIRECTORY_DOCUMENTS)?.absolutePath ?: ""
                } else {
                    Environment.getExternalStorageDirectory().absolutePath + (dstPath ?: "")
                }

                val publicFile = FileService.exportFile(
                    file,
                    File(storagePath)
                )

                // Define sticker asset URI
                val videoAssetUri: Uri?
                if (publicFile != null) {
                    videoAssetUri = FileProvider.getUriForFile(
                        context, context.packageName + fileProviderPath,
                        publicFile
                    )
                } else {
                    flutterResult.success(false)
                    return
                }

                video = ShareVideo.Builder()
                    .setLocalUrl(videoAssetUri)
                    .build()

                var stickerAsset: SharePhoto? = null
                if (stickerPath != null) {
                    val stickerFile = File(stickerPath)
                    val stickerStoragePath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        context.getExternalFilesDir(dstPath ?: Environment.DIRECTORY_DOCUMENTS)?.absolutePath ?: ""
                    } else {
                        Environment.getExternalStorageDirectory().absolutePath + (dstPath ?: "")
                    }

                    val stickerPublicFile = FileService.exportFile(
                        stickerFile,
                        File(stickerStoragePath)
                    )

                    // Define sticker asset URI
                    val stickerImageAssetUri: Uri?
                    if (stickerPublicFile != null) {
                        stickerImageAssetUri = FileProvider.getUriForFile(
                            context, context.packageName + fileProviderPath,
                            stickerPublicFile
                        )
                    } else {
                        flutterResult.success(false)
                        return
                    }

                    stickerAsset = SharePhoto.Builder().setImageUrl(stickerImageAssetUri).build()
                }

                val shareDialog = ShareDialog(context)
                val callbackManager = CallbackManager.Factory.create()
                val ht = ShareHashtag.Builder().setHashtag(hashtag).build()
                // Add to ShareStoryContent
                val content: ShareStoryContent = ShareStoryContent.Builder()
                    .setBackgroundAsset(video)
                    .setStickerAsset(stickerAsset)
                    .setShareHashtag(ht)
                    .setRef(ref)
                    .setPeopleIds(peopleIds)
                    .setPlaceId(placeId)
                    .setContentUrl(Uri.parse(contentUrl ?: ""))
                    .setPageId(pageId)
                    .setAttributionLink(attributionLink)
                    .setBackgroundColorList(backgroundColorList)
                    .build()

                shareDialog.registerCallback(
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

                if (ShareDialog.canShow(ShareStoryContent::class.java)) {
                    shareDialog.show(content)
                } else {
                    flutterResult.success(false)
                }
            }
        }
    }

    fun shareVideoToFacebookReels(
        context: Activity,
        flutterResult: MethodChannel.Result,
        filePath: String?,
        stickerPath: String?,
        appId: String,
        fileProviderPath: String,
        dstPath: String?,
        stickerTopBgColor: String?,
        stickerBottomBgColor: String?,
    ) {
        filePath?.let {
            // Instantiate an intent
            val intent = Intent("com.facebook.reels.SHARE_TO_REEL")

            // Attach your App ID to the intent
            intent.putExtra("com.facebook.platform.extra.APPLICATION_ID", appId)
            intent.flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
            if (stickerTopBgColor != null) {
                intent.putExtra("top_background_color", stickerTopBgColor)
            }
            if (stickerBottomBgColor != null) {
                intent.putExtra("bottom_background_color", stickerBottomBgColor)
            }

            // Attach your video to the intent from a URI
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

            val videoAssetUri: Uri?
            if (publicFile != null) {
                videoAssetUri = FileProvider.getUriForFile(
                    context, context.packageName + fileProviderPath,
                    publicFile
                )
            } else {
                return
            }

            intent.setDataAndType(videoAssetUri, "*/*") // Example: video/mp4, video/*, image/*, image/png

            var stickerAssetUri: Uri? = null
            if (stickerPath != null) {
                // Attach your video to the intent from a URI
                val stickerFile = File(stickerPath)
                val stickerStoragePath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    context.getExternalFilesDir(dstPath ?: Environment.DIRECTORY_DOCUMENTS)?.absolutePath ?: ""
                } else {
                    Environment.getExternalStorageDirectory().absolutePath + (dstPath ?: "")
                }

                val stickerPublicFile = FileService.exportFile(
                    stickerFile,
                    File(stickerStoragePath)
                )

                if (stickerPublicFile != null) {
                    stickerAssetUri = FileProvider.getUriForFile(
                        context, context.packageName + fileProviderPath,
                        stickerPublicFile
                    )
                    intent.putExtra("interactive_asset_uri", stickerAssetUri)
                }
            }

            context.grantUriPermission(
                context.packageName,
                videoAssetUri,
                Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_READ_URI_PERMISSION
            )
            context.grantUriPermission(
                FACEBOOK_PACKAGE,
                stickerAssetUri,
                Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_READ_URI_PERMISSION
            )

            // Verify that the activity resolves the intent and start it
            if (context.packageManager.resolveActivity(intent, 0) != null) {
                context.startActivityForResult(intent, 0)
            } else {
                flutterResult.success(false)
            }
        }
    }

    fun shareCameraEffectToFacebook(
        context: Activity,
        flutterResult: MethodChannel.Result,
        cameraTexturesKey: String,
        cameraTexturesUrl: String?,
        cameraArgumentsKey: String,
        cameraArgumentsValue: String?,
        cameraArgumentsArray: Array<String>?,
        effectId: String?,
        contentUrl: String?,
        pageId: String?,
        peopleIds: List<String>?,
        placeId: String?,
        ref: String?,
        hashtag: String?,
    ) {
        val hasPackage = StoreService.isPackageInstalled(context, FACEBOOK_PACKAGE)
        if (!hasPackage) {
            flutterResult.success(false)
            StoreService.openAppOnStore(context, FACEBOOK_PACKAGE)
        } else {
            val callbackManager = CallbackManager.Factory.create()
            val shareDialog = ShareDialog(context)

            val content = ShareCameraEffectContent.Builder()
                .setTextures(
                    CameraEffectTextures.Builder()
                        .putTexture(
                            cameraTexturesKey,
                            if (cameraTexturesUrl != null) Uri.parse(cameraTexturesUrl) else null,
                        )
                        .build()
                )
                .setEffectId(effectId)
                .setContentUrl(if (contentUrl != null) Uri.parse(contentUrl) else null)
                .setPageId(pageId)
                .setPeopleIds(peopleIds)
                .setPlaceId(placeId)
                .setRef(ref)
                .setShareHashtag(ShareHashtag.Builder().setHashtag(hashtag).build())

            if (cameraArgumentsValue != null && cameraArgumentsArray == null) {
                content.setArguments(
                    CameraEffectArguments
                        .Builder()
                        .putArgument(cameraArgumentsKey, cameraArgumentsValue)
                        .build()
                )
            } else if (cameraArgumentsArray != null && cameraArgumentsValue == null) {
                content.setArguments(
                    CameraEffectArguments
                        .Builder()
                        .putArgument(cameraArgumentsKey, cameraArgumentsArray)
                        .build()
                )
            } else if (cameraArgumentsValue != null && cameraArgumentsArray != null) {
                content.setArguments(
                    CameraEffectArguments
                        .Builder()
                        .putArgument(cameraArgumentsKey, cameraArgumentsValue)
                        .putArgument(cameraArgumentsKey, cameraArgumentsArray)
                        .build()
                )
            }

            shareDialog.registerCallback(
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

            if (ShareDialog.canShow(ShareCameraEffectContent::class.java)) {
                shareDialog.show(content.build())
            } else {
                flutterResult.success(false)
            }
        }
    }
}