import Flutter
import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import Photos
import TwitterKit
// import TikTokOpenSDK

public class SwiftLecleSocialSharePlugin: NSObject, FlutterPlugin, SharingDelegate {
    var flutterResult: FlutterResult!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "lecle_social_share", binaryMessenger: registrar.messenger())
        let instance = SwiftLecleSocialSharePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        flutterResult = result
        
        guard let args = call.arguments as? [String : Any?] else { return }
        
        switch call.method {
        case "shareFileFacebook":
            shareFileToFacebook(result: result, arguments: args)
            break
        case "shareFeedContentFacebook":
            shareFeedContentToFacebook(result: result, arguments: args)
            break
        case "shareLinkContentFacebook":
            shareLinkContentToFacebook(result: result, arguments: args)
            break
        case "shareMediaContentFileFacebook":
            shareMediaContentFileToFacebook(result: result, arguments: args)
            break
        case "shareCameraEffectToFacebook":
            shareCameraEffectToFacebook(result: result, arguments: args)
            break
        case "shareBackgroundAssetFileFacebookStory":
            shareBackgroundAssetFileToFacebookStory(result: result, arguments: args)
            break
        case "shareStickerAssetFacebookStory":
            shareStickerAssetToFacebookStory(result: result, arguments: args)
            break
        case "shareBackgroundImageAndStickerFacebookStoryiOS":
            shareBackgroundImageAndStickerToFacebookStoryiOS(result: result, arguments: args)
            break
        case "shareVideoFacebookReels":
            shareVideoToFacebookReels(result: result, arguments: args)
            break
        case "shareFileInsta":
            shareFileToInstagram(result: result, arguments: args)
            break
        case "sendMessageInsta":
            sendMessageToInstagram(result: result, arguments: args)
            break
        case "shareFileMessenger":
            shareFileToMessenger(result: result, arguments: args)
            break
        case "sendMessageMessenger":
            sendMessageToMessenger(result: result, arguments: args)
            break
        case "shareLinkContentMessenger":
            sendMessageToMessenger(result: result, arguments: args)
            break
        case "sendMessageTelegram":
            sendMessageToTelegram(result: result, arguments: args)
            break
        case "openTelegramDirectMessage":
            openTelegramDirectMessage(result: result, arguments: args)
            break
        case "openTelegramChannelViaShareLink":
            openTelegramChannelViaShareLink(result: result, arguments: args)
            break
        case "shareFileTelegram":
            shareFileToTelegram(result: result, arguments: args)
        case "sendMessageWhatsApp":
            sendMessageToWhatsApp(result: result, arguments: args)
            break
        case "shareFileWhatsApp":
            shareFileToWhatsApp(result: result, arguments: args)
            break
        case "createTwitterTweet":
            createTwitterTweet(result: result, arguments: args)
            break
        case "shareFileTwitter":
            shareFileToTwitter(result: result, arguments: args)
            break
        case "shareFilesTikTok":
            shareFilesToTikTok(result: result, arguments: args)
            break
        case "openTikTokUserPage":
            openTikTokUserPage(result: result, arguments: args)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    var fbAssetToDelete: PHAsset?
    func shareFileToFacebook(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let fileType = arguments["fileType"] as! String
        
        if (fileType == "video") {
            shareVideoToFacebook(result: result, arguments: arguments)
        } else {
            sharePhotoToFacebook(result: result, arguments: arguments)
        }
    }
    
    var videoAssetToDelete: PHAsset?
    private func shareVideoToFacebook(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let filePath: String? = arguments["filePath"] as? String
        let pageId: String? = arguments["pageId"] as? String
        let ref: String? = arguments["ref"] as? String
        let peopleIds: [String]? = arguments["peopleIds"] as? [String]
        let placeId: String? = arguments["placeId"] as? String
        let hashtag: String? = arguments["hashtag"] as? String
        let contentUrl: String? = arguments["contentUrl"] as? String
        let previewImagePath: String? = arguments["previewImagePath"] as? String
        
        guard let path = filePath else {
            result(false)
            return
        }
        
        guard let facebookURL = URL(string: "fb://") else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(facebookURL)) {
            let content: ShareVideoContent = ShareVideoContent()
            let fileURL = URL(fileURLWithPath: path)
            var video: ShareVideo!
            
            createAssetURL(url: fileURL, result: result, fileType: PHAssetMediaType.video) { asset in
                DispatchQueue.main.async {
                    self.videoAssetToDelete = asset
                    
                    if let previewPath = previewImagePath {
                        let previewURL = URL(fileURLWithPath: previewPath)
                        self.createAssetURL(url: previewURL, result: result, fileType: PHAssetMediaType.image) {
                            previewAsset in DispatchQueue.main.async {
                                let photo = SharePhoto(image: self.getUIImage(asset: previewAsset), isUserGenerated: true)
                                video = ShareVideo(videoAsset: asset, previewPhoto: photo)
                            }
                        }
                    } else {
                        video = ShareVideo(videoAsset: asset)
                    }
                    
                    content.video = video
                    content.ref = ref
                    content.hashtag = Hashtag(hashtag ?? "")
                    if let u = contentUrl {
                        if let url = URL(string: u) {
                            content.contentURL = url
                        }
                    }
                    content.peopleIDs = peopleIds ?? [String]()
                    content.placeID = placeId
                    content.pageID = pageId
                    
                    let shareDialog = ShareDialog(viewController: UIApplication.shared.windows.first!.rootViewController, content: content, delegate: self)
                    
                    do {
                        try shareDialog.validate()
                    } catch {
                        result("shareVideoToFacebookError: \(error)")
                        return
                    }
                    
                    shareDialog.show()
                }
            }
            
        } else {
            guard let facebookAppStoreLink = URL(string: "itms-apps://itunes.apple.com/uss/app/apple-store/id284882215") else{
                result(false)
                return
            }
            UIApplication.shared.open(facebookAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            result(false)
        }
    }
    
    var photoAssetToDelete: PHAsset?
    private func sharePhotoToFacebook(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let filePath: String? = arguments["filePath"] as? String
        let pageId: String? = arguments["pageId"] as? String
        let ref: String? = arguments["ref"] as? String
        let peopleIds: [String]? = arguments["peopleIds"] as? [String]
        let placeId: String? = arguments["placeId"] as? String
        let hashtag: String? = arguments["hashtag"] as? String
        let contentUrl: String? = arguments["contentUrl"] as? String
        
        guard let facebookURL = URL(string: "fb://") else {
            result(false)
            return
        }
        
        guard let path = filePath else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(facebookURL)) {
            let content = SharePhotoContent()
            let fileURL = URL(fileURLWithPath: path)
            
            createAssetURL(url: fileURL, result: result, fileType: PHAssetMediaType.image) { asset in
                DispatchQueue.main.async {
                    self.photoAssetToDelete = asset
                    let photo = SharePhoto(image: self.getUIImage(asset: asset), isUserGenerated: true)
                    content.photos = [photo]
                    content.ref = ref
                    content.hashtag = Hashtag(hashtag ?? "")
                    if let u = contentUrl {
                        if let url = URL(string: u) {
                            content.contentURL = url
                        }
                    }
                    content.peopleIDs = peopleIds ?? [String]()
                    content.placeID = placeId
                    content.pageID = pageId
                    
                    let shareDialog = ShareDialog(viewController: UIApplication.shared.windows.first!.rootViewController, content: content, delegate: self)
                    
                    do {
                        try shareDialog.validate()
                    } catch {
                        result("sharePhotoToFacebookError: \(error)")
                        return
                    }
                    
                    shareDialog.show()
                }
            }
        } else {
            guard let facebookAppStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id284882215") else {
                result(false)
                return
            }
            UIApplication.shared.open(facebookAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            result(false)
        }
    }
    
    func shareFeedContentToFacebook(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let link: String? = arguments["link"] as? String
        let pageId: String? = arguments["pageId"] as? String
        let ref: String? = arguments["ref"] as? String
        let peopleIds: [String]? = arguments["peopleIds"] as? [String]
        let placeId: String? = arguments["placeId"] as? String
        let hashtag: String? = arguments["hashtag"] as? String
        let quote: String? = arguments["quote"] as? String
        
        guard let facebookURL = URL(string: "fb://") else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(facebookURL)) {
            let content: ShareLinkContent = ShareLinkContent()
            content.ref = ref
            content.hashtag = Hashtag(hashtag ?? "")
            content.quote = quote
            if let l = link {
                if let url = URL(string: l) {
                    content.contentURL = url
                }
            }
            content.peopleIDs = peopleIds ?? [String]()
            content.placeID = placeId
            content.pageID = pageId
            
            let shareDialog = ShareDialog(viewController: UIApplication.shared.windows.first!.rootViewController, content: content, delegate: self)
            
            do {
                try shareDialog.validate()
            } catch {
                result("shareFeedContentToFacebookError: \(error)")
                return
            }
            
            shareDialog.show()
        } else {
            guard let facebookAppStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id284882215") else {
                result(false)
                return
            }
            UIApplication.shared.open(facebookAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            result(false)
        }
    }
    
    func shareLinkContentToFacebook(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let pageId: String? = arguments["pageId"] as? String
        let ref: String? = arguments["ref"] as? String
        let peopleIds: [String]? = arguments["peopleIds"] as? [String]
        let placeId: String? = arguments["placeId"] as? String
        let hashtag: String? = arguments["hashtag"] as? String
        let contentUrl: String? = arguments["contentUrl"] as? String
        let quote: String? = arguments["quote"] as? String
        
        guard let facebookURL = URL(string: "fb://") else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(facebookURL)) {
            let content: ShareLinkContent = ShareLinkContent()
            content.ref = ref
            content.hashtag = Hashtag(hashtag ?? "")
            content.quote = quote
            if let u = contentUrl {
                if let url = URL(string: u) {
                    content.contentURL = url
                }
            }
            content.peopleIDs = peopleIds ?? [String]()
            content.placeID = placeId
            content.pageID = pageId
            
            let shareDialog = ShareDialog(viewController: UIApplication.shared.windows.first!.rootViewController, content: content, delegate: self)
            
            do {
                try shareDialog.validate()
            } catch {
                result("shareLinkContentToFacebookError: \(error)")
                return
            }
            
            shareDialog.show()
        } else {
            guard let facebookAppStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id284882215") else {
                result(false)
                return
            }
            UIApplication.shared.open(facebookAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            result(false)
        }
    }
    
    func shareMediaContentFileToFacebook(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let imageUrls: [String?]? = arguments["imageUrls"] as? [String?]
        let videoUrls: [String?]? = arguments["videoUrls"] as? [String?]
        
        guard let facebookURL = URL(string: "fb://") else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(facebookURL)) {
            var videoList: [ShareVideo] = []
            var photoList: [SharePhoto] = []
            var shareList: [ShareMedia] = []
            
            if let vidUrls = videoUrls, let imgUrls = imageUrls {
                for (i, videoUrl) in vidUrls.enumerated() {
                    if let vidUrl = videoUrl {
                        createAssetURL(url: URL(fileURLWithPath: vidUrl), result: result, fileType: PHAssetMediaType.video) {
                            asset in DispatchQueue.main.async {
                                let vid = ShareVideo(videoAsset: asset)
                                videoList.append(vid)
                                
                                if (i == vidUrls.count - 1) {
                                    shareList.append(contentsOf: videoList)
                                }
                            }
                        }
                    }
                }
                
                for (i, imageUrl) in imgUrls.enumerated() {
                    if let imgUrl = imageUrl {
                        createAssetURL(url: URL(fileURLWithPath: imgUrl), result: result, fileType: PHAssetMediaType.image) {
                            asset in DispatchQueue.main.async {
                                let p = SharePhoto(image: self.getUIImage(asset: asset), isUserGenerated: true)
                                photoList.append(p)
                                
                                if (i == imgUrls.count - 1) {
                                    shareList.append(contentsOf: photoList)
                                    self.shareMediaContentToFacebook(shareList: shareList, result: result, arguments: arguments)
                                }
                            }
                        }
                    }
                }
            } else if let vidUrls = videoUrls {
                for (i, videoUrl) in vidUrls.enumerated() {
                    if let vidUrl = videoUrl {
                        createAssetURL(url: URL(fileURLWithPath: vidUrl), result: result, fileType: PHAssetMediaType.video) {
                            asset in DispatchQueue.main.async {
                                let vid = ShareVideo(videoAsset: asset)
                                videoList.append(vid)
                                
                                if (i == vidUrls.count - 1) {
                                    shareList.append(contentsOf: videoList)
                                    self.shareMediaContentToFacebook(shareList: shareList, result: result, arguments: arguments)
                                }
                            }
                        }
                    }
                }
            } else if let imgUrls = imageUrls {
                for (i, imageUrl) in imgUrls.enumerated() {
                    if let imgUrl = imageUrl {
                        createAssetURL(url: URL(fileURLWithPath: imgUrl), result: result, fileType: PHAssetMediaType.image) {
                            asset in DispatchQueue.main.async {
                                let p = SharePhoto(image: self.getUIImage(asset: asset), isUserGenerated: true)
                                photoList.append(p)
                                
                                if (i == imgUrls.count - 1) {
                                    shareList.append(contentsOf: photoList)
                                    self.shareMediaContentToFacebook(shareList: shareList, result: result, arguments: arguments)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            guard let facebookAppStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id284882215") else {
                result(false)
                return
            }
            UIApplication.shared.open(facebookAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            result(false)
        }
    }
    
    private func shareMediaContentToFacebook(shareList: [ShareMedia], result: @escaping FlutterResult, arguments: [String : Any?]) {
        let pageId: String? = arguments["pageId"] as? String
        let ref: String? = arguments["ref"] as? String
        let peopleIds: [String]? = arguments["peopleIds"] as? [String]
        let placeId: String? = arguments["placeId"] as? String
        let hashtag: String? = arguments["hashtag"] as? String
        let contentUrl: String? = arguments["contentUrl"] as? String
        
        let content = ShareMediaContent()
        content.ref = ref
        content.hashtag = Hashtag(hashtag ?? "")
        content.media = shareList
        if let u = contentUrl {
            if let url = URL(string: u) {
                content.contentURL = url
            }
        }
        content.peopleIDs = peopleIds ?? [String]()
        content.placeID = placeId
        content.pageID = pageId
        
        let shareDialog = ShareDialog(viewController: UIApplication.shared.windows.first!.rootViewController, content: content, delegate: self)
        
        do {
            try shareDialog.validate()
        } catch {
            result("shareMediaContentToFacebookError: \(error)")
            return
        }
        
        shareDialog.show()
        result(true)
    }
    
    func shareBackgroundAssetFileToFacebookStory(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let fileType = arguments["fileType"] as! String
        
        if (fileType == "video") {
            shareVideoBackgroundAssetToFacebookStory(result: result, arguments: arguments)
        } else {
            shareImageBackgroundAssetToFacebookStory(result: result, arguments: arguments)
        }
    }
    
    private func shareImageBackgroundAssetToFacebookStory(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let imagePath: String? = arguments["filePath"] as? String
        let appId: String = arguments["appId"] as! String
        
        if (imagePath == nil) {
            result(false)
            return
        }
        
        guard let facebookURL = URL(string: "facebook-stories://share") else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(facebookURL)) {
            var photoAsset: UIImage!
            
            createAssetURL(url: URL(fileURLWithPath: imagePath!), result: result, fileType: PHAssetMediaType.image) {
                asset in DispatchQueue.main.async {
                    photoAsset = self.getUIImage(asset: asset)
                    let backgroundImage = photoAsset!.pngData()! as NSData
                    
                    let pasteboardItems = [
                        [
                            "com.facebook.sharedSticker.backgroundImage": backgroundImage,
                            "com.facebook.sharedSticker.appID": appId,
                        ]
                    ]
                    let pasteboardOptions = [
                        UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
                    ]
                    UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
                    UIApplication.shared.open(facebookURL, options: [:])
                }
            }
        } else {
            guard let facebookAppStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id284882215") else {
                result(false)
                return
            }
            UIApplication.shared.open(facebookAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            result(false)
        }
    }
    
    private func shareVideoBackgroundAssetToFacebookStory(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let appId = arguments["appId"] as! String
        let videoPath = arguments["filePath"] as? String
        
        guard let assetPath = videoPath else {
            result(false)
            return
        }
        
        let backgroundUrl = URL(fileURLWithPath: assetPath)
        let backgroundVideoData = try? Data(contentsOf: backgroundUrl)
        
        guard let videoData = backgroundVideoData else {
            result(false)
            return
        }
        
        guard let facebookURL = URL(string: "facebook-stories://share") else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(facebookURL)) {
            let pasteboardItems = [
                [
                    "com.facebook.sharedSticker.backgroundVideo": videoData,
                    "com.facebook.sharedSticker.appID": appId,
                ]
            ]
            
            let pasteboardOptions = [
                UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
            ]
            UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
            UIApplication.shared.open(facebookURL, options: [:])
        } else {
            guard let facebookAppStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id284882215") else {
                result(false)
                return
            }
            UIApplication.shared.open(facebookAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            result(false)
        }
    }
    
    func shareStickerAssetToFacebookStory(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let stickerPath = arguments["stickerPath"] as? String
        let appId = arguments["appId"] as! String
        let backgroundTopColors = arguments["stickerTopBgColors"] as? [String]
        let backgroundBottomColors =  arguments["stickerBottomBgColors"] as? [String]
        
        guard stickerPath != nil else {
            result(false)
            return
        }
        
        guard let facebookURL = URL(string: "facebook-stories://share") else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(facebookURL)) {
            var photoAsset: UIImage!
            
            createAssetURL(url: URL(fileURLWithPath: stickerPath ?? ""), result: result, fileType: PHAssetMediaType.image) {
                asset in DispatchQueue.main.async {
                    photoAsset = self.getUIImage(asset: asset)
                    let stickerImage = photoAsset!.pngData()! as NSData
                    
                    let pasteboardItems = [
                        [
                            "com.facebook.sharedSticker.stickerImage": stickerImage,
                            "com.facebook.sharedSticker.backgroundTopColor": backgroundTopColors ?? [String](),
                            "com.facebook.sharedSticker.backgroundBottomColor": backgroundBottomColors ?? [String](),
                            "com.facebook.sharedSticker.appID": appId
                        ]
                    ]
                    
                    let pasteboardOptions = [
                        UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
                    ]
                    UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
                    UIApplication.shared.open(facebookURL, options: [:])
                }
            }
        } else {
            guard let facebookAppStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id284882215") else {
                result(false)
                return
            }
            UIApplication.shared.open(facebookAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            result(false)
        }
    }
    
    func shareBackgroundImageAndStickerToFacebookStoryiOS(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let appId = arguments["appId"] as! String
        let photoBackgroundAssetPaths = arguments["photoBackgroundAssetPaths"] as? [String?]
        let stickerAssetPaths = arguments["stickerAssetPaths"] as? [String?]
        let backgroundTopColor = arguments["backgroundTopColor"] as? [String]
        let backgroundBottomColor =  arguments["backgroundBottomColor"] as? [String]
        
        if (photoBackgroundAssetPaths == nil || photoBackgroundAssetPaths!.count == 0) {
            result(false)
            return
        }
        if (stickerAssetPaths == nil || stickerAssetPaths!.count == 0) {
            result(false)
            return
        }
        
        guard let facebookURL = URL(string: "facebook-stories://share") else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(facebookURL)) {
            var stickerImages: [NSData] = [NSData]()
            var backgroundImages: [NSData] = [NSData]()
            
            for (_, stickerAssetPath) in stickerAssetPaths!.enumerated() {
                if let stickerPath = stickerAssetPath {
                    createAssetURL(url: URL(fileURLWithPath: stickerPath), result: result, fileType: PHAssetMediaType.image) {
                        asset in DispatchQueue.main.async {
                            let photoAsset = self.getUIImage(asset: asset)
                            let stickerImage = photoAsset.pngData()! as NSData
                            stickerImages.append(stickerImage)
                        }
                    }
                }
            }
            
            for (i, photoBackgroundAssetPath) in photoBackgroundAssetPaths!.enumerated() {
                if let photoPath = photoBackgroundAssetPath {
                    createAssetURL(url: URL(fileURLWithPath: photoPath), result: result, fileType: PHAssetMediaType.image) {
                        asset in DispatchQueue.main.async {
                            let photoAsset = self.getUIImage(asset: asset)
                            let backgroundImage = photoAsset.pngData()! as NSData
                            backgroundImages.append(backgroundImage)
                            
                            if (i == photoBackgroundAssetPaths!.count - 1) {
                                let pasteboardItems = [
                                    [
                                        "com.facebook.sharedSticker.stickerImage": stickerImages,
                                        "com.facebook.sharedSticker.backgroundImage": backgroundImages,
                                        "com.facebook.sharedSticker.backgroundTopColor": backgroundTopColor ?? [String](),
                                        "com.facebook.sharedSticker.backgroundBottomColor": backgroundBottomColor ?? [String](),
                                        "com.facebook.sharedSticker.appID": appId,
                                    ]
                                ]
                                
                                let pasteboardOptions = [
                                    UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
                                ]
                                UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
                                UIApplication.shared.open(facebookURL, options: [:])
                                result(true)
                                return
                            }
                        }
                    }
                }
            }
        } else {
            guard let facebookAppStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id284882215") else {
                result(false)
                return
            }
            UIApplication.shared.open(facebookAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            result(false)
        }
    }
    
    func shareVideoToFacebookReels(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let appId = arguments["appId"] as! String
        let filePath = arguments["filePath"] as? String
        
        guard let assetPath = filePath else {
            result(false)
            return
        }
        
        let backgroundUrl = URL(fileURLWithPath: assetPath)
        let backgroundVideoData = try? Data(contentsOf: backgroundUrl)
        
        guard let videoData = backgroundVideoData else {
            result(false)
            return
        }
        
        guard let facebookURL = URL(string: "facebook-reels://share") else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(facebookURL)) {
            let pasteboardItems = [
                [
                    "com.facebook.sharedSticker.backgroundVideo": videoData,
                    "com.facebook.sharedSticker.appID": appId
                ]
            ]
            let pasteboardOptions = [
                UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
            ]
            UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
            UIApplication.shared.open(facebookURL, options: [:])
            result(true)
        } else {
            guard let facebookAppStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id284882215") else {
                result(false)
                return
            }
            UIApplication.shared.open(facebookAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            result(false)
        }
    }
    
    func shareCameraEffectToFacebook(result: @escaping FlutterResult, arguments: [String : Any?]) {
        var cameraTexturesKey = ""
        var cameraTexturesUrl: String? = nil
        if let cameraEffectTextures = arguments["cameraEffectTextures"] as? [String : Any] {
            cameraTexturesKey = cameraEffectTextures["textureKey"] as! String
            cameraTexturesUrl = cameraEffectTextures["textureUrl"] as? String
        }
        
        var cameraArgumentsKey = ""
        var cameraArgumentsValue: String? = nil
        var cameraArgumentsArray : [String]?
        if let cameraEffectArguments = arguments["cameraEffectArguments"] as? [String : Any] {
            cameraArgumentsValue = cameraEffectArguments["argumentValue"] as? String
            cameraArgumentsArray = cameraEffectArguments["argumentList"] as? [String]
            cameraArgumentsKey = cameraEffectArguments["argumentKey"] as! String
        }
        
        let effectId = arguments["effectId"] as? String
        let contentUrl = arguments["contentUrl"] as? String
        let pageId = arguments["pageId"] as? String
        let peopleIds = arguments["peopleIds"] as?[String]
        let ref: String? = arguments["ref"] as? String
        let placeId: String? = arguments["placeId"] as? String
        let hashtag: String? = arguments["hashtag"] as? String
        
        guard let facebookURL = URL(string: "fb://") else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(facebookURL)) {
            let content = ShareCameraEffectContent()
            
            let effectTextures = CameraEffectTextures()
            if let texturesUrl = cameraTexturesUrl {
                let fileURL = URL(fileURLWithPath: texturesUrl)
                createAssetURL(url: fileURL, result: result, fileType: PHAssetMediaType.image) { asset in
                    DispatchQueue.main.async {
                        effectTextures.set(self.getUIImage(asset: asset), forKey: cameraTexturesKey)
                    }
                }
            }
            content.effectTextures = effectTextures
            
            let effectArguments = CameraEffectArguments()
            effectArguments.set(cameraArgumentsValue, forKey: cameraArgumentsKey)
            effectArguments.set(cameraArgumentsArray, forKey: cameraArgumentsKey)
            content.effectArguments = effectArguments
            
            content.ref = ref
            if let id = effectId {
                content.effectID = id
            }
            content.hashtag = Hashtag(hashtag ?? "")
            if let u = contentUrl {
                if let url = URL(string: u) {
                    content.contentURL = url
                }
            }
            content.peopleIDs = peopleIds ?? [String]()
            content.placeID = placeId
            content.pageID = pageId
            
            let shareDialog = ShareDialog(viewController: UIApplication.shared.windows.first!.rootViewController, content: content, delegate: self)
            
            do {
                try shareDialog.validate()
            } catch {
                result("shareCameraEffectToFacebookError: \(error)")
                return
            }
            
            
            shareDialog.show()
        } else {
            guard let facebookAppStoreLink = URL(string: "itms-apps://itunes.apple.com/uss/app/apple-store/id284882215") else {
                result(false)
                return
            }
            UIApplication.shared.open(facebookAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            result(false)
        }
    }
    
    var instaAssetToDelete: PHAsset?
    func shareFileToInstagram(result: @escaping FlutterResult, arguments: [String : Any?])  {
        let filePath = arguments["filePath"] as? String
        let fileType = arguments["fileType"] as! String
        
        guard let instagramURL = URL(string: "instagram://app") else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(instagramURL)) {
            let fileURL = URL(fileURLWithPath: filePath ?? "")
            let type = fileType == "video" ? PHAssetMediaType.video : PHAssetMediaType.image
            createAssetURL(url: fileURL, result: result, fileType: type) { asset in
                DispatchQueue.main.async {
                    self.instaAssetToDelete = asset
                    let localIdentifier = asset.localIdentifier
                    let u = "instagram://library?LocalIdentifier=" + localIdentifier
                    
                    guard let url = URL(string: u) else {
                        result(false)
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        result(true)
                    } else {
                        result(false)
                    }
                }
            }
        } else {
            guard let instagramStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id389801252") else {
                result(false)
                return
            }
            UIApplication.shared.open(instagramStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            
            result(false)
        }
    }
    
    func sendMessageToInstagram(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let message = arguments["message"] as? String
        
        guard let instagramURL = URL(string: "instagram://app") else {
            result(false)
            return
        }
        
        guard let mess = message else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(instagramURL)) {
            let urlString = "instagram://sharesheet?text=\(mess)"
            let instaUrl = URL.init(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            
            if UIApplication.shared.canOpenURL(instaUrl!) {
                UIApplication.shared.open(instaUrl!)
                result(true)
            } else {
                result(false)
            }
        } else {
            guard let instagramStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id389801252") else {
                result(false)
                return
            }
            UIApplication.shared.open(instagramStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            
            result(false)
        }
    }
    
    func shareFileToMessenger(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let fileType = arguments["fileType"] as! String
        
        if (fileType == "video") {
            shareVideoToMessenger(result: result, arguments: arguments)
        } else {
            sharePhotoToMessenger(result: result, arguments: arguments)
        }
    }
    
    private func shareVideoToMessenger(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let filePath: String? = arguments["filePath"] as? String
        let pageId: String? = arguments["pageId"] as? String
        let ref: String? = arguments["ref"] as? String
        let peopleIds: [String]? = arguments["peopleIds"] as? [String]
        let placeId: String? = arguments["placeId"] as? String
        let hashtag: String? = arguments["hashtag"] as? String
        let contentUrl: String? = arguments["contentUrl"] as? String
        let previewImagePath: String? = arguments["previewImagePath"] as? String
        
        guard let path = filePath else {
            result(false)
            return
        }
        
        guard let messengerURL = URL(string: "https://m.me") else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(messengerURL)) {
            let content: ShareVideoContent = ShareVideoContent()
            let fileURL = URL(fileURLWithPath: path)
            var video: ShareVideo!
            
            createAssetURL(url: fileURL, result: result, fileType: PHAssetMediaType.video) { asset in
                DispatchQueue.main.async {
                    if let previewPath = previewImagePath {
                        let previewURL = URL(fileURLWithPath: previewPath)
                        self.createAssetURL(url: previewURL, result: result, fileType: PHAssetMediaType.image) {
                            previewAsset in DispatchQueue.main.async {
                                let photo = SharePhoto(image: self.getUIImage(asset: previewAsset), isUserGenerated: true)
                                video = ShareVideo(videoAsset: asset, previewPhoto: photo)
                            }
                        }
                    } else {
                        video = ShareVideo(videoAsset: asset)
                    }
                    
                    content.video = video
                    content.ref = ref
                    
                    if let ht = hashtag {
                        content.hashtag = Hashtag(ht)
                    }
                    
                    if let u = contentUrl {
                        if let url = URL(string: u) {
                            content.contentURL = url
                        }
                    }
                    content.peopleIDs = peopleIds ?? [String]()
                    content.placeID = placeId
                    content.pageID = pageId
                    
                    let shareDialog = MessageDialog(content: content, delegate: self)
                    
                    do {
                        try shareDialog.validate()
                    } catch {
                        result("shareVideoToMessengerError: \(error)")
                        return
                    }
                    
                    shareDialog.show()
                }
            }
            
        } else {
            guard let messengerAppStoreLink = URL(string: "itms-apps://itunes.apple.com/uss/app/apple-store/id454638411") else {
                result(false)
                return
            }
            UIApplication.shared.open(messengerAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            result(false)
        }
    }
    
    private func sharePhotoToMessenger(result: @escaping FlutterResult, arguments: [String : Any?])  {
        let filePath: String? = arguments["filePath"] as? String
        let pageId: String? = arguments["pageId"] as? String
        let ref: String? = arguments["ref"] as? String
        let peopleIds: [String]? = arguments["peopleIds"] as? [String]
        let placeId: String? = arguments["placeId"] as? String
        let hashtag: String? = arguments["hashtag"] as? String
        let contentUrl: String? = arguments["contentUrl"] as? String
        
        guard let messengerURL = URL(string: "https://m.me") else {
            result(false)
            return
        }
        
        guard let path = filePath else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(messengerURL)) {
            let content = SharePhotoContent()
            let fileURL = URL(fileURLWithPath: path)
            
            createAssetURL(url: fileURL, result: result, fileType: PHAssetMediaType.image) { asset in
                DispatchQueue.main.async {
                    let photo = SharePhoto(image: self.getUIImage(asset: asset), isUserGenerated: true)
                    content.photos = [photo]
                    content.ref = ref
                    
                    if let ht = hashtag {
                        content.hashtag = Hashtag(ht)
                    }
                    if let u = contentUrl {
                        if let url = URL(string: u) {
                            content.contentURL = url
                        }
                    }
                    content.peopleIDs = peopleIds ?? [String]()
                    content.placeID = placeId
                    content.pageID = pageId
                    
                    let shareDialog = MessageDialog(content: content, delegate: self)
                    
                    do {
                        try shareDialog.validate()
                    } catch {
                        result("sharePhotoToMessengerError: \(error)")
                        return
                    }
                    
                    shareDialog.show()
                }
            }
        } else {
            guard let messengerAppStoreLink = URL(string: "itms-apps://itunes.apple.com/uss/app/apple-store/id454638411") else {
                result(false)
                return
            }
            UIApplication.shared.open(messengerAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            result(false)
        }
    }
    
    func sendMessageToMessenger(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let pageId: String? = arguments["pageId"] as? String
        let ref: String? = arguments["ref"] as? String
        let peopleIds: [String]? = arguments["peopleIds"] as? [String]
        let placeId: String? = arguments["placeId"] as? String
        let hashtag: String? = arguments["hashtag"] as? String
        var contentURL: String = ""
        if let mess = arguments["message"] as? String {
            contentURL = mess
        }
        if let contentUrl = arguments["contentUrl"] as? String {
            contentURL = contentUrl
        }
        
        let quote: String? = arguments["quote"] as? String
        
        guard let messengerURL = URL(string: "fb-messenger://") else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(messengerURL)) {
            let content: ShareLinkContent = ShareLinkContent()
            content.ref = ref
            content.hashtag = Hashtag(hashtag ?? "")
            content.quote = quote
            content.contentURL = URL(string: contentURL)
            content.peopleIDs = peopleIds ?? [String]()
            content.placeID = placeId
            content.pageID = pageId
            
            let messageDialog = MessageDialog(content: content, delegate: self)
            
            do {
                try messageDialog.validate()
            } catch {
                result("shareLinkContentToMessengeriOSError: \(error)")
                return
            }
            
            messageDialog.show()
        } else {
            guard let messengerAppStoreLink = URL(string: "itms-apps://itunes.apple.com/uss/app/apple-store/id454638411") else {
                result(false)
                return
            }
            UIApplication.shared.open(messengerAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            result(false)
        }
    }
    
    func sendMessageToTelegram(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let message = arguments["message"] as? String
        
        guard let telegramURL = URL(string: "https://telegram.me") else {
            result(false)
            return
        }
        
        guard let mess = message else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(telegramURL)) {
            let urlString = "tg://msg?text=\(mess)"
            let tgUrl = URL.init(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            
            if UIApplication.shared.canOpenURL(tgUrl!) {
                UIApplication.shared.open(tgUrl!)
            } else {
                result(false)
            }
        } else {
            guard let telegramStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id686449807") else {
                result(false)
                return
            }
            UIApplication.shared.open(telegramStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            
            result(false)
        }
    }
    
    func openTelegramDirectMessage(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let username = arguments["username"] as? String
        
        guard let telegramURL = URL(string: "https://telegram.me") else {
            result(false)
            return
        }
        
        guard let receiver = username else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(telegramURL)) {
            let urlString = "tg://resolve?domain=\(receiver)"
            let tgUrl = URL.init(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            
            if UIApplication.shared.canOpenURL(tgUrl!) {
                UIApplication.shared.open(tgUrl!)
            } else {
                result(false)
            }
        } else {
            guard let telegramStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id686449807") else {
                result(false)
                return
            }
            UIApplication.shared.open(telegramStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            
            result(false)
        }
    }
    
    func openTelegramChannelViaShareLink(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let inviteLink = arguments["inviteLink"] as? String
        
        guard let telegramURL = URL(string: "https://telegram.me") else {
            result(false)
            return
        }
        
        guard let link = inviteLink else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(telegramURL)) {
            let tgUrl = URL(string: link)
            
            if UIApplication.shared.canOpenURL(tgUrl!) {
                UIApplication.shared.open(tgUrl!)
            } else {
                result(false)
            }
        } else {
            guard let telegramStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id686449807") else {
                result(false)
                return
            }
            UIApplication.shared.open(telegramStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            
            result(false)
        }
    }
    
    func shareFileToTelegram(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let filePath = arguments["filePath"] as? String
        let message = arguments["message"] as? String
        
        guard let path = filePath else {
            result(false)
            return
        }
        
        let url = URL(fileURLWithPath: path)
        var shareItems : [Any] = [url]
        
        if let mess = message {
            shareItems.append(mess)
        }
        
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        
        guard let view = UIApplication.shared.keyWindow?.rootViewController?.view else {
            result(false)
            return
        }
        
        activityViewController.popoverPresentationController?.sourceView = view // so that iPads won't crash
        UIApplication.shared.keyWindow?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func sendMessageToWhatsApp(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let message = arguments["message"] as? String
        
        guard let whatsAppURL = URL(string: "whatsapp://app") else {
            result(false)
            return
        }
        
        guard let mess = message else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(whatsAppURL)) {
            let urlString = "whatsapp://send?text=\(mess)"
            let waUrl = URL.init(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            
            if UIApplication.shared.canOpenURL(waUrl!) {
                UIApplication.shared.open(waUrl!)
            } else {
                result(false)
            }
        } else {
            guard let whatsAppStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id310633997") else {
                result(false)
                return
            }
            UIApplication.shared.open(whatsAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            
            result(false)
        }
    }
    
    func shareFileToWhatsApp(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let fileType = arguments["fileType"] as? String
        let filePath = arguments["filePath"] as? String
        let message = arguments["message"] as? String
        
        guard let whatsAppURL = URL(string: "whatsapp://app") else {
            result(false)
            return
        }
        
        guard let path = filePath else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(whatsAppURL)) {
            var type = ""
            
            switch fileType {
            case "image":
                type = "net.whatsapp.image"
                break
            case "video":
                type = "net.whatsapp.movie"
                break;
            case "audio":
                type = "net.whatsapp.audio"
                break
            case "pdf":
                type = "net.whatsapp.pdf"
                break
            case "vcCard":
                type = "net.whatsapp.vcard"
                break
            default:
                break
            }
            
            let fileUrl = URL(fileURLWithPath: path)
            let docController = UIDocumentInteractionController(url: fileUrl)
            docController.uti = type
            docController.annotation = [message]
            
            guard let view = UIApplication.shared.keyWindow?.rootViewController?.view else {
                result(false)
                return
            }
            
            docController.presentOpenInMenu(from: CGRect.zero, in: view, animated: true)
        } else {
            guard let whatsAppStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id310633997") else {
                result(false)
                return
            }
            UIApplication.shared.open(whatsAppStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            
            result(false)
        }
    }
    
    func createTwitterTweet(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let title = arguments["title"] as! String
        let attachedUrl = arguments["attachedUrl"] as? String
        let hashtags = arguments["hashtags"] as? [String]
        let via = arguments["via"] as? String
        let related = arguments["related"] as? [String]
        
        guard let twitterURL = URL(string: "twitter://") else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(twitterURL)) {
            var urlString: String!
            
            let ht = hashtags?.joined(separator: ",")
            let re = related?.joined(separator: ",")
            
            urlString = "https://twitter.com/intent/tweet?text=\(title)"
            
            if (attachedUrl != nil) {
                urlString += "&url=\(attachedUrl!)"
            }
            if (via != nil) {
                urlString += "&via=\(via!)"
            }
            if (ht != nil) {
                urlString += "&hashtags=\(ht!)"
            }
            if (re != nil) {
                urlString += "&related=\(re!)"
            }
            
            let twUrl = URL.init(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            
            if UIApplication.shared.canOpenURL(twUrl!) {
                UIApplication.shared.open(twUrl!)
            } else {
                result(false)
            }
        } else {
            guard let twitterStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id333903271") else {
                result(false)
                return
            }
            UIApplication.shared.open(twitterStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            
            result(false)
        }
    }
    
    private var store: TWTRSessionStore {
        return TWTRTwitter.sharedInstance().sessionStore
    }
    func shareFileToTwitter(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let filePath = arguments["filePath"] as? String
        let fileType = arguments["fileType"] as? String
        let title = arguments["title"] as? String
        let iOSConsumerKey = arguments["iOSConsumerKey"] as? String
        let iOSSecretKey = arguments["iOSSecretKey"] as? String
        
        guard let twitterURL = URL(string: "twitter://") else {
            result(false)
            return
        }
        
        guard let path = filePath else {
            result(false)
            return
        }
        
        guard let consumerKey = iOSConsumerKey else {
            result(false)
            return
        }
        
        guard let secretKey = iOSSecretKey else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(twitterURL)) {
            switch fileType {
            case "video":
                TWTRTwitter.sharedInstance().start(withConsumerKey: consumerKey, consumerSecret: secretKey)
                
                let videoURL = URL(fileURLWithPath: path)
                guard let userId = store.session()?.userID else { return }
                let client = TWTRAPIClient.init(userID: userId)
                
                // Get data from Url
                let videoData = try? Data(contentsOf: videoURL)
                guard let data = videoData else {
                    result(false)
                    return
                }
                
                client.sendTweet(withText: title ?? "", videoData: data) {
                    (tweet, error) in
                    
                    if let e = error {
                        // Handle error
                        result(e.localizedDescription)
                    } else {
                        // Handle Success
                        result(tweet)
                    }
                }
                break
            case "image":
                TWTRTwitter.sharedInstance().start(withConsumerKey: consumerKey, consumerSecret: secretKey)
                
                guard let userId = store.session()?.userID else { return }
                let client = TWTRAPIClient.init(userID: userId)
                
                var photoAsset: UIImage!
                createAssetURL(url: URL(fileURLWithPath: path), result: result, fileType: PHAssetMediaType.image) {
                    asset in DispatchQueue.main.async {
                        photoAsset = self.getUIImage(asset: asset)
                        
                        client.sendTweet(withText: title ?? "", image: photoAsset) {
                            (tweet, error) in
                            
                            if let e = error {
                                // Handle error
                                result(e.localizedDescription)
                            } else {
                                // Handle Success
                                result(tweet)
                            }
                        }
                    }
                }
                break
            default:
                break
            }
        } else {
            guard let twitterStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id333903271") else {
                result(false)
                return
            }
            UIApplication.shared.open(twitterStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            
            result(false)
        }
    }
    
    func shareFilesToTikTok(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let fileUrls = arguments["fileUrls"] as? [String?]
        let fileType = arguments["fileType"] as! String
        let shareFormat = arguments["shareFormat"] as! String
        let landedPageType = arguments["landedPageType"] as! String
        let hashtag = arguments["hashtag"] as? [String]
        
        // https://www.tiktok.com/en/
        // snssdk1180://
        // musically://
        guard let tikTokURL = URL(string: "snssdk1233://") else {
            result(false)
            return
        }
        
        guard let urls = fileUrls else {
            flutterResult(false)
            return
        }
        
        // if (UIApplication.shared.canOpenURL(tikTokURL)) {
        //     let request = TikTokOpenSDKShareRequest()
        //     var shareFiles = [String]()
        //     var type: PHAssetMediaType!
        //     var mediaType: TikTokOpenSDKShareMediaType!
        //     var format: TikTokOpenSDKShareFormatType!
        //     var pageType: TikTokOpenSDKLandedPageType!
            
        //     if (fileType == "image") {
        //         type = PHAssetMediaType.image
        //         mediaType = TikTokOpenSDKShareMediaType.image
        //     } else {
        //         type = PHAssetMediaType.video
        //         mediaType = TikTokOpenSDKShareMediaType.video
        //     }
            
        //     if (shareFormat == "normal") {
        //         format = TikTokOpenSDKShareFormatType.normal
        //     } else {
        //         format = TikTokOpenSDKShareFormatType.greenScreen
        //     }
            
        //     if (landedPageType == "clip") {
        //         pageType = TikTokOpenSDKLandedPageType.clip
        //     } else if (landedPageType == "edit") {
        //         pageType = TikTokOpenSDKLandedPageType.edit
        //     } else {
        //         pageType = TikTokOpenSDKLandedPageType.publish
        //     }
            
        //     for (i, url) in urls.enumerated() {
        //         if let u = url {
        //             createAssetURL(url: URL(fileURLWithPath: u), result: result, fileType: type) {
        //                 asset in DispatchQueue.main.async {
        //                     shareFiles.append(asset.localIdentifier)
                            
        //                     if (i == urls.count - 1) {
        //                         request.localIdentifiers = shareFiles
        //                         request.mediaType = mediaType
        //                         request.shareFormat = format
        //                         request.landedPageType = pageType
        //                         request.hashtag = hashtag?.joined(separator: ",") ?? ""
                                
        //                         request.send(completionBlock: { response in
        //                             if (response.isSucceed) {
        //                                 result(true)
        //                                 return
        //                             }
                                    
        //                             result(false)
        //                         })
        //                     }
        //                 }
        //             }
        //         }
        //     }
        //     return
        // } else {
        //     guard let tikTokStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id1235601864") else {
        //         result(false)
        //         return
        //     }
        //     UIApplication.shared.open(tikTokStoreLink, options: [:], completionHandler: { _Arg in
                
        //     })
            
        //     result(false)
        // }
    }
    
    func openTikTokUserPage(result: @escaping FlutterResult, arguments: [String : Any?]) {
        let username = arguments["username"] as! String
        
        // https://www.tiktok.com/en/
        // snssdk1180://
        // musically://
        guard let tikTokURL = URL(string: "snssdk1233://") else {
            result(false)
            return
        }
        
        if (UIApplication.shared.canOpenURL(tikTokURL)) {
            let urlString = "https://www.tiktok.com/\(username)"
            let tiUrl = URL.init(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            
            if UIApplication.shared.canOpenURL(tiUrl!) {
                UIApplication.shared.open(tiUrl!)
            } else {
                result(false)
            }
        } else {
            guard let tikTokStoreLink = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id1235601864") else {
                result(false)
                return
            }
            UIApplication.shared.open(tikTokStoreLink, options: [:], completionHandler: { _Arg in
                
            })
            
            result(false)
        }
    }
    
    func createAssetURL(url: URL, result: @escaping FlutterResult, fileType: PHAssetMediaType, completion: @escaping (PHAsset) -> Void) {
        switch fileType {
        case PHAssetMediaType.image:
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
            }) { saved, error in
                if saved {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d",
                                                         PHAssetMediaType.image.rawValue,
                                                         PHAssetMediaType.video.rawValue)
                    
                    guard let fetchResult = PHAsset.fetchAssets(with: fetchOptions).firstObject else {
                        return
                    }
                    completion(fetchResult)
                } else {
                    result(false)
                }
            }
            break
        case PHAssetMediaType.video:
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { saved, error in
                if saved {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d",
                                                         PHAssetMediaType.video.rawValue,
                                                         PHAssetMediaType.image.rawValue)
                    
                    guard let fetchResult = PHAsset.fetchAssets(with: fetchOptions).firstObject else {
                        return
                    }
                    completion(fetchResult)
                } else {
                    result(false)
                }
            }
            break
        default:
            return
        }
    }
    
    func getUIImage(asset: PHAsset) -> UIImage {
        var img: UIImage!
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }
    
    public func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        self.deleteCurrentAsset()
        flutterResult(true)
    }
    
    public func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        self.deleteCurrentAsset()
        flutterResult(false)
    }
    
    public func sharerDidCancel(_ sharer: Sharing) {
        self.deleteCurrentAsset()
        flutterResult(false)
    }
    
    private func deleteCurrentAsset() {
        //        guard let currentAsset = assetToDelete else{
        //            return
        //        }
        //        PHPhotoLibrary.shared().performChanges({
        //            PHAssetChangeRequest.deleteAssets([currentAsset] as NSArray)
        //        })
    }
}
