 //
//  AppDelegate.swift
//  socket
//
//  Created by 찬누리 박 on 2015. 9. 30..
//  Copyright © 2015년 찬누리 박. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON
import AEXML
import Alamofire
import Fabric
import TwitterKit
import OAuthSwift
import CryptoSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , UIAlertViewDelegate {

    private var reachability:Reachability!
    private let serverIp = "lb44196316nntH.hscc.hostwaycloud.co.kr"
    let log = LogPrint()
    var window: UIWindow?
    var token : NSString = ""
    var email : String!
    var standardUserDefaults = NSUserDefaults.standardUserDefaults()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var send_id : NSString!
    var userData : JSON = ["email":"","password":"","id":"","profile_picture":"noprofile.png","sex":"","bir_year":"","bir_mon":"","bir_day":"","register_form":"","country":"","device_id":"","push_token":"","regist_day":""]
    var language = NSLocale.preferredLanguages()[0]
    var login : LoginViewController!
    var moreToggle = false
    
    //MainView
    var contentview : ContentViewController!
    var tabbar : TabBarTestViewController!
    var main : HomeNativeViewController! //MainInterViewController!
    var testNavi : UINavigationController!
    var alram : AlramViewController!
    var second : SecondNativeViewController!
    var camera : CameraViewController!
    var myfeed : MyFeedNativeViewController! //MyFeedPageViewController!
    var signin : UINavigationController!
    var launch : LaunchViewController!
    
    
    
    
    //SubView
    var tags = NSMutableDictionary()
    var posts = NSMutableDictionary()
    var users = NSMutableDictionary()
    
    var controller = [SubViewController]()
    
    var ment: JSON =  ["friends_suggestion": "int"]
    var locale : String = ""
    
    var tagUsers = [String:String]()
    
    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"
    let subscriptionTopic = "/topics/global"
    var deviceId = ""
    var notiType = 0 //0이면 일반 1이면 알림을 통해서
    

//    var application : UIApplication!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        if launchOptions != nil {
            if let noti = launchOptions![UIApplicationLaunchOptionsRemoteNotificationKey] {
                notiType = 1
            }
        }
        application.applicationIconBadgeNumber = 0
        
        
        Fabric.with([Twitter.self])
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        GINInvite.applicationDidFinishLaunching()
        
        let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        print("알림 상태      :     ",application.currentUserNotificationSettings()?.types.rawValue)
        
        
        if application.currentUserNotificationSettings()?.types.rawValue == 0 {
            print("Not Notification")
            self.standardUserDefaults.setBool(false, forKey: "push")
        }else {
            print("Accept Notification")
            self.standardUserDefaults.setBool(true, forKey: "push")
        }
        
        
        
        
        
        if standardUserDefaults.valueForKey("uuid") == nil {
            var uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString
            uuid = uuid?.stringByReplacingOccurrencesOfString("-", withString: "")
            uuid = "iPhone"+uuid!+uuid!
            self.log.log("uuid         \(uuid)")
            
            standardUserDefaults.setValue(uuid, forKey: "uuid")
            
        }else {
            self.deviceId = standardUserDefaults.valueForKey("uuid")as! String
            self.log.log("uuid         \(self.deviceId)")
        }
        
        
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.grayColor()
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.whiteColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        
        // 뷰 콘트롤러의 각종 텍스트를 message로부터 가져와서 교체
        var fileName:String = ""
        let nation : NSArray = language.componentsSeparatedByString("-")
        locale = checkNational(nation[0] as! String)
        if locale == "ko_KR" {
            fileName = "strings"
        }else {
            fileName = "strings_en"
        }
        
        
        // 시스템이 한글이 아니면 fileName = "string_en"
        let xmlPath = NSBundle.mainBundle().pathForResource(fileName, ofType: "xml")
        let data = NSData(contentsOfFile: xmlPath!)
        
        do {
            let xmlDoc = try AEXMLDocument(xmlData: data!)
            
            for child in xmlDoc.root.children {
                if let value = child.value {
                    ment[child.attributes["name"]!].stringValue = value
                }else {
                    ment[child.attributes["name"]!].stringValue = ""
                }
            }
        } catch {
            
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"checkForReachability:", name: kReachabilityChangedNotification, object: nil)
        
        self.reachability = Reachability.reachabilityForInternetConnection()
        self.reachability.startNotifier()
        let currentState = self.reachability.currentReachabilityStatus()
        
        if currentState == NotReachable {
            let temp = self.ment["network_error_message"].stringValue.componentsSeparatedByString("&")
            let alert = UIAlertView(title: self.ment["network_error_title"].stringValue, message: "\(temp[0])\n\(temp[1])", delegate: self, cancelButtonTitle: self.ment["popup_confirm"].stringValue)
            alert.show()
        }else if currentState == ReachableViaWWAN {
            let temp = self.ment["network_warning_message"].stringValue.componentsSeparatedByString("&")
            let alert = UIAlertView(title: self.ment["network_warning_title"].stringValue, message: "\(temp[0])\n\(temp[1])", delegate: nil, cancelButtonTitle: self.ment["popup_confirm"].stringValue)
            alert.show()
        }
        loadView()
        
        if let url = launchOptions?[UIApplicationLaunchOptionsURLKey]as? NSURL {
            UIApplication.sharedApplication().openURL(url)
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationDidBecomeActive( application: UIApplication) {
        FBSDKAppEvents.activateApp()
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
    }
    // [END disconnect_gcm_service]
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        log.log("\(deviceToken)")
        self.token = deviceToken.description.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
        
        log.log("\(token)")
        
        if self.email != nil {
            let message : JSON = ["email":self.email,"device_id":self.deviceId,"push_token":self.token]
            self.doIt(221, message: message, callback: { (readData) -> () in
                print(readData)
            })
        }
        
        
    }
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
        error: NSError ) {
            print("Registration for remote notification failed with error: \(error.localizedDescription)")
    }
    
    // [START ack_message_reception]
    func application( application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
            print("Notification received: \(userInfo)")
    }
    
    
    //APNS DATA형식
    
    //"body" : "내용을 적어넣으세요",   "loc-key" : "CONTENT","loc-args" : [ "Jenna", "Frank" ]}
    
    //    {"aps" : { "alert" : {"loc-key" : "PL","loc-args" : [ "Channoori_Park" ]},"sound" : "default","badge" : 1},"push" : [ "post", "POST0000455109"]}
    
    //{"aps" : {"alert" : {"loc-args" : [ "Jun__Bae" ],"loc-key" : "FM"},"badge" : 1,"push" : [ "user", "901131246628906" ],"sound" : "default"}}
    
    //{"aps" : { "alert" : {"loc-key" : "KEY","loc-args" : [ "Channoori_Park" ,"aaa","bbb","ccc","ddd"]},"sound" : "default","badge" : 1},"push" : [ "post", "POST0000455109"]}
    
    //    {"aps" : {"alert":"안녕하세요","badge" : 5,"sound":"default","acme1" : [ "bang", "whiz"]}
    // "alert" : {"loc-key" : "PL","loc-args" : [ "Channoori_Park" ]},"sound" : "default","badge" : 1,}
    // "alert" : {"loc-args" : [ "Jun__Bae" ],"loc-key" : "PL"},"badge" : 1,"sound" : "default"}
    
    
    //    {"aps" : {"alert" : "You got your emails.","badge" : 1,"sound" : "default"}}
    
//    {aps: {acme1 = (post,POST0000455109); alert = {"loc-args" = ("Jun__Bae") "loc-key" = PL},badge = 1,sound = default}}
    
//    {"aps" : {"alert" : {"loc-args" : [ "Jun__Bae" ],"loc-key" : "PL"},"badge" : 1,"sound" : "default"},"push" : [ "post", "POST0000455109" ]}
    
    
    func application( application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
        fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
            
            print("fetch Notification received: \(userInfo)")
            var locMent = ""
            let user : JSON = JSON(userInfo)
            
            if application.applicationState == UIApplicationState.Inactive {
                if let infoUser = userInfo["push"] {
                    notiType = 0
                    let info = infoUser as! [String]
                    var url : NSURL!
                    if info.count > 2 {
                        url = NSURL(string: "picpic://\(info[0])/\(info[1])/\(info[2])")!
                    }else {
                        url = NSURL(string: "picpic://\(info[0])/\(info[1])")!
                    }
                    
                    if self.email != nil {
                        URLopenPage(url)
                    }else {
                        launch.pushData = url
                    }
                    print("url   :   ",url)
                }else {
                    self.notiType = 1
                }
            }else if application.applicationState == UIApplicationState.Active {
                
                if let lockey = user["aps"]["alert"]["loc-key"].string {
                    //custom pushnotification
                    let locargs = user["aps"]["alert"]["loc-args"].arrayValue
                    print(locargs)
                    locMent = lockey.localizedWithKey(lockey)
                    let tempArr = locMent.componentsSeparatedByString("%@")
                    print("tempArr count ",tempArr)
                    locMent = ""
                    
                    
                    for var i = 0; i<tempArr.count; i++ {
                        locMent += tempArr[i]
                        if i == locargs.count {
                            break
                        }
                        locMent += locargs[i].stringValue
                    }

                }else {
                    locMent = user["aps"]["alert"].stringValue
                }
                let alert = UIAlertController(title: "", message: locMent, preferredStyle: UIAlertControllerStyle.Alert)
                
                let button = UIAlertAction(title: self.ment["notification_action"].stringValue, style: .Default, handler: { (button) -> Void in
                    if let info = userInfo["push"] {
                        let infoArr = info as! [String]
                        print(infoArr[1])
                        
                        let url : NSURL = NSURL(string: "picpic://\(infoArr[0])/\(infoArr[1])")!
                        self.URLopenPage(url)
                        print("url   :   ",url)
                    }else {
                        self.notiType = 1
                        self.testNavi.popToRootViewControllerAnimated(true)
                        self.alram.alarmtableview.reloadData()
                        self.tabbar.click4(self.tabbar.button4)
                        
                    }
                })
                alert.addAction(button)
                
                let cancel = UIAlertAction(title: self.ment["notification_close"].stringValue, style: UIAlertActionStyle.Cancel, handler: { (cancel) -> Void in
                    
                })
                alert.addAction(cancel)
                self.testNavi.presentViewController(alert, animated: true, completion: nil)
            }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            exit(0)
        }
    }
    
    func URLopenPage(url:NSURL) {
        send_id = url.path
        log.log("query : \(url.query)")
        log.log("url : \(url)")
        var act:String = url.host!
        if send_id.length > 0 {
            send_id = send_id.substringFromIndex(1)
        }
        if url.host == "kakaolink" {
            let urlString:String = String(url)
            var urlStringArr = urlString.componentsSeparatedByString("?")
            urlStringArr = urlStringArr[1].componentsSeparatedByString("=")
            act = urlStringArr[0]
            send_id = urlStringArr[1]
        }
        log.log(send_id)
        
        var message : JSON!
        
        if(url.scheme == "http" || url.scheme == "https") {
            print("appdelegate url              ",url)
        }
        
        switch(act) {
            // view controller 호출
            
        case "share_sns":
            log.log("share_sns")
            let para = send_id.componentsSeparatedByString("/")
            let count = self.testNavi.viewControllers.count - 1
            let share = self.storyboard.instantiateViewControllerWithIdentifier("ShareViewController")as! ShareViewController
            share.post_id = para[0]
            share.url = para[4]
            self.testNavi.viewControllers[count].addChildViewController(share)
            self.testNavi.viewControllers[count].view.addSubview(share.view)
            break
        case "more_sns":
            log.log("more_sns")
            if moreToggle {
                break
            }
            log.log(send_id)
            let para = send_id.componentsSeparatedByString("/")
            moreToggle = true
            if self.email == para[1] {
                let count = self.testNavi.viewControllers.count - 1
                let moreme = self.storyboard.instantiateViewControllerWithIdentifier("MoreMeViewController")as! MoreMeViewController
                moreme.post_id = para[0]
                moreme.email = para[1]
                
                self.testNavi.viewControllers[count].addChildViewController(moreme)
                self.testNavi.viewControllers[count].view.addSubview(moreme.view)
            }else {
                let count = self.testNavi.viewControllers.count - 1
                let moreother = self.storyboard.instantiateViewControllerWithIdentifier("MoreOtherViewController")as! MoreOtherViewController
                moreother.post_id = para[0]
                self.testNavi.viewControllers[count].addChildViewController(moreother)
                self.testNavi.viewControllers[count].view.addSubview(moreother.view)
            }
            
            break
        case "post":
            log.log("call post \(self.email)")
            
            let post = self.storyboard.instantiateViewControllerWithIdentifier("PostPageViewController")as! PostPageViewController
            self.controller.append(post)
            post.type = "post"
            post.email = self.email
            post.postId = send_id as String
            self.testNavi.navigationBarHidden = true
            self.testNavi.pushViewController(post, animated: true)
            break
            
        case "tag":
            let tagview = self.storyboard.instantiateViewControllerWithIdentifier("TagViewController")as! TagViewController
            self.controller.append(tagview)
            tagview.type = "tag"
            tagview.tagId = send_id as String
            tagview.email = self.email
            self.testNavi.navigationBarHidden = true
            self.tabbar.view.hidden = true
            self.testNavi.pushViewController(tagview, animated: true)
            break;
        case "user":
            log.log("call user ")
            
            if self.controller[self.controller.count-1].type == "search" {
                self.tabbar.view.hidden = false
            }
            
            let user = self.storyboard.instantiateViewControllerWithIdentifier("UserPageViewController")as! UserPageViewController
            self.controller.append(user)
            user.type = "user"
            //            user.index = self.controller.count - 1
            user.myId = self.email
            user.userId = send_id as String
            self.testNavi.navigationBarHidden = true
            self.testNavi.pushViewController(user, animated: true)
            
            break;
        case "my_follower":
            log.log("call my_follower ")
            let follower = self.storyboard.instantiateViewControllerWithIdentifier("FollowerViewController")as! FollowerViewController
            follower.email = self.email
            follower.tagId = self.email
            follower.followType = "follower"
            self.testNavi.navigationBarHidden = false
            self.tabbar.view.hidden = true
            self.testNavi.pushViewController(follower, animated: true)
            break;
        case "my_following":
            log.log("call my_following ")
            let follower = self.storyboard.instantiateViewControllerWithIdentifier("FollowerViewController")as! FollowerViewController
            follower.email = self.email
            follower.tagId = self.email
            follower.followType = "following"
            self.tabbar.view.hidden = true
            self.testNavi.navigationBarHidden = false
            self.testNavi.pushViewController(follower, animated: true)
            break;
        case "follower":
            log.log("call follower ")
            break;
        case "profile_edit":
            log.log("call profile_edit ")
            let edit = self.storyboard.instantiateViewControllerWithIdentifier("MyfeedEditProfileNav")as! UINavigationController
            self.testNavi.presentViewController(edit, animated: true, completion: nil)
            break;
        case "setting":
            log.log("call setting ")
            let setting = storyboard.instantiateViewControllerWithIdentifier("settingNav")as! UINavigationController
            self.testNavi.presentViewController(setting, animated: true, completion: nil)
            break;
            
        case "comment":
            log.log("coment")
            log.log(send_id)
            let para = send_id.componentsSeparatedByString("/")
            
            let comment = storyboard.instantiateViewControllerWithIdentifier("comment")as! CommentViewController
            log.log(self.email)
            self.controller.append(comment)
            comment.type = "comment"
            comment.my_id = self.email
            comment.post_id = para[0]
            comment.postEmail = para[1]
            self.testNavi.pushViewController(comment, animated: true)
            self.main.view.hidden = true
            self.tabbar.view.hidden = true
            break
            
            // 소켓 통신만 진행
        case "do_follow":
            log.log("call do_follow ")
            let type : String!
            
            log.log("\(self.userData["register_form"].stringValue)")
            
            if self.userData["register_form"].string == "10001" {
                type = "N"
            }else if self.userData["register_form"].string == "10002" {
                type = "F"
            }else if self.userData["register_form"].string == "10003" {
                type = "G"
            }else {
                type = "R"
            }
            
            
            let message : JSON = ["myId":self.email,"email":[["email":send_id]],"type":type]
            self.doIt(402, message: message, callback: { (readData) -> () in
                
            })
            break;
        case "do_follow_tag":
            log.log("call do_follow_tag ")
            let message : JSON = ["myId":self.email,"tag_id":send_id]
            self.doIt(403, message: message, callback: { (readData) -> () in
                
            })
            break;
        case "do_like":
            log.log("like")
            log.log("\(self.controller)")
            var count = 0
            if self.controller.count == 1 {
                
            }else {
                count = self.controller.count-1
            }
            log.log("\(self.controller[count].type)")
            message = ["post_reply_id":send_id,"click_id":self.email,"like_form":"P"]
            self.doIt(302, message: message, callback: { (readData) -> () in
                
                self.log.log("\(readData)")
                if readData["msg"].string! == "success"{
                    
                }
            })
            break
        case "do_like_cancel":
            log.log("call do_like_cancel ")
            message = ["post_reply_id":send_id,"click_id":self.email,"like_form":"P"]
            self.doIt(303, message: message, callback: { (readData) -> () in
                if readData["msg"].string! == "success"{
                    self.log.log("좋아요 취소")
                }
            })
            break
        case "do_repic":
            break;
        case "tag_follower":
            log.log("call tag_follower ")
            let follower = self.storyboard.instantiateViewControllerWithIdentifier("FollowerViewController")as! FollowerViewController
            follower.email = self.email
            follower.tagId = send_id as String
            follower.followType = "tag"
            
            self.testNavi.hidesBottomBarWhenPushed = true
            self.testNavi.pushViewController(follower, animated: true)
            break;
        case "service" :
            let service = storyboard.instantiateViewControllerWithIdentifier("serviceNav")as! UINavigationController
            self.signin.presentViewController(service, animated: true, completion: nil)
            break
        case "policy" :
            let policy = storyboard.instantiateViewControllerWithIdentifier("policyNav")as! UINavigationController
            self.signin.presentViewController(policy, animated: true, completion: nil)
            break
        case "user_name" :
            var count = 0
            if self.controller.count == 1 {
                
            }else {
                count = self.controller.count-1
            }
            
            if self.controller[count].type == "post" {
                let a = self.controller[count]as! PostPageViewController
                a.postImage.enterBackground()
            }
            
            log.log("user_name \(send_id)")
//            let user = self.storyboard.instantiateViewControllerWithIdentifier("CommentUserPageViewController")as! CommentUserPageViewController
//            self.controller.append(user)
//            user.type = "user"
//            //            user.index = self.controller.count - 1
//            user.myId = self.email
//            user.userId = send_id as String
//            self.testNavi.navigationBarHidden = true
//            self.testNavi.pushViewController(user, animated: true)
            
            
            let message : JSON = ["my_id":self.email,"user_id":send_id as String]
            doIt(518, message: message, callback: { (readData) -> () in
                let vc = UserNativeViewController()
                vc.userEmail = readData["email"].stringValue
                self.testNavi.pushViewController(vc, animated: true)
            })
            
            
            
            
            
            break
        case "tag_name" :
            
            var count = 0
            if self.controller.count == 1 {
                
            }else {
                count = self.controller.count-1
            }
            
            if self.controller[count].type == "post" {
                let a = self.controller[count]as! PostPageViewController
                a.postImage.enterBackground()
            }
//            log.log("tag_name \(send_id)")
//            let tagview = self.storyboard.instantiateViewControllerWithIdentifier("CommentTagPageViewController")as! CommentTagPageViewController
//            self.controller.append(tagview)
//            tagview.type = "tag_name"
//            //            tagview.index = self.controller.count - 1
//            tagview.tagId = send_id as String
//            tagview.email = self.email
//            self.testNavi.navigationBarHidden = true
//            self.tabbar.view.hidden = true
//            self.testNavi.pushViewController(tagview, animated: true)
            
            let vc = TagNativeViewController()
            vc.tagName = send_id as String
            
            self.testNavi.pushViewController(vc, animated: true)
            
            break
            
        case "like_list" :
            let like = self.storyboard.instantiateViewControllerWithIdentifier("LikeListViewController")as! LikeListViewController
            like.email = self.email
            like.tagId = send_id as String
            self.testNavi.navigationBarHidden = false
            self.tabbar.view.hidden = true
            self.testNavi.pushViewController(like, animated: true)
            break
        default:
            break;
        }
    }
    
    
    
    
    func application(application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: NSError) {
        log.log(error.localizedDescription)
    }
    
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        
        print("openturl in   hahahahahahahahahahahahahahahahahahahahahahahahahahahahahahahaha")
        
        
        return true
    }
    
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication,
        openURL url: NSURL, options: [String: AnyObject]) -> Bool {
            print("open url url ",url.scheme)
            if url.scheme == "picpic" {
                URLopenPage(url)
            }
            if url.scheme == "fb1610072682575169" {
                return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey]as! String?, annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
            }else if url.host == "oauth-callback" {
                OAuthSwift.handleOpenURL(url)
                return true
            }else {
                
                let invite = GINInvite.handleURL(url, sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]as! String?, annotation:options[UIApplicationOpenURLOptionsAnnotationKey])
                if (invite != nil)
                {
                    GINInvite.completeInvitation()
                    let matchType =
                    (invite.matchType == GINReceivedInviteMatchType.Weak) ? "Weak" : "Strong"
                    print("Invite received from: \(options[UIApplicationOpenURLOptionsSourceApplicationKey]as! String?) Deeplink: \(invite.deepLink)," +
                        "Id: \(invite.inviteId), Type: \(matchType)")
                    GINInvite.convertInvitation(invite.inviteId)
                    return GIDSignIn.sharedInstance().handleURL(url,
                        sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey]as! String?,
                        annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
                }
                
                
                return GIDSignIn.sharedInstance().handleURL(url,
                    sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey]as! String?,
                    annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
            }
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(application: UIApplication) {
    }

    func checkNational(nation:String)->String{
        var language : String = ""
        if nation == "ko" {
            language = "ko_KR"
        }else if nation == "en" {
            language = "en_US"
        }else if nation == "zh" {
            language = "zh_CN"
        }else if nation == "ja" {
            language = "ja_JP"
        }
        return language
    }
    
    
    func loadView() {
        contentview = ContentViewController()
        tabbar = TabBarTestViewController()
        main = HomeNativeViewController() //MainInterViewController!
        alram = self.storyboard.instantiateViewControllerWithIdentifier("AlramViewController")as! AlramViewController
        second = SecondNativeViewController()
        camera = self.storyboard.instantiateViewControllerWithIdentifier("CameraViewController")as! CameraViewController
        myfeed = MyFeedNativeViewController() //MyFeedPageViewController()
        login = self.storyboard.instantiateViewControllerWithIdentifier("LoginViewController")as! LoginViewController
        
        testNavi = self.storyboard.instantiateViewControllerWithIdentifier("testNavi")as! UINavigationController
        //        self.window?.rootViewController = testNavi
        self.testNavi.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.testNavi.navigationItem.backBarButtonItem?.title = ""
        
        signin = self.storyboard.instantiateViewControllerWithIdentifier("signinNavigationController")as! UINavigationController
        
        if standardUserDefaults.objectForKey("tutorial") != nil {
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            launch = storyboard.instantiateViewControllerWithIdentifier("LaunchViewController")as! LaunchViewController
            launch.type = "first"
            self.window?.rootViewController = launch
        }else {
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            launch = storyboard.instantiateViewControllerWithIdentifier("LaunchViewController")as! LaunchViewController
            launch.type = "intro"
            self.window?.rootViewController = launch
        }
    }
    
    
    
    func reloadView(){
        contentview = ContentViewController()
        tabbar = TabBarTestViewController()
        main = HomeNativeViewController() //MainInterViewController!
        alram = self.storyboard.instantiateViewControllerWithIdentifier("AlramViewController")as! AlramViewController
        second = SecondNativeViewController()
        camera = self.storyboard.instantiateViewControllerWithIdentifier("CameraViewController")as! CameraViewController
        myfeed = MyFeedNativeViewController() //MyFeedPageViewController()
        login = self.storyboard.instantiateViewControllerWithIdentifier("LoginViewController")as! LoginViewController
        testNavi = self.storyboard.instantiateViewControllerWithIdentifier("testNavi")as! UINavigationController
    }
    
    
    var alert : UIAlertView!
    func doIt(serviceCode: Int,  message: JSON, callback: (JSON) -> ()) {
        print("doit  ")
        if self.reachability.currentReachabilityStatus() == NotReachable {
            let temp = self.ment["network_error_message"].stringValue.componentsSeparatedByString("&")
            log.log("네트워크 에러 메세지    :  \(temp)")
            let alert = UIAlertView(title: self.ment["network_error_title"].stringValue, message: "\(temp[0])\n\(temp[1])", delegate: nil, cancelButtonTitle: self.ment["popup_confirm"].stringValue)
            alert.show()
        }else {
            let url = NSURL(string: "https://ios.picpic.world/_app2/socket.jsp")!
//            let url = NSURL(string: "https://192.168.0.54:8443/_app2/socket.jsp")!
            print("request start")
            Alamofire.request(.POST, url, parameters: ["code": "\(serviceCode)","message":String(message)])
                .responseJSON { response in
                    print("request end")
                    self.log.log("\(response.result.value)")
                    switch response.result {
                    case .Success:
                        if let value = response.result.value {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                let json = JSON(value)
                                callback(json)
                            })
                        }
                    case .Failure(let error):
                        
                        print(error)
                        
                        break
//                        self.alert = UIAlertView(title: "", message: self.ment["app_error"].stringValue, delegate: self, cancelButtonTitle: nil)
//                        self.alert.show()
//                        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("clearAlert:"), userInfo: nil, repeats: false)
//                        self.doIt(serviceCode, message: message, callback: { (readData) -> () in
//                            callback(readData)
//                        })
                    }
            }
        }
    }
    
    func doItSocket(serviceCode: Int, message: JSON, callback: (JSON) -> ()) {
        if self.reachability.currentReachabilityStatus() == NotReachable {
            let temp = self.ment["network_error_message"].stringValue.componentsSeparatedByString("&")
            log.log("\(temp)")
            let alert = UIAlertView(title: self.ment["network_error_title"].stringValue, message: "\(temp[0])\n\(temp[1])", delegate: nil, cancelButtonTitle: self.ment["popup_confirm"].stringValue)
            alert.show()
        }else{
            var ip = "210.122.9.21"
            
            if(serviceCode >= 201 && serviceCode<=210) {
                
            } else if(serviceCode==215 || serviceCode==216) {
                
            } else if(serviceCode>=218 && serviceCode<=221) {
                
            } else if(serviceCode>=230 && serviceCode<=233) {
                
            } else if(serviceCode>=301 && serviceCode<=303) {
                
            } else if(serviceCode>=402 && serviceCode<=403) {
                
            } else if(serviceCode==601 || serviceCode==603 || serviceCode==604) {
                
            } else if(serviceCode==701 || serviceCode==702) {
                
            } else if(serviceCode==804) {
                
            } else {
                ip = serverIp
            }
            
            
            
            let dateFormatter = NSDateFormatter()
            let SECRETKEY = "SpI6k7IKSlKCliEk^E&SP%#[*I]M)rcF"
            let SECRETKEYIV = "^E&SP%#[*I]M)rcF"
            let keyTxt = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
            
            var dummy = ""
            
            for _ in 0..<10
            {
                let t = Int(arc4random_uniform(UInt32((SECRETKEY as NSString).length)))
                dummy += SECRETKEY.substringWithRange(SECRETKEY.startIndex.advancedBy(t) ..< SECRETKEY.startIndex.advancedBy(t+1))
            }
            
            
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            var sendMsg = message
            
            sendMsg["ct"].stringValue = dateFormatter.stringFromDate(NSDate())
            sendMsg["dm"].stringValue = keyTxt
            
            let data1 = [UInt8](sendMsg.description.stringByReplacingOccurrencesOfString("\n", withString: "").utf8)//(try! sendMsg.aesEncrypt(SECRETKEY, iv: SECRETKEYIV).utf8)
            
            var sendData: [UInt8] = []
            
            sendData.append(0x02)
            sendData.append(serviceCode.bytes1()[4])
            sendData.append(serviceCode.bytes1()[5])
            sendData.append(serviceCode.bytes1()[6])
            sendData.append(serviceCode.bytes1()[7])
            sendData.append(data1.count.bytes1()[4])
            sendData.append(data1.count.bytes1()[5])
            sendData.append(data1.count.bytes1()[6])
            sendData.append(data1.count.bytes1()[7])
            
            sendData += data1
            
//            let connection = Connection()
//            //소켓전송
//            connection.connect(ip, port: 34100)
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                connection.send(sendData)
//                dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
//                    print("****************")
//                    let output = connection.read()
//                    //
//                    
//                    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                        callback(JSON(output.convertToDictionary()!))
//                        connection.disconnect() })
//                })
//            })
            
            
            let completionHandler = {(data: NSData?, success: Bool, error: NSError?) in
                if error == nil
                {
                    print("**************read")
                    let result = JSON(data: data!)
                    if result.type == .Null
                    {
                        print("null")
                        self.doItSocket(serviceCode, message: message, callback: callback)
                    }
                    else
                    {
                        callback(result)
                    }
                }
                else
                {
                    print(error)
                    self.doItSocket(serviceCode, message: message, callback: callback)
                }
            }
            
            let session = NSURLSession.sharedSession()
            if #available(iOS 9.0, *) {
                let task = session.streamTaskWithHostName(ip, port: 34100)
                task.writeData(NSData(bytes: sendData), timeout: 5.0, completionHandler: {_ in })
                
                task.readDataOfMinLength(1024, maxLength: 30000, timeout: 5.0, completionHandler: completionHandler)
                task.resume()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    

    
    func clearAlert(timer : NSTimer) {
        if alert != nil {
            alert.dismissWithClickedButtonIndex(0, animated: true)
            exit(0)
            alert = nil
        }
    }
    
    
    
    
    
    func checkForReachability(notification:NSNotification) {
        if let networkReachability = notification.object as? Reachability {
            let remoteHostStatus = networkReachability.currentReachabilityStatus()
            
            if (remoteHostStatus == NotReachable) {
                //비행기모드
                
//                print("Not Reachable")
            }
            else if (remoteHostStatus == ReachableViaWiFi) {
                //와이파이
//                print("Reachable via Wifi")
            }
            else {
                //데이터
//                print("Reachable")
                let temp = self.ment["network_warning_message"].stringValue.componentsSeparatedByString("&")
                let alert = UIAlertView(title: self.ment["network_warning_title"].stringValue, message: "\(temp[0])\n\(temp[1])", delegate: nil, cancelButtonTitle: self.ment["popup_confirm"].stringValue)
                alert.show()
            }
        } else {
//            print("Unknown")
        }
    }
    
    
    let key: String = "secret0key000000"
    let iv: String = "0123456789012345"
    
    func enc(str: String) -> String
    {
        let encryptedBytes: [UInt8] = try! str.encrypt(AES(key: key, iv: iv, blockMode: .CBC))
        let base64Enc = NSData(bytes: encryptedBytes).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        return base64Enc
    }
    
    func dec(str: String) -> String
    {
        //let res: String = ""
        let decodedData = NSData(base64EncodedString: str, options: .IgnoreUnknownCharacters)
        
        let count = decodedData!.length / sizeof(UInt8)
        var byteArray = [UInt8](count: count, repeatedValue: 0)
        decodedData!.getBytes(&byteArray, length:count * sizeof(UInt8))
        
        let decodeStr: [UInt8] = try! byteArray.decrypt(AES(key: key, iv: iv, blockMode: .CBC))
        let data = NSData(bytes: decodeStr, length: Int(decodeStr.count))
        let res = try! NSString(data: data, encoding: NSUTF8StringEncoding)
        
        return String(res!)
    }
    
    
    

}

extension String {
    
    func URLEncoded() -> String {
        
        let characters = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        
        characters.removeCharactersInString("&")
        
        guard let encodedString = self.stringByAddingPercentEncodingWithAllowedCharacters(characters) else {
            return self
        }
        
        return encodedString
        
    }
    
    func convertToDictionary() -> [String: AnyObject]?
    {
        if let data = self.stringByReplacingOccurrencesOfString("\0", withString: "").stringByReplacingOccurrencesOfString("\n", withString: "").stringByReplacingOccurrencesOfString("\t", withString: "").dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject]
                return json
            } catch let error as NSError
            {
                print(error)
            }

        }
        return nil
    }
}

extension Character {
    
    func toInt() -> Int? {
        return Int(String(self))
    }
    
}
 
 
 extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
    
    func localizedWithKey(key:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: key, comment: "")
    }
 }

