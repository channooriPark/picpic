//
//  UserPageShareViewController.swift
//  PicPic
//
//  Created by 찬누리 박 on 2016. 3. 24..
//  Copyright © 2016년 찬누리 박. All rights reserved.
//

import UIKit
import SwiftyJSON
import FBSDKShareKit
import Photos
import SpringIndicator
import AssetsLibrary
import Accounts
import Social


class UserPageShareViewController: UIViewController ,UIAlertViewDelegate {
    
    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    //    var post_id : String!
    //    var url : String!
    var userId : String!
    let imageURL = ImageURL()
    let log = LogPrint()
    var alert : UIAlertView!
    var profileURL : String!
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
        let action = KakaoTalkLinkAction.createAppAction(.IOS, devicetype: .Phone, execparam: ["user_name":"\(self.userId)"])
        let android = KakaoTalkLinkAction.createAppAction(.Android, devicetype: .Phone, execparam: nil)
        let applink : KakaoTalkLinkObject = KakaoTalkLinkObject.createAppButton("PicPic", actions: [action,android])
        let message : KakaoTalkLinkObject = KakaoTalkLinkObject.createLabel("PicPic에서 " + self.userId + "님을 팔로우 해 보세요")
        let image : KakaoTalkLinkObject = KakaoTalkLinkObject.createImage(imageURL.imageurl(self.profileURL), width: 80, height: 80)
        
        KOAppCall.openKakaoTalkAppLink([applink,message,image])
        self.view.removeFromSuperview()
    }
    
    
    @IBAction func facebook(sender: AnyObject) {
        print("facebook")
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentTitle = "PicPic"
        let dialog = FBSDKShareDialog()
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.mode = FBSDKShareDialogMode.Automatic
        dialog.show()
        DismissKeyboard()
    }
    
    @IBAction func twitter(sender: AnyObject) {
        let data = NSData(contentsOfURL: NSURL(string: imageURL.imageurl(self.profileURL))!)
        tweetWithImage(data)
    }
    
    func tweetWithImage(data:NSData!)
    {
        let account = ACAccountStore()
        let accountType = account.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        let message = "PicPic에서 " + self.userId + "님을 팔로우 해 보세요"
        let arrayOfAccons = account.accountsWithAccountType(accountType)
        print(arrayOfAccons.count)
        for var acc in arrayOfAccons {
            print(acc)
        }
        
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
        let params : NSDictionary = ["screen_name":message,"forKey":"status","trim_user":"1","count":"1"]
        
        account.requestAccessToAccountsWithType(accountType, options: nil, completion: { (granted, error) -> Void in
            if granted {
                print("granted in  true")
                let arrayOfAccounts = account.accountsWithAccountType(accountType)
                if arrayOfAccons.count > 0 {
                    let acct = arrayOfAccounts[0]
                    var postRequest = Social.SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, URL: NSURL(string: "https://api.twitter.com/1.1/statuses/update_with_media.json"), parameters: ["status":message]as [NSObject:AnyObject])
                    postRequest.addMultipartData(data, withName: "media", type: "image/gif", filename: nil)
                    
                    postRequest.account = acct as! ACAccount
                    postRequest.performRequestWithHandler({ (responseData, urlResponse, error) -> Void in
                        if error != nil {
                            print(error.localizedDescription)
                        }else {
                            print("Twitter response, HTTP response : ",urlResponse.statusCode)
                        }
                    })
                }
            }else {
                print("granted false")
            }
            
            if error != nil {
                print(error.localizedDescription)
            }
            
        })
    }
    
    @IBAction func pinterest(sender: AnyObject) {
    }
    
    @IBAction func tumblr(sender: AnyObject) {
    }

}
