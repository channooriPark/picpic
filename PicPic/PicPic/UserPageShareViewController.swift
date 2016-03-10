//
//  UserPageShareViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2015. 12. 21..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import FBSDKShareKit
import Photos
import SpringIndicator
import AssetsLibrary
import Social
import Accounts

class UserPageShareViewController: UIViewController,UIAlertViewDelegate {

    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//    var post_id : String!
//    var url : String!
    var userId : String!
    let imageURL = ImageURL()
    let log = LogPrint()
    var alert : UIAlertView!
    @IBOutlet weak var spring: SpringIndicator!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var kakaoButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var tumblrButton: UIButton!
    @IBOutlet weak var pinterestButton: UIButton!
    @IBOutlet weak var loadingBackView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kakaoButton.setTitle("             \(self.appdelegate.ment["popup3_kakao"].stringValue)", forState: .Normal)
        facebookButton.setTitle("             \(self.appdelegate.ment["popup3_facebook"].stringValue)", forState: .Normal)
        twitterButton.setTitle("             \(self.appdelegate.ment["popup3_twitter"].stringValue)", forState: .Normal)
        pinterestButton.setTitle("             \(self.appdelegate.ment["popup3_pinterest"].stringValue)", forState: .Normal)
        tumblrButton.setTitle("             \(self.appdelegate.ment["popup3_tumblr"].stringValue)", forState: .Normal)
        loading(false)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        backView.addGestureRecognizer(tap)
        
//        let message : JSON = ["my_id":appdelegate.email,"user_id":userId]
//        print(message)
//        appdelegate.doIt(406, message: message) { (readData) -> () in
//            self.log.log("\(readData)")
//        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DismissKeyboard(){
        self.view.removeFromSuperview()
    }
    
    func loading(state:Bool){
        if state {
            self.loadingBackView.hidden = false
            self.spring.startAnimation()
        }else {
            self.loadingBackView.hidden = true
            self.spring.stopAnimation(true)
        }
    }
    
    @IBAction func kakao(sender: AnyObject) {
        let alert = UIAlertView(title: "", message: self.appdelegate.ment["not_supported_kakao"].stringValue, delegate: self, cancelButtonTitle: self.appdelegate.ment["popup_confirm"].stringValue, otherButtonTitles: self.appdelegate.ment["popup_cancel"].stringValue)
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if buttonIndex == alertView.cancelButtonIndex {
    let action = KakaoTalkLinkAction.createAppAction(.IOS, devicetype: .Phone, execparam: ["user":"\(self.userId)"])
    let android = KakaoTalkLinkAction.createAppAction(.Android, devicetype: .Phone, execparam: nil)
    //            let image : KakaoTalkLinkObject = KakaoTalkLinkObject.createImage(url, width: 138, height: 80)
    let applink : KakaoTalkLinkObject = KakaoTalkLinkObject.createAppButton("PicPic", actions: [action,android])
    
    KOAppCall.openKakaoTalkAppLink([applink])
    self.view.removeFromSuperview()
    }
    }
    
    @IBAction func facebook(sender: AnyObject) {
        print("facebook")
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentTitle = "PicPic"
        content.contentURL = NSURL(string: "picpic://user_name")
        let dialog = FBSDKShareDialog()
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.mode = FBSDKShareDialogMode.Automatic
        dialog.show()
        DismissKeyboard()
    }
    
    @IBAction func twitter(sender: AnyObject) {
        let twitter : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
//        let path = imageURL.gifImageUrl(url)
//        let data = NSData(contentsOfURL: NSURL(string: path)!)!
//        let im = UIImage.gifWithData(data)
//        twitter.addImage(im)
//        twitter.addURL(NSURL(string: path))
        twitter.completionHandler = {
            (result:SLComposeViewControllerResult) in
            if result == SLComposeViewControllerResult.Done {
                self.view.removeFromSuperview()
            }
            
        }
        self.presentViewController(twitter, animated: true, completion: nil)
    }
    
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
                        let postRequest = SLRequest(forServiceType:
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
    
    @IBAction func pinterest(sender: AnyObject) {
//        let path = imageURL.gifImageUrl(self.url)
//        let imageaddr = "https://www.pinterest.com/pin/create/button/?url=http%3A%2F%2Fwww.picpic.world%2Fpic%2F\(self.post_id)&media=http%3A%2F%2Fgif.picpic.world%2F\(self.url)"
//        let url = NSURL(string: imageaddr)
//        let request = NSURLRequest(URL: url!)
//        if(request.URL?.scheme == "http" || request.URL?.scheme == "https") {
//            UIApplication.sharedApplication().openURL(request.URL!)
//        }
    }
    
    @IBAction func tumblr(sender: AnyObject) {
//        let path = imageURL.gifImageUrl(self.url)
//        let imageaddr = "https://www.tumblr.com/widgets/share/tool?shareSource=legacy&canonicalUrl=&url=http://www.picpic.world/pic/\(self.post_id)&posttype=photo&content=http://gif.picpic.world/\(self.url)&caption=www.picpic.world"
//        let url = NSURL(string: imageaddr)
//        let request = NSURLRequest(URL: url!)
//        if(request.URL?.scheme == "http" || request.URL?.scheme == "https") {
//            UIApplication.sharedApplication().openURL(request.URL!)
//        }
    }
    
    
}
