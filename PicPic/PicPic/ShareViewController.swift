//
//  ShareViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 11. 5..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import FBSDKShareKit
import Photos
import SpringIndicator
import AssetsLibrary
import Accounts
import Social



class ShareViewController: UIViewController,UIAlertViewDelegate{

    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var post_id : String!
    var url : String!
    let imageURL = ImageURL()
    let log = LogPrint()
    var alert : UIAlertView!
    
    @IBOutlet weak var repicButton: UIButton!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var kakaoButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var gifDown: UIButton!
    
    @IBOutlet weak var loadingBack: UIView!
    @IBOutlet weak var spring: SpringIndicator!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var picterestButton: UIButton!
    @IBOutlet weak var tumblrButton: UIButton!
    @IBOutlet weak var shareView: UIView!
    var _hud: MBProgressHUD = MBProgressHUD()
    
    var repicState = false
    
    
    @IBOutlet weak var backView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        _hud.mode = MBProgressHUDModeIndeterminate
        _hud.center = self.view.center
        self.view.addSubview(_hud)
        _hud.hide(false)
        
        self.shareView.layer.cornerRadius = 3
        self.shareView.layer.masksToBounds = true
        
        if repicState {
            repicButton.setTitle("             \(self.appdelegate.ment["repic_delete"].stringValue)", forState: .Normal)
        }else {
            repicButton.setTitle("             \(self.appdelegate.ment["repic_store"].stringValue)", forState: .Normal)
        }
        linkButton.setTitle("             \(self.appdelegate.ment["popup3_link"].stringValue)", forState: .Normal)
        kakaoButton.setTitle("             \(self.appdelegate.ment["popup3_kakao"].stringValue)", forState: .Normal)
        facebookButton.setTitle("             \(self.appdelegate.ment["popup3_facebook"].stringValue)", forState: .Normal)
        gifDown.setTitle("             \(self.appdelegate.ment["popup2_gif_download"].stringValue)", forState: .Normal)
        twitterButton.setTitle("             \(self.appdelegate.ment["popup3_twitter"].stringValue)", forState: .Normal)
        picterestButton.setTitle("             \(self.appdelegate.ment["popup3_pinterest"].stringValue)", forState: .Normal)
        tumblrButton.setTitle("             \(self.appdelegate.ment["popup3_tumblr"].stringValue)", forState: .Normal)
        
        loading(false)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        backView.addGestureRecognizer(tap)
        
    }
    
    func loading(state:Bool){
        if state {
            self.loadingBack.hidden = false
            self.spring.startAnimation()
        }else {
            self.loadingBack.hidden = true
            self.spring.stopAnimation(true)
        }
    }
    
    func DismissKeyboard(){
//        var count = (self.navigationController?.viewControllers.count)!-2
//        if count < 0 {
//            count = 0
//        }
//        let a = self.navigationController?.viewControllers[count] as! SubViewController
//        if a.type == "post" {
//            let post = self.navigationController?.viewControllers[count]as! PostPageViewController
//            post.postImage.enterForeground()
//        }
        self.view.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func down(sender: AnyObject) {
        
        self._hud.show(true)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { () -> Void in
            var path = self.imageURL.gifImageUrl(self.url)
            let fileManager = NSFileManager.defaultManager()
            let data = NSData(contentsOfURL: NSURL(string: path)!)
            let formatter : NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let date = NSDate()
            let currentDate = formatter.stringFromDate(date)
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let gifsFolder = "\(documentDirectory)/gifs"
            let gifName = currentDate + ".gif"
            path = String(format: "%@/%@", arguments: [gifsFolder, gifName])
            fileManager.createFileAtPath(path, contents: data, attributes: nil)
            print(path)
            var photosAsset: PHFetchResult!
            var collection: PHAssetCollection!
            var assetCollectionPlaceholder: PHObjectPlaceholder!
            
            //Make sure we have custom album for this app if haven't already
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", "PicPic")
            collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions).firstObject as? PHAssetCollection
            
            //if we don't have a special album for this app yet then make one
            if collection == nil {
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle("PicPic")
                    assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
                    }, completionHandler: { success, error in
                        if success {
                            let collectionFetchResult = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([assetCollectionPlaceholder.localIdentifier], options: nil)
                            print(collectionFetchResult)
                            collection = collectionFetchResult.firstObject as! PHAssetCollection
                        }
                })
            }
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImageAtFileURL(NSURL(string: path)!)
                print(assetRequest)
                let assetPlaceholder = assetRequest!.placeholderForCreatedAsset
                photosAsset = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
                let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: collection, assets: photosAsset)
                albumChangeRequest!.addAssets([assetPlaceholder!])
                }, completionHandler: { success, error in
                    if success {
                        print("added video to album")
                        let alert = UIAlertView(title: "", message: self.appdelegate.ment["download_completed"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                        alert.show()
                        self._hud.hide(false)
                    }else if error != nil{
                        print("handle error since couldn't save video    ",error)
                        let alert = UIAlertView(title: "", message: self.appdelegate.ment["download_fail"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
                        alert.show()
                        self._hud.hide(false)
                    }
            })
        }
//        PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
//            switch status{
//            case .Authorized:
//                dispatch_async(dispatch_get_main_queue(), {
//                    print("Authorized")
//                    self.loading(true)
//                    print("fail")
//                    let image = NSData(contentsOfURL: NSURL(string:path)!)
//                    
//                    ALAssetsLibrary().writeImageDataToSavedPhotosAlbum(image, metadata: nil, completionBlock: { (assetURL: NSURL!, error: NSError!) -> Void in
//                        print(assetURL)
//                        if error == nil {
//                            self.loading(false)
//                            let alert = UIAlertView(title: "", message: self.appdelegate.ment["download_completed"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
//                            alert.show()
//                        }else {
//                            self.loading(false)
//                            let alert = UIAlertView(title: "", message: self.appdelegate.ment["download_fail"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
//                            alert.show()
//                        }
//                        
//                    })
//                })
//                break
//            case .Denied:
//                dispatch_async(dispatch_get_main_queue(), {
//                    print("Denied")
//                    let alert = UIAlertView(title: "", message: self.appdelegate.ment["access_error"].stringValue, delegate: nil, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue)
//                    alert.show()
//                })
//                break
//            default:
//                dispatch_async(dispatch_get_main_queue(), {
//                    print("Default")
//                })
//                break
//            }
//        })
    }
    
    
    @IBAction func repic(sender: AnyObject) {
        var message : JSON = ["myId":self.appdelegate.email,"post_id":self.post_id]
        
        if repicState {
            self.appdelegate.doIt(206, message: message) { (readData) -> () in
                self.log.log("repic response data : \(readData)")
                self.alert = UIAlertView(title: "", message: self.appdelegate.ment["repic_del_complete"].stringValue, delegate: self, cancelButtonTitle: nil)
                self.alert.show()
                NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("clearAlert:"), userInfo: nil, repeats: false)
            }
        }else {
            self.appdelegate.doIt(205, message: message) { (readData) -> () in
                self.log.log("repic response data : \(readData)")
                if readData["duplicate_yn"].string! == "Y" {
                    self.alert = UIAlertView(title: "", message: self.appdelegate.ment["repic_add_aleady"].stringValue, delegate: self, cancelButtonTitle: nil)
                    self.alert.show()
                    NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("clearAlert:"), userInfo: nil, repeats: false)
                }else {
                    self.alert = UIAlertView(title: "", message: self.appdelegate.ment["repic_add_complete"].stringValue, delegate: self, cancelButtonTitle: nil)
                    self.alert.show()
                    NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("clearAlert:"), userInfo: nil, repeats: false)
                }
            }
        }
        DismissKeyboard()
    }
    
    func clearAlert(timer : NSTimer) {
        if alert != nil {
            alert.dismissWithClickedButtonIndex(0, animated: true)
            alert = nil
        }
    }
    
    

    @IBAction func copyLink(sender: AnyObject) {
        let clipboar = UIPasteboard.generalPasteboard()
        clipboar.string = imageURL.imageurl(self.url)
        log.log(imageURL.imageurl(self.url))
        DismissKeyboard()
    }
    @IBAction func kakao(sender: AnyObject) {
        
        log.log(url)
        let alert = UIAlertView(title: "", message: self.appdelegate.ment["not_supported_kakao"].stringValue, delegate: self, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue, otherButtonTitles: self.appdelegate.ment["popup_cancel"].stringValue)
        alert.show()
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            let temp = self.url.componentsSeparatedByString("_2.")
            let url = imageURL.imageurl("\(temp[0]).jpg")
            let action = KakaoTalkLinkAction.createAppAction(.IOS, devicetype: .Phone, execparam: ["post":"\(self.post_id)"])
            let android = KakaoTalkLinkAction.createAppAction(.Android, devicetype: .Phone, execparam: nil)
//            let image : KakaoTalkLinkObject = KakaoTalkLinkObject.createImage(url, width: 138, height: 80)
            log.log("gifurl : \(imageURL.gifImageUrl(self.url))")
            let gifurl = KakaoTalkLinkObject.createLabel(imageURL.gifImageUrl(self.url))
            let applink : KakaoTalkLinkObject = KakaoTalkLinkObject.createAppButton("PicPic", actions: [action,android])
            
            KOAppCall.openKakaoTalkAppLink([gifurl,applink])
            DismissKeyboard()
        }
    }
    
    @IBAction func facebook(sender: AnyObject) {
        var path = imageURL.gifImageUrl(url)
        log.log("\(path)")
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentTitle = "PicPic"
        content.contentURL = NSURL(string: path)
        let dialog = FBSDKShareDialog()
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.mode = FBSDKShareDialogMode.Automatic
        dialog.show()
        DismissKeyboard()
    }
    
    
    @IBAction func twitter(sender: AnyObject) {
        let twitter : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        let path = imageURL.gifImageUrl(url)
        let data = NSData(contentsOfURL: NSURL(string: path)!)!
        let im = UIImage.gifWithData(data)
        twitter.addImage(im)
        twitter.addURL(NSURL(string: path))
        twitter.completionHandler = {
            (result:SLComposeViewControllerResult) in
            if result == SLComposeViewControllerResult.Done {
                self.DismissKeyboard()
            }
        }
        self.presentViewController(twitter, animated: true, completion: nil)
    }
    //                        message["status"] = "Test Tweet with image"
    //https://api.twitter.com/1.1/statuses/update_with_media.json
    //                        let requestURL = NSURL(string:"https://api.twitter.com/1.1/statuses/update.json")
    
    
    func tweetWithImage(data:NSData)
    {
        
        let account = ACAccountStore()
        let accountType = account.accountTypeWithAccountTypeIdentifier(
            ACAccountTypeIdentifierTwitter)
        
        account.requestAccessToAccountsWithType(accountType, options: nil,
            completion: {(success: Bool, error: NSError!) -> Void in
                if success {
                    let arrayOfAccounts =
                    account.accountsWithAccountType(accountType)
                    
                    if arrayOfAccounts.count > 0 {
                        let twitterAccount = arrayOfAccounts.first as! ACAccount
                        var message = Dictionary<String, AnyObject>()
                        let requestURL = NSURL(string:"https://api.twitter.com/1.1/statuses/update_with_media.json")
                        let postRequest = Social.SLRequest(forServiceType:
                            SLServiceTypeTwitter,
                            requestMethod: SLRequestMethod.POST,
                            URL: requestURL,
                            parameters: message)
                        
                        postRequest.account = twitterAccount
                        postRequest.addMultipartData(data, withName: "media", type: nil, filename: nil)
                        
                        postRequest.performRequestWithHandler({
                            (responseData: NSData!,
                            urlResponse: NSHTTPURLResponse!,
                            error: NSError!) -> Void in
                            if let err = error {
                                print("Error : \(err.localizedDescription)")
                            }
                            if urlResponse.statusCode == 200 {
                                let alert = UIAlertView(title: "\(urlResponse.statusCode)", message: "", delegate: nil, cancelButtonTitle: "확인")
                                alert.show()
                                self.loading(false)
                            }else {
                                let alert = UIAlertView(title: "\(urlResponse.statusCode)", message: "", delegate: nil, cancelButtonTitle: "확인")
                                alert.show()
                                self.loading(false)
                            }
                            
                            
                            print("Twitter HTTP response \(urlResponse.statusCode)")
                            
                        })
                    }
                }
                else
                {
                }
        })
    }
    
    @IBAction func picterest(sender: AnyObject) {
        let path = imageURL.gifImageUrl(self.url)
                let imageaddr = "https://www.pinterest.com/pin/create/button/?url=http%3A%2F%2Fwww.picpic.world%2Fpic%2F\(self.post_id)&media=http%3A%2F%2Fgif.picpic.world%2F\(self.url)"
                let url = NSURL(string: imageaddr)
                let request = NSURLRequest(URL: url!)
                if(request.URL?.scheme == "http" || request.URL?.scheme == "https") {
                    UIApplication.sharedApplication().openURL(request.URL!)
                }
        DismissKeyboard()
    }
    
    @IBAction func tumblr(sender: AnyObject) {
        let path = imageURL.gifImageUrl(self.url)
                let imageaddr = "https://www.tumblr.com/widgets/share/tool?shareSource=legacy&canonicalUrl=&url=http://www.picpic.world/pic/\(self.post_id)&posttype=photo&content=http://gif.picpic.world/\(self.url)&caption=www.picpic.world"
                let url = NSURL(string: imageaddr)
                let request = NSURLRequest(URL: url!)
                if(request.URL?.scheme == "http" || request.URL?.scheme == "https") {
                    UIApplication.sharedApplication().openURL(request.URL!)
                }
        DismissKeyboard()
    }
    
//    https://www.pinterest.com/pin/create/button/?url=http%3A%2F%2Fwww.picpic.world%2Fpic%2FPOST0000000075&media=http%3A%2F%2Fgif.picpic.world%2F11134719986825491442834036723_2.gif
    
    
    
}
