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




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , UIAlertViewDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate {

    private var reachability:Reachability!
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
    var main : MainInterViewController!
    var testNavi : UINavigationController!
    var alram : AlramViewController!
    var second : TestSecondViewController!
    var camera : CameraViewController!
    var myfeed : MyFeedPageViewController!
    var signin : UINavigationController!
    
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
        
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        log.log("sender id           \(gcmSenderID)")
        if #available(iOS 8.0, *) {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            // Fallback
            let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
            application.registerForRemoteNotificationTypes(types)
        }
        
        // [END register_for_remote_notifications]
        // [START start_gcm_service]
        let gcmConfig = GCMConfig.defaultConfig()
        gcmConfig.receiverDelegate = self
        GCMService.sharedInstance().startWithConfig(gcmConfig)
        // [END start_gcm_service]
        
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
    
    
    
    func subscribeToTopic() {
        if(registrationToken != nil && connectedToGCM) {
            GCMPubSub.sharedInstance().subscribeWithToken(self.registrationToken, topic: subscriptionTopic,
                options: nil, handler: {(NSError error) -> Void in
                    if (error != nil) {
                        // Treat the "already subscribed" error more gently
                        if error.code == 3001 {
                            print("Already subscribed to \(self.subscriptionTopic)")
                        } else {
                            print("Subscription failed: \(error.localizedDescription)");
                        }
                    } else {
                        self.subscribedToTopic = true;
                        NSLog("Subscribed to \(self.subscriptionTopic)");
                    }
            })
        }
    }
    
    // [START connect_gcm_service]
    func applicationDidBecomeActive( application: UIApplication) {
        // Connect to the GCM server to receive non-APNS notifications
        GCMService.sharedInstance().connectWithHandler({
            (NSError error) -> Void in
            if error != nil {
                print("Could not connect to GCM: \(error.localizedDescription)")
            } else {
                self.connectedToGCM = true
                print("Connected to GCM")
                // [START_EXCLUDE]
                self.subscribeToTopic()
                // [END_EXCLUDE]
            }
        })
    }
    // [END connect_gcm_service]
    
    // [START disconnect_gcm_service]
    func applicationDidEnterBackground(application: UIApplication) {
        GCMService.sharedInstance().disconnect()
        // [START_EXCLUDE]
        self.connectedToGCM = false
        // [END_EXCLUDE]
    }
    // [END disconnect_gcm_service]
    
    // [START receive_apns_token]
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
        deviceToken: NSData ) {
            // [END receive_apns_token]
            // [START get_gcm_reg_token]
            // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
            let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
            instanceIDConfig.delegate = self
            // Start the GGLInstanceID shared instance with that config and request a registration
            // token to enable reception of notifications
            GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
            registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
                kGGLInstanceIDAPNSServerTypeSandboxOption:true]
            GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
                scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
            // [END get_gcm_reg_token]
    }
    
    // [START receive_apns_token_error]
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
        error: NSError ) {
            print("Registration for remote notification failed with error: \(error.localizedDescription)")
            // [END receive_apns_token_error]
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(
                registrationKey, object: nil, userInfo: userInfo)
    }
    
    // [START ack_message_reception]
    func application( application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
            print("Notification received: \(userInfo)")
            // This works only if the app started the GCM service
            GCMService.sharedInstance().appDidReceiveMessage(userInfo);
            // Handle the received message
            // [START_EXCLUDE]
            NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,
                userInfo: userInfo)
            // [END_EXCLUDE]
    }
    
    func application( application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
        fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
//            print("fetch Notification received: \(userInfo)")
//            print(userInfo["gcm.notification.acme1"])
            // This works only if the app started the GCM service
            GCMService.sharedInstance().appDidReceiveMessage(userInfo);
            // Handle the received message
            // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
            // [START_EXCLUDE]
            NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,
                userInfo: userInfo)
            if application.applicationState == UIApplicationState.Active {
//                let alert = UIAlertView(title: "", message: "Active", delegate: nil, cancelButtonTitle: "확인")
//                alert.show()
            }
            
            if application.applicationState == UIApplicationState.Inactive {
                notiType = 1
//                if let navi = self.testNavi {
//                    let alert = UIAlertView(title: "", message: "Inactive \(userInfo)", delegate: nil, cancelButtonTitle: "확인")
//                    alert.show()
//                }
                
            }
            handler(UIBackgroundFetchResult.NoData);
            // [END_EXCLUDE]
    }
    // [END ack_message_reception]
    
    func registrationHandler(registrationToken: String!, error: NSError!) {
        if (registrationToken != nil) {
            self.registrationToken = registrationToken
            print("Registration Token: \(registrationToken)")
            self.token = self.registrationToken!
            if (self.standardUserDefaults.valueForKey("push_token") == nil) {
                self.standardUserDefaults.setValue(self.token, forKey: "push_token")
            }else {
                self.standardUserDefaults.removeObjectForKey("push_token")
                self.standardUserDefaults.setValue(self.token, forKey: "push_token")
            }
            if email != nil {
                let message : JSON = ["email":email,"device_id":self.deviceId,"push_token":registrationToken]
                self.doIt(221, message: message, callback: { (readData) -> () in
                })
            }
            
            
            self.subscribeToTopic()
            let userInfo = ["registrationToken": registrationToken]
            NSNotificationCenter.defaultCenter().postNotificationName(
                self.registrationKey, object: nil, userInfo: userInfo)
        } else {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(
                self.registrationKey, object: nil, userInfo: userInfo)
        }
    }
    
    // [START on_token_refresh]
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    // [END on_token_refresh]
    
    // [START upstream_callbacks]
    func willSendDataMessageWithID(messageID: String!, error: NSError!) {
        if (error != nil) {
            // Failed to send the message.
        } else {
            // Will send message, you can save the messageID to track the message
        }
    }
    
    func didSendDataMessageWithID(messageID: String!) {
        // Did successfully send message identified by messageID
    }
    // [END upstream_callbacks]
    
    func didDeleteMessagesOnServer() {
        // Some messages sent to this device were deleted on the GCM server before reception, likely
        // because the TTL expired. The client should notify the app server of this, so that the app
        // server can resend those messages.
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == alertView.cancelButtonIndex {
            exit(0)
        }
    }

    func application(application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: NSError) {
        log.log(error.localizedDescription)
    }
    
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
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
//            message = ["my_id":self.email,"post_id":send_id]
//            let connection = URLConnection(serviceCode: 504, message: message)
//            let readData = connection.connection()
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
//            message = ["my_id":self.email,"post_id":send_id]
//            let connection = URLConnection(serviceCode: 504, message: message)
//            let readData = connection.connection()
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
//            post.index = self.controller.count - 1
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
//            tagview.index = self.controller.count - 1
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
//            comment.index = self.controller.count - 1
            comment.my_id = self.email
            comment.post_id = para[0]
            comment.postEmail = para[1]
//            self.viewcontroller.presentViewController(comment, animated: true, completion: nil)
//            self.contentview.pushViewController(comment, animated: true)
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
//            let connection = URLConnection(serviceCode: 402, message: message)
//            let readData = connection.connection()
            self.doIt(402, message: message, callback: { (readData) -> () in
                
            })
            break;
        case "do_follow_tag":
            log.log("call do_follow_tag ")
            let message : JSON = ["myId":self.email,"tag_id":send_id]
//            let connection = URLConnection(serviceCode: 403, message: message)
//            let readData = connection.connection()
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
//            let connection = URLConnection(serviceCode: 303, message: message)
//            let readData = connection.connection()
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
            let user = self.storyboard.instantiateViewControllerWithIdentifier("CommentUserPageViewController")as! CommentUserPageViewController
            self.controller.append(user)
            user.type = "user"
//            user.index = self.controller.count - 1
            user.myId = self.email
            user.userId = send_id as String
            self.testNavi.navigationBarHidden = true
            self.testNavi.pushViewController(user, animated: true)
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
            log.log("tag_name \(send_id)")
            let tagview = self.storyboard.instantiateViewControllerWithIdentifier("CommentTagPageViewController")as! CommentTagPageViewController
            self.controller.append(tagview)
            tagview.type = "tag_name"
//            tagview.index = self.controller.count - 1
            tagview.tagId = send_id as String
            tagview.email = self.email
            self.testNavi.navigationBarHidden = true
            self.tabbar.view.hidden = true
            self.testNavi.pushViewController(tagview, animated: true)
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
        print("url  host              ",url.host)
        print("url  scheme            ",url.scheme)
        if url.scheme == "fb1610072682575169" {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }else if url.scheme == "" {
            return GIDSignIn.sharedInstance().handleURL(url,
                sourceApplication: sourceApplication,
                annotation: annotation)
        }else {
            return GIDSignIn.sharedInstance().handleURL(url,
                sourceApplication: sourceApplication,
                annotation: annotation)
        }
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication,
        openURL url: NSURL, options: [String: AnyObject]) -> Bool {
            return GIDSignIn.sharedInstance().handleURL(url,
                sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey]as! String?,
                annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }
    

    func applicationWillResignActive(application: UIApplication) {
    }

//    func applicationDidEnterBackground(application: UIApplication) {
//    }

    func applicationWillEnterForeground(application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

//    func applicationDidBecomeActive(application: UIApplication) {
//        FBSDKAppEvents.activateApp()
//    }

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
        main = MainInterViewController()
        alram = self.storyboard.instantiateViewControllerWithIdentifier("AlramViewController")as! AlramViewController
        second = TestSecondViewController()
        camera = self.storyboard.instantiateViewControllerWithIdentifier("CameraViewController")as! CameraViewController
        myfeed = MyFeedPageViewController()
        login = self.storyboard.instantiateViewControllerWithIdentifier("LoginViewController")as! LoginViewController
        
        testNavi = self.storyboard.instantiateViewControllerWithIdentifier("testNavi")as! UINavigationController
        //        self.window?.rootViewController = testNavi
        self.testNavi.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.testNavi.navigationItem.backBarButtonItem?.title = ""
        
        signin = self.storyboard.instantiateViewControllerWithIdentifier("signinNavigationController")as! UINavigationController
        
        if standardUserDefaults.objectForKey("tutorial") != nil {
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            let launch = storyboard.instantiateViewControllerWithIdentifier("LaunchViewController")as! LaunchViewController
            launch.type = "first"
            self.window?.rootViewController = launch
            
        }else {
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            let launch = storyboard.instantiateViewControllerWithIdentifier("LaunchViewController")as! LaunchViewController
            launch.type = "intro"
            self.window?.rootViewController = launch
        }
    }
    
    
    
    func reloadView(){
        contentview = ContentViewController()
        tabbar = TabBarTestViewController()
        main = MainInterViewController()
        alram = self.storyboard.instantiateViewControllerWithIdentifier("AlramViewController")as! AlramViewController
        second = TestSecondViewController()
        camera = self.storyboard.instantiateViewControllerWithIdentifier("CameraViewController")as! CameraViewController
        myfeed = MyFeedPageViewController()
        login = self.storyboard.instantiateViewControllerWithIdentifier("LoginViewController")as! LoginViewController
        testNavi = self.storyboard.instantiateViewControllerWithIdentifier("testNavi")as! UINavigationController
    }
    
    
    var alert : UIAlertView!
    func doIt(serviceCode: Int,  message: JSON, callback: (JSON) -> ()) {
        
        if self.reachability.currentReachabilityStatus() == NotReachable {
            let temp = self.ment["network_error_message"].stringValue.componentsSeparatedByString("&")
            log.log("\(temp)")
            let alert = UIAlertView(title: self.ment["network_error_title"].stringValue, message: "\(temp[0])\n\(temp[1])", delegate: nil, cancelButtonTitle: self.ment["popup_confirm"].stringValue)
            alert.show()
        }else {
            let url = NSURL(string: "https://ios.picpic.world/_app2/socket.jsp")!
//            let url = NSURL(string: "https://192.168.0.54:8443/_app2/socket.jsp")!
            Alamofire.request(.POST, url, parameters: ["code": "\(serviceCode)","message":String(message)])
                .responseJSON { response in
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
                        self.alert = UIAlertView(title: "", message: self.ment["app_error"].stringValue, delegate: self, cancelButtonTitle: nil)
                        self.alert.show()
                        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("clearAlert:"), userInfo: nil, repeats: false)
                    }
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
    
}

extension Character {
    
    func toInt() -> Int? {
        return Int(String(self))
    }
    
}

